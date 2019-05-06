function result=MeduimModelOptimization(testcase)


if testcase==1

count=1;
w=10000;
t=[0.12 6.12;0.25 5.24;0.13 4.21;0.13 4.21];
F=[1000 1000;1000 1000;1000 1000;1000 1000];
for i=1:4
   
    for j=1:2
        f(count)=t(i,j)+F(i,j)/w;
        count=count+1;
    end
end


e=[12.5;25.1;13.5;4.21];
count=1;
for i=1:4
    
    A1(count)=e(i);
    count=count+1;
end

F=[1000;1000;1000;1000];
et=[12.5;12.5;13.5;12.5;12.5,];
count=1;
for i=1:4
    
    A2(count)=F(i)*et(i);
    count=count+1;
end


m=[5123;6672;5012;6542];
count=1;
for i=1:4
   
    A3(count)=m(i);
    count=count+1;
end

mt=[4926;6222;4012;4542];
count=1;
for i=1:4
   
    A4(count)=mt(i);
    count=count+1;
end
temp1=[A1,A2];
temp2=[A3,A4];

A=[temp1;temp2];
b=[1000;60000]
f=f';

lb=zeros(8,1);
[x1,fval,exitflag]=linprog(f,A,b,[],[],lb);
x1=x1*10^10;
for i=1:length(x1)
    if x1(i)>0.5
        x2(i)=1;
    else
        x2(i)=0;
    end
end
[x,fval,exitflag]=intlinprog(f,1:8,A,b,[],[],lb);

else if testcase==2

count=1;
w=10000;
t=[0.12 6.12;0.25 5.24;0.13 4.21;0.52 3.22;0.22 6.822;2.3291 8.223;1.157 6.622];
F=[1000 1000;1000 1000;1000 1000;1000 1000;1000 1000;1000 1000;1000 1000];
for i=1:7
    
    for j=1:2
        f(count)=t(i,j)+F(i,j)/w;
        count=count+1;
    end
end



e=[12.5;25.1;13.5;4.21;12.5;22.4;15.4];
count=1;
for i=1:7
    
    A1(count)=e(i);
    count=count+1;
end

F=[1000;1000;1000;1000;1000;1000;1000];
et=[12.5;12.5;13.5;12.5;12.5;12.5;11.5;12.4];
count=1;
for i=1:7
    
    A2(count)=F(i)*et(i);
    count=count+1;
end


m=[5123;6672;5012;6542;5422;6479;4692];
count=1;
for i=1:7
   
    A3(count)=m(i);
    count=count+1;
end

mt=[4926;6222;4012;4542;4223;6322;5419];
count=1;
for i=1:7

    A4(count)=mt(i);
    count=count+1;
end
temp1=[A1,A2];
temp2=[A3,A4];

A=[temp1;temp2];
b=[1000;60000]
f=f';

lb=zeros(14,1);
[x1,fval,exitflag]=linprog(f,A,b,[],[],lb);
x1=x1*10^10;
for i=1:length(x1)
    if x1(i)>0.5
        x2(i)=1;
    else
        x2(i)=0;
    end
end
[x,fval,exitflag]=intlinprog(f,1:14,A,b,[],[],lb);

else if testcase==3

count=1;
w=10000;
t=[0.12 6.12;0.25 5.24;0.13 4.21;0.13 4.21];
F=[1000 1000;1000 1000;1000 1000;1000 1000];
for i=1:4
 
    for j=1:2
        f(count)=t(i,j)+F(i,j)/w;
        count=count+1;
    end
end


e=[12.5;25.1;13.5;4.21];
count=1;
for i=1:4
   
    A1(count)=e(i);
    count=count+1;
end

F=[1000;1000;1000;1000];
et=[12.5;12.5;13.5;12.5;12.5,];
count=1;
for i=1:4
   
    A2(count)=F(i)*et(i);
    count=count+1;
end



m=[5123;6672;5012;6542];
count=1;
for i=1:4
    
    A3(count)=m(i);
    count=count+1;
end

mt=[4926;6222;4012;4542];
count=1;
for i=1:4
   
    A4(count)=mt(i);
    count=count+1;
end
temp1=[A1,A2];
temp2=[A3,A4];

A=[temp1;temp2];
b=[1000;60000]
f=f';

lb=zeros(8,1);
[x1,fval,exitflag]=linprog(f,A,b,[],[],lb);
x1=x1*10^10;
for i=1:length(x1)
    if x1(i)>0.5
        x2(i)=1;
    else
        x2(i)=0;
    end
end
[x,fval,exitflag]=intlinprog(f,1:8,A,b,[],[],lb);
end

end