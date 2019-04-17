function ret = humanDetection(handle,filename)
% Detect the intruder using CSI signal in real time 
%
% **Note**:  
% 1. An fifo file should be created at first using mkfifo  
% 2. You may re-MEX \toolScripts\read_bfee.c  
% 
% filename: the name of fifo file

thehandle=handle;
addpath('toolScripts');
f = fopen(filename,'rb');
if (f < 0)
    error('Couldn''t open file %s',filename);
    return;
end

count = 0;
broken_perm = 0;% Flag marking whether we've encountered a broken CSI yet
triangle = [1 3 6 9];
varSilent = 0;

% customized parameters

pauseTime = 0; % for real time purpose
subc = 15; % which subcarrier
SNThresRatio = 5; % the threshold of ratio between "nobody" environment and "intruder" environment
silentRange = [1,4]; % the time interval range we collect CSI in "nobody" environment as baseline
pingInterval = 0.05;
pingPktRate = 1;
windowDuration = 1; % window duration for judegement
stepDuration = 0.5; % 2 judegements for 1 second 
pktRate = 1 / pingInterval * pingPktRate; % the number of CSI matrixes in 1 second
silentPktRange = silentRange * pktRate; 
windowLength = windowDuration * pktRate;
stepLength = stepDuration * pktRate;
shownFlag = 0;
signalsome=[0 0];


% Process all entries in file
while 1
    field_len = fread(f,1,'uint16',0,'ieee-be');

    code = fread(f,1);

    if (code == 187)
        bytes = fread(f, field_len-1, 'uint8=>uint8');
        if(length(bytes) ~= field_len-1)
            % XXX
            fclose(f);
            return;
        end
    else %skip all other info
        fread(f,field_len-1);
        continue;
    end

    if (code == 187)
        count = count + 1;
        ret{count} = read_bfee(bytes);
        perm = ret{count}.perm;
        Nrx = ret{count}.Nrx;

        if Nrx ~= 1 % No permuting needed for only 1 antenna
            if sum(perm) ~= triangle(Nrx) % matrix does not contain default values
                if broken_perm == 0
                    broken_perm = 1;
                    fprintf('WARN ONCE: Found CSI (%s) with Nrx=%d and invalid perm=[%s]\n', filename, Nrx, int2str(perm));
                end
            else
                ret{count}.csi(:,perm(1:Nrx),:) = ret{count}.csi(:,1:Nrx,:);
            end
        end
       
        csi = get_scaled_csi(ret{count});
        csiSubc(count) = db(abs((csi(1,1,subc))));
        
        plot(thehandle.axes1,db(abs(squeeze(csi(1,1,:)).')));
        axis(thehandle.axes1,[0,30,0,35]);
        xlabel(thehandle.axes1,'Subcarriers','fontsize',18);
        ylabel(thehandle.axes1,'Amplitude','fontsize',18);
        
        plot(thehandle.axes2,csiSubc,'LineWidth',2);
        axis(thehandle.axes2,[floor(count/100)*100,floor(count/100)*100+100,0,35]);
        xlabel(thehandle.axes2,'Data Index','fontsize',18);
        ylabel(thehandle.axes2,'Amplitude','fontsize',18);
        title(thehandle.axes2,strcat('One SubChannel:',num2str(subc)));
        
        %频域信息，用fft
        if count>200
        N=128;
        fs=100;
        n=0:N-1;
        y=fft(csiSubc,128);
        mag=abs(y);
        freq=n*fs/N;    %频率序列
        plot(thehandle.axes3,freq,mag);
        %axis(thehandle.axes1,[0,30,0,35]);
        xlabel(thehandle.axes3,'Freqs','fontsize',18);
        ylabel(thehandle.axes3,'Amplitude','fontsize',18);
        
        end
        
        drawnow;
        
        
        
        if count == 1 
            fprintf('Receive the first CSI and wait for the baseline time...\n');
            %fflush(stdout);
            continue;
        end

        if count == silentPktRange(1)
            fprintf('Enter into baseline time...\n');
            %fflush(stdout);
            continue;
        end

        if count == silentPktRange(2)
            varSilent = var(csiSubc(silentPktRange(1):silentPktRange(2)));
            fprintf('Begin to detect...\n');
            fprintf('1 : An intruder, 0 : Safe\n');
            %fflush(stdout);
            continue;
        end

        if count > silentPktRange(2) & mod(count - silentPktRange(2), stepLength) == 0
            if(SNThresRatio * varSilent < var(csiSubc(count - stepLength:count)))
                signalsome=[0 1];
% 				if(shownFlag == 0)
%                         clear h;
%                         h=com.test.Hello;
%                         h.showHello;
%                         shownFlag = 1;
%                 end
				fprintf('1\n');
                %fflush(stdout);
            else
                signalsome=[1 0];
%                 if(shownFlag == 1)
%                         h.closeDialog;
%                         shownFlag = 0;
%                 end
                fprintf('0\n');
                %fflush(stdout);
            end
            continue;
        end

    end
end
ret = ret(1:count);

%% Close file
fclose(f);
end
