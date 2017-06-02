function get_speaker_spectrogram(speaker, stimDur, stimMinFreq, stimMaxFreq, portID, configFile)

% DOCUMENTATION TABLE OF CONTENTS:
% I. SYNTAX
% II. OVERVIEW
% III. REQUIREMENTS
% IV. INPUTS
% V. OUTPUTS
% VI. INSTRUCTIONS

% I. SYNTAX:
% get_speaker_spectrogram(speaker, stimDur, stimMinFreq, stimMaxFeq, portID, configFile)


% II. OVERVIEW: 
% Use this function to record sound from a speaker generating band-limited
% noise. This host-PC-side code instructs an Arduino to generate a
% fixed-duration band-limited noise stimulus and records, saves, and plots
% concurrent analog input from a microphone connected to a data acquisition
% device. 


% III. REQUIREMENTS:
% A) Hardware
    % 1) A host PC configured for use with suitable data acquisition hardware 
    % (e.g. a National Instruments PCI data acquisition card connected to a BNC
    % Connector block, etc.). 

    % 2) Suitable audio recording equipment (microphone, preconditioner, etc.).
    % For more detailed hardware requirements, see the README available at
    % https://github.com/danieldkato/hardware_tests/tree/master/test_speakers/get_speaker_spectrogram.

    % 3) An Arduino microcontroller connected to a two-terminal analog speaker. 
    
% B) Software
    % 1) MATLAB data acquisition toolbox. Must be a version
    % supporting MATLAB's legacy DAQ interface, (will have to be
    % updated in future versions to session-based interface).

    % 2) The Arduino sketch `get_speaker_spectrogram.ino`, available at 
    % https://github.com/danieldkato/hardware_tests/blob/master/test_speakers/get_speaker_spectrogram/get_speaker_spectrogram.ino. 
    % THE BAUD RATE SPECIFIED IN THIS SKETCH MUST MATCH THE BAUD RATE
    % SPECIFIED IN THE CONFIG FILE PASSED AS INPUT TO THIS FUNCTION (see
    % inputs below).

    % 3) Hardware class definitions, databases, and validation functions,
    % all available at:
    % https://github.com/danieldkato/hardware_tests/tree/master/test_speakers/get_speaker_spectrogram
    % These include:
        % Speaker.m
        % Microphone.m
        % SignalConditioner.m
        
        % Speakers.mat
        % Mics.mat
        % SignalConditioners.mat
        
        % validateSpeakers.m
        % validateMic.m
        % validateSignalConditioner.m
    
% *IMPORTANT WARNING*: As of 7/20/16, when running on hs05bruno8 ('504 -
% physiology'), this script often raises an out-of-memory error and crashes
% when it tries to call spectrogram(). If collecting data on hs05bruno8, it
% may be necessary to analyze the data offline on another computer.


% IV. INPUTS:
% 1) speaker - string specifying the model number of the speaker. If this
% matches the model number of one of the speakers defined in Speakers.mat,
% then get_speaker_spectrogram will perform validation on the speaker to
% ensure that the speaker's specifications support the requested stimulus.
% If they do not, the function will throw a warning.

% 2) stimDur - stimulus duration, in seconds

% 3) stimMinFreq - lower bound of stimulus noise frequency band, in Hz 

% 4) stimMaxFreq - upper bound of stimulus noise frequency band, in Hz 

% 5) portID - string specifying the port connected to the Arduino microcontroller

% 6) configFile - path to a MATLAB-evaluable .txt file defining a structure
% called `Recording`, which specifies various parameters necessary for
% setting up data acquisition. While this function supplies default values
% for all required fields, it is best practice to use a config file that
% defines the following:
%
%   Recording.PreStimDuration.val % numeric value specifying duration of pre-stimulus period, in seconds
%   Recording.PostStimDuration.val % numeric value specifying duration of post-stimulus period, in seconds
%   Recording.Microphone % string specifying the model number of the microphone
%   Recording.SignalConditioner % string specifying the model number of the signal conditioner
%   Recording.DAQDeviceDriver % string specifying the data acquisition driver to use for the current recording session
%   Recording.DAQDeviceID % string specifying the data acquisition device ID to use for the current recording session
%   Recording.DAQChannel % integer value specifying the data acquisition channel to use for the current recording session
%   Recording.DAQTgtSampleRate.val % numeric value specifying the desired data acquisition rate in samples per second
%   Recording.SerialBaudRate % integer value specifying the baud rate of the host-PC-to-Arduino serial connection 
%   Recording.InputRangeMin.val % minimum of data acquisition analog input range, in volts. See your DAQ device's documentation for supported input ranges  
%   Recording.InputRangeMax.val % minimum of data acquisition analog input range, in volts. See your DAQ device's documentation for supported input ranges  

