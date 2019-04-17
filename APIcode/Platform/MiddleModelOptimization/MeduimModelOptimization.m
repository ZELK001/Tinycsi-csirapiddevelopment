function result=MeduimModelOptimization(testcase)
% clc,clear
% a=0;
% hold on
% while a<0.05
%     c=[-0.05,-0.27,-0.19,-0.185,-0.185];
%     A=[zeros(4,1),diag([0.025,0.015,0.055,0.026])];
%     b=a*ones(4,1);
%     Aeq=[1,1.01,1.02,1.045,1.065];
%     beq=1;
%     LB=zeros(5,1);
%     [x,Q]=linprog(c,A,b,Aeq,beq,LB);
%     Q=-Q;
%     plot(a,Q,'*k');
%     a = a + 0.001;
% end

% f=[1;3;1];
% A=[1 1 0;1 0 0;0 1 0;0 0 1];
% b=[15;5;20;2];
% lb=zeros(3,1);
% 
% [x,fval,exitflag]=linprog(f,A,b,[],[],lb);
% x
% fval
% exitflag

if testcase==1
%入侵检测优化
%优化目标：总时间最短，总时间=节点端处理时间+服务器处理时间+传输时间，存在并行性的可能？（同一个API会在节点和服务器端都执行），串行不是更简单吗
count=1;
w=10000;%传输速率，10mbps
t=[0.12 6.12;0.25 5.24;0.13 4.21;0.13 4.21];%不同函数处理CSI需要的时间
F=[1000 1000;1000 1000;1000 1000;1000 1000];%映射函数，每个task对应的output的数据量大小
for i=1:4
    %4为从代码中获取的API总个数
    for j=1:2
        f(count)=t(i,j)+F(i,j)/w;
        count=count+1;
    end
end

%约束条件：能耗和占用内存
%能耗：考虑两种情况：只在节点端处理的耗能；要在服务器端处理的而引起的在节点端传输的耗能
%仅在节点端：E=300mw
e=[12.5;25.1;13.5;4.21];%不同函数处理CSI需要的能耗
count=1;
for i=1:4
    %4为从代码中获取的API总个数
    A1(count)=e(i);
    count=count+1;
end
%传输至服务器端：E'=500mw
F=[1000;1000;1000;1000];%映射函数，每个task对应的output的数据量大小
et=[12.5;12.5;13.5;12.5;12.5,];%不同函数处理CSI需要的传输能耗
count=1;
for i=1:4
    %4为从代码中获取的API总个数
    A2(count)=F(i)*et(i);
    count=count+1;
end

%内存：同样考虑两种情况:节点端和服务器端
%节点端：M=35000
m=[5123;6672;5012;6542];%不同函数处理CSI需要的能耗
count=1;
for i=1:4
    %4为从代码中获取的API总个数
    A3(count)=m(i);
    count=count+1;
end
%服务器端：M'=35000
mt=[4926;6222;4012;4542];%不同函数处理CSI需要的能耗
count=1;
for i=1:4
    %4为从代码中获取的API总个数
    A4(count)=mt(i);
    count=count+1;
end
temp1=[A1,A2];
temp2=[A3,A4];
%A=[A1:A2;A3:A4];
%L=f+b+A;
A=[temp1;temp2];
b=[1000;60000]
f=f';
%用线性规划求最优解
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
%手势识别检测
%优化目标：总时间最短，总时间=节点端处理时间+服务器处理时间+传输时间
count=1;
w=10000;%传输速率，10mbps
t=[0.12 6.12;0.25 5.24;0.13 4.21;0.52 3.22;0.22 6.822;2.3291 8.223;1.157 6.622];%不同函数处理CSI需要的时间
F=[1000 1000;1000 1000;1000 1000;1000 1000;1000 1000;1000 1000;1000 1000];%映射函数，每个task对应的output的数据量大小
for i=1:7
    %4为从代码中获取的API总个数
    for j=1:2
        f(count)=t(i,j)+F(i,j)/w;
        count=count+1;
    end
