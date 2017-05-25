function recordAudio(duration, device, chanID, varargin)
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
    addOptional(p, 'SampleRate', defaultSampleRate);
    addOptional(p, 'Driver', defaultDriver);
    addOptional(p, 'Mic', defaultMic);
    addOptional(p, 'SignalConditioner', defaultSignalConditioner);
    addOptional(p, 'SignalConditionerGain', defaultSignalConditionerGain);
    
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
    AI.SamplesPerTrigger = duration * AI.SampleRate;
    AI.TriggerType = 'Manual';
    
    %% Acquire data
    start(AI);
    startTime = datestr(now, 'yymmdd_HH-MM-SS');
    trigger(AI);
    wait(AI, duration + 0.1);
    
    %% Save data to seconary storage
    data = getdata(AI);
    plot(data); % plot data to make sure it looks sensible
    dirName = strcat(['audio_recording_', startTime, '_',num2str(duration),'s_', num2str(sampleRate/1000), 'Hz']);
    mkdir(dirName);
    cd(dirName);
    filename = strcat(dirName, '.csv');
    csvwrite(filename, data);
    
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
