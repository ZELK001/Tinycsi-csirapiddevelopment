function result=GetAmplitude(Txant,Rxant,Subc,RawCSI)
% Get csi amplitude
%
% RawCSI: input csi file
% Txant:Tx antenna
% Rxant:Rx antenna
% Subc: Subcarrier Number
%
% Author: LBJ
csi = get_scaled_csi(RawCSI);
result=db(abs(squeeze(csi(Txant,Rxant,Subc))));
end