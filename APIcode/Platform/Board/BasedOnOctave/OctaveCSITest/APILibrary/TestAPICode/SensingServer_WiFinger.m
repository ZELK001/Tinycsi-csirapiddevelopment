function SensingServer(handle,filename,trainortest,gesture)
% x=0:0.01:10;
% 
% y=sin(x);
% 
% plot(x,y);
  
% obj=servercode.ServerMain();
% 
% obj.createServer('111',0.01,111);
trainortest
gesture
thehandles=handle;
%CSI处理代码：WiFinger
addpath('../toolScripts');
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


windowlen=100;%手势识别的窗口
count_profile=1;%用来统计profile的个数
j=1;

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
        
        plot(thehandles.axes1,db(abs(squeeze(csi(1,1,:)).')),'LineWidth',2);
        axis([0,30,0,35]);
        drawnow;
        
        %获取30*1的向量
        for sub=1:30
            CSI_measurements(sub,count) = db(abs(csi(1,1,sub)));
            if isinf(CSI_measurements(sub,count))
            CSI_measurements(sub,count)=CSI_measurements(sub,count-1);
            end
        end
        
        %数据预处理
        if mod(count,windowlen)==0
           % 离异点去除 Outlier removal
           for subc = 1:30
             CSI_final_hampel(subc,count-windowlen+1:count)=medfilt1(CSI_measurements(subc,count-windowlen+1:count),5);
           end
           %低通滤波器 butterworth low passing fitter（去噪也可以用DWT）
           fs=100; %采样频率 sampling rate
           fc=40;  %stopping frequency
           order=4; 
           [b,a]=butter(order,2*fc/fs);
           for subc = 1:30
                butterworthResult(subc,count-windowlen+1:count) = filter(b,a,CSI_final_hampel(subc,count-windowlen+1:count));
           end
      
           %开始处理CSI,即各个应用的具体算法
          
 
         
           for subc=1:30
              varSilent(subc) = var(butterworthResult(subc,silentPktRange(1):silentPktRange(2)));%标准差 
           end
         
           %核心部分
           if count > silentPktRange(2) & mod(count - silentPktRange(2), stepLength) == 0
               %获取profile，即对有可能动作的CSI进行切片
               windowCSI=butterworthResult(:,count-windowlen+1:count);
               count_change=0;%统计30个子信道中标准差变化大的个数
               for subc=1:30
                  varNow(subc) = var(windowCSI(subc,:));%标准差
                  if(varNow(subc)>varSilent(subc))
                    count_change=count_change+1;
                  end
               end
               if count_change>16%统计子信道大于16个时，认为是有手势动作,开始构建profile
                   movementProfile(count-windowlen+1:count)=mean(windowCSI,1);
                  fprintf('findone\n');
               end
               
               %DWT 来获得细节系数，其对微小变化敏感
              [C,L]=wavedec(movementProfile,4,'db4');
               d1 = wrcoef('d',C,L,'db4',1); 
               d2 = wrcoef('d',C,L,'db4',2); 
               d3 = wrcoef('d',C,L,'db4',3); 
               d4 = wrcoef('d',C,L,'db4',4); 
               movementProfile_final = d4;%只取d4

               
              if trainortest==1 && gesture==1%训练拳头
                 movementData(1,j:j+windowlen-1)=d4(count-windowlen+1:count);
                 movementData(2,j:j+windowlen-1)=1;
                 j=j+windowlen;
                 count_profile=count_profile+1;
                 save('testdata_riot.mat','movementData');
               
               elseif trainortest==1 && gesture==2%训练手掌
                 movementData(1,j:j+windowlen-1)=d4(count-windowlen+1:count);
                 movementData(2,j:j+windowlen-1)=2;
                 j=j+windowlen;
                 count_profile=count_profile+1;
                 save('testdata_palm.mat','movementData');
                
                elseif trainortest==1 && gesture==3%训练book
                 movementData(1,j:j+windowlen-1)=d4(count-windowlen+1:count);
                 movementData(2,j:j+windowlen-1)=3;
                 j=j+windowlen;
                 count_profile=count_profile+1;
                 save('testdata_book.mat','movementData');
              end
               
              if trainortest==2
                  %读取之前的数据利用KNN输出判断结果
                  traindata_riot=load('traindata_riot.mat');
                  traindata_palm=load('traindata_palm.mat');
                  traindata_book=load('traindata_book.mat');
                  traindata=[traindata_riot.movementData(:,1:100) traindata_palm.movementData(:,1:100) traindata_book.movementData(:,1:100)];
                  profilesize=ceil(length(traindata)/100);
                  result=KNN(6,movementData,test_temp1,50,profilesize);
                  if result==1
                      set(thehandles.edit1,'string','riot');
                  elseif result==2
                      set(thehandles.edit1,'string','palm');
                  else
                      set(thehandles.edit1,'string','book');
                  end
              end
                
            continue;
           end
        end
    end
end

end