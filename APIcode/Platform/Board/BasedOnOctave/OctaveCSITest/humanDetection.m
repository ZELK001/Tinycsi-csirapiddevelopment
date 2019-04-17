function ret = humanDetection(filename)
% Detect the intruder using CSI signal in real time 
%
% **Note**:  
% 1. An fifo file should be created at first using mkfifo  
% 2. You may re-MEX \toolScripts\read_bfee.c  
% 
% filename: the name of fifo file
error(nargchk(1,1,nargin));

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
subc = 10; % which subcarrier
SNThresRatio = 3; % the threshold of ratio between "nobody" environment and "intruder" environment
silentRange = [1,5]; % the time interval range we collect CSI in "nobody" environment as baseline
pingInterval = 0.05;
pingPktRate = 1;
windowDuration = 1; % window duration for judegement
stepDuration = 0.5; % 2 judegements for 1 second 
pktRate = 1 / pingInterval * pingPktRate; % the number of CSI matrixes in 1 second
silentPktRange = silentRange * pktRate; 
windowLength = windowDuration * pktRate;
stepLength = stepDuration * pktRate;


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

        if count == 1 
            fprintf('Receive the first CSI and wait for the baseline time...\n');
            fflush(stdout);
            continue;
        end

        if count == silentPktRange(1)
            fprintf('Enter into baseline time...\n');
            fflush(stdout);
            continue;
        end

        if count == silentPktRange(2)
            varSilent = var(csiSubc(silentPktRange(1):silentPktRange(2)));
            fprintf('Begin to detect...\n');
            fprintf('1 : An intruder, 0 : Safe\n');
            fflush(stdout);
            continue;
        end

        if count > silentPktRange(2) & mod(count - silentPktRange(2), stepLength) == 0
            if(SNThresRatio * varSilent < var(csiSubc(count - stepLength:count)))
                fprintf('1\n');
                fflush(stdout);
            else
                fprintf('0\n');
                fflush(stdout);
            end
            continue;
        end

    end
end
ret = ret(1:count);

%% Close file
fclose(f);
end
