function result=GetFloatPointNum(a0)
a=mod(a0,1);%the fraction part
div=0.1;
digitNum=0;
while abs(a-0)>1e-17
    a=mod(a,div);
    digitNum=digitNum+1;
    div=10^(-digitNum-1);
end
digitNum
end