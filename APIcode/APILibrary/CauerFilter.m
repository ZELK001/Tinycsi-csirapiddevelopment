function result=CauerFilter(csidata,fs,Rp,Rs)
% CauerFilter removes noise
%
% csidata: input csi file
% fs:sampling rate
% Rp:Maximum ripple of passband
% Rs:Stopband minimum attenuation
%
% Author: LBJ
Wp =2 *[ 100 200] /fs;
Ws = 2 *[ 80 220] /fs;
[ n,Wn] = ellipord(Wp, Ws ,Rp , Rs);
[ b , a] = ellip(n , Rp, Rs Wn);
result = filter(b,a,csidata);
end