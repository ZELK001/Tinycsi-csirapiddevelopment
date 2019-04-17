% Display CSI signal of 30 subcarriers offline
%
function ret = csiOfflineDisplay(filename)
error(nargchk(1,1,nargin));

csi_trace = read_bf_file(filename);
for i = 1:length(csi_trace)
    csi_entry=csi_trace{i};
    csi=get_scaled_csi(csi_entry);
    plot(db(abs(squeeze(csi(1,1,:)).')))
    %hold on
    %legend('RX Antenna A', 'RX Antenna B', 'RX Antenna C', 'Location', 'SouthEast' );
    xlabel('Subcarrier index');
    ylabel('SNR [dB]');
    axis([0,30,0,30]);
    pause(0.05)
end
plot(ifft(db(abs(squeeze(csi(1,1,:)).'))))
