function result=GetFunctionOutputMap(functionName)
csiFunctionName=char('GetAmplitude','GetPhase','GetRelativePhase','GetTimeStamp','GetRSSI','GetCFO','ButterworthFilter',...
                     'HampelFilter','MeadianFilter','PCAFilter','SelectSensitiveSubc',...
                      'GetVar','GetStd','GetMean','GetMAX','GetMIN','GetDTWDist','GetFreqVectorUsingDWT',...
                     'GetChangeSignIndicator','GetAoAUsingMUSIC','KNNClassifier');
%函数的输出数量，用于传输数量大小
%计算方法：输出为float，占4bytes，之前时间能耗等数据都是基于1000个数据包测，因此对于GetAmplitude传输个数为4000，而对于滤波器要考虑时间窗，则有400
output=[4000 4000 4000 4000 2000 800 800 400 400 500 400 4000 4000 4000 4000 400 400 400 500 400 4000 4000];
for i=1:size(csiFunctionName,1)
      matches=0;
      matches=findstr(functionName,csiFunctionName(i,:));
     if length(matches)>0
        result=output(i);
        break;
    end
    end                
end