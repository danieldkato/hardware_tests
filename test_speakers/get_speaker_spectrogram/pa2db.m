function dB = pa2db(p)
%% DOCUMENTATION TABLE OF CONTENTS
% I. OVERVIEW
% I. REQUIREMENTS
% III. INPUTS
% IV. OUTPUTS

%%
% I. OVERVIEW
% This function takes a vector of sound pressure values expressed in
% pascals and returns a vector of of sound pressure values expressed in dB
% SPL.

% I. REQUIREMENTS
% None (beyond those needed to run MATLAB).

% III. INPUTS
% 1) P - 1 x n vector of sound pressure values, expressed in pascals

% IV. OUTPUTS
% 1) dB - 1 x n vector of sound pressure values, expressed in dB SPL.

% last updated DDK 2017-06-08

%%
p0 = 20e-6; % reference sound pressure level, in Pascals, for dB SPL
dB = 20*log10(P/p0);