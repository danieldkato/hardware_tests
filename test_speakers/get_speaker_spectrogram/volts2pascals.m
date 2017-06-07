function pascals = volts2pascals(Recording)

% DOCUMENTATION TABLE OF CONTENTS
% I. SYNATX
% II. OVERVIEW
% III. REQUIREMENTS
% IV. INPUTS
% V. OUTPUTS


%%
% I. SYNTAX
% pascals = volts2pascals(Recordings)


% II. OVERVIEW
% This function takes a voltage trace from an audio recording and converts
% it to a pressure trace.


% III. REQUIREMENTS
% 1) Mics.mat - .mat file containing a MATLAB struct array called Mics,
% each element of which represents a microphone and defines its
% specifications. Each element of Mics must have at least the following
% fields:
%   Mdl - String stating the model number of the microphone
%   Sensitivity - numeric value specifying the microphone's sensitivity in mV/Pa

% A Mics.mat file containing definitions for one commonly used microphone
% is available a 


% IV. INPUTS
% 1) Recording - MATLAB struct containing audio recording data and metadata.
% It must contain at least the following fields:
%   a) Data - actual recording data, in Volts, formatted as a 1 x N vector, where N is the number of samples in the recording.
%   b) Microphone - String specifying the model number of the microphone used to make the recording


% V. OUTPUTS
% 1) pascals - 1 x N vector of pressure values, expressed in pascals


% TODO:
% 1) Provide alternative syntax for when Microphone.m and Mics.mat are not
% available?
% 2) Provide alternative syntax for non-MATLAB struct inputs?

% Last updated DDK 2017-06-07


%%

% Get mic sensitivity by looking it up; might want to offer alternative
% ways of entering mic sensitivity if make this optional if mic database is
% not available
load('Mics.mat') % load microphone specs
for m = 1:length(Mics)
        if strcmp(Mics(m).Mdl, Recording.Microphone)
            sensitivity = Mics(m).Sensitivity * 1000; % convert from mV/Pa to V/Pa
        end
end

pascals = Recording.Data/sensitivity;
