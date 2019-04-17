function result=RemoveNoiseWithWavelet(sub, ant, startPkt,lastPkt)

%Wavelet denoising for CSI (combined with hample fitter)
%filename:file of the raw CSI data
%sub: subcarrier number([1,30])
%ant:antenna number([1,3])
%startPkt:startPkt packet
%lastPkt:lastPkt packet

%Author: Bingji Li
%Date: 2018_6_12

csi_trace = read_bf_file(filename);
len = length(csi_trace);
if nargin == 1
    pcstream = 2;
    sub=20;
    ant = 1;
    startPkt = 1;
    lastPkt = len;
elseif nargin == 2
    sub=20;
    ant = 1;
    startPkt = 1;
    lastPkt = len;
elseif nargin == 3
    ant=1;
    startPkt = 1;
    lastPkt = len;
elseif nargin == 4
    startPkt = 1;
    lastPkt = len; 
elseif nargin == 5 || nargin > 6
    error('Requires 1,2,3,4 or 6 input arguments.');
end

color_table = ['b','g','r','c','m','y','k','w'];
amplitudeArray = zeros(30,lastPkt-startPkt);

for i = 1:lastPkt-startPkt
    csi_entry = csi_trace{i+startPkt};
    csi = get_scaled_csi(csi_entry);
    for subc = 1:30
        amplitudeArray(subc,i) = (abs(csi(1,ant,subc)));
    end
end
%save('amplitude.mat','amplitudeArray');
%cov_ingredients=cov(amplitudeArray)
result=zeros(30,len-1);
for subc = 1:30
    hampelResult(subc,:) = hampel(amplitudeArray(subc,:));
    [C,L]=wavedec(hampelResult(subc,:),4,'db4');
    a4 = wrcoef('d',C,L,'db4',4);
    result(subc,:)=a4;
end

for subc = 1:30
    plot(result(subc,:),color_table(mod(subc,8)+1));
    hold on;
end
%axis([1 lastPkt-startPkt -15 15]);
xlabel('Packets Number');
ylabel('Amplitude');


selectOneSubcarrier=result(sub,:);
figure(10);
meanValue = mean(selectOneSubcarrier(~isinf(selectOneSubcarrier)));
disp('m:')
disp(meanValue)
plot(selectOneSubcarrier - meanValue, 'b.-');
%axis([1 lastPkt-startPkt -15 15]);
xlabel('Packets Number');
ylabel('Amplitude');
end