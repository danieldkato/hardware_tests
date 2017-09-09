function recordDigitalTriggeredAudioNoise(speaker, stimID, portID, configFile)

% DOCUMENTATION TABLE OF CONTENTS:
% I. SYNTAX
% II. OVERVIEW
% III. REQUIREMENTS
% IV. INPUTS
% V. OUTPUTS
% VI. INSTRUCTIONS


%% I. SYNTAX:
% recordDigitalTriggeredAudioNoise(speaker, stimID, portID, configFile)


%% II. OVERVIEW: 
% Use this function to record auditory stimuli delivered by the LabView
% virtual instrument DigitalTriggeredAudioNoise.vi.


%% III. REQUIREMENTS:
% A) Hardware
%   1) A host PC configured for use with analog-to-digital data acquisition
%      hardware compatible with MATLAB's data acquisition toolbox(e.g., a
%      National Instruments PCI data acquisition card connected to a BNC
%      Connector block). 

%   2) Digital data acquisition hardware compatible for use with MATLAB's
%      data acquisition toolbox (e.g., a National Instruments PCI data
%      acquisition card connected to a BNC Connector block). 
    
%   3) An Arduino microcontroller. 
    
%   4) Audio recording equipment compatible with the analog-to-digital
%      data acquisition equipment specified in 1). This will most likely
%      include a prepolarized microphone, a preamplifier, and preconditioner. 
%      For more detailed hardware requirements, see the README available at
%      https://github.com/danieldkato/hardware_tests/tree/master/test_speakers/get_speaker_spectrogram.
    
    
    
% B) Software
%    1) MATLAB data acquisition toolbox. Must be a version
%       supporting MATLAB's legacy DAQ interface, (will have to be
%       updated in future versions to session-based interface).

%    2) Arduino IDE 1.6.9 or later.
    
%    3) Arduino-side code for running the ArduFSM protocol MultiSens. This
%       includes the following files:
    
%        a) MultiSens.ino
%        b) States.h
%        c) States.cpp
      
%        These files are available at https://github.com/danieldkato/ArduFSM/tree/soundcard/MultiSens
    
%        In addition, these files make use of the following Arduino libraries: 

%        a) chat, https://github.com/cxrodgers/ArduFSM/tree/master/libraries/chat
%        b) TimedState, https://github.com/cxrodgers/ArduFSM/tree/master/libraries/TimedState
    
%    4) National Instruments LabView systems engineering software.
    
%    5) The LabView virtual instrument DigitalTriggeredAudioNoise.vi, available at
%       https://github.com/danieldkato/hardware_tests/tree/master/test_speakers/get_speaker_spectrogram/recordDigitalTriggeredAudioNoise
    
%    6) The JSONlab toolbox, available at
%    https://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files
 
%    7) getSHA1.m, available at https://github.com/danieldkato/utilities/blob/master/getSHA1.m
    
% *IMPORTANT WARNING*: As of 7/20/16, when running on hs05bruno8 ('504 -
% physiology'), this script often raises an out-of-memory error and crashes
% when it tries to call spectrogram(). If collecting data on hs05bruno8, it
% may be necessary to analyze the data offline on another computer.


%% IV. INPUTS:
% 1) speaker - string specifying the model number of the speaker.

% 2) stimID - index of the auditory stimulus condition to play from
%    DigitalTriggeredAudio.vi. 0 means no stimulus; 1 mean stimulus condition
%    1 in DigitalTriggeredAudio.vi; 2 means stimulus condition 2 in
%    DigitalTriggeredAudio.vi

% 3) portID - string specifying the port connected to the Arduino microcontroller

% 4) configFile - path to a MATLAB-evaluable .txt file defining a structure
%    called `Recording`, which specifies various parameters necessary for
%    setting up data acquisition. This structure must supply the following fields:

