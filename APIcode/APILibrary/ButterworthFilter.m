function result=ButterworthFilter(csidata,order,framelen)
% ButterworthFilter removes noise
%
% csidata: input csi file
% fs:sampling rate
% fc:stopping frequency
% order:sampling point
%
% Author: LBJ
fs=20; %sampling rate
fc=5;  %stopping frequency
order=4; 
b=ones(1,5);
a=zeros(1,5);
[b,a]=butter(order,2*fc/fs);
result = filter(b,a,csidata(:));
end