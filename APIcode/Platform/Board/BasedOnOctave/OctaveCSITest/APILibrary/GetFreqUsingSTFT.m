function result=GetFreqUsingSTFT(csidata)
%暂时有问题，无法正常运行
T=length(csidata);
[tfr,t,f] = tfrstft(csidata',1:T,T,hamming(501),0); 
result=tfr;
end