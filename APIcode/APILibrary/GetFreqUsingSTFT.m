function result=GetFreqUsingSTFT(csidata)
% Short-time signal X Fourier transform
%
% csidata: input csi file
%
% Author: LBJ
T=length(csidata);
[tfr,t,f] = tfrstft(csidata',1:T,T,hamming(501),0); 
result=tfr;
end