% For an example config file, see:
% https://github.com/danieldkato/hardware_tests/blob/master/test_speakers/get_speaker_spectrogram/config.txt

% Note that it is also possible to specify alternative units for pre- and
% post-stim duration, sample rate, and input range min and max, but this is
% not recommended as this function assumes inputs are specified in the
% units stated above.


% V. OUTPUTS
% This function has no formal return, but saves the following to secondary
% storage: 

% 1) A .mat file containing a structure called `Recordings`, which includes
% all analog input data as well as stimulus and data acquisition metadata

% 2) A .csv containing the analog input data (for any subsequent non-MATLAB analysis)

% 3) A .txt containing stimulus and data acquisition metadata (for any subsequent non-MATLAB analysis)


% VI: INSTRUCTIONS: 
% 1) Connect the host PC to the Arduino microcontroller. Optionally, to 
% confirm that the Arduino, the speaker, and all connections are working,
% upload the sketch `test_speakers.ino` (available at https://github.com/danieldkato/hardware_tests/tree/master/test_speakers/test_speakers)
% to the Arduino. The speaker should emit a short burst of white noise.

% 2) Connect the audio recording equipment to the host PC. This will
% probably entail connecting a combined microphone/preamplifier to a signal
% preconditioner, which in turn connects via BNC cable to a connector block, 
% which in turn connects into a PCI data acquisition board. 

% 3) Position the microphone appropriately in front of the speaker. In most
% cases, this will mean positioning the long axis of the microphone
% perpendicular to the speaker diaphragm and less than 5 mm away.

% 4) Ensure that the serial port specified in `portID` matches the serial 
% port connected to the Arduino microcontroller.

% 5) Ensure that the baud rate specified in `get_speaker_spectrogram.ino`
% matches the baud rate specified in the config file or the default value
% of 9600.

% 6) Upload `get_speaker_spectrogram.ino` to the Arduino microcontroller

% 7) Ensure that the DAQ board and channel number specified by
% `currDAQ` and `chanID`, respectively, match the DAQ board and channel
% connected to the recording equipment. 

% 8) Run this script.

% 9) When prompted, enter the following numeric inputs in the command line:

%   - The product of all gains on any signal conditioners or amplifiers in
%   line with the microphone. For example, if there is a signal conditioner
%   with a gain of 10 in line with another amplifier with a gain of 50, set
%   this to 500. If there is no signal conditioner, enter `1`. (we need this to recover the amplitude of the actual voltage signal put out by the microphone, which, along with the microphone spec sheet, can be used to infer the actual sound pressure level on the mic in Pa)

%   - The distance of the microphone from the speakers, in millimeters

%   - Then angle of incidence of the sound on the microphone - i.e., the
%   angle between the long axis of the microphone and the axis
%   perpendicular to the speaker diaphragm - in degrees. 


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
% 1) Should ultimately update this to use session-based, rather than
% legacy DAQ interface (when we update MATLAB on ephys computer)

% 2) Should ultimately update this so that figures are saved (when we
% update to a version of MATLAB that has savefig)

% 3) Should rename - this function doesn't generate spectrograms anymore,
% it just records

% 4) Add support for single-ended vs. differential input

% 5) Should add a log of all warnings to metadata

% Last updated DDK 2017-06-01


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
Defaults.InputRangeMin.val = -10;
Defaults.InputRangeMin.units = 'volts';
Defaults.InputRangeMax.val = 10;
Defaults.InputRangeMax.units = 'volts';
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


%% Configure analog input object:
AI = analoginput(Recording.DAQDeviceDriver, Recording.DAQDeviceID);
AI.InputType = 'SingleEnded';
maxSampleRate = daqhwinfo(AI,'MaxSampleRate');
if maxSampleRate < stimMaxFreq/2
    warning('DAQ board max sampling rate is less than Nyquist rate for desired stimulus.');
end

