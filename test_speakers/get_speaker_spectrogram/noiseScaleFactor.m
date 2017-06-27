function S = noiseScaleFactor(recordingPath, band1, band2, varargin)

% DOCUMENTATION TABLE OF CONTENTS:
% I. OVERVIEW
% II. REQUIREMENTS
% III. SYNTAX
% IV. INPUTS
% V. OUTPUTS
% VI. DESCRIPTION


%% I. OVERVIEW
% This function computes the scale factor needed to ensure that acoustic
% noise played in one frequency band matches the
% loudness of noise played in another frequency band from the same speaker.
% It also creates a plot that overlays the speaker's response chart, a
% murine audiogram, and rectangular patches highlighting the requested
% frequency bands to aid in manual selection of reasonable frequency bands.


%% II. REQUIREMENTS
% 1) dftRMS.m, available at github.com/danieldkato/hardware_tests/tree/master/test_speakers/get_speaker_spectrogram/conversion
% 2) volts2pascals.m, available at github.com/danieldkato/hardware_tests/tree/master/test_speakers/get_speaker_spectrogram/conversion
% 3) pa2db.m, available at github.com/danieldkato/hardware_tests/tree/master/test_speakers/get_speaker_spectrogram/conversion
% 4) db2pa.m, available at github.com/danieldkato/hardware_tests/tree/master/test_speakers/get_speaker_spectrogram/conversion
% 5) Mics.mat, available github.com/danieldkato/hardware_tests/tree/master/test_speakers/get_speaker_spectrogram/hardwareDefs
% 6) audiogram_Heffner2002.mat, avaialable at github.com/danieldkato/hardware_tests/tree/master/test_speakers/get_speaker_spectrogram/audiograms

% Note that some of these requirements may have other dependencies of their own.
% Also, see INPUTS below for input formatting requirements.


%% III. SYNTAX
% S = mkSpectrogram2(recordingPath, band1, band2)
% S = mkSpectrogram2(recordingPath, band1, band2, audiogramPath)


%% IV. INPUTS
% 1) recordingPath - string specifying the location of a .mat file
% containing a structure called `Recording`. This structure must include at
% least the following fields:
%   a) Data - a 1 x N vector containing a time series recording of a 
%      white noise stimulus, where N is the number of samples in the recording.
%   b) Microphone - a string specifying the model number of the microphone
%      used to record the stimulus (this is necessary to retrieve the
%      sensitivity of the microphone from Mics.mat, which is in turn
%      necessary to convert the raw voltage trace into actual sound
%      pressure units that can be compared to the audiogram).
%   c) PreStimDuration.val - duration of any pre-stimulus period, in
%      seconds, included in the recording
%   d) PreStimDuration.val - duration of any post-stimulus period, in
%      seconds, included in the recording

% 2) band1 - a 2-element array specifying the lower and upper bounds, in KHz, of the
% first desired frequency range.

% 3) band2 - a 2-element array specifying the lower and upper bounds, in KHz, of the
% second desired frequency range.

% 4) [optional] audiogramPath - string specifying the location of a .mat file
% containing a structure called `Audiogram`. This structure must include at
% least the following fields:

%   a) ThreshDBSPL - a 1 x F vector of hearing thresholds, in dB SPL, where
%      F is the number of frequencies for which hearing thresholds have been
%      measured
%   b) FreqKHz - a 1 x F vector of frequencies, in KHz, for which hearing
%      thresholds have been measured. The frequency specified by a given
%      element of FreqKHz must correspond to the hearing thresholds specified
%      the corresponding element of ThreshDBSPL - in other words, the i-th
%      element of ThreshDBSPL should be the hearing threshold at the frequency
%      specified by the i-th element of FreqKHz

% If no audiogramPath is specified, then the Audiogram structure saved in
% `audiogram_Heffner2002.mat` will be used as a default. 


%% V. OUTPUTS
% 1) S, a structure with the following fields:

%   a) ScaleFactor - the scalar by which the amplitude of any signal in the
%      first frequency band must be multiplied in order to match the loudness
%      of any signal in the second frequency band
%   b) FrequenciesKHz - 1 x N vector specifying the frequencies, in KHz,
%      for which the speaker's response function is defined. This function
%      also linearly interpolates the audiogram data to define the audiogram
%      for all of these frequencies as well. 
%   c) DFT - structure containing information about the discrete Fourier
%      transform of the recorded noise stimulus. This structure includes the
%      following fields:

