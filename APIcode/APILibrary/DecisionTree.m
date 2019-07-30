function [node] =DecisionTree(data,feature,tag)
  type=mostType(data);
  [m,n]=size(data);
  node=struct('value','null','name','null','type','null','children',[]);
  temp_type=data(1,n);
  temp_b=true;
  for i=1:m
    if temp_type~=data(i,n)
      temp_b=false;
    end
  end

  if temp_b==true
    node.value=data(1,n);
    return;
  end

  if sum(feature)==0
    node.value=type;
    return;
  end
  feature_bestColumn=bestFeature(data);
  best_feature=getData();
  best_distinct=unique(best_feature);
  best_num=length(best_distinct);
  best_proc=zeros(best_num,2);
  best_proc(:,1)=best_distinct(:,1);
  for i=1:best_num
    Dv=[];
    Dv_index=1;
    bach_node=struct('value','null','name','null','type','null','children',[]);
    for j=1:m
      if best_proc(i,1)==data(j,feature_bestColumn)
        Dv(Dv_index,:)=data(j,:);
        Dv_index=Dv_index+1;
      end
    end
    if length(Dv)==0
      bach_node.value=type;
      bach_node.type=best_proc(i,1);
      bach_node.name=feature_bestColumn;
      node.children(i)=bach_node;
      return;
    else
      feature(feature_bestColumn)=0;
      bach_node=createTree(Dv,feature);
      bach_node.type=best_proc(i,1);
      bach_node.name=feature_bestColumn;
      node.children(i)=bach_node;
    end
  end
end