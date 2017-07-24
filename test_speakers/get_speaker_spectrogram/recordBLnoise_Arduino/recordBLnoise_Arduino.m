function recordBLnoise_Arduino(speaker, stimDur, stimMinFreq, stimMaxFreq, portID, configFile)

% DOCUMENTATION TABLE OF CONTENTS:
% I. SYNTAX
% II. OVERVIEW
% III. REQUIREMENTS
% IV. INPUTS
% V. OUTPUTS
% VI. INSTRUCTIONS


%% I. SYNTAX:
% get_speaker_spectrogram(speaker, stimDur, stimMinFreq, stimMaxFeq, portID, configFile)


%% II. OVERVIEW: 
% Use this function to record sound from a speaker generating band-limited
% noise. This host-PC-side code instructs an Arduino to generate a
% fixed-duration band-limited noise stimulus and records, saves, and plots
% concurrent analog input from a microphone connected to a data acquisition
% device. 


%% III. REQUIREMENTS:
% A) Hardware
%   1) A host PC configured for use analog-to-digital data acquisition
%      hardware compatible with MATLAB's data acquisition toolbox(e.g., a
%      National Instruments PCI data acquisition card connected to a BNC
%      Connector block). 

%   2) Audio recording equipment compatible with the analog-to-digital
%      data acquisition equipment specified in 1). This will most likely
%      include a prepolarized microphone, a preamplifier, and preconditioner. 
%      For more detailed hardware requirements, see the README available at
%      https://github.com/danieldkato/hardware_tests/tree/master/test_speak
%      ers/get_speaker_spectrogram.

%   3) An Arduino microcontroller connected to a two-terminal analog speaker. 
    
% B) Software
%   1) MATLAB data acquisition toolbox. Must be a version
%      supporting MATLAB's legacy DAQ interface, (will have to be
%      updated in future versions to session-based interface).

%    2) The Arduino sketch `get_speaker_spectrogram.ino`, available at 
%       https://github.com/danieldkato/hardware_tests/blob/master/test_speakers/get_speaker_spectrogram/get_speaker_spectrogram.ino. 
%       THE BAUD RATE SPECIFIED IN THIS SKETCH MUST MATCH THE BAUD RATE
%       SPECIFIED IN THE CONFIG FILE PASSED AS INPUT TO THIS FUNCTION (see
%       inputs below).

%    3) Hardware class definitions, databases, and validation functions,
%       all available at:
%       https://github.com/danieldkato/hardware_tests/tree/master/test_speakers/get_speaker_spectrogram
%       These include:
%           Speaker.m
%           Microphone.m
%           SignalConditioner.m
        
%           Speakers.mat
%           Mics.mat
%           SignalConditioners.mat

%           validateSpeakers.m
%           validateMic.m
%           validateSignalConditioner.m
        
%    4) struct2txt.m, available at https://github.com/danieldkato/utilities/blob/master/struct2txt.m
    
%    5) getSHA1.m, available at https://github.com/danieldkato/utilities/blob/master/getSHA1.m
    
% *IMPORTANT WARNING*: As of 7/20/16, when running on hs05bruno8 ('504 -
% physiology'), this script often raises an out-of-memory error and crashes
% when it tries to call spectrogram(). If collecting data on hs05bruno8, it
% may be necessary to analyze the data offline on another computer.


%% IV. INPUTS:
% 1) speaker - string specifying the model number of the speaker. If this
%    matches the model number of one of the speakers defined in Speakers.mat,
%    then get_speaker_spectrogram will perform validation on the speaker to
%    ensure that the speaker's specifications support the requested stimulus.
%    If they do not, the function will throw a warning.

% 2) stimDur - stimulus duration, in seconds

% 3) stimMinFreq - lower bound of stimulus noise frequency band, in Hz 

% 4) stimMaxFreq - upper bound of stimulus noise frequency band, in Hz 

% 5) portID - string specifying the port connected to the Arduino microcontroller

% 6) configFile - path to a MATLAB-evaluable .txt file defining a structure
%    called `Recording`, which specifies various parameters necessary for
%    setting up data acquisition. This struct must supply the following
%    fields: 

%       Recording.Arduino.Sketch.LocalPath - char array specifying the path of the main sketch to be run on the Arduino 
%       Recording.Arduino.Board - char array specifying the model of the board to which the sketch will be uploaded. This 
%                                 should have the syntax used by the Arduino command line interface. E.g., for an Arduino 
%                                 Uno, the value should be 'arduino:avr:uno'. For more detail, see the Arduino CLI documentation at 
%                                 https://github.com/arduino/Arduino/blob/master/build/shared/manpage.adoc

