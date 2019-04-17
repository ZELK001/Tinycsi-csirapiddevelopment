function result=GetRSSI(csi_entry)
%从csientry中获取发送端每个天线的Rssi
temp_result(1)=csi_entry.rssi_a;
temp_result(2)=csi_entry.rssi_b;
temp_result(3)=csi_entry.rssi_c;
result=mean(temp_result);

end