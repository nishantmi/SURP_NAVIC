% Code for tracking GPS signals

%% Load raw data
fileID = fopen('gioveAandB_short.bin', 'r');
raw_data = fread(fileID, 'int8');

%% Setting up parameters
svnum = 22;%input('Enter the satellite number you want to track: ');
codeStart = 15042;%input('Enter starting point of CA code detected after acquisition: ');
fc = 4128460;%input('Enter the frequency of carrier signal detected after acquisition: ');
%fcBasis = 4128460;
fcBasis = fc;
fs = 16367600;
ts = 1/fs;
ms  = 1;
Len = ms*fs/1000;
nn = [0:Len-1];
ca_freq = 1023000.0;
codeFreqBasis = ca_freq;
codeLength = 1023;
remCodePhase = 0.0;     %residual code phase in chips
remCarrPhase = 0.0;
earlyLateSpace = 0.5;

% Summation interval
PDIcode = 0;%.0001;
dllNoiseBandwidth = 5;
dllDampingRatio = 0.7;
% Calculate filter coefficient values
[tau1code, tau2code] = calcLoopCoef(dllNoiseBandwidth,dllDampingRatio, 1.0);

% Summation interval
PDIcarr = 0;%.0001;
pllNoiseBandwidth = 25;
pllDampingRatio = 0.7;
% Calculate filter coefficient values
[tau1carr, tau2carr] = calcLoopCoef(pllNoiseBandwidth, pllDampingRatio, 0.25);

%code tracking loop parameters
oldCodeNco   = 0.0;
oldCodeError = 0.0;

%carrier/Costas loop parameters
oldCarrNco   = 0.0;
oldCarrError = 0.0;

%% Code and Carrier Tracking loops
indDat = 1 ;
%Read data from the point where the CA code starts
readStart = codeStart;
%Generate CA code and adjust it to easily generate early and late codes
CAcode = codegen(svnum);
CAcode = [CAcode(1023) CAcode CAcode];                         %To generate late and early codes

trackingData = zeros(20, 10);
ind = 1;
while true                             %Loop to run through the whole data
     %Read in appropriate number of samples and exit if enough samples not
     %read
     %Len = 2^14;
     Len = ceil((codeLength - remCodePhase)/(ca_freq/fs));
     data = raw_data(readStart: min([readStart + Len - 1, length(raw_data)])); %Read 1ms long data from the point where CA code starts
     if length(data) < Len
         break
     end
     data = data';
     readStart = readStart + Len;
     %Code frequency is a variable now
     
     %Define early, prompt and late codes
     %Early
     tcode = (remCodePhase - earlyLateSpace):(ca_freq/fs):((Len-1)*(ca_freq/fs)+remCodePhase - earlyLateSpace);
     tcode2 = ceil(tcode)+1;
     earlyCode = CAcode(tcode2);
     
     %Late
     tcode = (remCodePhase + earlyLateSpace):(ca_freq/fs):((Len-1)*(ca_freq/fs)+remCodePhase + earlyLateSpace);
     tcode2 = ceil(tcode)+1;
     lateCode = CAcode(tcode2);
     
     %Prompt
     tcode = (remCodePhase):(ca_freq/fs):((Len-1)*(ca_freq/fs)+remCodePhase);
     tcode2 = ceil(tcode)+1;
     promptCode = CAcode(tcode2);
     
     remCodePhase = (tcode(Len) + ca_freq/fs) - 1023.0;
     
     %Generate carrier frequency signals
     time    = (0:Len) ./ fs;
            
     % Get the argument to sin/cos functions
     trigarg = ((fc * 2.0 * pi) .* time) + remCarrPhase;
     remCarrPhase = rem(trigarg(Len+1), (2 * pi));
            
     % Finally compute the signal to mix the collected data to bandband
     carrCos = cos(trigarg(1:Len));
     carrSin = sin(trigarg(1:Len));
     %Generate I_P, Q_P, etc
     % First mix to baseband
     qBasebandSignal = carrCos .* data;
     iBasebandSignal = carrSin .* data;

     % Now get early, late, and prompt values for each
     I_E = earlyCode  .* iBasebandSignal;
     I_E = sum(I_E(1:end));
     Q_E = earlyCode  .* qBasebandSignal;
     Q_E = sum(Q_E(1:end));
     I_P = promptCode .* iBasebandSignal;
     I_P = sum(I_P(1:end));
     Q_P = promptCode .* qBasebandSignal;
     Q_P = sum(Q_P(1:end));
     I_L = lateCode   .* iBasebandSignal;
     I_L = sum(I_L(1:end));
     Q_L = lateCode   .* qBasebandSignal;
     Q_L = sum(Q_L(1:end));
     %Update Carrier PLL
     % Implement carrier loop discriminator (phase detector)
     carrError = atan(Q_P / I_P) / (2.0 * pi);
            
     % Implement carrier loop filter and generate NCO command
     carrNco = oldCarrNco + (tau2carr/tau1carr) * (carrError - oldCarrError) + carrError * (PDIcarr/tau1carr);
     oldCarrNco   = carrNco;
     oldCarrError = carrError;

     % Modify carrier freq based on NCO command
     fc = fcBasis + carrNco;
     
     %Update Code PLL
     codeError = (sqrt(I_E * I_E + Q_E * Q_E) - sqrt(I_L * I_L + Q_L * Q_L)) / ...
                (sqrt(I_E * I_E + Q_E * Q_E) + sqrt(I_L * I_L + Q_L * Q_L));
            
     % Implement code loop filter and generate NCO command
     codeNco = oldCodeNco + (tau2code/tau1code) * ...
                (codeError - oldCodeError) + codeError * (PDIcode/tau1code);
     oldCodeNco   = codeNco;
     oldCodeError = codeError;
            
     % Modify code freq based on NCO command
     ca_freq = codeFreqBasis - codeNco;
     
     trackingData(ind, 1) = fc;
     trackingData(ind, 2) = I_P;
     trackingData(ind, 3) = Q_P;
     trackingData(ind, 4) = I_E;
     trackingData(ind, 5) = Q_E;
     trackingData(ind, 6) = I_L;
     trackingData(ind, 7) = Q_L;
     trackingData(ind, 8) = carrNco;
     trackingData(ind, 9) = codeError;
     trackingData(ind, 10) = codeNco;
     ind = ind + 1;
end

figure 
%plot((0:ind-2)*ts,trackingData(1:ind-1,1));
plot((0:ind-2)*ts*Len,trackingData(1: ind-1,2));
%plot((0:ind-2)*ts*Len,trackingData(1: ind-1,8));
%plot(trackingData(:,2), trackingData(:,3));
grid on