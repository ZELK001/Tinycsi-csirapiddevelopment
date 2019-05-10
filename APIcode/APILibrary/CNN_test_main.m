layer_c1_num=20;
layer_s1_num=20;
layer_f1_num=100;
layer_output_num=10;
yita=0.01;
bias_c1=(2*rand(1,20)-ones(1,20))/sqrt(20);
bias_f1=(2*rand(1,100)-ones(1,100))/sqrt(20);
[kernel_c1,kernel_f1]=init_kernel(layer_c1_num,layer_f1_num);
pooling_a=ones(2,2)/4;
weight_f1=(2*rand(20,100)-ones(20,100))/sqrt(20);
weight_output=(2*rand(100,10)-ones(100,10))/sqrt(100);

for iter=1:20
for n=1:20
    for m=0:9
        train_data=imread(strcat(num2str(m),'_',num2str(n),'.bmp'));
        train_data=double(train_data);

        for k=1:layer_c1_num
            state_c1(:,:,k)=convolution(train_data,kernel_c1(:,:,k));
          
            state_c1(:,:,k)=tanh(state_c1(:,:,k)+bias_c1(1,k));
          
            state_s1(:,:,k)=pooling(state_c1(:,:,k),pooling_a);
        end
    
        [state_f1_pre,state_f1_temp]=convolution_f1(state_s1,kernel_f1,weight_f1);
      
        for nn=1:layer_f1_num
            state_f1(1,nn)=tanh(state_f1_pre(:,:,nn)+bias_f1(1,nn));
        end
       
        for nn=1:layer_output_num
            output(1,nn)=exp(state_f1*weight_output(:,nn))/sum(exp(state_f1*weight_output));
        end
  
        Error_cost=-output(1,m+1);
        [kernel_c1,kernel_f1,weight_f1,weight_output,bias_c1,bias_f1]=CNN_upweight(yita,Error_cost,m,train_data,...
                                                                                                state_c1,state_s1,...
                                                                                                state_f1,state_f1_temp,...
                                                                                                output,...
                                                                                                kernel_c1,kernel_f1,weight_f1,weight_output,bias_c1,bias_f1);
    end    
end
end
count=0;
for n=1:20
    for m=0:9
        
        train_data=imread(strcat(num2str(m),'_',num2str(n),'.bmp'));
        train_data=double(train_data);
  
        for k=1:layer_c1_num
            state_c1(:,:,k)=convolution(train_data,kernel_c1(:,:,k));
          
            state_c1(:,:,k)=tanh(state_c1(:,:,k)+bias_c1(1,k));
           
            state_s1(:,:,k)=pooling(state_c1(:,:,k),pooling_a);
        end
      
        [state_f1_pre,state_f1_temp]=convolution_f1(state_s1,kernel_f1,weight_f1);
        
        for nn=1:layer_f1_num
            state_f1(1,nn)=tanh(state_f1_pre(:,:,nn)+bias_f1(1,nn));
        end
       
        for nn=1:layer_output_num
            output(1,nn)=exp(state_f1*weight_output(:,nn))/sum(exp(state_f1*weight_output));
        end
        [p,classify]=max(output);
        if (classify==m+1)
            count=count+1;
        end
    end
end