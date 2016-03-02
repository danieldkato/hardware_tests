%%
%Use this script in conjunction with an Arduino running record_speakers.ino
%to confirm that the speakers used for auditory stimulus presentation are
%actually outputting signals with the desired spectral content. The script
%will deliver trigger the Arduino to devlier a white noise stimulus,
%acquire the analog data, then do an fft on the data.

%This script is written for use on the electrophysiology computer, which
%currently (160121) runs MATLAB 2010a with Data Acquisition Toolbox ver.
%2.16.

%Stimulus design considerations: Mice can hear frequencies ranging from
%~2-80 kHz (see Koay, Heffner and Heffner 2002 for audiogram). 

%Hardware considerations: 
%Speaker: when selecting a speaker, take note of the nominal frequency
%response - many typical commercially available speakers only go up to 20
%kHz or so.

%Microphone: when selecting a mic, take note of the response chart -
%ideally it should be relatively flat [+/- 1-2 dB?] over the frequency
%range of interest.

%DAQ board: make sure that sampling rate is at least double the highest
%frequency of interest (i.e. Nyquist rate); the National Instruments
%PCI-6221 currently on the ephys computer can go up to 250 kS/s.

%%
%Define current test parameters:

%HW parameters:
currSpeaker = 'ACS340'; %enter unique model number
currMic = '378C01'; %enter unique model number
currSignalConditioner = '480E09'; %enter unique model number

currDAQ = 'Dev1'; %Name for PCI-6221 in DAQ toolbox on the ephys computer 
chanID = 8;
sampleRate = 150000;

portID = 'COM13';
baudRate = 9600;

%Stimulus parameters:
preStimDur = 1; %seconds
stimDur = 5; %seconds
stimMinFreq = 4000; %Hz
stimMaxFreq = 20000; %Hz

%%
%Define hardware options:

%1. Speakers:
%Each speaker is represented by a cell array with the format:
%   {speaker name, min freq(Hz), max freq(Hz)}
speakers = {
  {'Altec Lansing ACS340',30,20000}  
};

%2. Microphones:
%Each microphone is represented by a cell array with the format:
%   {mic name, frequency range (+/-1 db) min (Hz), frequency range (+/-1 db) max(Hz)}
mics = {
    {'PCB Piezoelectronics 378C01 1/4" free-field prepolarized mirophone and preamplifier',7,12500}
};

%3. Signal conditioners:
%Each signal conditioner is represented by a cell array with the format:
%   {signal conditioner name, frequency range (-5%) min (Hz), frequency range (-5%) max (Hz)}
signalConditioners = {
    {'PCB Peizoelectronics 480E09 ICP sensor signal conditioner',0.15,100000}
};

%4. DAQ boards - hardware info included in daqtoolbox


%%
%Check that hardware configuration is appropriate for desired stimulus,
%return any necessary warnings

%Evaluate speakers
spkrFound = 0;
spkrInd = 0;
currSpkrMin = 0;
currSpkrMax = 0;
for ii = 1:length(speakers)
    if ~isempty(strfind(speakers{ii}{1}, currSpeaker))
        spkrInd = ii;
        spkrFound = spkrFound + 1;
        currSpkrMin = speakers{ii}{2};
        currSpkrMax = speakers{ii}{3};
    end
end

if spkrFound == 0
    warning('Selected speaker specifications not found; desired stimulus may not be within range.');
elseif spkrFound > 1
    warning('Speaker specifications could not be determined because provided model number matches multiple devices; desired stimulus may not be within range.');
elseif spkrFound == 1
    if currSpkrMin > stimMinFreq 
        warning('Desired minimum stimulus frequency outside of speaker range.');
    end

    if currSpkrMax < stimMaxFreq
        warning('Desired maximum stimulus frequency outside of speaker range.');
    end
end


%Evaluate microphone
micFound = 0;
micInd = 0;
currMicMin = 0;
currMicMax = 0;
for jj = 1:length(mics)
    if ~isempty(strfind(mics{jj}{1}, currMic))
        micInd = jj;
        micFound = micFound + 1;
        currMicMin = mics{jj}{2};
        currMicMax = mics{jj}{3};
    end
end

if micFound == 0
    warning('Selected microphone specifications not found; desired stimulus may not be within range.');
elseif micFound > 1
    warning('Microphone specifications could not be determined because provided model number matches multiple devices; desired stimulus may not be within range.');
elseif micFound == 1
    if currMicMin > stimMinFreq 
        warning('Desired minimum stimulus frequency outside of microphone range.');
    end

    if currMicMax < stimMaxFreq
        warning('Desired maximum stimulus frequency outside of microphone range.');
    end
