function result=WiFinger(filename,trainortest,movementclass)
%手势识别，主要用KNN聚类，DWT计算距离
%LBJ 2018-9-19
%主要流程：读入CSI文件，离异点去除，低通滤波器（过滤高频噪音），Mutlipath去除（先IFFT，获取CIR后，筛去delay大于100ns的，再FFT变回CSI）
%          手势动作识别（signindicator，即什么时候开始有动作），动作切片，KNN+DTW作聚类后训练，最后分类。
addpath('toolScripts');

csi_trace = read_bf_file(filename);
len = length(csi_trace);

%len=len-7900;%采集60s,频率是100Hz，按理应该有6000个包，但是一共有13000多个，可能是ICMP来回的包？--riot下采集的数据
len=len-8000;%采集60s,频率是100Hz，按理应该有6000个包，但是一共有13000多个，可能是ICMP来回的包？--palm下采集的数据
startPkt=1;
lastPkt=len;
ant=1;%接收端天线
CSI_measurements = zeros(30,len);

silent_time = 400;%静默时间，用来生成阈值和之后又手势动作时比较
window_size = 500;%用于手势检测的时间窗口

if trainortest==1%训练
count=1;
%获取30个子信道的振幅值
for i = 1:lastPkt-startPkt
    csi_entry = csi_trace{i+startPkt};
    count=count+1;
%     count
%     len
%     i
%     csi_entry
    csi = get_scaled_csi(csi_entry);
    for sub=1:30
       CSI_measurements(sub,i) = db(abs(csi(1,ant,sub)));
       if isinf(CSI_measurements(sub,i))
            CSI_measurements(sub,i)=CSI_measurements(sub,i-1);
        end
    end
end
CSI_final_hampel = zeros(30,len);
butterworthResult= zeros(30,len);
multipathResult= zeros(30,len);
CSI_final= zeros(30,len);
movementProfile= zeros(1,len);
movementProfile_final= zeros(1,len);
% 离异点去除 Outlier removal
for subc = 1:30
    %CSI_final_hampel(subc,:) = hampel(CSI_measurements(subc,:));
    CSI_final_hampel(subc,:)=medfilt1(CSI_measurements(subc,:),5);
end
figure;
plot(CSI_final_hampel(20,:));


%低通滤波器 butterworth low passing fitter（去噪也可以用DWT）
fs=100; %采样频率 sampling rate
fc=40;  %stopping frequency
order=4; 
[b,a]=butter(order,2*fc/fs);
for subc = 1:30
    butterworthResult(subc,:) = filter(b,a,CSI_final_hampel(subc,:));
end
% figure;
% plot(butterworthResult(20,:));


%多径效应去除Multipath Remove
% for subc = 1:30
%     temp(subc,:) = ifft(butterworthResult(subc,:));
%     for j=1:len
%         if temp(subc,j)<100
%             multipathResult(subc,j)=temp(subc,j);
%         else
%             multipathResult(subc,j)=0;
%         end
%     end
%     CSI_final(subc,:)=fft(multipathResult(subc,:));
% end
% figure;
% plot(CSI_final(20,:));
CSI_final= butterworthResult;

%计算静默时相关的值
for subc=1:30
   varSilent(subc) = var(CSI_final(subc,1:silent_time));%标准差
 
end

count_profile=1;%用来统计profile的个数
%动作检测Signindicator
for i=silent_time+1:len
    if mod(i, window_size) == 0
        windowCSI=CSI_final(:,i-window_size+1:i);
        %计算signindicator
        arraytemp=windowCSI*windowCSI';%30*500和500*30矩阵相乘，生成30*30方阵，来求得特征值和特征向量----这一步不太理解，暂时不用了，直接用标准差变化较大来判断
        
        count_change=0;%统计30个子信道中标准差变化大的个数
        for subc=1:30
           varNow(subc) = var( windowCSI(subc,:));%标准差
           if(varNow(subc)>varSilent(subc))
               count_change=count_change+1;
           end
        end
        if count_change>1%统计子信道大于16个时，认为是有手势动作,开始构建profile
               movementProfile(i-window_size+1:i)=mean(windowCSI,1);
               fprintf('findone\n');
        end
        
    end
