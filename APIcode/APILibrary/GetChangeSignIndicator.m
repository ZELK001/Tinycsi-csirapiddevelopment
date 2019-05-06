function result=GetChangeSignIndicator(silentcsidata,csidata)
%Obtain movement change indication
silentCSI=silentcsidata;
windowCSI=csidata;
arraytemp=windowCSI*windowCSI';      
count_change=0;
for subc=1:30
    varSilent(subc) = var( silentCSI(subc,:));
    
end
for subc=1:30
    varNow(subc) = var( windowCSI(subc,:));
    if(varNow(subc)>varSilent(subc))
               count_change=count_change+1;
    end
end
movementProfile=zeros(1,length(windowCSI));
%When the number of statistical subchannels is greater than 16, they are considered to be active and begin to build profiles.
if count_change>16
    fprintf('findone\n');
    movementProfile=mean(windowCSI,1);
end
result=movementProfile;
end