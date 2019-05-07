SERVER_PORT = 8099;
SensingServer.CloseSocket();

% 1. Initialization Configurations
Samplerate = 0.05;
Duration = 600;
SilentRange=[1,10];
Detectionwinlen=10;
% 2. Parse settings for the callback
global PS;
PS=struct();
PS.Samplerate=Samplerate;
PS.Duration=Duration;
PS.SilentRange=SilentRange;
PS.Detectionwinlen=Detectionwinlen;
PS.thres=0;
PS.ratio=5;

% 3. Create Sensing server with callback
sensingserver=SensingServer(SERVER_PORT,@MotionDetectionCallback);