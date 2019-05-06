
clear all;
clc;
C = 10;
kertype = 'linear';
%training sample
n = 50;
randn('state',6);%To ensure that the random number generated at each time is the same
x1 = randn(2,n);    
y1 = ones(1,n);      
x2 = 5+randn(2,n);  
y2 = -ones(1,n);      

figure;
plot(x1(1,:),x1(2,:),'bx',x2(1,:),x2(2,:),'k.'); 
axis([-3 8 -3 8]);
xlabel('x÷·');
ylabel('y÷·');
hold on;

X = [x1,x2];        %D*n Matrix of Training Samples
Y = [y1,y2];        %1*n Matrix of Training Objectives
svm = svmTrain(X,Y,kertype,C);
plot(svm.Xsv(1,:),svm.Xsv(2,:),'ro');


[x1,x2] = meshgrid(-2:0.05:7,-2:0.05:7);  
[rows,cols] = size(x1);  
nt = rows*cols;                  
Xt = [reshape(x1,1,nt);reshape(x2,1,nt)];
Yt = ones(1,nt);
result = svmTest(svm, Xt, Yt, kertype);

Yd = reshape(result.Y,rows,cols);
contour(x1,x2,Yd,'m');

