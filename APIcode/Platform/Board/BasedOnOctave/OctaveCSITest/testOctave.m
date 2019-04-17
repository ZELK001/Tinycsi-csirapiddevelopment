f = fopen('testtesttest','w+');
a = 1.245;
b = 1234.3;
fprintf(f,'%f\n',a);
fprintf(f,'%f\n',b);
fclose(f);
