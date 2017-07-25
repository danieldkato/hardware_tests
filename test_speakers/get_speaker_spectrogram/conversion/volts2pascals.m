function pascals = volts2pascals(Recording)

% DOCUMENTATION TABLE OF CONTENTS
% I. OVERVIEW
% II. REQUIREMENTS
% III. INPUTS
% IV. OUTPUTS


%% I. OVERVIEW
% This function takes a voltage trace from an audio recording and converts
% it to a pressure trace.


%% II. REQUIREMENTS
% 1) Mics.mat - .mat file containing a MATLAB struct array called Mics,
% each element of which represents a microphone and defines its
% specifications. Each element of Mics must have at least the following
% fields:
%   a) Mdl - String stating the model number of the microphone
%   b) Sensitivity - numeric value specifying the microphone's sensitivity in mV/Pa

% A Mics.mat file containing definitions for one commonly used microphone
% is available at:

% https://github.com/danieldkato/hardware_tests/tree/master/test_speakers/get_speaker_spectrogram/hardwareDefs


%% III. INPUTS
% 1) Recording - MATLAB struct containing audio recording data and metadata.
% It must contain at least the following fields:
%   a) Data - actual recording data, in Volts, formatted as a 1 x N vector, where N is the number of samples in the recording.
%   b) Microphone - String specifying the model number of the microphone used to make the recording


%% IV. OUTPUTS
% 1) pascals - 1 x N vector of pressure values, expressed in pascals


%% TODO:
% 1) Provide alternative syntax for when Microphone.m and Mics.mat are not
% available?
% 2) Provide alternative syntax for non-MATLAB struct inputs?

% Last updated DDK 2017-06-07


%%

% Get mic sensitivity by looking it up; might want to offer alternative
% ways of entering mic sensitivity if make this optional if mic database is
% not available
load('Mics.mat') % load microphone specs

times = (1/Recording.TrueSampleRate.val) * (1:1:length(Recording.Data));

% plot trace in volts
figure;
plot(times, Recording.Data);
title('Raw time-domain signal');
xlabel('Time (s)');
ylabel('Signal (V)');
xlim([min(times) max(times)]);

found = 0;
for m = 1:length(Mics)
        if strcmp(Mics(m).Mdl, Recording.Microphone)
            sensitivity = Mics(m).Sensitivity * 1000; % convert from mV/Pa to V/Pa
            found = 1;
        end
end

if found == 0
    error('Specified microphone model number not found in Mics.mat; mic sensitivity unknown, cannot convert from Volts to pascals.');
end

pascals = Recording.Data*sensitivity;

% plot trace in Pascals
figure;
plot(times, pascals);
title('Time-domain signal in Pascals');
xlabel('Time (s)');
ylabel('Signal (Pa)');
xlim([min(times) max(times)]);
