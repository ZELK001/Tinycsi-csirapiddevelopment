
function [indmin,indmax]=PickUpExtremum(x)
%  Pick up the extremum ;
%
% x: the input series;
% 
% indmin: the index of extre min extremum
% indmin: the index of extre max extremum
d=diff(x);
n=length(d);
d1=d(1:n-1);
d2=d(2:n);
indmin=find(d1.*d2<0 & d1<0)+1;
indmax=find(d1.*d2<0 & d1>0)+1;