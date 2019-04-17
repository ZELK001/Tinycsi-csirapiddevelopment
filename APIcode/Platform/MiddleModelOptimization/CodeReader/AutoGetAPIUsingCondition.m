function result=AutoGetAPIUsingCondition(filename)
%filename为用户callback代码
f = fopen(filename,'rb');
if (f < 0)
    error('Couldn''t open file %s',filename);
    return;
end
fp=fopen('AutoCountResult.txt','w+');
if (fp < 0)
    error('Open file Error');
    return;
end


csiFunctionName=char('GetAmplitude','GetPhase','GetRelativePhase','GetTimeStamp','GetRSSI','GetCFO','ButterworthFilter',...
                     'HampelFilter','MeadianFilter','PCAFilter','RemoveCFO','RemoveSFO','RemovePBD','SelectSensitiveSubc',...
                     'RemoveMultiPath','GetVar','GetStd','GetMean','GetMAX','GetMIN','getDTWDist()','GetFreqVectorUsingDWT',...
                     'GetFreqUsingFFT','GetFreqUsingSTFT','GetChangeSignIndicator','GetAoAUsingMUSIC','GetAoAUsingDynamicMUSIC',...
                     'GetDFS','GetToF','GetFFZRange','KNNClassifier','SVMClassifier','NBClassifier','RFClassifier');
while feof(f) ==0
    tline=fgetl(f);  
    tline(find(isspace(tline))) = [] ;
    for i=1:size(csiFunctionName,1)  
      matches=[];
      str=sprintf('%s',csiFunctionName(i,:));
      str(find(isspace(str))) = [] ;%直接用csiFunctionName(i,:)的话，在函数名后会有空格，原因是要和字符串数组中最长的字符串对齐，所以要去除空格
      matches=findstr(tline,str);

      if length(matches)>0
  
        length(matches)
        fprintf(fp,'%s\r\n',str);
        break;
      end
    end
    
end
fclose(f);
fclose(fp);
end