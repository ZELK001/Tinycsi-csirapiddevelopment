function result=GetFunctionRunTime(functionName)
csiFunctionName=char('GetAmplitude','GetPhase','GetRelativePhase','GetTimeStamp','GetRSSI','GetCFO','ButterworthFilter',...
                     'HampelFilter','MeadianFilter','PCAFilter','SelectSensitiveSubc',...
                      'GetVar','GetStd','GetMean','GetMAX','GetMIN','GetDTWDist','GetFreqVectorUsingDWT',...
                     'GetChangeSignIndicator','GetAoAUsingMUSIC','KNNClassifier');
%运行时间，一组中的第一项表示服务器端运行时间，第二项表示节点端运行时间。与函数名称对应
runtime=[0.12 6.14;0.13 5.22;0.36 5.4;0.05 0.44;0.018 1.7529;0.17 6.2;1.36 9;0.15 6.223;3.75 9.03;4.726 10.882;0.14 5.2;...
         0.19 6.3;0.14 5.16;0.14 6.17;0.14 5.15;0.22 6.86;0.30 7.92;0.16 6.42;25.74 45.7;0.56 5.31;2.39 8.22;1.15 6.33];
for i=1:size(csiFunctionName,1)
      matches=0;
      matches=findstr(functionName,csiFunctionName(i,:));
     if length(matches)>0
        result=runtime(i,:);
        break;
    end
    end                
end