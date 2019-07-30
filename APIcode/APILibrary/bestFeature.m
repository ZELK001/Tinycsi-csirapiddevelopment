function [column] = bestFeature(data)
  [m,n]=size(data);
  featureSize=n-1;
  gain_proc=zeros(featureSize,2);
  entropy=getEntropy(data);
  for i=1:featureSize
    gain_proc(i,1)=i;
    gain_proc(i,2)=getGain(entropy,data,i);
  end
  for i=1:featureSize
    if gain_proc(i,2)==max(gain_proc(:,2))
      column=i;
      break;
    end
  end
end