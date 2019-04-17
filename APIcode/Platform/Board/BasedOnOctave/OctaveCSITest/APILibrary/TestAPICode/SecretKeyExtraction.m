function SecretKeyExtraction(Alicefilename,Bobfilename)
Alice_csi_trace = read_bf_file(Alicefilename);
Bob_csi_trace = read_bf_file(Bobfilename);
Alice_len = length(Alice_csi_trace);
Bob_len = length(Bob_csi_trace);
count=1;
for j = 1:Alice_len
    csi_entry = Alice_csi_trace{j};
    csi = get_scaled_csi(csi_entry);
    %计算幅值
    Alice_Amplitude(count,:) = db(abs((csi(1,1,:))));
    count=count+1;
end

count=1;
for j = 1:Bob_len
    csi_entry = Bob_csi_trace{j};
    csi = get_scaled_csi(csi_entry);
    %计算幅值
    Bob_Amplitude(count,:) = db(abs((csi(1,1,:))));
    count=count+1;
end
%根据先导包(probe packet)的个数达到200个以后，可以看做进入互易性稳定时期
for j=200:Alice_len
   %计算增益补充量（complement），用来调整两个设备端的振幅使其更加相似
   for i=1:30
       temp(j,i)=Alice_Amplitude(j,i)-Bob_Amplitude(j,i);
   end
end
%求得30*M矩阵的每行的平均值，即每个子载波的平均值来作为补充量
uf=mean(temp,2);
%对于Alice进行补偿
for j=200:Alice_len
   %计算增益补充量（complement），用来调整两个设备端的振幅使其更加相似
   for i=1:30
       Alice_Result(j,i)=Alice_Amplitude(j,i)-uf(i);
   end
end
%对于矫正后的Alice_Result进行量化(Quantization)和编码(Encode)
%量化不太懂，没做，直接做的编码
Threshold=30;%阈值自己设定的，也可以取平均值之类的
SecretKeyLencount=1
for j=200:Alice_len
   %计算增益补充量（complement），用来调整两个设备端的振幅使其更加相似
   for i=1:30
       %当修正过的振幅大于Threshold时编码为1，否则为0
       if Alice_Result(j,i)>Threshold
           Alice_SecretKey(SecretKeyLencount)=1;
       else 
           Alice_SecretKey(SecretKeyLencount)=0;
       end
       SecretKeyLencount=SecretKeyLencount+1;
   end
end
end
