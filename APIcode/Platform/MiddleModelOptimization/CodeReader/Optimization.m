function result=Optimization(filename,Wuplink,Wtrans)

f = fopen(filename,'rb');
if (f < 0)
    error('Couldn''t open file %s',filename);
    return;
end


csiFunctionName=char('GetAmplitude','GetPhase','GetRelativePhase','GetTimeStamp','GetRSSI','GetCFO','ButterworthFilter',...
                     'HampelFilter','MeadianFilter','PCAFilter','SelectSensitiveSubc',...
                      'GetVar','GetStd','GetMean','GetMAX','GetMIN','GetDTWDist','GetFreqVectorUsingDWT',...
                    'GetChangeSignIndicator','GetAoAUsingMUSIC','KNNClassifier');
K=1;
Pcollect=12.63;
Euplink=4.87;

count=1;
while feof(f) ==0
    tline=fgetl(f);
    for i=1:size(csiFunctionName,1)
      matches=0;
      matches=findstr(tline,csiFunctionName(i,:));
      
    if length(matches)>0
      
        temp=GetFunctionRunTime(csiFunctionName(i,:));
        Target(count)=temp(1)+temp(2)+GetFunctionOutputMap(csiFunctionName(i,:))/Wtrans+GetFunctionOutputMap(csiFunctionName(i,:))/Wuplink;
       
       
        NodeTime(count)=temp(2);
       
        ServerTime(count)=temp(1);
       
        TransTime(count)=GetFunctionOutputMap(csiFunctionName(i,:))/Wtrans+GetFunctionOutputMap(csiFunctionName(i,:))/Wuplink;
        
        
        Powerconsume(count)=Pcollect+GetFunctionPowerConsume(csiFunctionName(i,:))+(GetFunctionOutputMap(csiFunctionName(i,:))/Wuplink)*Euplink;
        
       
        Memoryconsume(count)=GetFunctionMemoryConsume(csiFunctionName(i,:));
        
        count=count+1;
    end
    end
end
A=[NodeTime;ServerTime;TransTime;Powerconsume;Memoryconsume];
b=[K*5;K*5;K*5;1000;60000];
Target=Target';
Target
A
b
lb=zeros(count,1);

[x1,fval,exitflag]=linprog(Target,A,b,[],[],lb);
x1
%x1=x1*10^17;
% for i=1:3
%     GetFloatPointNum(x1(i));
% end
ub=ones(count,1);
[x1,fval,exitflag]=intlinprog(Target,1:length(Target),A,b,[],[],lb,ub);
x1
% for i=1:length(x1)
% if x1(i)>0.5
%      x2(i)=1;
%   else
%         x2(i)=0;
%     end
% end
  %x2
    %[x,fval,exitflag]=intlinprog(f,1:8,A,b,[],[],lb);
fclose(f);

end
