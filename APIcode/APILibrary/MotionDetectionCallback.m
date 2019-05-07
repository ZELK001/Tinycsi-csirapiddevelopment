function DetectionResult=IntrusionDetectionCallback(context,action,CSIdata)

global PS;
Amplitude=GetAmplitude(1,1,15,CSIdata);
PreprocessData=ButterworthFilter(Amplitude,20,5,4,'low');

% 1. Get the silent environment threshold
if  action == context.CALLBACK_INIT
   PS.thres=GetVar(Preprocess); 
   
% 2. Detect intrusion in real time
else if  action == context.CALLBACK_WINDOWDATA
   Result=GetVar(PreprocessData);
        if(Result>(PS.thres*PS.ratio))
          print("Intrusion!");
		else
		  PS.thres=Result;
		end
end

end