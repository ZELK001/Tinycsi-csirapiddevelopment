function result=GetPhase(Txant,Rxant,Subc,RawCSI)
%从csi_entry中获取csi(rawcsi即已经过read_bfee(bytes)读取后的结果，具体可以参考入侵检测代码中的相关部分)
%csi_entry= csi_trace{i+startPkt};
csi = get_scaled_csi(RawCSI);
result=phase((csi(Txant,Rxant,Subc)));
end