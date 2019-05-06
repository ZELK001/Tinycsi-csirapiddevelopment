function result=GetFunctionPowerConsume(functionName)
csiFunctionName=char('GetAmplitude','GetPhase','GetRelativePhase','GetTimeStamp','GetRSSI','GetCFO','ButterworthFilter',...
                     'HampelFilter','MeadianFilter','PCAFilter','SelectSensitiveSubc',...
                      'GetVar','GetStd','GetMean','GetMAX','GetMIN','GetDTWDist','GetFreqVectorUsingDWT',...
                     'GetChangeSignIndicator','GetAoAUsingMUSIC','KNNClassifier');
powerconsume=[12.56 10.82 21.06 7.55 8.52 9.67 16 19.12 28.96 26.03 8.69 7.25 7.24 6.98 8.24 24.91 26.77 27.23 39.25 21.42 40.6 20.77];
for i=1:size(csiFunctionName,1)
      matches=0;
      matches=findstr(functionName,csiFunctionName(i,:));
     if length(matches)>0
        result=powerconsume(i);
        break;
    end
    end                
end