%       - FrequenciesHz - 1 x F vector of frequencies, in Hz, for which
%          the discrete Fourier transform of the original recording is
%          defined, where F is the number of frequencies in the DFT. Note that
%          F is equal to the number of samples in the original time-series
%          data.
%       - AmplitudesPaRMS - 1 x F vector of amplitudes, in RMS pascals,
%         associated with each frequency component of the original signal.
%         That is, in order to reconstruct the original signal, then for all
%         elements i of FrequenciesHz and AmplitudesPaRMS, you would need to
%         add a sine wave with frequency FrequenciesHz(i) and
%         AmplitudesPaRMS(i). 
%       - AmplitudesDBSPL - same as AmplitudesPaRMS, but expressed in dB
%         SPL. 

%   c) Band1 - structure defining the bounds of the first frequency band.
%      This structure includes the following fields:
%       - FrequenciesKHz - 2-element array defining the upper and lower
%          bounds of the first frequency band in KHz
%       - indices - 2-element array defining the upper and lower
%         bounds of the first frequency band as indices into a 1 x F vector,
%         where F is the number of frequencies sampled

%   d) Band2 - same as Band1, but for the second frequency band

%   e) Recording - structure containing all metadata fields from the struct
%      `Recording` used to compute the scale factor

%   f) Audiogram - structure containing audiogram data and metadata used to
%      compute the scale factor


%% VI. DESCRIPTION
% The purpose of this function is to compute a scale factor by which the
% amplitude of noise in one frequency band must be multiplied in order to
% have the same loudness as noise in another frequency band. 

% When a time-varying sinusoidal voltage signal of fixed amplitude is fed
% to a speaker at different frequencies, the resulting sounds will have
% different perceived loudness for two reasons: 1) the speaker itself
% responds differently at different frequencies (i.e., the speaker's
% "response chart" is not flat), and 2) the mouse's hearing threshold is
% different for different frequencies (i.e., the mouse's "audiogram" is not
% flat).

% In order for two sounds of different frequencies f1 and f2 to have the
% same perceived loudness, then the ratio of the sound pressure at f1 to
% the mouse's hearing threshold at f1 - measured in linear units like
% pascals (as opposed to logarithmic units like decibels) - must equal the
% ratio of the sound pressure at f2 to the mouse's hearing threshold at f2.

% To put it another way: suppose that R(f) is a function that defines the
% sound pressure produced by the speaker at each frequency. Suppose
% moreover that T(f) is the mouse's audiogram, i.e., a function that
% defines the minimum detectable sound pressure at each frequency. Suppose
% both R(f) and T(f) are in linear units like pascals (as opposed to
% logarithmic units like decibels). In order for two sounds of different
% frequencies f1 and f2 to have the same perceived loudness, then we want 

% R(f1)/T(f1) = R(f2)/T(f2)

% When dealing with a pair of frequency bands rather than a pair of
% individual frequencies, we approximate the relationship between the
% perceived loudness of each band with:

% integral(R/T, f1min, f1max) = integral(R/T, f2min, f2max)

% where integral(F/G, min, max) is the integral of F(x)/G(x) over the range
% min to max. 

% If these ratios are not equal, then one must be scaled by some
% appropriate factor to equal the other. It is this scale factor that
% this function computes.


%% Check if audiogram was defined, and if not, use default audiogram

audiogramPath = 'audiogram_Heffner2002';

if length(varargin)>0
    audiogramPath = varargin{1};
end

S.AudiogramPath = audiogramPath;
S.Speaker = 'unknown';

%% Define desired frequency bands:
range1 = [4 8];
range2 = [15 19];

S.Band1.FrequenciesKHz = band1;
S.Band2.FrequenciesKHz = band2;


%% Create periodogram of recording:
load(recordingPath); 
S.RecordingPath = recordingPath;
if isfield(Recording, 'Speaker')
    S.Speaker = Recording.Speaker;
end
S.DFT = dftRMS(Recording); % get the Fourier transform of the recording in pascals RMS
S.FrequenciesKHz = S.DFT.FrequenciesHz/1000; % convert frequencies associated with the DFT from Hz to KHz
S.DFT.AmplitudesDBSPL = pa2db(S.DFT.AmplitudesPaRMS); % convert amplitudes associated with the DFT from pascals RMS into decibels; PLOTTING PURPOSES ONLY


