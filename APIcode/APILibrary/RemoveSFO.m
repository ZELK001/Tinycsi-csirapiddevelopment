function result=RemoveSFO(csi_with_sfo)
% Eliminate the effects of SFO in phase
%
% csi_with_sfo: a input csi length*30 matrix with sfo
%
% csi_after_sfo: a length*30 matrix after eliminate the sfo
% Author: Yuxiang Lin

	% Parameters
	channel_width = 40; % channel bandwidth
	f_adjacent = 40/30; % 40M/30, maybe 20M/30, depends on the channel bandwidth
	csi_after_sfo_phase = [];
	csi_amplitude = abs(csi_with_sfo); %length*30
	
	len = size(csi_with_sfo,1);
	for ii = 1:len
		x_regression = 0:2*pi*f_adjacent:29*2*pi*f_adjacent;
		y_regression = phase(csi_with_sfo(ii,:));
		SFO_calibrated = polyfit(x_regression,y_regression,1);
		csi_after_sfo_temp = phase(csi_with_sfo(ii,:))-polyval(SFO_calibrated,x_regression);
		csi_after_sfo_phase = [csi_after_sfo_phase; csi_after_sfo_temp]; % return a length*30 matrix
	end
	csi_after_sfo = csi_amplitude.*exp(-j.*csi_after_sfo_phase);
end 

