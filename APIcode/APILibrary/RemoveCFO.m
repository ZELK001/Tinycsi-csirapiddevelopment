function result=RemoveCFO(csi_trace,ant,startPkt,lastPkt)
% Remove CFO
%
% csi_trace: input csi file
% startPkt: start packetNumber
% stopPkt: last packetNumber
% Author: LBJ
%Carrier Frequency Offset (CFO)
amplitudeArray = zeros(30,lastPkt-startPkt);
phaseArray = zeros(30,lastPkt-startPkt);
for i = 1:lastPkt-startPkt
    csi_entry = csi_trace{i+startPkt};
    csi = get_scaled_csi(csi_entry);
    for subc = 1:30
        amplitudeArray(subc,i) = db(abs(csi(1,ant,subc)));
        phaseArray(sub,i)=phase((csi(1,ant,subc)));
    end
end
maxStaticComponent=0;
for i = 1:lastPkt-startPkt
    for subc = 1:30
    if amplitudeArray(sub,i)>maxStaticComponent && subc<29
        maxStaticComponet=db(amplitudeArray(sub,i));
    end
    end
end
 for i = 1:lastPkt-startPkt
    for subc = 1:30
    if amplitudeArray(sub,i)>maxStaticComponent && subc<29
        maxStaticComponet=db(amplitudeArray(sub,i));
    end
    end
    phaseArray(sub,i)=phaseArray(sub+1,i)/phaseArray(sub,i);

 end
result=phaseArray;
end