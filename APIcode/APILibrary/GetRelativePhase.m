function result=GetRelativePhase(Txant,Rxant1,Rxant2,Subc,RawCSI)
% Get relative csi amplitude
%
% RawCSI: input csi file
% Txant:Tx antenna
% Rxant1:Rx antenna1
% Rxant2:Rx antenna2
% Subc: Subcarrier Number
%
% Author: LBJ
csi = get_scaled_csi(RawCSI);
csi1 = squeeze(csi(Txant,Rxant1,:));
csi2= squeeze(csi(Txant,Rxant2,:));
originalPhase_1 = phase(csi1);
originalPhase_2 = phase(csi2);
averagePhase_1= mean(originalPhase_1);
averagePhase_2= mean(originalPhase_2);
difference=averagePhase_2-averagePhase_1;
result=difference;
end