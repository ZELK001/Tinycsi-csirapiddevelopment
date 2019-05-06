function result=GetTimeStamp(Txant,RxAnt,subc,CSIData)
% Get csi TimeStamp
%
% RawCSI: input csi file
% Txant:Tx antenna
% Rxant:Rx antenna
% Subc: Subcarrier Number
%
% Author: LBJ
result=CSIData.timestamp_low;
end