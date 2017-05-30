function get_speaker_spectrogram(speaker, stimDur, stimMinFreq, stimMaxFreq, portID, configFile)
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

% TODO:
% 1) Want to change inputs to make it more foolproof. Arguments that are
% likely to be forgotten should be required inputs: e.g., signal
% conditioner gain, distance, and angle. Perhaps not only that, but also to
% ensure that users don't lazily reuse input parameters from the last call,
% actually prompt the user for command-line input for these parameters
% (especially since they're not onerous to type).

% 2) For the other (many) parameters that are less likely to change, put
% them in a configuration file (like a MATLAB-evaluable text file) and have
% them read in. 

%% Parse inputs into stimulus and DAQ parameters, and, where possible, validate hardware:

sigCondGain = input('Please enter the gain on any signal conditioners being used in the current setup. If no signal conditioners are being used, please enter "1".'); % requiring user input for this because it's easy to forget to update
distance = input('Please enter the distance between the microphone cap and the speaker in millimeters.'); % requiring user input for this because it's easy to forget to update
angle = input('Please enter the angle between the long axis of the microphone and axis normal to the speaker diaphragm in degrees.'); % requiring user input for this because it's easy to forget to update

% Define default settings:
Defaults.PreStimDuration.val = 1;
Defaults.PreStimDuration.units = 'seconds';
Defaults.PostStimDuration.val = 1;
Defaults.PostStimDuration.units = 'seconds';
Defaults.Microphone = 'unknown';
Defaults.SignalConditioner = 'unknown';
Defaults.DAQDeviceDriver = 'nidaq';
Defaults.DAQChannel = 10;
Defaults.DAQTgtSampleRate.val = 150000;
Defaults.DAQTgtSampleRate.units = 'samples per second';
Defaults.SerialBaudRate = 9600;
requiredFields = fieldnames(Defaults);

% Load settings specified in config file:
fid = fopen(configFile);
content = fscanf(fid, '%c');
eval(content);

% Validate that config file includes required settings; if not, throw a warning and use defaults
for i = 1:length(requiredFields)
    if ~isfield(Recording, requiredFields{i}) % If a field is missing entirely from the loaded condig structure...
        if isfield(Defaults.(requiredFields{i}), 'val') % ... and if the missing field is supposed to have separate value and units sub-fields...
            Recording.(requiredFields{i}).val = Defaults.(requiredFields{i}).val;
            Recording.(requiredFields{i}).units = Defaults.(requiredFields{i}).units;
            defaultStr = strcat([num2str(Defaults.(requiredFields{i}).val), ' ', Defaults.(requiredFields{i}).units]);
        else % ... if the missing field doesn't have spearate value and unit sub-fields...
            Recording.(requiredFields{i}) = Defaults.(requiredFields{i});
            if ~ischar(Defaults.(requiredFields{i}))
                defaultStr = num2str(Defaults.(requiredFields{i}));
            else
                defaultStr = Defaults.(requiredFields{i});
            end
        end
        warning(strcat([requiredFields{i}, ' not specified in config file. Using default value of ', defaultStr]));     
    elseif isfield(Defaults.(requiredFields{i}), 'val') &&  ~isfield(Recording.(requiredFields{i}), 'val') % If a field consists of value and units sub-fields and is missing the value sub-field...
        Recording.(requiredFields{i}).val = Defaults.(requiredFields{i}).val;
        Recording.(requiredFields{i}).units = Defaults.(requiredFields{i}).units;
        defaultStr = strcat([num2str(Defaults(requiredFields{i}).val), ' ', Defaults(requiredFields{i}).units]);
        warning(strcat([requiredFields{i}, 'not specified in config file. Using default value of ', defaultStr]));
    elseif isfield(Defaults.(requiredFields{i}), 'units') && ~isfield(Recording.(requiredFields{i}), 'units') % If a field consists of value and units sub-fields and is missing the units sub-field... 
        Recording.(requiredFields{i}).units = 'unknown';
        warning(strcat(['Units not specified for ', requiredFields{i}, 'field. Units will be set to "unknown".']));
    end
end 


% Define default values for optional audio recording equipment parameters: 
spkr = 'unknown';
mic = 'unknown';
sigCond = 'unknown';
sigCondGain = [];

% Define default values for optional analog data acquisiton parameters:
chanID = 10;
desiredSampleRate = 150000; %samples/second
currDAQ = 'Dev1'; %Name for PCI-6221 in DAQ toolbox on the ephys computer 

% Define default values for optional Arduino communications parameters:
baudRate = 9600;

% Define default values for optional stimulus parameters:
preStimDur = 1; %seconds
postStimDur = 1; %seconds

% Define default values for physical microphone configuration with respect to speaker
distance = []; % should be in mm
angle = []; % should be in degrees


