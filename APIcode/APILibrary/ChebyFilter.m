function result=ChebyFilter(csidata,fs,Rp,Rs)
% ChebyFilter removes noise
%
% csidata: input csi file
% fs:sampling rate
% Rp:Maximum ripple of passband
% Rs:Stopband minimum attenuation
%
% Author: LBJ
fs = 1000;   
wp = 55/(fs/2);  
[n,Wn]=cheb1ord(Wp,Ws,Rp,Rs); 
[b,a]=cheby1(n,Rp,Wn, 'low');  
result = filter(b,a,csidata);        
end