%       Recording.Arduino.Sketch.LocalPath - char array specifying the path of the main sketch to be run on the Arduino 
%       Recording.Arduino.Board - char array specifying the model of the board to which the sketch will be uploaded. This 
%                                 should have the syntax used by the Arduino command line interface. E.g., for an Arduino 
%                                 Uno, the value should be 'arduino:avr:uno'. For more detail, see the Arduino CLI documentation at 
%                                 https://github.com/arduino/Arduino/blob/master/build/shared/manpage.adoc

%    In addition, it is best practice to use a config file that defines the 
%    following fields, although this function will provide defaults if needed:
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
%    all analog input data as well as stimulus and data acquisition metadata

% 2) A .csv containing the analog input data (for any subsequent non-MATLAB analysis)

% 3) A JSON file containing stimulus and data acquisition metadata (for any subsequent non-MATLAB analysis)


%% VI: INSTRUCTIONS: 

% 1) Connect the appropriate output pins on the Arduino to the
%    corresponding digital input pins on the digital data acquisition
%    hardware. By default, this entails the following connections:
%       
%       Arduino digital output pin      BNC-2110 Digital input pin
%       --------------------------      --------------------------
%       4                               P0.1
%       5                               P0.2
%       13                              P0.0

%    For more general description, see below. 

% 2) Ensure that the baud rate specified in `MultiSens.ino` matches either the
%    baud rate specified in the config file or the default value of 9600.

% 3) Connect the Arduino to the host PC via USB port.

% 4) Upload the Arduino sketch `MultiSens.ino`, along with `States.h` and
%   `States.cpp`, to the Arduino microcontroller.

% 5) Connect the audio recording equipment to the host PC. This will
%    probably entail connecting a combined microphone/preamplifier to a signal
%    preconditioner, which in turn connects via BNC cable to a connector block, 
%    which in turn connects into a PCI data acquisition board. 

% 6) Position the microphone appropriately in front of the speaker. In most
%    cases, this will mean positioning the long axis of the microphone
%    perpendicular to the speaker diaphragm and less than 5 mm away.

% 7) Ensure that the DAQ board and channel number specified by
%    `DAQDeviceID` and `DAQChannel`, respectively, match the DAQ board and
%    channel connected to the recording equipment. 

% 8) Open DigitalTriggeredAudio.vi in LabView and hit 'Run Continuously' in
%    the LabView GUI. 

% 9) Call this function from the MATLAB command window with the desired inputs.

% 10) When prompted, enter the following numeric inputs in the command line:

%   a) The product of all gains on any signal conditioners or amplifiers in
%     line with the microphone. For example, if there is a signal conditioner
%     with a gain of 10 in line with another amplifier with a gain of 50, set
%     this to 500. If there is no signal conditioner, enter `1`. (we need 
%     this to recover the amplitude of the actual voltage signal put out by 
%     the microphone, which, along with the microphone spec sheet, can be 
%     used to infer the actual sound pressure level on the mic in Pa)

%   b) The distance of the microphone from the speakers, in millimeters

%   c) Then angle of incidence of the sound on the microphone - i.e., the
%     angle between the long axis of the microphone and the axis
%     perpendicular to the speaker diaphragm - in degrees. 


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

% 5) I've been assuming that the scale factor for both stimuli in
%    DigitalTriggeredAudioNoise.vi is 1 in the original recording, but this
%    function should really record this information explicity. I think this
%    means that this information needs to be included in the inputs to
%    recordDigitalTriggeredAudioNoise.m and passed to the output metadata
%    file; the scale factors can be recorded explicitly in the configuration
%    file, and the SHA1 digest of the latest git commit of
%    DigitalTriggeredAudioNoise.vi can also be saved.

% Last updated DDK 2017-09-08


%% Define settings, and, where possible, validate hardware:

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
Defaults.BaudRate = 9600;
Defaults.InputRangeMin.val = -10;
Defaults.InputRangeMin.units = 'volts';
Defaults.InputRangeMax.val = 10;
Defaults.InputRangeMax.units = 'volts';
requiredFields = fieldnames(Defaults);

% Load settings specified in struct Recording defined in config file:
fid = fopen(configFile);
content = fscanf(fid, '%c');
eval(content);

