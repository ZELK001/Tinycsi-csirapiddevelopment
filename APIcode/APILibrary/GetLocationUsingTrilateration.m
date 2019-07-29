function [locx,locy] =GetLocationUsingTrilateration(xa,ya,da,xb,yb,db,xc,yc,dc)
%  Reference node A£¨xa,ya£©,B(xb,yb),C(xc,yc)
%  Location node D(locx,locy),The distances to these three points are da,db,dc
% £¨locx£¬locy): Calculated position coordinates of location node D
%
syms x y 
f1 = '2*x*(xa-xc)+xc^2-xa^2+2*y*(ya-yc)+yc^2-ya^2=dc^2-da^2';
f2 = '2*x*(xb-xc)+xc^2-xb^2+2*y*(yb-yc)+yc^2-yb^2=dc^2-db^2';

[xx,yy] = solve(f1,f2,x,y); 
px = eval(xx); 
py = eval(yy);  
locx = px;
locy = py;