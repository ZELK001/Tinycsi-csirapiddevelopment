function [best_Label best_Center best_ind label] = KMCluster(P,K,method)
%%%%-----------------------------------------------------------------------
%   Version 1.0 
%   Author: feitengli@foxmail.com   from DUT
%   CreateTime: 2012-11-29
%%%------------------------------------------------------------------------
%KM   K-Means Clustering or K-Medoids Clustering
%    P is an d-by-N data matrix 
%    K is the clustering number
%    method = KMeans    :K-Means Clustering
%           = KMedoids  :K-Medoids Clustering
%References£º
%        1.The Elements of Statistical Learning 2nd Chapter14.3.6&&14.3.10
%%%%-----------------------------------------------------------------------
[d N] = size(P); 
nitial = max(20,N/(5*K));
label = zeros(max_Initial,N);
center = zeros(d,K,max_Initial);
C = zeros(1,N);
for initial_Case = 1:max_Initial
    pointK = KMClusterInitialCenter(P,K);    
    iter = 0;
    max_iter = 1e+3;
    while iter < max_iter
        iter = iter+1;
        for i = 1:N
            dert = repmat(P(:,i),1,K)-pointK;
            distK = sqrt(diag(dert'*dert));
            [~,j] = min(distK);
            C(i) = j;
        end     
        xK_ = zeros(d,K);
        for i = 1:K
            Pi = P(:,find(C==i));
            Nk = size(Pi,2);    
            switch lower(method)
                case 'kmeans'  
                    xK_(:,i) = sum(Pi,2)/Nk;
                case 'kmedoids'
                    Dx2 = zeros(1,Nk);
                    for t=1:Nk
                       dx = Pi - Pi(:,t)*ones(1,Nk);
                       Dx2(t) = sum(sqrt(sum(dx.*dx,1)),2);
                    end
                    [~,min_ind] = min(Dx2);
                    xK_(:,i) = Pi(:,min_ind);
                otherwise
                    errordlg('kmeans-OR-kmedoids','MATLAB error');
            end
        end
        %The only difference between K-Means K-Medoids is the way to select the center point.
        if xK_==pointK   % & iter>50
            label(initial_Case,:) = C;
            center(:,:,initial_Case) = xK_;
            break
        end
        pointK = xK_;
    end
    if iter == max_iter
         label(initial_Case,:) = C;
         center(:,:,initial_Case) = xK_;
    end  
end
 dist_N = zeros(max_Initial,K);
 for initial_Case=1:max_Initial     
     for k=1:K
         tem = find(label(initial_Case,:)==k);
         dx = P(:,tem)-center(:,k,initial_Case)*ones(1,size(tem,2));
         dxk = sqrt(sum(dx.*dx,1));
         dist_N(initial_Case,k) = sum(dxk);       
         
     end     
 end
 %Classification error for max_Initial secondary initialization center point
 %Taking the Least Error Case as the Final Classification
 dist_N_sum = sum(dist_N,2);
 [~,best_ind] = min(dist_N_sum);
 best_Label = label(best_ind,:); 
 best_Center = center(:,:,best_ind);
end