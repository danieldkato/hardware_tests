function P = db2pa(dB)
%% DOCUMENTATION TABLE OF CONTENTS

% I. OVERVIEW
% II. REQUIREMENTS
% III. INPUTS
% IV. OUTPUTS

%%
% I. OVERVIEW
% This function converts a vector of sound pressure level values expressed
% in dB SPL to a vector of sound pressure level values expressed in
% pascals.

% II. REQUIREMENTS
% None (beyond those needed to run MATALB).

% II. INPUTS
% dB - a 1 x n vector of sound pressure level values expressed in dB SPL

% IV. OUTPUTS
% P - a 1 x n vector of sound pressure level values expressed in pascals


%%
p0 = 20e-6; % reference sound pressure level, in Pascals, for dB SPL
P = p0 * 10.^(dB/20);