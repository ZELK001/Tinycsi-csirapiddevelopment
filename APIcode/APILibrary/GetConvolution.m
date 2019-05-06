function result=GetConvolution(u,v)
%Get a subsection of the convolution
w = conv(u,v);
result=w;
end