function [final_dynamic_path,CFO_calibrated]=ExtractDynamicPath(test_csi_file, static_csi_file,antenna_number)
% Extract the dynamic path which is caused by the human movement
%
% test_csi_file: input csi file
% static_csi_file: static CSI measured during static time
% antenna_number: 1 or 2 or 3, represent the serial number of the antenna
%
% final_dynamic_path: a length*30 output matrix, represent for the dynamic path
% CFO_calibrated: CFO coefficients
%
% Author: Yuxiang Lin

% ******************Pay attention to some tuple's initialization******************
   % Parameters
    smooth_average_parameter = 0.1;
    sample_index = 0;
   % Two shown subcarriers
	subcarrier_1 = 1;
	subcarrier_2 = 20;
    %local_max = inf;
    
   % Initialize for tuples..., need carefully check
	static_CSIMatrix = [];
	CSIMatrix_with_SFO = [];
	final_dynamic_path = [];
	CFO_calibrated = [];
	
   % Read CSI file & initialize
    csi_trace = read_bf_file(test_csi_file);
    len = length(csi_trace);
	static_csi_trace = read_bf_file(static_csi_file);
    n = 0; % Extreme point number

   % Get H_static, a 1*30 matrix
	for ii = 1:length(static_csi_trace)
		static_csi = squeeze(get_scaled_csi(static_csi_trace{ii}));
		static_CSIMatrix = [static_CSIMatrix; static_csi(antenna_number,:)]; %length*30 matrix		
	end
   % Calibration with SFO calibration
	H_static = mean(sfo_calibration(static_CSIMatrix));    
   
   % Get SFO calibrated test csi
	for sample_index = 1:len
        temp_CSIMatrix = csi_trace{sample_index};
		csi = squeeze(get_scaled_csi(temp_CSIMatrix));
        CSIMatrix_with_SFO = [CSIMatrix_with_SFO; csi(antenna_number,:)]; % A length*30 matrix
	end
   CSIMatrix_temp = sfo_calibration(CSIMatrix_with_SFO); % A len*30 matrix
   CSIMatrix = CSIMatrix_temp';
   
   % Get amplitude of dynamic path and static component with CFO
   % calibration
   % ************The number of antennas can be further considered***************
    for subcarrier = 1:30      
       for sample_index = 1:len
           csi_amplitude(subcarrier,sample_index) = abs(CSIMatrix(subcarrier,sample_index)); % Get amplitude of CSI, a 1*len matrix
           csi_phase(subcarrier,sample_index) = phase(CSIMatrix(subcarrier,sample_index)); % Get phase of CSI, a 1*len matrix
       end
       
       % Get the peaks and valleys
       [min_index,max_index] = PickUpExtremum(csi_amplitude(subcarrier,:));
       n = 0;
       for search_index = 1:len
           if(ismember(search_index,min_index) || ismember(search_index,max_index))
               n = n+1;
               extreme_point(n) = csi_amplitude(subcarrier,search_index);
			   extreme_point_index(n) = search_index;
		       if(n == 1)
                   amplitude_static_temp(n) = (csi_amplitude(subcarrier,1)+extreme_point(n))/2.0;
                   %amplitude_dynamic_temp(n) = abs(csi_amplitude(subcarrier,1)-extreme_point(n))/2;
				   amplitude_temp_index(n) = extreme_point_index(n);
               else
                   amplitude_static_temp(n) = (extreme_point(n-1)+extreme_point(n))/2.0;
                   %amplitude_dynamic_temp(n) = abs(extreme_point(n-1)-extreme_point(n))/2;
				   amplitude_temp_index(n) = (extreme_point_index(n)+extreme_point_index(n-1))/2.0; % A approximation of index
				   % Avoid collecting the same index
				   if(amplitude_temp_index(n) == amplitude_temp_index(n-1))
						n = n-1;
						continue;
				   end
               end
           end
           
           % Smoothing average (a wrong step in the paper)
           %if(n <= 1)
           %    amplitude_static(search_index) = csi_amplitude(subcarrier,search_index)/2;
           %    amplitude_dynamic(search_index) = csi_amplitude(subcarrier,search_index)/2;
           %else
           %    amplitude_static(search_index) = (1-smooth_average_parameter)*amplitude_static(search_index-1)+smooth_average_parameter*amplitude_static_temp(n);
           %    amplitude_dynamic(search_index) = (1-smooth_average_parameter)*amplitude_dynamic(search_index-1)+smooth_average_parameter*amplitude_dynamic_temp(n);
           %end
		end
        
		% Get the static path with linear interpolation
		% My smooth method
		x = [1, amplitude_temp_index(1:n)];
		y = [csi_amplitude(subcarrier,1), amplitude_static_temp(1:n)];
		xp = 1:len;
		static_path = interp1(x,y,xp,'spline');
		plot(x,y,'o',xp,static_path);
		legend('raw static path', 'extended static path');
				
		% Get the dynamic path
		for search_point_index = 1:length(extreme_point_index)
			static_for_dynamic_amplitude(search_point_index) = static_path(extreme_point_index(search_point_index));
			amplitude_dynamic_temp(search_point_index) = abs(extreme_point(search_point_index)-static_for_dynamic_amplitude(search_point_index));
		end
		
		% Add the 1st point
		x2 = [1, extreme_point_index(1:n)];
		y2 = [0, amplitude_dynamic_temp(1:n)];
		xp2 = 1:len;
		dynamic_path = interp1(x2,y2,xp2,'spline');
				   
        % Calculate angle between static path vector and measured channel vector 
		for search_angle_index = 1:len
			theta_static(search_angle_index) = acos((pow2(csi_amplitude(subcarrier,search_angle_index))+pow2(static_path(search_angle_index))-pow2(dynamic_path(search_angle_index)))/(2.0*csi_amplitude(subcarrier,search_angle_index)*static_path(search_angle_index)));
			theta_dynamic(search_angle_index) = acos((pow2(csi_amplitude(subcarrier,search_angle_index))+pow2(dynamic_path(search_angle_index))-pow2(static_path(search_angle_index)))/(2.0*csi_amplitude(subcarrier,search_angle_index)*dynamic_path(search_angle_index)));

			% First subcarrier's stream
			if(subcarrier == 1)
				phase_base(search_angle_index) = theta_static(search_angle_index);
			end

			% Calculate the phase difference
			vector1 = [real(CSIMatrix(subcarrier,search_angle_index)), imag(CSIMatrix(subcarrier,search_angle_index))];
			vector_first_subcarrier = [real(CSIMatrix(1,search_angle_index)), imag(CSIMatrix(1,search_angle_index))];
			phase_diffenrence(search_angle_index) = GetAngle(vector1,vector_first_subcarrier);
			phase_dynamic(search_angle_index) = phase_diffenrence(search_angle_index)+phase_base(search_angle_index)-theta_dynamic(search_angle_index);

			% Get the intermediate estimated dynamic dynamic path CSI
			intermediate_dynamic_path(subcarrier,search_angle_index) = dynamic_path(search_angle_index)*exp(-j*phase_dynamic(search_angle_index));
		end	
    end

	% Use CFO to calibrate teh dynamic path
	for ii = 1:len
		% Use 30 subcarriers for regression
		x_regression = H_static; % 1*30
		y_regression = (CSIMatrix(:,ii)-intermediate_dynamic_path(:,ii))';
		CFO_calibrated_temp = polyfit(x_regression,y_regression,1);
		CFO_calibrated = [CFO_calibrated; CFO_calibrated_temp];
		final_dynamic_path_temp = CSIMatrix(:,ii)'-polyval(CFO_calibrated_temp,x_regression); 
		final_dynamic_path = [final_dynamic_path; final_dynamic_path_temp]; % the final len*30 matrix
	end
	
	% Plot phase in subcarrier 1 and 10
	for ii = 1:len
		dynamic_phase_subcarrier_1(ii) = phase(final_dynamic_path(ii,subcarrier_1));
		dynamic_phase_subcarrier_2(ii) = phase(final_dynamic_path(ii,subcarrier_2));
	end
	jj = 1:len;
	figure(2);
	plot(jj,dynamic_phase_subcarrier_1,jj,dynamic_phase_subcarrier_2);
	legend('dynamic subcarrier_1','dynamic subcarrier_{10}');
	xlabel('Nomalized time');
	ylabel('Phase (rad)');
    figure(3);
	plot(jj,CSIMatrix_with_SFO(:,subcarrier_1),jj,CSIMatrix_with_SFO(:,subcarrier_2));
	legend('raw subcarrier_1','raw subcarrier_{10}');
	xlabel('Nomalized time');
	ylabel('Phase (rad)');
    figure(4);
	plot(jj,csi_phase(subcarrier_1,:),jj,csi_phase(subcarrier_2,:));
	legend('SFO subcarrier_1','SFO subcarrier_{10}');
	xlabel('Nomalized time');
	ylabel('Phase (rad)');
end
end