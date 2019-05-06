function dist = DTW(t,r)
% Dynamic time warping (DTW) is a typical optimization problem
% Its essence is a method to measure the similarity of two time series with different lengths
n = size(t,1);
m = size(r,1);
% Frame matching distance matrix
d = zeros(n,m);
for i = 1:n
    for j = 1:m
        d(i,j) = sum((t(i,:)-r(j,:)).^2);
    end
end
% Cumulative distance matrix
D = ones(n,m) * realmax;
D(1,1) = d(1,1);
% dynamic programming
for i = 2:n
    for j = 1:m
        D1 = D(i-1,j);
        if j>1
            D2 = D(i-1,j-1);
        else
            D2 = realmax;
        end
        if j>2
            D3 = D(i-1,j-2);
        else
            D3 = realmax;
        end
        D(i,j) = d(i,j) + min([D1,D2,D3]);
    end
end
dist = D(n,m);