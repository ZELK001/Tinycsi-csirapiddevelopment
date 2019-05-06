function dist = DTW(t,r)
%Dynamic Time Warping 动态时间规整DTW是一个典型的优化问题
%它的本质是一种衡量两个长度不同的时间序列的相似度的方法
n = size(t,1);
m = size(r,1);
% 帧匹配距离矩阵
d = zeros(n,m);
for i = 1:n
    for j = 1:m
        d(i,j) = sum((t(i,:)-r(j,:)).^2);
    end
end
% 累积距离矩阵
D = ones(n,m) * realmax;
D(1,1) = d(1,1);
% 动态规划
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