function result=GetChangeSignIndicator(silentcsidata,csidata)
%动作检测Signindicator
silentCSI=silentcsidata;
windowCSI=csidata;
%计算signindicator
arraytemp=windowCSI*windowCSI';%30*500和500*30矩阵相乘，生成30*30方阵，来求得特征值和特征向量----这一步不太理解，暂时不用了，直接用标准差变化较大来判断      
count_change=0;%统计30个子信道中标准差变化大的个数
for subc=1:30
    varSilent(subc) = var( silentCSI(subc,:));%标准差
    
end
for subc=1:30
    varNow(subc) = var( windowCSI(subc,:));%标准差
    if(varNow(subc)>varSilent(subc))
               count_change=count_change+1;
    end
end
movementProfile=zeros(1,length(windowCSI));
if count_change>16%统计子信道大于16个时，认为是有手势动作,开始构建profile   
    fprintf('findone\n');
    movementProfile=mean(windowCSI,1);
end
result=movementProfile;
end