function sort_pop(a)
n=length(a);
for i=1:3
    for j=1:n-i
        if a(j+1)<a(j)
            temp=a(j);
            a(j)=a(j+1);
            a(j+1)=temp;
        end
    end
end
end