% Validate that config file includes required settings; if not, throw a warning and use defaults
for i = 1:length(requiredFields)
    if ~isfield(Recording, requiredFields{i}) % If a field is missing entirely from the loaded config structure...
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

% Add CLI-defined parameters to metadata:
Recording.StimID = stimID;
Recording.Speaker = speaker;
Recording.SignalConditionerGain = sigCondGain;
Recording.Distance.val = distance;
Recording.Distance.units = 'millimeters';
Recording.Angle.val = angle;
Recording.Angle.units = 'degrees';
Recording.Arduino.Port = portID;
Recording.mFile.LocalPath = strcat(mfilename('fullpath'), '.m');

% Add some addition parameters to metadata:
[~, Recording.Hostname] = system('hostname');
Recording.Hostname = Recording.Hostname(1:end-1); % get rid of superfluous newline character

% Get software version information:
warnMsgs = {};
files = {Recording.mFile, Recording.Arduino.Sketch, Recording.VI}; % 

for i = 1:length(files)
    [warnOut, files{i}.SHA1] = getSHA1(files{i}.LocalPath); 
    if ~isempty(warnOut)
        warnMsgs{end+1} = warnOut; 
        checkContinue();
    end
end

% need to re-assign b/c the elements of 'files' were deep copies
Recording.mFile = files{1};
Recording.Arduino.Sketch = files{2};
Recording.VI = files{3};

Recording.Warnings = warnMsgs;

%{
Recording.mFile.SHA1 = getSHA1(Recording.mFile.LocalPath);
Recording.Arduino.Sketch.SHA1 = getSHA1(Recording.Arduino.Sketch.LocalPath);
Recording.VI.SHA1 = getSHA1(Recording.VI.LocalPath);
%}



% Check if software is under git control
%   if not, give user opporunity to abort
%       if user does not abort, throw and save warning

% Check if software has uncommitted changes
%   if so, give user opportunity to abort
%       if user does not abort, throw and save warning

% If software is under git control and does not have uncommitted changes,
% get and save SHA1 digest

% Maybe checking the git status, throwing any warnings and getting the SHA1
% digest should be the responsibility of another function like getSHA1.m;
% giving the user the opportunity to abort should be this program's
% responsibility

%% Upload Arduino sketch

