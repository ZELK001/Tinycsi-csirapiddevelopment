function SensingServer(filename)
 
% obj=servercode.ServerMain();
% 
% obj.createServer('111',0.01,111);
addpath('../toolScripts');
%CSI处理代码：MUSIC算法解AOA
f = fopen(filename,'rb');
if (f < 0)
    error('Couldn''t open file %s',filename);
    return;
end

count = 0;
broken_perm = 0;% Flag marking whether we've encountered a broken CSI yet
triangle = [1 3 6 9];
varSilent = 0;

% customized parameters

pauseTime = 0; % for real time purpose
subc = 15; % which subcarrier
SNThresRatio = 5; % the threshold of ratio between "nobody" environment and "intruder" environment
silentRange = [1,4]; % the time interval range we collect CSI in "nobody" environment as baseline
pingInterval = 0.05;
pingPktRate = 1;
windowDuration = 1; % window duration for judegement
stepDuration = 0.5; % 2 judegements for 1 second 
pktRate = 1 / pingInterval * pingPktRate; % the number of CSI matrixes in 1 second
silentPktRange = silentRange * pktRate; 
windowLength = windowDuration * pktRate;
stepLength = stepDuration * pktRate;

window_size=50;
Degree_final_count=1;
ToA_count=1;
count_degree=1;
SP_count=1;

% Process all entries in file
while 1
    field_len = fread(f,1,'uint16',0,'ieee-be');
    code = fread(f,1);

    if (code == 187)
        bytes = fread(f, field_len-1, 'uint8=>uint8');
        if(length(bytes) ~= field_len-1)
            % XXX
            fclose(f);
            return;
        end
    else %skip all other info
        fread(f,field_len-1);
        continue;
    end

    if (code == 187)
        count = count + 1;
        ret{count} = read_bfee(bytes);
        perm = ret{count}.perm;
        Nrx = ret{count}.Nrx;

        if Nrx ~= 1 % No permuting needed for only 1 antenna
            if sum(perm) ~= triangle(Nrx) % matrix does not contain default values
                if broken_perm == 0
                    broken_perm = 1;
                    fprintf('WARN ONCE: Found CSI (%s) with Nrx=%d and invalid perm=[%s]\n', filename, Nrx, int2str(perm));
                end
            else
                ret{count}.csi(:,perm(1:Nrx),:) = ret{count}.csi(:,1:Nrx,:);
            end
        end
       
        %获取CSI
        csi = get_scaled_csi(ret{count});%db(abs((csi(1,1,subc))))是获取振幅
  
        for sub=1:30
           CSI_measurements_firstant(sub) =csi(1,1,sub);
           CSI_measurements_secondant(sub) =csi(1,2,sub);
           CSI_measurements_thirdant(sub) =csi(1,3,sub);
        end
         %获得90个sensor
        CSI_measurements(1:30,count)=CSI_measurements_firstant';
        CSI_measurements(31:60,count)=CSI_measurements_secondant';
        CSI_measurements(61:90,count)=CSI_measurements_thirdant';
        %开始处理CSI,即各个应用的具体算法
        %MUSIC算法计算AOA不需要静默状态
        %MUSIC算法
        derad = pi/180;       
        radeg = 180/pi;
        twpi = 2*pi;
        kelm =  30*3;    %阵元个数     
        dd = 0.06;       %阵元间距       
        d=0:dd:(kelm-1)*dd;     
        iwave = 3;   
        Rxx=CSI_measurements(:,count)*CSI_measurements(:,count)';
        InvS=inv(Rxx); 
        [EV,D]=eig(Rxx);
        EVA=diag(D)';
        [EVA,I]=sort(EVA);
        EVA=fliplr(EVA);
        EV=fliplr(EV(:,I));
        for iang = 1:361
         angle(iang)=(iang-181)/2;
         phim=derad*angle(iang);
         a=exp(-j*twpi*d*sin(phim)).';
         %自己加的（原MUSIC算法里没有），a的前30个数即为ToA
         ToA_all(ToA_count)=mean(a(1:30));
         ToA_count=ToA_count+1;
         L=iwave;    
         En=EV(:,L+1:kelm);
         SP(iang)=(a'*a)/(a'*En*En'*a);
       end
       SP=abs(SP);
       SPmax=max(SP);
       SP=10*log10(SP/SPmax);%可以理解为候选的角度
       SP_Array(SP_count,:)=SP;
       SP_count=SP_count+1;
        
       if mod(count,window_size)==0
           fprintf('im in\n')
           count_degree=1;
           SP_count=1;
           ToA_count=1;
           for jj=1:361
               for ii=1:window_size
                   if SP_Array(ii,jj)>mean(SP_Array(:,jj))%大于平均值即表现在图像上是突出来的，即可作为候选角度
                      
                       degreeselect(1,count_degree)=SP_Array(ii,jj);%即为候选角度矩阵，第一行为具体幅值（物理意义尚不清楚），第二行为角度
                       degreeselect(2,count_degree)=jj;
                       degreeselect(3,count_degree)=ToA_all((jj-1)*50+ii);
                       count_degree=count_degree+1;
                   end
                   
               end
           end

           %staticpath去除
           table=tabulate(degreeselect(1,:));
           [F,location]=max(table(:,2));
           location=find(table(:,2)==F);

           staticpath_Amp=table(location,1);%DymicMUSIC中证明Staticpath出现最多，选出出现频率最多的即为staticpath
           minToA=degreeselect(3,1);
           for iii=1:length(degreeselect)
               if degreeselect(1,iii)~=staticpath_Amp
                   %根据TOA来选出Targetpath，TargetPath的ToA最小
                   if degreeselect(3,iii)<minToA
                       minToA=degreeselect(3,iii);
                   %[minToA,location]=min(degreeselect(3,:));
                   end     
               end
         
           end 
     
          for iii=1:length(degreeselect)
                if degreeselect(3,iii)==minToA
                   Degree_final(Degree_final_count)=degreeselect(2,iii);
                   %degreeselect(2,iii)
                   Degree_final_count=Degree_final_count+1;
                end
          end
          Degree_final_result=mean(Degree_final)-120; 
          Degree_final_result
       end
      

    end
end


end