function ret=GetAPIRunTime(APINum,filename)
addpath('../../toolScripts');
addpath('../');
csi_trace = read_bf_file(filename);
len = length(csi_trace);
startPkt=1;
lastPkt=1000;
ant=1;
fprintf('数据长度：');
len
csimeasurements = zeros(30,lastPkt-startPkt);
windowlen=100;

%打印当前开始时间
%datestr(now,13)
tic

count=1;
%测30个子信道的不同API的运行时间
for i = 1:lastPkt-startPkt
    csi_entry = csi_trace{i+startPkt};
    sub=10;
    %for sub=1:30
       %csimeasurements(sub,i) = db(abs(csi(1,ant,sub)));
       if APINum==1
           csimeasurements(sub,i) = GetAmplitude(1,1,sub,csi_entry);
           
       elseif APINum==2
           csimeasurements(sub,i) = GetPhase(1,1,sub,csi_entry);
       elseif APINum==3
            csimeasurements(sub,i) = GetRelativePhase(1,1,2,sub,csi_entry);
       elseif APINum==4
            csimeasurements(sub,i) = GetTimeStamp(1,1,sub,csi_entry);
       elseif APINum==5
            csimeasurements(sub,i) = GetRSSI(csi_entry);
       elseif APINum==6
            csimeasurements = GetCIR(csi_entry);
       elseif APINum==7
            csimeasurements(sub,i) = GetAmplitude(1,1,sub,csi_entry);
            result(:,count)=ButterworthFilter(csimeasurements,20,5,4);
            count=count+1;
       elseif APINum==8
            csimeasurements(sub,i) = GetAmplitude(1,1,sub,csi_entry);
            if mod(i,windowlen)==0
                result(sub,i-windowlen+1:i)=HampelFilter(csimeasurements(sub,i-windowlen+1:i));
            end
       elseif APINum==9
            csimeasurements(sub,i) = GetAmplitude(1,1,sub,csi_entry);
            if mod(i,windowlen)==0
                result(sub,i-windowlen+1:i)=MedianFilter(csimeasurements(sub,i-windowlen+1:i),5);
            end
       elseif APINum==10
            for subc = 1:30
              csimeasurements(subc,i) = GetAmplitude(1,1,subc,csi_entry);
               if isinf(csimeasurements(subc,i))
                 csimeasurements(subc,i)= csimeasurements(subc,i-1);
               end
            end
            if mod(i,windowlen)==0
              
                result=PCAFilter(csimeasurements(:,i-windowlen+1:i),2);
                size(result)
            end
        elseif APINum==11%SelectSensitiveSubc
            csi = get_scaled_csi(csi_entry);
            csidata(:,i)=csi(1,1,:);
            if i==1000
                result=SelectSensitiveSubc(1,1,csidata,200);
            end
        elseif APINum==11%SelectSensitiveSubc
            csi = get_scaled_csi(csi_entry);
            csidata(:,i)=csi(1,1,:);
            if i==1000
                result=SelectSensitiveSubc(1,1,csidata,200);
            end
        elseif APINum==12
            csimeasurements(sub,i) = GetAmplitude(1,1,sub,csi_entry);
            if mod(i,windowlen)==0
                result=GetVar(csimeasurements(sub,i-windowlen+1:i));
            end
        elseif APINum==13
            csimeasurements(sub,i) = GetAmplitude(1,1,sub,csi_entry);
            if mod(i,windowlen)==0
                result=GetStd(csimeasurements(sub,i-windowlen+1:i));
            end
        elseif APINum==14
            csimeasurements(sub,i) = GetAmplitude(1,1,sub,csi_entry);
            if mod(i,windowlen)==0
                result=GetMean(csimeasurements(sub,i-windowlen+1:i));
            end
        elseif APINum==15
            csimeasurements(sub,i) = GetAmplitude(1,1,sub,csi_entry);
            if mod(i,windowlen)==0
                result=GetMAX(csimeasurements(sub,i-windowlen+1:i));
            end
        elseif APINum==16
            csimeasurements(sub,i) = GetAmplitude(1,1,sub,csi_entry);
            if mod(i,windowlen)==0
                result=GetMIN(csimeasurements(sub,i-windowlen+1:i));
            end
        elseif APINum==17
            csimeasurements(sub,i) = GetAmplitude(1,1,sub,csi_entry);
            if mod(i,windowlen)==0
                result=GetFreqVectorUsingDWT(csimeasurements(sub,i-windowlen+1:i),4,'db4',4);
            end
        elseif APINum==18
            csimeasurements(sub,i) = GetAmplitude(1,1,sub,csi_entry);
            if mod(i,windowlen)==0
                result=GetFreqUsingFFT(csimeasurements(sub,i-windowlen+1:i),128);
            end
        elseif APINum==19
            csi = get_scaled_csi(csi_entry);
            csidata(:,i)=csi(1,1,:);
            if i>200 &&  mod(i,windowlen)==0
                result=GetChangeSignIndicator(csidata(:,1:200),csidata(:,i-windowlen+1:i));
            end
         elseif APINum==20
            csirawentry(i)=csi_entry;
            if i==900 
                result=GetAoAUsingMUSIC(csirawentry);
            end
    end
   % end

end

%打印结束时间
%datestr(now,13)
t=toc
%feature('memstats')
%计算总耗时

end