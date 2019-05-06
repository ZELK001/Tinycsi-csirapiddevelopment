function [cid,nr,centers] = kmeans(x,k,nc) 
%x:data source
%k:Cluster number
%nc: K initial clustering centers
[n,d] = size(x); 
% Set cid as the display matrix of classification results 
cid = zeros(1,n); 
% Make this different to get the loop started. 
oldcid = ones(1,n); 
% The number in each cluster. 
nr = zeros(1,k); 
% Set up maximum number of iterations. 
maxgn=100; 
iter=1; 
%Calculate the distance from each data to the cluster center and select the smallest worthwhile location to cid
while iter < maxgn  
for i = 1:n 
 dist = sum((repmat(x(i,:),k,1)-nc).^2,2); 
 [m,ind] = min(dist);
 cid(i) = ind; 
end 
 for i = 1:k 
  ind = find(cid==i); 
  nc(i,:) = mean(x(ind,:)); 
  nr(i) = length(ind); 
 end 
  iter = iter + 1; 
end 

 % Now check each observation to see if the error can be minimized some more. 
 % Loop through all points. 
   maxiter = 2;
   iter = 1; 
   move = 1; 
   while iter < maxiter & move ~= 0 
     move = 0; 
     %Judge all the data again to find the best clustering result 
     for i = 1:n 
        dist = sum((repmat(x(i,:),k,1)-nc).^2,2); 
        r = cid(i); 
        dadj = nr./(nr+1).*dist';
        [m,ind] = min(dadj); 
            if ind ~= r
                   cid(i) = ind;
                   ic = find(cid == ind);%Recalculate the cluster center that adjusts the current category
                    nc(ind,:) = mean(x(ic,:)); 
                   move = 1; 
              end 
       end 
         iter = iter+1; 
    end 
    centers = nc; 
     if move == 0 
         disp('No points were moved after the initial clustering procedure.') 
      else 
        disp('Some points were moved after the initial clustering procedure.') 
     end
end