%{
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

if length(varargin) > 10
    distance = varargin{11};
end

if length(varargin) > 11
    angle = varargin{10};
end
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
pause(2); %wait for handshake to complete; this actually takes quite a long time

params = [preStimDur, stimDur, stimMinFreq, stimMaxFreq];

% Send stimulus information to Arduino
fprintf(arduino,'%s',strcat(num2str(preStimDur),'\n'));
disp(fscanf(arduino)); %Scan serial port for echo of pre-stim duration
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
startTimeTitle = datestr(now, 'yyyy-mm-dd HH:MM:SS');

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

%% Plot raw data from the analog input object:
Recording.Data = getdata(AI); % create a session object that will glue the recording data together with metadata critical for interpretation
hwinfo = daqhwinfo(AI);
delete(AI); clear AI;
figure; hold on;
seconds = [1:length(Recording.Data)]./trueSampleRate;
plot(seconds, Recording.Data)
ylabel('Voltage (V)');
xlabel('Time (s)');
yl = ylim;
rectangle('Position',[preStimDur yl(1) stimDur yl(2)-yl(1)], 'FaceColor', [.9 .9 1], 'EdgeColor', 'none');
set(gca,'children',flipud(get(gca,'children')));
titleStr = {strcat([num2str(floor(stimMinFreq/1000)), '-', num2str(floor(stimMaxFreq/1000)), ' kHz noise']);
            strcat(['acquired from speaker ', spkr, ' ', startTimeTitle]);
            strcat(['Mic: ', mic]);
            strcat(['Signal Conditioner: ', sigCond, ', Gain: x', num2str(sigCondGain)]);
            };
title(titleStr);
%savefig(dirName); % save figure % this function doesn't work for MATLAB v < 2013b

%% Write metadata into the same struct containing the data and save to secondary storage as a .mat to allow for easy analysis later
Recording.Speaker = spkr;
Recording.stimMinFreq.val = stimMinFreq;
Recording.stimMinFreq.units = 'Hz';
Recording.stimMaxFreq.val = stimMaxFreq;
Recording.stimMaxFreq.units = 'Hz';
Recording.stimDur.val = stimDur;
Recording.stimDur.units = 'seconds';
Recording.Distance.val = distance;
Recording.Distance.units = 'millimeters';
Recording.Angle.val = angle;
Recording.Angle.units = 'degrees';
Recording.trueSampleRate.val = trueSampleRate;
Recording.trueSampleRate.units = 'samples/second';

dirName = strcat(['spkr',rename(spkr), '_', num2str(floor(stimMinFreq/1000)),'-', num2str(floor(stimMaxFreq/1000)), 'kHz_noise_', startTime, '_mic', rename(mic), '_sigCond', rename(sigCond)]);
mkdir(dirName);
old = cd(dirName);
save(dirName, 'Recording');

%% Write data as .csv metadata as .txt for non-MATLAB analysis?

csvwrite(strcat([dirName, '.csv']), Recording.Data); 
allFieldNames = fieldnames(Recording);
metadataFieldNames = allFieldNames(cellfun(@(x) ~strcmp(x, 'Data'), allFieldNames)); % exclude data from the fields to write

%{
metadata = {{'Speaker', strcat(spkr,'\n')},
            {'MinStimFrequency', strcat(num2str(stimMinFreq),' Hz\n')},
            {'MaxStimFrequency', strcat(num2str(stimMaxFreq),' Hz\n')},
            {'StimDuration', strcat(num2str(stimDur), ' sec\n')},
            {'PreStimDuration', strcat(num2str(preStimDur), ' sec\n')},
            {'PostStimDuration', strcat(num2str(postStimDur), ' sec\n')},
            {'SampleRate', strcat(num2str(trueSampleRate), 'samples/sec \n')},
            {'Date', strcat(startTimeTitle, '\n')},
            %{'Driver', strcat(driver, '/n')},
            {'DAQdeviceName', strcat(hwinfo.DeviceName, '/n')},
            {'Channel', strcat(num2str(chanID),'\n')},
            {'Microphone', strcat(mic, '\n')},
            {'SignalConditioner', strcat(sigCond, '\n')},
            {'SignalConditionerGain', num2str(sigCondGain)},
            {'Distance', strcat([num2str(distance), ' mm\n'])},
            {'Angle', strcat([num2str(angle), ' deg'])}
            };
%}
    
fileID = fopen(strcat(dirName, '_metadata.txt'), 'wt');
%fprintf(fileID, strcat(['date:', startTime]));
%fprintf(fildID, strcat(['duration:', ]));
for i =1:length(metadataFieldNames)
    if isfield(Recording.(metadataFieldNames{i}), 'val')
        fprintf(fileID, strcat([metadataFieldNames{i},'.val: ', num2str(Recording.(metadataFieldNames{i}).val), '\n']));
        fprintf(fileID, strcat([metadataFieldNames{i},'.units: ', getfield(getfield(Recording, metadataFieldNames{i}), 'units'), '\n' ]));
    else
        val = getfield(Recording,metadataFieldNames{i});
        if isnumeric(val)
            val = num2str(val);
        end
        disp(metadataFieldNames{i});
        fprintf(fileID, strcat([metadataFieldNames{i},': ', val, '\n']));
    end
    %fprintf(fileID, strcat([metadata{i}{1},': ',metadata{i}{2}]));
end

fclose(fileID);


cd(old);
