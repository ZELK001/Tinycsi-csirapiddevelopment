function [Delta,Psi,P,I] = HMM_Viterbi(A,B,Pi,O)
A_size = size(A);
O_size = size(O);
N = A_size(1,1);
M = A_size(1,2);
K = O_size(1,1);

Delta = zeros();
for i = 1:M
    Delta(i,1) = Pi(i) * B(i,O(1,1));
end
Delta_j = zeros();
Psi = zeros();
Psi(:,1) = 0;
for t = 2:K
    for j = 1:N
        for i = 1:M
            Delta_j(i,1) = Delta(i,t-1) * A(i,j) * B(j,O(t,1));
        end
        [max_delta_j,psi] = max(Delta_j); %Find the maximum probability
        Psi(j,t) = psi;
        Delta(j,t) = max_delta_j; 
    end
end

[P_better,psi_k] = max(Delta(:,K));
P = P_better; % Optimal Path Probability
I = zeros();
I(K,1) = psi_k;
for t = K-1:-1:1
    I(t,1) = Psi(I(t+1,1),t+1); %Optimal Path Obtained by Path Backtracking
end
end