function result=SavitzkyGolayFilter(csidata,order,framelen)
%
% csidata: input csi file
% order:sampling point
% framelen:frame length
result = sgolayfilt(csidata,order,framelen);
end