%    In addition, it is best practice to use a config file that defines the 
%    following fields, although this function will provide defaults if
%    needed:
%
%       Recording.PreStimDuration.val - numeric value specifying duration of pre-stimulus period, in seconds
%       Recording.PostStimDuration.val - numeric value specifying duration of post-stimulus period, in seconds
%       Recording.Microphone - string specifying the model number of the microphone
%       Recording.SignalConditioner - string specifying the model number of the signal conditioner
%       Recording.DAQDeviceDriver - string specifying the data acquisition driver to use for the current recording session
%       Recording.DAQDeviceID - string specifying the data acquisition device ID to use for the current recording session
%       Recording.DAQChannel - integer value specifying the data acquisition channel to use for the current recording session
%       Recording.DAQTgtSampleRate.val - numeric value specifying the desired data acquisition rate in samples per second
%       Recording.SerialBaudRate - integer value specifying the baud rate of the host-PC-to-Arduino serial connection 
%       Recording.InputRangeMin.val - minimum of data acquisition analog input range, in volts. See your DAQ device's documentation for supported input ranges  
%       Recording.InputRangeMax.val - minimum of data acquisition analog input range, in volts. See your DAQ device's documentation for supported input ranges  

%   For an example config file, see:
%   https://github.com/danieldkato/hardware_tests/blob/master/test_speakers/get_speaker_spectrogram/config.txt

%   Note that it is also possible to specify alternative units for pre- and
%   post-stim duration, sample rate, and input range min and max, but this is
%   not recommended as this function assumes inputs are specified in the
%   units stated above.


%% V. OUTPUTS
% This function has no formal return, but saves the following to secondary
% storage: 

% 1) A .mat file containing a structure called `Recordings`, which includes
%    all analog input data as well as data acquisition and stimulus metadata

% 2) A .csv containing the analog input data (for any subsequent non-MATLAB analysis)

% 3) A .txt containing stimulus and data acquisition metadata (for any subsequent non-MATLAB analysis)


%% VI: INSTRUCTIONS: 
% 1) Connect the host PC to the Arduino microcontroller. Optionally, to 
%    confirm that the Arduino, the speaker, and all connections are working,
%    upload the sketch `test_speakers.ino` (available at https://github.com/danieldkato/hardware_tests/tree/master/test_speakers/test_speakers)
%    to the Arduino. The speaker should emit a short burst of white noise.

% 2) Connect the audio recording equipment to the host PC. This will
%    probably entail connecting a combined microphone/preamplifier to a signal
%    preconditioner, which in turn connects via BNC cable to a connector block, 
%    which in turn connects into a PCI data acquisition board. 

% 3) Position the microphone appropriately in front of the speaker. In most
%    cases, this will mean positioning the long axis of the microphone
%    perpendicular to the speaker diaphragm and less than 5 mm away.

% 4) Ensure that the baud rate specified in `get_speaker_spectrogram.ino`
%    matches the baud rate specified in the config file or the default value
%    of 9600.

% 5) Ensure that the DAQ board and channel number specified by
%    `currDAQ` and `chanID`, respectively, match the DAQ board and channel
%    connected to the recording equipment. 

% 6) Call this function from the MATLAB command window with the desired inputs.

% 7) When prompted, enter the following numeric inputs in the command line:

%   a) The product of all gains on any signal conditioners or amplifiers in
%      line with the microphone. For example, if there is a signal conditioner
%      with a gain of 10 in line with another amplifier with a gain of 50, set
%      this to 500. If there is no signal conditioner, enter `1`. (we need this to recover the amplitude of the actual voltage signal put out by the microphone, which, along with the microphone spec sheet, can be used to infer the actual sound pressure level on the mic in Pa)

%   b) The distance of the microphone from the speakers, in millimeters

%   c) Then angle of incidence of the sound on the microphone - i.e., the
%      angle between the long axis of the microphone and the axis
%      perpendicular to the speaker diaphragm - in degrees. 


%% DESCRIPTION
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


%% TODO:
% 1) Should ultimately update this to use session-based, rather than
%    legacy DAQ interface (when we update MATLAB on ephys computer)

% 2) Should ultimately update this so that figures are saved (when we
%    update to a version of MATLAB that has savefig)

% 3) Add support for single-ended vs. differential input

% 4) Should write a generic function that *recursively* checks if structure
%    defined in config file has all necessary fields defined in default 
%    structure (this function currently does not check recursively; e.g.,
%    if Recording has a field that is itself a structure, this function
%    will not check if that subordinate structure has all of its own
%    required fields)

% Last updated DDK 2017-07-20


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

% Validate hardware
Recording.Warnings = {};

spkrWarn = validateSpeakers(speaker, stimMinFreq, stimMaxFreq)
micWarn = validateMic(Recording.Microphone, stimMinFreq, stimMaxFreq)
sigCondWarn = validateSignalConditioner(Recording.SignalConditioner, stimMinFreq, stimMaxFreq)

