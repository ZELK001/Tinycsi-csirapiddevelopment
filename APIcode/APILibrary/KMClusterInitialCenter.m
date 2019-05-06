function center = KMClusterInitialCenter(X,K) 
%Selection of initial center
        N = size(X,2);
        rnd_Idx = randperm(N);  
        center = X(:,rnd_Idx(1:K));  
end