chan = addchannel(AI, Recording.DAQChannel);
AI.Channel.InputRange = [Recording.InputRangeMin.val Recording.InputRangeMax.val];
disp(Recording.DAQTgtSampleRate);
AI.SampleRate = Recording.DAQTgtSampleRate.val;
trueSampleRate = double(AI.SampleRate); %MATLAB may not use the exact sample rate specified
Fs = trueSampleRate;
AI.SamplesPerTrigger = ceil((Recording.PreStimDuration.val + stimDur + Recording.PostStimDuration.val) * trueSampleRate);
AI.TriggerType = 'Manual';


%% Send stimulus parameters to Arduino 

% Create and open serial connection with Arduino:
arduino = serial(portID, 'BaudRate', Recording.SerialBaudRate);
fopen(arduino);
pause(2); %wait for handshake to complete; this actually takes quite a long time

params = [Recording.PreStimDuration.val, stimDur, stimMinFreq, stimMaxFreq];

% Send stimulus information to Arduino
for p = 1:length(params)
    fprintf(arduino,'%s',strcat(num2str(params(p)),'\n'));
    disp(fscanf(arduino)); %Scan serial port for echo of pre-stim duration
    pause(.1);    
end


%% Acquire analog data:
startTime = datestr(now, 'yymmdd_HH-MM-SS');
startTimeTitle = datestr(now, 'yyyy-mm-dd HH:MM:SS');

% Issue stimulus start trigger to Arduino:
disp('Starting data acquisition...');
fprintf(arduino,'%s','GO\n');

% Begin data acquisition:
start(AI);
trigger(AI);

%Wait for AI object to finish data acquisition:
wait(AI, Recording.PreStimDuration.val + stimDur + Recording.PostStimDuration.val + .1);
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
xlim([0 max(seconds)]);
rectangle('Position',[Recording.PreStimDuration.val yl(1) stimDur yl(2)-yl(1)], 'FaceColor', [.9 .9 1], 'EdgeColor', 'none');
set(gca,'children',flipud(get(gca,'children')));
titleStr = {strcat(['Speaker ', speaker, ' delivering ',num2str(floor(stimMinFreq/1000)), '-', num2str(floor(stimMaxFreq/1000)), ' kHz band-limited noise']);
            strcat(['acquired ', startTimeTitle]);
            strcat(['Mic: ', Recording.Microphone]);
            strcat(['Signal Conditioner: ', Recording.SignalConditioner, ', Gain: x', num2str(sigCondGain)]);
            };
title(titleStr);
%savefig(dirName); % save figure % this function doesn't work for MATLAB v < 2013b


%% Write metadata into the same struct containing the data and save to secondary storage as a .mat to allow for easy analysis later
Recording.Speaker = speaker;
Recording.StimMinFreq.val = stimMinFreq;
Recording.StimMinFreq.units = 'Hz';
Recording.StimMaxFreq.val = stimMaxFreq;
Recording.StimMaxFreq.units = 'Hz';
Recording.StimDur.val = stimDur;
Recording.StimDur.units = 'seconds';
Recording.SignalConditionerGain = sigCondGain;
Recording.Distance.val = distance;
Recording.Distance.units = 'millimeters';
Recording.Angle.val = angle;
Recording.Angle.units = 'degrees';
Recording.TrueSampleRate.val = trueSampleRate;
Recording.TrueSampleRate.units = 'samples/second';

dirName = strcat(['spkr',rename(speaker), '_', num2str(floor(stimMinFreq/1000)),'-', num2str(floor(stimMaxFreq/1000)), 'kHz_noise_', startTime, '_mic', rename(Recording.Microphone), '_sigCond', rename(Recording.SignalConditioner)]);
mkdir(dirName);
old = cd(dirName);
save(dirName, 'Recording');


%% Write data as .csv metadata as .txt for non-MATLAB analysis?

csvwrite(strcat([dirName, '.csv']), Recording.Data); 
allFieldNames = fieldnames(Recording);
metadataFieldNames = allFieldNames(cellfun(@(x) ~strcmp(x, 'Data'), allFieldNames)); % exclude data from the fields to write
 
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
        fprintf(fileID, strcat([metadataFieldNames{i},': ', val, '\n']));
    end
    %fprintf(fileID, strcat([metadata{i}{1},': ',metadata{i}{2}]));
end
fclose(fileID);
cd(old);