end

%约束条件：能耗和占用内存
%能耗：考虑两种情况：只在节点端处理的耗能；要在服务器端处理的而引起的在节点端传输的耗能
%仅在节点端：E=300mw
e=[12.5;25.1;13.5;4.21;12.5;22.4;15.4];%不同函数处理CSI需要的能耗
count=1;
for i=1:7
    %4为从代码中获取的API总个数
    A1(count)=e(i);
    count=count+1;
end
%传输至服务器端：E'=500mw
F=[1000;1000;1000;1000;1000;1000;1000];%映射函数，每个task对应的output的数据量大小
et=[12.5;12.5;13.5;12.5;12.5;12.5;11.5;12.4];%不同函数处理CSI需要的传输能耗
count=1;
for i=1:7
    %4为从代码中获取的API总个数
    A2(count)=F(i)*et(i);
    count=count+1;
end

%内存：同样考虑两种情况:节点端和服务器端
%节点端：M=35000
m=[5123;6672;5012;6542;5422;6479;4692];%不同函数处理CSI需要的能耗
count=1;
for i=1:7
    %7为从代码中获取的API总个数
    A3(count)=m(i);
    count=count+1;
end
%服务器端：M'=35000
mt=[4926;6222;4012;4542;4223;6322;5419];%不同函数处理CSI需要的能耗
count=1;
for i=1:7
    %4为从代码中获取的API总个数
    A4(count)=mt(i);
    count=count+1;
end
temp1=[A1,A2];
temp2=[A3,A4];
%A=[A1:A2;A3:A4];
%L=f+b+A;
A=[temp1;temp2];
b=[1000;60000]
f=f';
%用线性规划求最优解
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
%MUSIC算法
%优化目标：总时间最短，总时间=节点端处理时间+服务器处理时间+传输时间
count=1;
w=10000;%传输速率，10mbps
t=[0.12 6.12;0.25 5.24;0.13 4.21;0.13 4.21];%不同函数处理CSI需要的时间
F=[1000 1000;1000 1000;1000 1000;1000 1000];%映射函数，每个task对应的output的数据量大小
for i=1:4
    %4为从代码中获取的API总个数
    for j=1:2
        f(count)=t(i,j)+F(i,j)/w;
        count=count+1;
    end
end

%约束条件：能耗和占用内存
%能耗：考虑两种情况：只在节点端处理的耗能；要在服务器端处理的而引起的在节点端传输的耗能
%仅在节点端：E=300mw
e=[12.5;25.1;13.5;4.21];%不同函数处理CSI需要的能耗
count=1;
for i=1:4
    %4为从代码中获取的API总个数
    A1(count)=e(i);
    count=count+1;
end
%传输至服务器端：E'=500mw
F=[1000;1000;1000;1000];%映射函数，每个task对应的output的数据量大小
et=[12.5;12.5;13.5;12.5;12.5,];%不同函数处理CSI需要的传输能耗
count=1;
for i=1:4
    %4为从代码中获取的API总个数
    A2(count)=F(i)*et(i);
    count=count+1;
end

%内存：同样考虑两种情况:节点端和服务器端
%节点端：M=35000
m=[5123;6672;5012;6542];%不同函数处理CSI需要的能耗
count=1;
for i=1:4
    %4为从代码中获取的API总个数
    A3(count)=m(i);
    count=count+1;
end
%服务器端：M'=35000
mt=[4926;6222;4012;4542];%不同函数处理CSI需要的能耗
count=1;
for i=1:4
    %4为从代码中获取的API总个数
    A4(count)=mt(i);
    count=count+1;
end
temp1=[A1,A2];
temp2=[A3,A4];
%A=[A1:A2;A3:A4];
%L=f+b+A;
A=[temp1;temp2];
b=[1000;60000]
f=f';
%用线性规划求最优解
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