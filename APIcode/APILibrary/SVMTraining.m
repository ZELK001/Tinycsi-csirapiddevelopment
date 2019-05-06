function svm = svmTrain(X,Y,kertype,C)
options = optimset;    % Options are vectors used to control the parameters of the algorithm's options
options.LargeScale = 'off';% LargeScale refers to large-scale search. Off Signs Closed in Scale Search Mode
options.Display = 'off';

n = length(Y);
H = (Y'*Y).*kernel(X,X,kertype);

f = -ones(n,1); 
A = [];
b = [];
Aeq = Y; 
beq = 0;
lb = zeros(n,1);
ub = C*ones(n,1);
a0 = zeros(n,1);  
[a,fval,eXitflag,output,lambda]  = quadprog(H,f,A,b,Aeq,beq,lb,ub,a0,options);

epsilon = 1e-8;                     
sv_label = find(abs(a)>epsilon);     
svm.a = a(sv_label);
svm.Xsv = X(:,sv_label);
svm.Ysv = Y(sv_label);
svm.svnum = length(sv_label);