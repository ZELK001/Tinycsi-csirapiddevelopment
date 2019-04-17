function ret=KNN(K,traindata,testdata,windowsize,profilesize)
 %%下面开始KNN算法。
 %求测试数据和类中每个profile数据的DTW距离 
len=length(traindata);
count=1;
distance=zeros(2,profilesize);
len

for i=1:len
    if mod(i, windowsize) == 0
        distance(1,count)=GetDTWDist(traindata(1,i-windowsize+1:i),testdata);
        distance(2,count)=traindata(2,i-windowsize+1);
        count=count+1;
    end
end
% count
% distance
tmp=1;
label_ma=1;
%选择排序法，只找出最小的前K个数据,对数据和标号都进行排序
for i=1:K
   ma=distance(1,i);
   for j=i+1:count-1
     if distance(1,j)<ma
        ma=distance(1,j);
        label_ma=distance(2,j);
        tmp=j;
     end
   end
   distance(1,tmp)=distance(1,i);  %排数据
   distance(1,i)=ma;
   
   distance(2,tmp)=distance(2,i);        %排标号，主要使用标号
   distance(2,i)=label_ma;
end
% 
% distance
% %冒泡排序
% for i=1:K
%     for j=1:count-1-i
%         if distance(1,j+1)<distance(1,j)
%             temp=distance(1,j);
%             distance(1,j)=distance(1,j+1);
%             distance(1,j+1)=temp;
%             temp_label=distance(2,j);
%             distance(2,j)=distance(2,j+1);
%             distance(2,j+1)=temp_label;
%         end
%     end
% end
distance

cls1=0; %统计类1中距离测试数据最近的个数
cls2=0;  %类2中距离测试数据最近的个数
cls3=0;

for i=1:K
   if distance(1,i)<1
      if distance(2,i)==1
         fprintf('属于riot类\n'); 
      elseif distance(2,i)==2
         fprintf('属于palm类\n'); 
      elseif distance(2,i)==3
         fprintf('属于book类\n'); 
      end
      break;
   end    
   if distance(2,i)==1
     cls1=cls1+1;
   elseif distance(2,i)==2
     cls2=cls2+1;
   elseif distance(2,i)==3
     cls3=cls3+1;
   end
end
cls1
cls2
cls3
result=0;
if cls1>cls2 && cls1>cls3  
     fprintf('属于riot类\n'); 
     result=1;
elseif cls2>cls1&&cls2>cls3
     fprintf('属于palm类\n'); 
     result=2;
elseif cls3>cls1&&cls3>cls2
     fprintf('属于book类\n'); 
     result=3;
end
ret=result;
end