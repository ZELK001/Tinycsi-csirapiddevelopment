function result=DataInterpolation(x,y,xi,method)
%x,y:Interpolation node
%xi: Interpolated node
%method: 'nearest','linear','spline','cubic'
result=interp1(x,y,xi,method);
end