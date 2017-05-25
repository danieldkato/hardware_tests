function get_speaker_spectrogram(stimDur, stimMinFreq, stimMaxFreq, portID, varargin)
% get_speaker_spectrogram(stimDur, stimMinFreq, stimMaxFreq, portID)
% get_speaker_spectrogram(stimDur, stimMinFreq, stimMaxFreq, portID [, spkr, mic, sigCond, sigCondGain, chanID, desiredSampleRate, currDAQ, baudRate, preStimDur, postStimDur])

% Last updated DDK 2017-05-25

% OVERVIEW: 
% This script constitutes the desktop-side code for
% `get_speaker_spectrogram`, a program for generating a single white noise
% stimulus from an Arduino-controlled speaker, recording the output through
% a prepolarized microphone, then generating a spectrogram of the speaker
% output in MATLAB. Use this program in conjunction with
% `get_sepaker_spectrogram.ino` to assess how much power a potential
% stimulus speaker generates in the hearing range of mice.
%
%
% REQUIREMENTS:
% 1) A host PC configured for use with suitable data acquisition hardware 
% (e.g. a National Instruments PCI data acquisition card connected to a BNC
% Connector block, etc.). For more detailed hardware requirements, see the
% README available at https://github.com/danieldkato/hardware_tests/tree/master/test_speakers/get_speaker_spectrogram.
% 
% 2) Suitable audio recording equipment (microphone, preconditioner, etc.).
% For more detailed hardware requirements, see the README available at
% https://github.com/danieldkato/hardware_tests/tree/master/test_speakers/get_speaker_spectrogram.
%
% 3) An Arduino microcontroller connected to a two-terminal analog speaker.
% For detailed hardware requirements, see the documentation for the 
% corresponding Arduino sketch (described below) and 
% https://github.com/danieldkato/hardware_tests/tree/master/test_speakers/get_speaker_spectrogram. 
% 
% 3) MATLAB data acquisition toolbox ver 2.16 or above.
%
% 4) The Arduino sketch `get_speaker_spectrogram.ino`, available at 
% https://github.com/danieldkato/hardware_tests/blob/master/test_speakers/get_speaker_spectrogram/get_speaker_spectrogram.ino. 
% This sketch should be running concurrently on a connected Arduino microcontroller connected 
% to the host PC.
%
% 5) The baud rates specified in `get_speaker_spectrogram.m` and 
% `get_speaker_spectrogram.ino` must agree.
% 
% *IMPORTANT WARNING*: As of 7/20/16, when running on hs05bruno8 ('504 -
% physiology'), this script often raises an out-of-memory error and crashes
% when it tries to call spectrogram(). If collecting data on hs05bruno8, it
% may be necessary to analyze the data offline on another computer.
%
% 
% INPUTS:
% 1) stimDur - stimulus duration, in seconds
% 2) stimMinFreq - lower bound of stimulus noise frequency band, in Hz 
% 3) stimMaxFreq - upper bound of stimulus noise frequency band, in Hz 
% 4) portID - String specifying the port connected to the Arduino microcontroller
%
%
% INSTRUCTIONS: 
% 1) Connect the host PC to the Arduino microcontroller. Optionally, to 
% confirm that the Arduino, the speaker, and all connections are working,
% upload the sketch `test_speakers.ino` (available at https://github.com/danieldkato/hardware_tests/tree/master/test_speakers/test_speakers)
% to the Arduino. The speaker should emit a short burst of white noise.
%
% 2) Connect the audio recording equipment to the host PC (this will
% probably entail connecting a combined microphone/preamplifier to a signal
% preconditioner, which in turn connects via BNC cable to a connector block, 
% which in turn connects into a PCI data acquisition board. 
%
% 3) Position the microphone appropriately in front of the speaker. In most
% cases, this will mean positioning microphone perpendicular to the speaker
% diaphragm and less than inch away.
%
% 4) Ensure that the serial port specified in `portID` matches the serial 
% port connected to the Arduino microcontroller.
%
% 5) Upload the corresponding `get_speaker_spectrogram.ino` 
% to the Arduino microcontroller
%
% 6) Ensure that the DAQ board and channel number specified by
% `currDAQ` and `chanID`, respectively, match the DAQ board and channel
% connected to the recording equipment. 
%
% 7) Specify the desired stimulus duration, minimum frequency and maximum
% frequency in this script. 
% 
% 8) Specify the model number of the speaker, microphone, and signal conditioner 
% to be used in the current recording session. 
%
% 9) Run this script.


