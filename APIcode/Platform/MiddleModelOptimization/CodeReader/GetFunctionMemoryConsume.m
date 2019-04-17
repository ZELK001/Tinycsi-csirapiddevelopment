function result=GetFunctionMemoryConsume(functionName)
csiFunctionName=char('GetAmplitude','GetPhase','GetRelativePhase','GetTimeStamp','GetRSSI','GetCFO','ButterworthFilter',...
                     'HampelFilter','MeadianFilter','PCAFilter','SelectSensitiveSubc',...
                      'GetVar','GetStd','GetMean','GetMAX','GetMIN','GetDTWDist','GetFreqVectorUsingDWT',...
                     'GetChangeSignIndicator','GetAoAUsingMUSIC','KNNClassifier');
%运行占用内存（只考虑节点端），与函数名对应
memoryconsume=[4927 5422 6782 2311 4235 2631 9245 8937 9221 8524 4396 5322 5427 3289 3842 4502 6744 6998 12663 6533 8526 4761];
for i=1:size(csiFunctionName,1)
      matches=0;
      matches=findstr(functionName,csiFunctionName(i,:));
     if length(matches)>0
        result=memoryconsume(i);
        break;
    end
    end                
end
