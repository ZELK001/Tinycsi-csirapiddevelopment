function [res] = mostType(data)
  [m,n]=size(data);
  res_distinct = unique(data(:,n));
  res_proc = zeros(length(res_distinct),2);
  res_proc(:,1)=res_distinct(:,1);
  for i=1:length(res_distinct)
    for j=1:m
      if res_proc(i,1)==data(j,n)
        res_proc(i,2)=res_proc(i,2)+1;
      end
    end
  end
  for i=1:length(res_distinct)
    if res_proc(i,2)==max(res_proc(:,2))
      res=res_proc(i,1);
      break;
    end
  end
end