% DESCRIPTION
% This script specifies the duration, minimum frequency and maximum
% frequency of a white noise stimulus to be emitted by an
% Arduino-controlled speaker. It also includes a library of specifications
% for different audio equipment, including speakers, microphones, and
% signal conditioners, and issues warnings if any of the hardware is
% incompatible with the desired stimulus parameters. 

% After evaluating the hardware, the script sends the stimulus parameters
% to the Arduino. Shortly before the speaker begins playing the stimulus, this
% script begins recording from the microphone for the duration of the
% stimulus. Once the stimulus duration elapses, the script ends the
% recording and generates a spectrogram of the recorded signal. 

%% Parse inputs into stimulus and DAQ parameters, and, where possible, validate hardware:

% Define default values for optional audio recording equipment parameters: 
spkr = 'unknown';
mic = 'unknown';
sigCond = 'unknown';
sigCondGain = 'unknown';

% Define default values for optional analog data acquisiton parameters:
chanID = 8;
desiredSampleRate = 150000; %samples/second
currDAQ = 'Dev1'; %Name for PCI-6221 in DAQ toolbox on the ephys computer 

% Define default values for optional Arduino communications parameters:
baudRate = 9600;

% Define default values for optional stimulus parameters:
preStimDur = 1; %seconds
postStimDur = 1; %seconds

% Parse optional parameters:
if ~isempty(varargin)
    spkr = varargin{1}; 
    validateSpeakers(varargin{1}, stimMinFreq, stimMaxFreq);
else
    warning('No speaker specified; skipping speaker validation. Requested stimulus frequencies may lie outside of speaker range.');
end

if length(varargin) > 1
    mic = varargin{2};
    validateMic(varargin{2}, stimMinFreq, stimMaxFreq);
else
    warning('No microphone specified; skipping microphone validation. Requested stimulus frequencies may lie outside of microphone range.');
end

if length(varargin) > 2
    sigCond = varargin{3};
    validateSignalConditioner(varargin{3}, stimMinFreq, stimMaxFreq);
else
    warning('No signal conditioner specified; skipping signal conditioner validation. Requested stimulus frequencies may lie outside of microphone range.');
end

if length(varargin) > 3
    sigCondGain = varargin{4};
end

if length(varargin) > 4
    chanID = varargin{5};
end

if length(varargin) > 5
    desiredSampleRate = varargin{6};
end

if length(varargin) > 6
    currDAQ = varargin{7};
end

if length(varargin) > 7
    baudRate = varargin{8};
end

if length(varargin) > 8
    preStimDur = varargin{9};
end

if length(varargin) > 9
    postStimDur = varargin{10};
end

%{
%HW parameters:
currSpeaker = 'Green'; %enter unique model number
currMic = '378C01'; %enter unique model number
currSignalConditioner = '480E09'; %enter unique model number
%}

%% Configure analog input object:
AI = analoginput('nidaq', currDAQ);
AI.InputType = 'SingleEnded';
maxSampleRate = daqhwinfo(AI,'MaxSampleRate');
if maxSampleRate < stimMaxFreq/2
    warning('DAQ board max sampling rate is less than Nyquist rate for desired stimulus.');
end

chan = addchannel(AI, chanID);
AI.Channel.InputRange = [-10 10];
AI.SampleRate = desiredSampleRate;
trueSampleRate = double(AI.SampleRate); %MATLAB may not use the exact sample rate specified
Fs = trueSampleRate;
AI.SamplesPerTrigger = (preStimDur + stimDur + postStimDur) * trueSampleRate;
AI.TriggerType = 'Manual';

%% Send stimulus parameters to Arduino 

% Create and open serial connection with Arduino:
arduino = serial(portID, 'BaudRate', baudRate);
fopen(arduino);
pause(1); %wait for handshake to complete; this actually takes quite a long time

