function P = db2pa(dB)
%% DOCUMENTATION TABLE OF CONTENTS
% I. SYNTAX
% II. OVERVIEW
% III. REQUIREMENTS
% IV. INPUTS
% V. OUTPUTS

%%
% I. SYNTAX
% P = db2pa(dB)

% II. OVERVIEW
% This function converts a vector of sound pressure level values expressed
% in dB SPL to a vector of sound pressure level values expressed in
% pascals.

% III. REQUIREMENTS
% None (beyond those needed to run MATALB).

% IV. INPUTS
% dB - a 1 x n vector of sound pressure level values expressed in dB SPL

% V. OUTPUTS
% P - a 1 x n vector of sound pressure level values expressed in pascals


%%
p0 = 20e-6; % reference sound pressure level, in Pascals, for dB SPL
P = p0 * 10.^(dB/20);