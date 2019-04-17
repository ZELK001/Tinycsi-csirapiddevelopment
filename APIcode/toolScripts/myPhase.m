csi_trace = read_bf_file('../../data/2017_6_13_dat/2.csi');
oldPurifiedPhase = zeros(30,1);
for j = 1:length(csi_trace)
csi_entry_1 = csi_trace{j};
csi_1 = get_scaled_csi(csi_entry_1);
csi_1_1 = squeeze(csi_1(1,2,:));
originalPhase = phase(csi_1_1);
average = mean(originalPhase);
difference = (originalPhase(30)-originalPhase(1))/29; 
purifiedPhase = zeros(30,1);
diffPurifiedPhase = zeros(30,1);
for i = 1:30
purifiedPhase(i) = originalPhase(i) - (difference*(i-15) + average);
end
if j > 1
diffPurifiedPhase = purifiedPhase - oldPurifiedPhase;
plot(diffPurifiedPhase);
axis([1,30,-2,2]);
hold on;
if mod(j, 20) == 0
% text(0,j/length(csi_trace)*max(diffPurifiedPhase),num2str(floor(j/20)));
text(0+j/20*0.3,1,num2str(floor(j/20)));
end
end
oldPurifiedPhase = purifiedPhase;
% plot(originalPhase);
% figure();
pause(0.01);
end