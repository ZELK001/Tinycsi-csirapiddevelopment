function result=GetRelativePhase(Txant,Rxant1,Rxant2,Subc,RawCSI)
%获取相对相位差，相对相位差为两个接收方天线相位的差值，而差值较直接测量要跟家稳定，需要选择两个Rx端的天线
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