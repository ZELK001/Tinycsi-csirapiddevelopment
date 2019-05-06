function result=GetPhase(Txant,Rxant,Subc,RawCSI)
% Get csi phase
%
% RawCSI: input csi file
% Txant:Tx antenna
% Rxant:Rx antenna
% Subc: Subcarrier Number
%
% Author: LBJ
csi = get_scaled_csi(RawCSI);
result=phase((csi(Txant,Rxant,Subc)));
end