warnings = {spkrWarn, micWarn, sigCondWarn};

for w = 1:length(warnings)
    if ~isempty(warnings{w})
        for x = 1:length(warnings{w})
            %disp(warnings);
            Recording.Warnings = horzcat(Recording.Warnings, warnings{w}{x});
        end
    end
end


%% Upload Arduino sketch

disp(strcat(['Uploading ', Recording.Arduino.Sketch.Path, ' to Arduino...']));
old = cd('C:\Program Files\Arduino\arduino-1.6.9-windows\arduino-1.6.9'); % need to cd here b/c Windows won't recognize arduino_debug as a command; not sure why, since I added it to Path environment variable
[status, cmdout] = system(strcat(['arduino_debug --board ', Recording.Arduino.Board,' --port ',  portID, ' --upload "', strrep(Recording.Arduino.Sketch.Path, '\', '\\'), '"']));
disp('... upload complete.');
disp(cmdout);
cd(old);


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
%startTime = datestr(now, 'yymmdd_HH-MM-SS');
%startTimeTitle = datestr(now, 'yyyy-mm-dd HH:MM:SS');
%startNow = now;
%startTime = datestr(startNow, 'yymmdd_HH-MM-SS');
%startTimeTitle = datestr(startNow, 'yyyy-mm-dd HH:MM:SS');

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


%% Write metadata into the same struct containing the data and save to secondary storage as a .mat to allow for easy analysis later

Data = getdata(AI)
Recording.Data = Data; % create a session object that will glue the recording data together with metadata critical for interpretation
hwinfo = daqhwinfo(AI);
delete(AI); clear AI;

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
Recording.Arduino.Sketch.SHA1 = getSHA1(Recording.Arduino.Sketch.Path);
Recording.Arduino.Port = portID;
Recording.mFile.Path = strcat(mfilename('fullpath'), '.m');
Recording.mFile.SHA1 = getSHA1(Recording.mFile.Path);
[~, Recording.Hostname] = system('hostname');
Recording.Hostname = Recording.Hostname(1:end-1); % get rid of superfluous newline character

saveTime = now;
Recording.Date = datestr(saveTime, 'yyyy-mm-dd');
Recording.Time = datestr(saveTime, 'HH:MM:SS');

dirName = strcat(['spkr',rename(speaker), '_', num2str(floor(stimMinFreq/1000)),'-', num2str(floor(stimMaxFreq/1000)), 'kHz_noise_', datestr(saveTime, 'yyyy-mm-dd_HH-MM-SS')]);
mkdir(dirName);
old = cd(dirName);
save(dirName, 'Recording');


%% Write data as .csv and metadata as .txt for non-MATLAB analysis?

csvwrite(strcat([dirName, '.csv']), Recording.Data); 
Recording = rmfield(Recording, 'Data');

% Write warnings to metadata file:
Warnings = Recording.Warnings;
Recording = rmfield(Recording, 'Warnings'); 
fid = fopen('test.txt', 'wt');
struct2txt(Recording, fid);
warningBaseStr = 'Recording.Warnings = {';
fprintf(fid, strcat([warningBaseStr, Warnings{1}, '\n']));
for i = 2:length(Warnings)-1
    fprintf(fid, strcat([repmat(' ', 1, length(warningBaseStr)), Warnings{i}, '\n']));
end
fprintf(fid, strcat([repmat(' ', 1, length(warningBaseStr)), Warnings{end}, '}\n']));
fclose(fid);
cd(old);


%% Plot raw data from the analog input object:

figure; hold on;
seconds = [1:length(Data)]./trueSampleRate;
plot(seconds, Data)
ylabel('Voltage (V)');
xlabel('Time (s)');
yl = ylim;
xlim([0 max(seconds)]);
rectangle('Position',[Recording.PreStimDuration.val yl(1) stimDur yl(2)-yl(1)], 'FaceColor', [.9 .9 1], 'EdgeColor', 'none');
set(gca,'children',flipud(get(gca,'children')));
titleStr = {strcat(['Speaker ', speaker, ' delivering ',num2str(floor(stimMinFreq/1000)), '-', num2str(floor(stimMaxFreq/1000)), ' kHz band-limited noise']);
            strcat(['acquired ', datestr(saveTime, 'yyyy-mm-dd HH:MM:SS')]);
            strcat([num2str(distance), ' mm,', num2str(angle), ' degrees from microphone']);
            strcat(['Mic: ', Recording.Microphone]);
            strcat(['Signal Conditioner: ', Recording.SignalConditioner, ', Gain: x', num2str(sigCondGain)]);
            };
title(titleStr);
%savefig(dirName); % save figure % this function doesn't work for MATLAB v< 2013b