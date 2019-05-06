function result=KNNClassifier(K,traindata,testdata,windowsize,traintag)
% KNN Classifier
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
for i=1:K
   ma=distance(1,i);
   for j=i+1:count-1
     if distance(1,j)<ma
        ma=distance(1,j);
        label_ma=distance(2,j);
        tmp=j;
     end
   end
   distance(1,tmp)=distance(1,i);  
   distance(1,i)=ma;
   
   distance(2,tmp)=distance(2,i);        
   distance(2,i)=label_ma;
end
cls=zeros(1,traintag);
cls1=0; 
cls2=0; 
cls3=0;
for i=1:K
   if distance(1,i)<1
      result=distance(2,i);
      break;
   end    
   if distance(2,i)==i
     cls(i)=cls(i)+1;
   end
end
[m,p]=max(cls);
if m>1
    result=cls(p);
end
end
