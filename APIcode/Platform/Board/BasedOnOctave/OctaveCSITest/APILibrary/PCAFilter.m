function result=PCAFilter(csidata,pcstream)
ResultforPCA=csidata';
[coeff,score,latent]=princomp(ResultforPCA);
len2=length(score);
score2=zeros(len2,30);
score2(:,pcstream:30)=score(:,pcstream:30);
PCAResult=(score2*coeff)';
result=PCAResult;
end