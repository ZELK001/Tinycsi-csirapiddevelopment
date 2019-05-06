function result=GetTimeDomaimFeatureSet(csidata)
[m,n]=size(data);
D=[];
DA=[];
for i=1:1:m
    d=data(i,:)
    d=d(~isnan(d));%remove NAN 
    ave=mean(d);%mean
    u=std(d);%std
    time=length(d);%time
    theta=var(d);%var
    area=sum(abs(d));
    maxv=max(d);
    minv=min(d);
    [dd,minp,maxp]=premnmx(d);  %get information entropy
    entropy=yyshang(dd,9);
    D=[D;ave;maxv;minv;u;area;time;theta;entropy];
    DA=[DA,D];
    D=[];
end
DA=DA';
result=DA;
end