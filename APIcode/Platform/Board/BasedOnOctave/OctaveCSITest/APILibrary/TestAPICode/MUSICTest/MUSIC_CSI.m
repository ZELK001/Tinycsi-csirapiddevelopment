function MUSIC_CSI(filename)
%用MUSIC算法计算AOA，ToF，核心思想利用子载波扩展Sensor（天线）的个数
%主要参考Dymic-MUSIC，以及Spotfi
%Spotfi中是15*2，DymicMUSIC中没说
addpath('../toolScripts');

csi_trace = read_bf_file(filename);
len = length(csi_trace);

len=len-8000;%采集60s,频率是100Hz，按理应该有6000个包，但是一共有13000多个，可能是ICMP来回的包？--palm下采集的数据
len=500;
startPkt=1;
lastPkt=len;
window_size=50;
Degree_final_count=1;
CSI_measurements = zeros(90,len);
count=1;
%获取30*3个子信道的振幅值
for i = 1:lastPkt-startPkt
    csi_entry = csi_trace{i+startPkt};
    csi = get_scaled_csi(csi_entry);
    count=count+1;
    for sub=1:30
       CSI_measurements_firstant(sub) =csi(1,1,sub);
       CSI_measurements_secondant(sub) =csi(1,2,sub);
       CSI_measurements_thirdant(sub) =csi(1,3,sub);
    end
    %获得90个sensor
    %CSI_measurements=[CSI_measurements_firstant';CSI_measurements_secondant';CSI_measurements_thirdant'];
    CSI_measurements(1:30,i)=CSI_measurements_firstant';
    CSI_measurements(31:60,i)=CSI_measurements_secondant';
    CSI_measurements(61:90,i)=CSI_measurements_thirdant';
end

length(CSI_measurements)
pause;

%使用MUSI算法求解AOA
count=1;
ToA_count=1;
count_degree=1;
%ToA_all=zeros(361*window_size);
%SP_Array=zeros(window_size,361);%保存选择角度的结果
for i = 1:lastPkt-startPkt
    
       %MUSIC算法
       derad = pi/180;       
       radeg = 180/pi;
       twpi = 2*pi;
       kelm =  30*3;    %阵元个数     
       dd = 0.06;       %阵元间距       
       d=0:dd:(kelm-1)*dd;     
       iwave = 3;   
    
       Rxx=CSI_measurements(:,i)*CSI_measurements(:,i)';
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
         %ToA_count
         %
         L=iwave;    
         En=EV(:,L+1:kelm);
         SP(iang)=(a'*a)/(a'*En*En'*a);
       end
       SP=abs(SP);
       SPmax=max(SP);
       SP=10*log10(SP/SPmax);%可以理解为候选的角度
       
%        if mod(i,500)==0
%        figure;
%        h=plot(angle,SP);
%        set(h,'Linewidth',2)
%        xlabel('angle (degree)')
%        ylabel('magnitude (dB)')
%        end
       
       SP_Array(count,:)=SP;
       
%        if count==1 
%            SP_Array(1,1:10)
%            pause;
%        end
       count=count+1;
       
     
       if mod(i,window_size)==0
           fprintf('im in\n')
           count_degree=1;
           count=1;
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
%            i
%            length(SP_Array)
%            SP_Array(:,1)
           %degreeselect
           
           %staticpath去除
           table=tabulate(degreeselect(1,:));
           % length(table)
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
            
         
       end
      
end


Degree_final_result=mean(Degree_final);
Degree_final_result
    
%     figure;
%     h=plot(angle,SP);
%     set(h,'Linewidth',2)
%     xlabel('angle (degree)')
%     ylabel('magnitude (dB)')


end
