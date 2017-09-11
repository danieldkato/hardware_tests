function digitalTriggeredAudioNoise(settings)

%% Read in settings

% define some filter parameters:
sampleRate = % get this from settings somehow 
stopAttn = % stopband attenuation; get this from settings; 60 seems to be a good value?
passAttn = % maximum allowable passband ripple amplitude; get from settings? 0.5 used in online example?
lowF = % 1 x 2 array giving pass band start frequency for each stim condition
highF = % 1 x 2 array giving pass band end frequency for each stim condition

% design filters for each stimulus:
filters = [];
for f = 1:2
    d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2', lowF(f)-250, lowF(f), highF(f), highF(f)+250, stopAttn, passAttn, stopAttn, sampleRate);
    filters(f) = design(d);
end


%% Set up digital input objects

%% Set up analog output objects:

%% Infinite while loop:

    %while condition signal has not yet been received, read for condition
    %signal:
    
        %generate white noise to be filtered:
        noise = wgn(%length, amplitude);
        
        % when condition signal has been recieved, generate appropriate
        % noise stimulus and raise flag that condition has been received
        stim = filter(filters(s),noise);
        
    %while trigger signal has not yet been received, read for trigger
    %signal:
    
        % when trigger signal has been received, send sitmulus to
        % soundcard; reset trigger signal and condition signal received to
        % 0

end