function [gain] = getGain(entropy,data,column)
  [m,n]=size(data);
  feature=data(:,column);
  feature_distinct=unique(feature);
  feature_num=length(feature_distinct);
  feature_proc=zeros(feature_num,2);
  feature_proc(:,1)=feature_distinct(:,1);
  f_entropy=0;
  for i=1:feature_num
    feature_data=[];
    feature_proc(:,2)=0;
    feature_row=1;
    for j=1:m
      if feature_proc(i,1)==data(j,column)
        feature_proc(i,2)=feature_proc(i,2)+1;
      end
      if feature_distinct(i,1)==data(j,column)
        feature_data(feature_row,:)=data(j,:);
        feature_row=feature_row+1;
      end
    end
    f_entropy=f_entropy+feature_proc(i,2)/m*getEntropy(feature_data);
  end
  gain=entropy-f_entropy;
end