function removeNoise(filename)

%data preprcessing with hample->PCA->butterworth->diff->middle filtter
%this function is used just for observing the effect of different denoising
%methods

%Author: Yuxiang Lin
%Date: 8_4_2017

pcstream=2;
shownSubcarrier=20;

csi_trace = read_bf_file(filename);
len = length(csi_trace);
ant = 1;
startPkt = 1;
lastPkt = len;

for i = 1:lastPkt-startPkt
    csi_entry = csi_trace{i+startPkt};
    csi = get_scaled_csi(csi_entry);
    for subc = 1:30
        amplitudeArray(subc,i) = (abs(csi(1,ant,subc)));
    end
end

amplitudeArrayShown=amplitudeArray(shownSubcarrier,:);
figure(1)
m = mean(amplitudeArrayShown(~isinf(amplitudeArrayShown)));
plot(amplitudeArrayShown - m, 'b.-');
axis([1 1200 -15 15]);

%hample fittering
for subc = 1:30
    hampelResult(subc,:) = hampel(amplitudeArray(subc,:));
end
hampelResultShown=hampelResult(shownSubcarrier,:);
figure(2)
mHampel = mean(hampelResultShown(~isinf(hampelResultShown)));
plot(hampelResultShown - mHampel, 'b.-');
axis([1 1200 -15 15]);



%PCA denoising
hampelResultforPCA=hampelResult';
[coeff,score,latent]=princomp(hampelResultforPCA);
len2=length(score);
score2=zeros(len2,30);
score2(:,pcstream:30)=score(:,pcstream:30);
PCAResult=(score2*coeff)';
PCAResultShown=PCAResult(shownSubcarrier,:);
figure(3)
mPCA = mean(PCAResultShown(~isinf(PCAResultShown)));
plot(PCAResultShown - mPCA, 'b.-');
axis([1 1200 -15 15]);

%butterworth low passing fitter
fs=20; %sampling rate
fc=5;  %stopping frequency
order=4; 
[b,a]=butter(order,2*fc/fs);
for subc = 1:30
    butterworthResult(subc,:) = filter(b,a,PCAResult(subc,:));
end
butterworthResultShown=butterworthResult(shownSubcarrier,:);
figure(4)
mButterworth = mean(butterworthResultShown(~isinf(butterworthResultShown)));
plot(butterworthResultShown - mButterworth, 'b.-');
axis([1 1200 -15 15]);

%one-order differece
for subc = 1:30
    diffResult(subc,:) = diff(butterworthResult(subc,:));
end
diffResultShown=diffResult(shownSubcarrier,:);
figure(5)
mDiff = mean(diffResultShown(~isinf(diffResultShown)));
plot(diffResultShown - mDiff, 'b.-');
axis([1 1200 -15 15]);

%5-order middle fittering
for subc = 1:30
    middleFitResult(subc,:) = medfilt1(diffResult(subc,:),5);
end
middleFitResultShown=middleFitResult(shownSubcarrier,:);
figure(6)
mMiddle = mean(middleFitResultShown(~isinf(middleFitResultShown)));
plot(middleFitResultShown - mMiddle, 'b.-');
axis([1 1200 -15 15]);