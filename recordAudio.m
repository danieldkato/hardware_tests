function recordAudio(duration, device, chanID, varargin)
% recordAudio(duration, device, chanID)
% recordAudio(duration, device, chanID [, SampleRate, Driver, Mic, SignalConditioner, SignalConditionerGain])

    %% Parse inputs
    p = inputParser;
    defaultMic = 'unknown';
    defaultSignalConditioner = 'unknown';
    defaultSampleRate = 150000;
    defaultDriver = 'nidaq';
    defaultSignalConditionerGain = NaN;
    
    addRequired(p, 'duration');
    addRequired(p, 'device');
    addRequired(p, 'channel');
    addOptional(p, 'SampleRate', defaultSampleRate); % add optional positional argument
    addOptional(p, 'Driver', defaultDriver); % add optional positional argument
    addOptional(p, 'Mic', defaultMic); % add optional positional argument
    addOptional(p, 'SignalConditioner', defaultSignalConditioner); % add optional positional argument
    addOptional(p, 'SignalConditionerGain', defaultSignalConditionerGain); % add optional positional argument
    
    parse(p, duration, device, chanID, varargin{:});
    
    disp(p.Results);
    
    sampleRate = p.Results.SampleRate;
    driver = p.Results.Driver;
    mic = p.Results.Mic;
    sigCond = p.Results.SignalConditioner;
    scGain = p.Results.SignalConditionerGain;
    
    %% Set up analog input
    AI = analoginput(driver, device);
    AI.inputType = 'SingleEnded';
    chan = addchannel(AI, chanID);
    AI.Channel.InputRange = [-10 10];
    AI.SampleRate = sampleRate;
    trueSampleRate = double(AI.SampleRate);
    AI.SamplesPerTrigger = duration * AI.SampleRate;
    AI.TriggerType = 'Manual';
    
    %% Acquire data
    start(AI);
    startTime = datestr(now, 'yymmdd_HH-MM-SS');
    trigger(AI);
    wait(AI, duration + 0.1);
    
    %% Save data to secondary storage
    data = getdata(AI);
    dirName = strcat(['audio_recording_', startTime, '_',num2str(duration),'s_', num2str(sampleRate), 'samplesPerSec']);
    mkdir(dirName);
    cd(dirName);
    filename = strcat(dirName, '.csv');
    csvwrite(filename, data);
    
    %Plot raw data to make sure signal looks reasonable
    figure;
    hold on;
    seconds = [1:length(data)]./trueSampleRate;
    plot(seconds, data);
    title(strcat(['Audio recording ', starTime, ', ', num2str(sampleRate), ' samples/sec, mic: ', mic, ', signal conditioner: ', sigCond, ', gain:', num2str(scGain) ]));
    xlabel('Time (s)');
    ylabel('Volts (V)');
    savefig(dirName); % save figure
    
    %% Write metadata
    hwinfo = daqhwinfo(AI);
    metadata = {{'Date', startTime},
                {'SampleRate', num2str(AI.SampleRate)},
                {'Duration', num2str(duration)},
                {'Driver', driver},
                {'DAQdeviceName', hwinfo.DeviceName},
                {'Microphone', mic},
                {'SignalConditioner', sigCond},
                {'SignalConditionerGain', num2str(scGain)}
                };
    
    fileID = fopen(strcat('audio_recording_', startTime, '_metadata.txt'), 'w');
    %fprintf(fileID, strcat(['date:', startTime]));
    %fprintf(fildID, strcat(['duration:', ]));
    for i =1:length(metadata)
        fprintf(fileID, strcat([metadata{i}{1},': ',metadata{i}{2}]));
    end
    
    fclose(fileID);
