function SensingServer(handle,filename,trainortest,gesture)

thehandle=handle;
global fatherhandle;
gesturehandle=fatherhandle;
trainortest
gesture

addpath('../../../../toolScripts');
f = fopen(filename,'rb');
if (f < 0)
    error('Couldn''t open file %s',filename);
    return;
end
filename
count = 1;
broken_perm = 0;% Flag marking whether we've encountered a broken CSI yet
triangle = [1 3 6 9];
varSilent = 0;

% customized parameters

pauseTime = 0; % for real time purpose
subc = 15; % which subcarrier
SNThresRatio = 5; % the threshold of ratio between "nobody" environment and "intruder" environment
silentRange = [1,4]; % the time interval range we collect CSI in "nobody" environment as baseline
pingInterval = 0.05;
pingPktRate = 1;
windowDuration = 1; % window duration for judegement
stepDuration = 0.5; % 2 judegements for 1 second 
pktRate = 1 / pingInterval * pingPktRate; % the number of CSI matrixes in 1 second
silentPktRange = silentRange * pktRate; 
windowLength = windowDuration * pktRate;
stepLength = stepDuration * pktRate;


windowlen=100;
count_profile=1;
j=1;

% Process all entries in file
while 1
    field_len = fread(f,1,'uint16',0,'ieee-be');
    code = fread(f,1);

    if (code == 187)
        bytes = fread(f, field_len-1, 'uint8=>uint8');
        if(length(bytes) ~= field_len-1)
            % XXX
            fclose(f);
            return;
        end
    else %skip all other info
        fread(f,field_len-1);
        continue;
    end

    if (code == 187)
        count = count + 1;
        ret{count} = read_bfee(bytes);
        perm = ret{count}.perm;
        Nrx = ret{count}.Nrx;

        if Nrx ~= 1 % No permuting needed for only 1 antenna
            if sum(perm) ~= triangle(Nrx) % matrix does not contain default values
                if broken_perm == 0
                    broken_perm = 1;
                    fprintf('WARN ONCE: Found CSI (%s) with Nrx=%d and invalid perm=[%s]\n', filename, Nrx, int2str(perm));
                end
            else
                ret{count}.csi(:,perm(1:Nrx),:) = ret{count}.csi(:,1:Nrx,:);
            end
        end

        csi = get_scaled_csi(ret{count});
        csiSubc(count) = db(abs((csi(1,1,subc))));
        
        plot(thehandle.axes1,db(abs(squeeze(csi(1,1,:)).')));
        axis(thehandle.axes1,[0,30,0,30]);
        xlabel(thehandle.axes1,'Subcarrier','fontsize',12,'FontWeight','bold');
        ylabel(thehandle.axes1,'Amplitude','fontsize',12,'FontWeight','bold');
        title(thehandle.axes1,'All Subcarriers','FontWeight','bold');
        set(thehandle.axes1,'FontWeight','bold');
        
        plot(thehandle.axes2,csiSubc,'LineWidth',2);
        axis(thehandle.axes2,[floor(count/100)*100,floor(count/100)*100+100,0,20]);
        xlabel(thehandle.axes2,'Time','fontsize',12,'FontWeight','bold');
        ylabel(thehandle.axes2,'Amplitude','fontsize',12,'FontWeight','bold');
        %title(thehandle.axes2,strcat('One SubChannel:',num2str(15)));
        title(thehandle.axes2,'15th Subcarrier','FontWeight','bold');
        set(thehandle.axes2,'FontWeight','bold');
        
        
        set(thehandle.edit15,'string',num2str(csiSubc(count)));
         
         if count > 5 & mod(count - 5, stepLength) == 0
             set(thehandle.edit16,'string',num2str(var(csiSubc(count - stepLength:count))));
         end
        
      
        if count>200
        N=128;
        fs=100;
        n=0:N-1;
        y=fft(csiSubc,128);
        mag=db(abs(y));
        freq=n*fs/N;    
        plot(thehandle.axes4,freq,mag);
        axis(thehandle.axes4,[0,30,0,60]);
         %axis(thehandle.axes1,[0,30,0,35]);
        xlabel(thehandle.axes4,'Freq','fontsize',12,'FontWeight','bold');
        ylabel(thehandle.axes4,'Magnitude','fontsize',12,'FontWeight','bold');
        title(thehandle.axes4,'15th Subcarrier','FontWeight','bold');
        
        set(thehandle.axes4,'FontWeight','bold');
        end  
        drawnow;
        
        
        
        for sub=1:30
            CSI_measurements(sub,count) = db(abs(csi(1,1,sub)));
            if isinf(CSI_measurements(sub,count))
            CSI_measurements(sub,count)=CSI_measurements(sub,count-1);
            end
        end
        
      
        if mod(count,windowlen)==0
          
           for subc = 1:30
             CSI_final_hampel(subc,count-windowlen+1:count)=medfilt1(CSI_measurements(subc,count-windowlen+1:count),5);
           end
           
           fs=100; 
           fc=40;  
           order=4; 
           [b,a]=butter(order,2*fc/fs);
           for subc = 1:30
                butterworthResult(subc,count-windowlen+1:count) = filter(b,a,CSI_final_hampel(subc,count-windowlen+1:count));
           end
       
           for subc=1:30
              varSilent(subc) = var(butterworthResult(subc,silentPktRange(1):silentPktRange(2))); 
           end
           movementProfile(count-windowlen+1:count)=zeros(1,windowlen);
       
           if count > silentPktRange(2) & mod(count - silentPktRange(2), stepLength) == 0
               
               windowCSI=butterworthResult(:,count-windowlen+1:count);
               count_change=0;
               for subc=1:30
                  varNow(subc) = var(windowCSI(subc,:));
                  if(varNow(subc)>varSilent(subc))
                    count_change=count_change+1;
                  end
               end
               if count_change>16
                   movementProfile(count-windowlen+1:count)=mean(windowCSI,1);
                  fprintf('findone\n');
               end
               
               
              [C,L]=wavedec(movementProfile,4,'db4');
               d1 = wrcoef('d',C,L,'db4',1); 
               d2 = wrcoef('d',C,L,'db4',2); 
               d3 = wrcoef('d',C,L,'db4',3); 
               d4 = wrcoef('d',C,L,'db4',4); 
               movementProfile_final = d4;

               
              if trainortest==1 && gesture==1
                 movementData(1,j:j+windowlen-1)=d4(count-windowlen+1:count);
                 movementData(2,j:j+windowlen-1)=1;
                 j=j+windowlen;
                 count_profile=count_profile+1;
                 save('testdata_fist.mat','movementData');
               
               elseif trainortest==1 && gesture==2%
                 movementData(1,j:j+windowlen-1)=d4(count-windowlen+1:count);
                 movementData(2,j:j+windowlen-1)=2;
                 j=j+windowlen;
                 count_profile=count_profile+1;
                 save('testdata_palm.mat','movementData');
                
                elseif trainortest==1 && gesture==3
                 movementData(1,j:j+windowlen-1)=d4(count-windowlen+1:count);
                 movementData(2,j:j+windowlen-1)=3;
                 j=j+windowlen;
                 count_profile=count_profile+1;
                 save('testdata_book.mat','movementData');
              end
               
              if trainortest==2
                  traindata_riot=load('testdata_fist.mat');
                  traindata_palm=load('testdata_palm.mat');
                  traindata_book=load('testdata_book.mat');
                  traindata=[traindata_riot.movementData(:,1:500) traindata_palm.movementData(:,1:500) traindata_book.movementData(:,1:500)];
                  profilesize=ceil(length(traindata)/100);
                  result=KNN(6,traindata,d4(count-windowlen+1:count),100,profilesize);
                  if result==1
                      set(gesturehandle.edit2,'string','Fist');
                  elseif result==2
                      set(gesturehandle.edit2,'string','Palm');
                  else
                      set(gesturehandle.edit2,'string','Book');
                  end
              end
                
            continue;
           end
        end
    end
end

end