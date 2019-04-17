function result=MedianFilter(csidata,n)
middleFitResult = medfilt1(csidata,n);
result=middleFitResult;
end