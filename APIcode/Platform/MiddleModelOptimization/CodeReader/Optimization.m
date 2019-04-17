function result=Optimization(filename,Wuplink,Wtrans)
%filename为统计用户callback函数后的结果
%Wuplink为网络实时带宽（从入网点到服务器）
%Wtrans为实时传输速率（从节点到入网点）
f = fopen(filename,'rb');
if (f < 0)
    error('Couldn''t open file %s',filename);
    return;
end


csiFunctionName=char('GetAmplitude','GetPhase','GetRelativePhase','GetTimeStamp','GetRSSI','GetCFO','ButterworthFilter',...
                     'HampelFilter','MeadianFilter','PCAFilter','SelectSensitiveSubc',...
                      'GetVar','GetStd','GetMean','GetMAX','GetMIN','GetDTWDist','GetFreqVectorUsingDWT',...
                    'GetChangeSignIndicator','GetAoAUsingMUSIC','KNNClassifier');
K=1;%考虑多核情况，加在每个时间约束阈值前
Pcollect=12.63;%采集CSI能耗(1000个包)
Euplink=4.87;
%构建目标函数Target和约束条件Constraint
count=1;
while feof(f) ==0
    tline=fgetl(f);
    for i=1:size(csiFunctionName,1)
      matches=0;
      matches=findstr(tline,csiFunctionName(i,:));
      
    if length(matches)>0
        %构建目标函数
        temp=GetFunctionRunTime(csiFunctionName(i,:));
        Target(count)=temp(1)+temp(2)+GetFunctionOutputMap(csiFunctionName(i,:))/Wtrans+GetFunctionOutputMap(csiFunctionName(i,:))/Wuplink;
       
        %构建约束
        %节点端时间约束
        NodeTime(count)=temp(2);
        %服务器端时间约束
        ServerTime(count)=temp(1);
        %传输时间约束
        TransTime(count)=GetFunctionOutputMap(csiFunctionName(i,:))/Wtrans+GetFunctionOutputMap(csiFunctionName(i,:))/Wuplink;
        
        %能耗约束
        Powerconsume(count)=Pcollect+GetFunctionPowerConsume(csiFunctionName(i,:))+(GetFunctionOutputMap(csiFunctionName(i,:))/Wuplink)*Euplink;
        
        %内存约束
        Memoryconsume(count)=GetFunctionMemoryConsume(csiFunctionName(i,:));
        
        count=count+1;
    end
    end
end
 %构建完成，使用线性规划获得最优解
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