%% Load audiogram:
load(audiogramPath); 
Audiogram.ThreshPa.Raw = db2pa(Audiogram.ThreshDBSPL); % convert from dB SPL to pascals

% Interpolate audiogram for comparison with periodogram;
% output will have the same length as rmsPa.Amplitudes 
Audiogram.ThreshPa.Interpolated = interp1(Audiogram.FreqKHz, Audiogram.ThreshPa.Raw, S.FrequenciesKHz)';
Audiogram.ThreshDB.Interpolated = pa2db(Audiogram.ThreshPa.Interpolated); % for plotting purposes only


%% Compute scale factor: 
Ratio = S.DFT.AmplitudesPaRMS./Audiogram.ThreshPa.Interpolated; % want to take this ratio in pascals, not decibels

% Convert bounds of desired frequency ranges from KHz into indices into Ratio:
frequencyStep = max(S.FrequenciesKHz)/length(S.FrequenciesKHz); % frequency step size, in KHz per step
S.Band1.indices = floor(band1./frequencyStep); 
S.Band2.indices = floor(band2./frequencyStep);

range1integral = sum(Ratio(S.Band1.indices(1):S.Band1.indices(2)));
range2integral = sum(Ratio(S.Band2.indices(1):S.Band2.indices(2)));
S.ScaleFactor = range2integral/range1integral;


%% Create figure with audiogram superimposed on periodogram:

% Plot raw periodogram:
figure;
hold on;
rawPeriodogram = plot(S.FrequenciesKHz, S.DFT.AmplitudesDBSPL);

% Smooth the periodogram:
boxWidth = 100;
smoothIndices = (boxWidth/2:1:length(S.DFT.AmplitudesDBSPL)-boxWidth/2);
dbSmooth = arrayfun(@(a) mean(S.DFT.AmplitudesDBSPL(a-boxWidth/2+1:a+boxWidth/2)), smoothIndices);
smoothPeriodogram = plot(S.FrequenciesKHz(smoothIndices), dbSmooth, 'Color', [0, 0, 0.5]);

% Plot audiogram:
audiogramPlot = plot(S.FrequenciesKHz, Audiogram.ThreshDB.Interpolated, 'LineWidth', 1.5, 'Color', [1, 0, 0]);

% Plot rectangles corresponding to target frequency ranges:
yl = ylim;
recY = [yl fliplr(yl)];
p1 = patch([S.Band1.FrequenciesKHz(1) S.Band1.FrequenciesKHz(1) S.Band1.FrequenciesKHz(2) S.Band1.FrequenciesKHz(2)], recY, [0.95, 0.95, 0.25], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
p2 = patch([S.Band2.FrequenciesKHz(1) S.Band2.FrequenciesKHz(1) S.Band2.FrequenciesKHz(2) S.Band2.FrequenciesKHz(2)], recY, [0.95, 0.95, 0.25], 'FaceAlpha', 0.3, 'EdgeColor', 'none');

% Label figure
titleStr = {strcat(['Speaker ', S.Speaker, ' response chart & murine audiogram']);
            strcat(['Response chart obtained from ', num2str(Recording.StimDur.val), '-', Recording.StimDur.units(1:end-1), ' white noise burst']);
};

title(titleStr);
xlabel('Frequency (kHz)');
ylabel('Volume (dB SPL)');
agName = strcat([Audiogram.Authors{1}{1}, ' et al ', num2str(Audiogram.Year)]);
legend([rawPeriodogram, audiogramPlot], {strcat(['Speaker ', S.Speaker, ' response chart']),
        strcat(['Murine audiogram (', agName, ')'])
});

%% Write some recording metadata to S 
Recording = rmfield(Recording, 'Data');
S.Recording = Recording;
S.Audiogram = Audiogram;

%{
figure;
hold on;
% for potting purposes, take log of X-values
logMicFreqs = log10(KHz);
logAudiogramFreqs = log10(Audiogram.FreqKHz);
plot(logMicFreqs, db);
plot(logAudiogramFreqs, Audiogram.ThreshDBSPL, 'r');
ax = gca;
oldMarks = ax.XTick;
newMarks = log10(floor(10.^oldMarks));
newLabels = arrayfun(@(a) num2str(10^a), newMarks, 'UniformOutput', false);
ax.XTickLabel = newLabels;
%}


