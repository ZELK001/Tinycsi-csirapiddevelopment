% my_angle.m
% This function is written for calculating the angle between two complex number ;
% -----------------------INPUT-----------------------
% a,b: the two complex number;
% -----------------------OUTPUT-----------------------
% angle: the angle between two complex number
function angle=my_angle(a,b)
angle = acos(dot(a,b)/(norm(a)*norm(b)));