disp(strcat(['Uploading ', Recording.Arduino.Sketch.LocalPath, ' to Arduino...']));
old = cd('C:\Program Files\Arduino\arduino-1.6.9-windows\arduino-1.6.9'); % need to cd here b/c Windows won't recognize arduino_debug as a command; not sure why, since I added it to Path environment variable
[status, cmdout] = system(strcat(['arduino_debug --board ', Recording.Arduino.Board,' --port ',  portID, ' --upload "', strrep(Recording.Arduino.Sketch.LocalPath, '\', '\\'), '"']))
disp('... upload complete.');
%disp(cmdout);
cd(old);


%% Configure analog input object:

AI = analoginput(Recording.DAQDeviceDriver, Recording.DAQDeviceID);
AI.InputType = 'SingleEnded';
maxSampleRate = daqhwinfo(AI,'MaxSampleRate');

chan = addchannel(AI, Recording.DAQChannel);
AI.Channel.InputRange = [Recording.InputRangeMin.val Recording.InputRangeMax.val];
disp(Recording.DAQTgtSampleRate);
AI.SampleRate = Recording.DAQTgtSampleRate.val;
trueSampleRate = double(AI.SampleRate); %MATLAB may not use the exact sample rate specified
Fs = trueSampleRate;
AI.SamplesPerTrigger = ceil((Recording.PreStimDuration.val + Recording.VI.Stim.Duration.val + Recording.PostStimDuration.val) * trueSampleRate);
AI.TriggerType = 'Manual';


%% Send stimulus parameters to Arduino 

% Create and open serial connection with Arduino:
disp('Opening serial connection with Arduino...');
arduino = serial(portID, 'BaudRate', Recording.BaudRate);
fopen(arduino);
pause(max([2, Recording.VI.Stim.Duration.val+2])); %wait for handshake to complete; this actually takes quite a long time. Also, opening the serial connection triggers the stimulus for some reason, so leave enough time for it to complete
disp(fscanf(arduino)); 

% Send stimulus information to Arduino
instructions = strcat(['SET SPKRIDX ', num2str(stimID), '\n']);
fprintf(arduino,'%s', instructions);
disp(fscanf(arduino)); 
pause(.5);    


%% Acquire analog data:

startTime = datestr(now, 'yymmdd_HH-MM-SS');
startTimeTitle = datestr(now, 'yyyy-mm-dd HH:MM:SS');
disp('Starting data acquisition...');

% Begin data acquisition:
start(AI);
trigger(AI);
pause(Recording.PreStimDuration.val);

% Issue stimulus start trigger to Arduino:
fprintf(arduino,'%s','RELEASE_TRL\n'); 

%Wait for AI object to finish data acquisition:
wait(AI, Recording.VI.Stim.Duration.val + Recording.PostStimDuration.val + .1);
disp('... data acquisition complete.');

%Close serial communication with Arduino:
fclose(arduino);
disp('... serial connection closed.');


%% Write data into the Recording struct
Data = getdata(AI);
Recording.Data = Data; % create a `Recording` struct that will glue the recording data together with metadata critical for interpretation
hwinfo = daqhwinfo(AI);
delete(AI); clear AI;


%% Add a few remaining metadata parameters that are only defined after data acquision:
Recording.TrueSampleRate.val = trueSampleRate;
Recording.TrueSampleRate.units = 'samples/second';

saveTime = now;
Recording.Date = datestr(saveTime, 'yyyy-mm-dd');
Recording.Time = datestr(saveTime, 'HH:MM:SS');


%% Save data and metadata to secondary storage:

% Save struct Recording, including both data and metadata, as .mat file:
dirName = strcat(['spkr',rename(speaker), '_DigitalTriggeredNoiseStim', num2str(stimID), '_', datestr(saveTime, 'yyyy-mm-dd_HH-MM-SS')]);
mkdir(dirName);
old = cd(dirName);
save(dirName, 'Recording');

% Save data as a .csv file for possible subsequent non-MATLAB analysis:
csvwrite(strcat([dirName, '.csv']), Recording.Data); 

% Save metadata as a JSON file for possible sbsequent non-MATLAB analysis:
Recording = rmfield(Recording, 'Data');
savejson('', Recording, 'metadata.json');
cd(old);


%% Plot raw data from the analog input object:
figure; hold on;
seconds = [1:length(Data)]./trueSampleRate;
plot(seconds, Data)
ylabel('Voltage (V)');
xlabel('Time (s)');
yl = ylim;
xlim([0 max(seconds)]);
rectangle('Position',[Recording.PreStimDuration.val yl(1) Recording.VI.Stim.Duration.val yl(2)-yl(1)], 'FaceColor', [.9 .9 1], 'EdgeColor', 'none');
set(gca,'children',flipud(get(gca,'children')));
titleStr = {strcat(['Speaker ', speaker, ' delivering band-limited noise']);
            strcat(['acquired ', datestr(saveTime, 'yyyy-mm-dd HH:MM:SS')]);
            strcat([num2str(distance), ' mm, ', num2str(angle), ' degrees from microphone']);
            strcat(['Mic: ', Recording.Microphone]);
            strcat(['Signal Conditioner: ', Recording.SignalConditioner, ', Gain: x', num2str(sigCondGain)]);
            };
title(titleStr);
%savefig(dirName); % save figure % this function doesn't work for MATLAB v
%< 2013b
end


%% Function for validating user input:
function checkContinue()
    in = input('Proceed anyway? (y/n)', 's');
    if strcmp(in, 'n')
        error('Execution terminated by user.');
    elseif ~strcmp(in, 'y')
        disp('Please enter "y" or "n".');
        checkContinue()
    end
end