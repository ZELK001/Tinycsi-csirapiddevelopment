function result=HampelFilter(csidata)
% HampelFilter removes noise
%
% csidata: input csi file
%
% Author: LBJ
hampelResult = hampel(csidata);
result=hampelResult;
end