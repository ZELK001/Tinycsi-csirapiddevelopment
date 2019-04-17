function re=Openfile(filename)
global f;
f = fopen(filename,'rb');
if (f < 0)
    error('Couldn''t open file %s',filename);
end
end