end
% figure;
% plot(movementProfile);

%DWT 来获得细节系数，其对微小变化敏感
[C,L]=wavedec(movementProfile,4,'db4');
d1 = wrcoef('d',C,L,'db4',1); 
d2 = wrcoef('d',C,L,'db4',2); 
d3 = wrcoef('d',C,L,'db4',3); 
d4 = wrcoef('d',C,L,'db4',4); 
movementProfile_final = d4;%只取d4

% figure;
% plot(movementProfile_final);

%开始利用KNN+DTW进行分类（KNN是分类方法，不是聚类方法，属于有监督学习，即需要提前指定label）
%1.Train 训练
%暂时分为两类：拳头和手掌
count_profile=1;
movementData= zeros(2,len);%第一行动作的波形d4，第二行类别
j=1;
if trainortest==1 && movementclass==1%训练拳头
    for i=silent_time+1:len
        if mod(i, window_size) == 0

%             movementData(1,i-window_size+1:i)=d4(i-window_size+1:i);
%             movementData(2,i-window_size+1:i)=1;
            movementData(1,j:j+window_size-1)=d4(i-window_size+1:i);
            movementData(2,j:j+window_size-1)=1;
            j=j+window_size;
            count_profile=count_profile+1;
        end
    end
elseif trainortest==1 && movementclass==2%训练手掌
    for i=silent_time+1:len
        if mod(i, window_size) == 0
%             movementData(1,i-window_size+1:i)=d4(i-window_size+1:i);
%             movementData(2,i-window_size+1:i)=2;
            movementData(1,j:j+window_size-1)=d4(i-window_size+1:i);
            movementData(2,j:j+window_size-1)=2;
            j=j+window_size;
            count_profile=count_profile+1;
        end
    end
elseif trainortest==1 && movementclass==3%训练book
    for i=silent_time+1:len
        if mod(i, window_size) == 0
%             movementData(1,i-window_size+1:i)=d4(i-window_size+1:i);
%             movementData(2,i-window_size+1:i)=1;
            movementData(1,j:j+window_size-1)=d4(i-window_size+1:i);
            movementData(2,j:j+window_size-1)=3;
            j=j+window_size;
            count_profile=count_profile+1;
        end
    end
end
%save('traindata_palm.mat','movementData');
save('testdata_book.mat','movementData');
% figure;
% plot(movementData(1,:));

%2.Test 测试 要用到KNN和DTW了
elseif trainortest==2
%temp1=movementData(1,2001:2500);
%temp2=movementData(1,2051:2550);
% temp3=movementData(1,2051:2100);
% result1=GetDTWDist(temp1,temp2);
% result2=GetDTWDist(temp2,temp3);
% disp(result1);
% disp(result2);
traindata_riot=load('traindata_riot.mat');
traindata_palm=load('traindata_palm.mat');
traindata_book=load('traindata_book.mat');

testdata_palm=load('testdata_riot.mat');
testdata=testdata_palm.movementData(:,1:5000);
test_temp1=testdata(1,501:1000);

testdata_palm=load('testdata_palm.mat');
testdata=testdata_palm.movementData(:,1:5000);
test_temp2=testdata(1,501:1000);

testdata_palm=load('testdata_book.mat');
testdata=testdata_palm.movementData(:,1:5000);
test_temp3=testdata(1,501:1000);

movementData=[traindata_riot.movementData(:,1:5000) traindata_palm.movementData(:,1:5000) traindata_book.movementData(:,1:5000)];

profilesize=ceil(length(movementData)/500);
temp1=traindata_riot.movementData(1,501:1000);
temp2=traindata_palm.movementData(1,501:1000);
temp3=traindata_book.movementData(1,501:1000);

KNN(6,movementData,test_temp1,500,profilesize);
end


end