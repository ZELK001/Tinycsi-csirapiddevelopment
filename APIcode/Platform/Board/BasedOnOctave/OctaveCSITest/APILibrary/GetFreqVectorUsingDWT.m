function result=GetFreqVectorUsingDWT(csidata,n,wname,targetdetail)
%DWT 来获得细节系数，其对微小变化敏感
[C,L]=wavedec(csidata,n,wname);
d1 = wrcoef('d',C,L,'db4',1); 
d2 = wrcoef('d',C,L,'db4',2); 
d3 = wrcoef('d',C,L,'db4',3); 
d4 = wrcoef('d',C,L,'db4',4); 
if targetdetail==4
result = d4;%只取d4
end