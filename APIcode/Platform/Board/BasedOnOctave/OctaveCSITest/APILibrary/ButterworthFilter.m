function result=ButterworthFilter(csidata,fs,fc,order)
fs=20; %sampling rate
fc=5;  %stopping frequency
order=4; 
[b,a]=butter(order,2*fc/fs);
butterworthResult = filter(b,a,csidata(:));
result=butterworthResult ;
end