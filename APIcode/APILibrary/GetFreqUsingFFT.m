function result=GetFreqUsingFFT(csidata,N)
% Fast Fourier Transform of Signal X
%
% csidata: input csi file
% N:The first n points of signal X
%
% Author: LBJ
result=fft(csidata,N);
end