end


%Evaluate signal conditioner
scFound =0;
scInd = 0;
currSCMin = 0;
currSCMax = 0;
for kk = 1:length(signalConditioners)
    if ~isempty(strfind(signalConditioners{kk}{1}, currSignalConditioner))
        scInd = kk;
        scFound = scFound + 1;
        currSCMin = signalConditioners{kk}{2};
        currSCMax = signalConditioners{kk}{3};
        
        if currSCMin < stimMinFreq 
            warning('Desired minimum stimulus frequency outside of signal conditioner range.');
        end
        
        if currSCMax > stimMaxFreq
            warning('Desired maximum stimulus frequency outside of signal conditioner range.');
        end
    end
end

if scFound == 0
    warning('Selected signal conditioner specifications not found; desired stimulus may not be within range.');
elseif scFound > 1
    warning('Signal conditioner specifications could not be determined because provided model number matches multiple devices; desired stimulus may not be within range.');
elseif scFound == 1
    if currSCMin > stimMinFreq 
        warning('Desired minimum stimulus frequency outside of signal conditioner range.');
    end

    if currSCMax < stimMaxFreq
        warning('Desired maximum stimulus frequency outside of signal conditioner range.');
    end
end


AI = analoginput('nidaq', currDAQ);
AI.InputType = 'SingleEnded';
maxSampleRate = daqhwinfo(AI,'MaxSampleRate');
if maxSampleRate < stimMaxFreq/2
    warning('DAQ board max sampling rate is less than Nyquist rate for desired stimulus.');
end

%%
%Configure analog input object:
chan = addchannel(AI, chanID);
AI.Channel.InputRange = [-10 10];
AI.SampleRate = sampleRate;
Fs = sampleRate;
AI.SamplesPerTrigger = ( (stimDur-1) * sampleRate );
AI.TriggerType = 'Manual';
blocksize = AI.SamplesPerTrigger;

%Create and open serial communication object:
arduino = serial(portID, 'BaudRate', baudRate);
fopen(arduino);
pause(3); %wait for handshake to complete

%Send stimulus information to Arduino
fprintf(arduino,'%s',strcat(num2str(stimDur),'\n'));
disp(fscanf(arduino)); %Scan serial port for echo of stim duration
pause(.1);
fprintf(arduino,'%s',strcat(num2str(stimMinFreq),'\n'));
disp(fscanf(arduino)); %Scan serial port for echo of min frequency
pause(.1);
fprintf(arduino,'%s',strcat(num2str(stimMaxFreq),'\n'));
disp(fscanf(arduino)); %Scan serial port for echo of max frequency


%Pause for pre-stimulus period:
pause(preStimDur);

%Issue trigger to Arduino:
fprintf(arduino,'%s','1');

%Begin data acquisition:
start(AI);
disp('Starting data acquisition...');
trigger(AI);

%Wait for AI object to finish data acquisition:
wait(AI, stimDur+1);
disp('... data acquisition complete.');

%Close serial communication object:
fclose(arduino);

%Get the data from the analog input object:
data = getdata(AI);
%csvwrite('micData', data);

%Plot raw data to make sure signal looks reasonable
figure;
seconds = [1:length(data)]./sampleRate;
plot(seconds, data);
title('Raw data');
xlabel('Time (s)');


%{
%Calculate fft:
xfft = abs(fft(data));

%Avoid taking the log of 0.
index = find(xfft == 0);
xfft(index) = 1e-17;

%Convert to decibels:
mag = 20*log10(xfft);
mag = mag(1:floor(blocksize/2));
f = (0:length(mag)-1)*Fs/blocksize;
f = f(:);

%Plot fft:
figure;
plot(f,mag);
grid on
ylabel('Magnitude (dB)');
xlabel('Frequency (Hz)');
speakerName = speakers{spkrInd}{1};
micName = mics{micInd}{1};
scName = signalConditioners{scInd}{1};
titleStr = strcat(['Frequency components of ', speakerName, ', ', num2str(stimMinFreq),'-',num2str(stimMaxFreq), ' Hz white noise' ]);
title(titleStr);
legendStr = strcat([micName, ' with ', scName]);
legend(legendStr);


%Create spectrogram:
%s = spectrogram(data);
%spectrogram(data, 'yaxis');
spectrogram(data, 128, 120);
titleStr2 = strcat(['Spectrogram of ', speakerName, ', ', num2str(stimMinFreq),'-',num2str(stimMaxFreq), ' Hz white noise' ]);
title(titleStr2);
%}

%Clean up:
delete(AI);
clear AI

disp('Done');