% Send stimulus information to Arduino
fprintf(arduino,'%s',strcat(num2str(preStimDur),'\n'));
disp(fscanf(arduino)); %Scan serial port for echo of stim duration
pause(.1);
fprintf(arduino,'%s',strcat(num2str(stimDur),'\n'));
disp(fscanf(arduino)); %Scan serial port for echo of stim duration
pause(.1);
fprintf(arduino,'%s',strcat(num2str(stimMinFreq),'\n'));
disp(fscanf(arduino)); %Scan serial port for echo of min frequency
pause(.1);
fprintf(arduino,'%s',strcat(num2str(stimMaxFreq),'\n'));
disp(fscanf(arduino)); %Scan serial port for echo of max frequency

%% Acquire analog data:
startTime = datestr(now, 'yymmdd_HH-MM-SS');

% Issue stimulus start trigger to Arduino:
fprintf(arduino,'%s','1');

% Begin data acquisition:
start(AI);
disp('Starting data acquisition...');
trigger(AI);

%Wait for AI object to finish data acquisition:
wait(AI, preStimDur + stimDur + postStimDur + .1);
disp('... data acquisition complete.');

%Close serial communication with Arduino:
fclose(arduino);

%% Get, plot and save raw data from the analog input object:
data = getdata(AI);
delete(AI);
clear AI

dirName = strcat([rename(currSpeaker), '_', num2str(floor(stimMinFreq/1000)),'-', num2str(floor(stimMaxFreq/1000)), 'kHz_noise_', startTime, '_mic-', rename(currMic), '_sigCond-', rename(currSignalConditioner)]);
mkdir(dirName);
old = cd(dirName);
csvwrite(strcat([dirName, '.csv']), data); 

%Plot raw data to make sure signal looks reasonable
figure;
hold on;
seconds = [1:length(data)]./trueSampleRate;
plot(seconds, data);
title('Raw data');
xlabel('Time (s)');
yl = ylim;
rectangle('Position',[preStimDur yl(1) stimDur yl(2)-yl(1)], 'FaceColor', [.9 .9 1], 'EdgeColor', 'none');
set(gca,'children',flipud(get(gca,'children')));
savefig(dirName); % save figure

%% Write metadata
hwinfo = daqhwinfo(AI);
metadata = {{'Speaker', spkr},
            {'MinFrequency', strcat(num2str(stimMinFreq),' Hz')},
            {'MaxFrequency', strcat(num2str(stimMaxFreq),' Hz')},
            {'StimDuration', stract(num2str(stimDur), ' sec')},
            {'PreStimDuration', strcat(num2str(preStimDur), ' sec')},
            {'PostStimDuration', strcat(num2str(postStimDur), ' sec')},
            {'SampleRate', num2str(AI.SampleRate)},
            {'Date', startTime},
            {'Driver', driver},
            {'DAQdeviceName', hwinfo.DeviceName},
            {'Channel', num2str(chanID)},
            {'Microphone', mic},
            {'SignalConditioner', sigCond},
            {'SignalConditionerGain', num2str(scGain)}
            };
    
fileID = fopen(strcat(dirName, '_metadata.txt'), 'w');
%fprintf(fileID, strcat(['date:', startTime]));
%fprintf(fildID, strcat(['duration:', ]));
for i =1:length(metadata)
    fprintf(fileID, strcat([metadata{i}{1},': ',metadata{i}{2}]));
end

fclose(fileID);


cd(old);

%% 
%%{
%Calculate fft:
stimData = data(preStimDur*trueSampleRate:end);
xfft = abs(fft(stimData));

%Avoid taking the log of 0.
index = find(xfft == 0);
xfft(index) = 1e-17;

%Convert to decibels:
blocksize = stimDur * trueSampleRate;
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
%WARNING: Calling spectrogram on hs05bruno ('') has raised errors related
%to memory issues before. It may be necessary to actually the data offline
%on another computer.
if strcmp(getenv('computername'), 'HS05BRUNO8') == 0
    spectrogram(data, 128, 120, [], 'yaxis');
    titleStr2 = strcat(['Spectrogram of ', speakerName, ', ', num2str(stimMinFreq),'-',num2str(stimMaxFreq), ' Hz white noise' ]);
    title(titleStr2);
end 


disp('Done');


