function Comparison = noiseScaleFactor2(cond1path, cond2path, varargin);

% DOCUMENTATION TABLE OF CONTENTS:
% I. OVERVIEW
% II. REQUIREMENTS
% III. SYNTAX
% IV. INPUTS
% V. OUTPUTS
% VI. DESCRIPTION


%% I. OVERVIEW
% This function computes the factor by which the amplitude of noise played
% in one frequency band must be scaled to match the perceived loudness (to
% a mouse) of noise played in another frequency band.

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
% S = mkSpectrogram2(cond1path, cond2path)
% S = mkSpectrogram2(cond1path, cond2path, audiogramPath)


%% IV. INPUTS
% 1) cond1path - path to a directory containing audio recording data from
%    condition 1 (i.e., the first frequency band). This condition-specific
%    directory should in turn contain a number of directories corresponding
%    to a single recording each (i.e., the output of one call to
%    recordDigitalTriggeredAudioNoise.m). Each recording-specific directory
%    must in turn include a .mat file containing a structure called
%    `Recording`. This structure must include at least the following
%    fields:

%       a) Data - a 1 x N vector containing a time series of a
%          white noise stimulus, where N is the number of samples in the
%          recording.

%       b) Microphone - a string specifying the model number of the microphone
%          used to record the stimulus (this is necessary to retrieve the
%          sensitivity of the microphone from Mics.mat, which is in turn
%          necessary to convert the raw voltage trace into actual sound
%          pressure units that can be compared to the audiogram).

%       c) PreStimDuration.val - duration of any pre-stimulus period, in
%          seconds, included in the recording

%       d) PreStimDuration.val - duration of any post-stimulus period, in
%          seconds, included in the recording


% 2) cond1path - path to a directory containing audio recording data from
%    condition 2 (i.e., the second frequency band). This directory should
%    have the same structure as that described for condition 1.

% 3) [optional] audiogramPath - string specifying the location of a .mat file
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
% 1) Comparison, a structure with the following fields:

%   a) ScaleFactor - ratio of the loudness of condition 1 to the loudness
%      of condition 2. Mulitply the 'scale factor' variable of condition 2
%      in DigitalTriggeredAudioNoise.vi by this value to equalize the
%      loudness of the two stimulus conditions.
%
%   b) Speaker - speaker used to play the stimuli. The scale factor will
%      depend on the particular response chart of the speaker.
%
%   c) AudiogramPath - path to the audiogram used to compute the scale factor.
%
%   d) mFile - a struct containing information about the .m file used to
%      compute the scale factor, including:
%
%           1) Path - full path to this .m file
%
%           2) SHA1 - digest of this .m file's most recent git commit
%
%   e) Condtn - 1 x 2 struct array containing information about each
%      sitmulus condition. Each struct corresponds to one stimulus condition 
%      and includes the following fields:
%
%           1) LowF - lower bound of the stimulus condition's frequencty range, in kHz. 
%
%           2) HighF - upper bound of the stimulus condition's frequencty range, in kHz. 
%
%           3) MeanDFTPaRMS - mean DFT of the stimulus condition, expressed in RMS pascals 
%              and stored as an n x 1 vector, where n is the number of samples in all recordings
%              (note this means that all recordings must be the same length and have the same
%              pre- and post-stimulus periods).  
%
%           4) Integral - integral of R(f)/T(f) over the stimulus
%              frequencty range, where R(f) is the stimulus periodogram and
%              T(f) is the murine audiogram, used to compute the scale factor. 
%              See DESCRIPTION below for more detail. 
%
%           5) Recordings - 1 x r struct array, where r is the number of
%              recordings of the stimulus condition. Each struct corresponds
%              one recording and includes the following fields:
%
%                   1) Path - path to the original .mat file containing the
%                      recording data.
%
%                   2) VolumeDBSPL - overall volume of the recorded
%                      stimulus, expressed in dB SPL.
%
%                   3) DFT - struct containing information about the
%                      discrete Fourier transform of the recorded stimulus,
%                      including the DFT itself expressed in RMS pascals, as
%                      well as vectors of the frequencies for which the DFT
%                      was computed, expressed in both Hz and kHz.


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

% To put it another way: suppose that R1(f) is the periodogram of stimulus
% condition 1, defining the sound pressure produced by stimulus condition 1
% at each frequency, and R2(f) is the periodogram of stimulus condition 2.
% Suppose moreover that T(f) is the mouse's audiogram, i.e., a function
% that defines the minimum detectable sound pressure at each frequency.
% Suppose both R(f) and T(f) are in linear units like pascals (as opposed
% to logarithmic units like decibels). In order for two sounds of different
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

% Because the recordings are noisy, this function takes a number of
% recordings from each stimulus condition and computes the mean DFT of each
% stimulus condition. That is, it takes the DFT of each recording within a
% stimulus condition, then takes the mean of those DFTs. These mean DFTs are
% used as the periodogram functions R1(f) and R2(f) described above. 


%% Load inputs, settings, etc:

% Set defaults:
audiogramPath = 'audiogram_Heffner2002';
Comparison.Speaker = 'unknown';

%Check if audiogram is defined by user, and if not, use default audiogram:
if length(varargin)>0
    audiogramPath = varargin{1};
end
Comparison.AudiogramPath = audiogramPath;
load(audiogramPath); 

% Place paths to condition directories in an iterable cell array:
conditions = {cond1path, cond2path};

% Define some colors that will be useful for plotting later on:
blue = [0 0 1];
purple = [0.5 0 0.5];
Colors = [blue; purple];

tld = cd;

%% For each stimulus condition, compute the mean DFT:

for c = 1:length(conditions)
    
    cd(conditions{c});
    recordingDirs = dir;
    
    % Compute the DFT for each recording within the current stimulus condition:
    for r = 3:length(recordingDirs)
        old = cd(recordingDirs(r).name);
        files = dir;
        
        % In the directory for the current recording, find and load the file that ends in .mat:
        out = cellfun(@(a) strfind(a, '.mat'), {files.name}, 'UniformOutput', 0);
        out2 = cellfun(@(c) isempty(c), out);
        matFileName = files(~out2).name;
        load(matFileName); % this loads a struct called `Recording` into the workspace
        Comparison.Condtn(c).Recordings(r-2).Path = [cd filesep matFileName];
        
        % Get the volume of the stimulus in dB SPL:
        dataPa = volts2pascals(Recording);
        stimDataPa = dataPa(floor(Recording.PreStimDuration.val * Recording.TrueSampleRate.val): length(Recording.Data)-ceil(Recording.PostStimDuration.val * Recording.TrueSampleRate.val));
        plot(stimDataPa);
        stimDataPaRMS = rms(stimDataPa);
        Comparison.Condtn(c).Recordings(r-2).VolumeDBSPL = pa2db(stimDataPaRMS);
        
        % Get lower and upper frequency bounds for current stimulus condition:
        Comparison.Condtn(c).LowF = (Recording.VI.Stim.StartFreqs.val(Recording.StimID))/1000; % remember to convert to kHz;
        Comparison.Condtn(c).HighF = Comparison.Condtn(c).LowF + (Recording.VI.Stim.FreqRange.val)/1000; % remember to convert to kHz
        
        % Get the DFT of the recording in pascals RMS:
        Comparison.Condtn(c).Recordings(r-2).DFT = dftRMS(Recording); 
        Comparison.Condtn(c).Recordings(r-2).DFT.FrequenciesKHz = Comparison.Condtn(c).Recordings(r-2).DFT.FrequenciesHz/1000; 

        cd(old);
    end
    
    % Once DFTs for all recordings in the current stimulus condition have been computed, take the mean DFT for the current stimulus condition:
    allDFTPaRMS = [];
    for rr = 1:length(Comparison.Condtn(c).Recordings)
        allDFTPaRMS = [allDFTPaRMS Comparison.Condtn(c).Recordings(rr).DFT.AmplitudesPaRMS];
    end
    Comparison.Condtn(c).MeanDFTPaRMS = mean(allDFTPaRMS, 2); % for computing the scale factor, we will need in the mean DFT in RMS pascals

    cd(tld);
end


%% Compute the scale factor:

% Interpolate audiogram and convert from dB SPL to RMS pascals:
Audiogram.InterpolatedThreshDB = interp1(Audiogram.FreqKHz, Audiogram.ThreshDBSPL, Comparison.Condtn(1).Recordings(1).DFT.FrequenciesKHz)'; % Interpolate audiogram:
Audiogram.InterpolatedThreshPa = db2pa(Audiogram.InterpolatedThreshDB); 

% Compute frequency step: 
frequencyStep = max(Comparison.Condtn(1).Recordings(1).DFT.FrequenciesKHz) / length(Comparison.Condtn(1).Recordings(1).DFT.FrequenciesKHz); % frequency step size, in KHz per step; TODO: include way of confirming that FrequenciesKHz is identical for all recordings?

% For each condition, take the integral of P(c,f)/A(f), where P(c,f) is the periodogram for condition c and A(f) is the audiogram:
for d = 1:length(conditions)
    Ratio = Comparison.Condtn(d).MeanDFTPaRMS./Audiogram.InterpolatedThreshPa; % want to take this ratio in pascals, not decibels
    indices = floor([Comparison.Condtn(d).LowF, Comparison.Condtn(d).HighF]./frequencyStep);    
    Comparison.Condtn(d).Integral = sum(Ratio(indices(1):indices(2)));
end

Comparison.ScaleFactor = Comparison.Condtn(1).Integral/Comparison.Condtn(2).Integral;


%% Plot:

f = figure;
hold on;

% Plot the mean DFT for each sitmulus condition in dB SPL
for e = 1:length(conditions)    
    Comparison.Condtn(e).MeanDFTdBSPL = pa2db(Comparison.Condtn(e).MeanDFTPaRMS); % for plotting purposes, it will be convenient to also have the mean DFT in dB SPL
    Figures(e).plot = plot(Comparison.Condtn(e).Recordings(1).DFT.FrequenciesKHz, Comparison.Condtn(e).MeanDFTdBSPL, 'Color', Colors(e,:));
end

% Plot audiogram:
audiogramPlot = plot(Comparison.Condtn(1).Recordings(1).DFT.FrequenciesKHz, Audiogram.InterpolatedThreshDB, 'LineWidth', 1.5, 'Color', [1, 0, 0]);

% Plot rectangles corresponding to frequency band of each stimulus:
for f = 1:length(conditions)
    yl = ylim;
    recY = [yl fliplr(yl)];    
    p1 = patch([Comparison.Condtn(f).LowF Comparison.Condtn(f).LowF Comparison.Condtn(f).HighF Comparison.Condtn(f).HighF], recY, [0.5, 0.5, 0.95], 'FaceAlpha', 0.4, 'EdgeColor', 'none');    
end

titleStr = {strcat(['Stimulus periodograms & murine audiogram']);
            strcat(['played from speaker ', Recording.Speaker]);
            strcat(['acquired ', Recording.Date]);
};

title(titleStr);
xlabel('Frequency (kHz)');
ylabel('Volume (dB SPL)');

agName = strcat([Audiogram.Authors{1}{1}, ' et al ', num2str(Audiogram.Year)]);

legend([Figures(1).plot Figures(2).plot audiogramPlot],... 
       ['Stim #1 (' num2str(Comparison.Condtn(1).LowF) '-' num2str(Comparison.Condtn(1).HighF) ' KHz)' ],...
       ['Stim #2 (' num2str(Comparison.Condtn(2).LowF) '-' num2str(Comparison.Condtn(2).HighF) ' KHz)' ],...
       strcat(['Murine audiogram (', agName, ')']));

   
%% Include some metadata:

Comparison.Speaker = Recording.Speaker; % should check that speaker for all recordings is the same?
Comparison.mFile.Path = [mfilename('fullpath') '.m'];
Comparison.mFile.SHA1 = getSHA1(Comparison.mFile.Path);   
   
cd(tld);
save('Stim1vsStim2.mat', 'Comparison');
savefig('Stim1vsStim2');
   

%% Plot the audiogram

%{    
    % Load Recording, get metadata
    load(conditions{c});
    Comparison.Stimulus(c).Path = conditions{c};
    Comparison.Stimulus(c).Recording = Recording;
    
    Comparison.Speaker = Recording.Speaker;
    
    % Compute integral of ratio of periodogram to audiogram
    Comparison.Condtn(c).Recording(r).FrequenciesKHz = Comparison.Stimulus(c).DFT.FrequenciesHz/1000; % convert frequencies associated with the DFT from Hz to KHz
    

    frequencyStep = max(Comparison.Stimulus(c).FrequenciesKHz)/length(Comparison.Stimulus(c).FrequenciesKHz); % frequency step size, in KHz per step



    
    % Plot...
    Comparison.Stimulus(c).DFT.AmplitudesDBSPL = pa2db(Comparison.Stimulus(c).DFT.AmplitudesPaRMS); % convert amplitudes associated with the DFT from pascals RMS into decibels; PLOTTING PURPOSES ONLY
    
    
    % ... raw periodogram...
    Figures(c).fig = figure;
    hold on;
    rawPeriodogram = plot(Comparison.Stimulus(c).FrequenciesKHz, Comparison.Stimulus(c).DFT.AmplitudesDBSPL);
    
    % ... smoothed periodogram...
    boxWidth = 100;
    smoothIndices = (boxWidth/2:1:length(Comparison.Stimulus(c).DFT.AmplitudesDBSPL)-boxWidth/2);
    dbSmooth = arrayfun(@(a) mean(Comparison.Stimulus(c).DFT.AmplitudesDBSPL(a-boxWidth/2+1:a+boxWidth/2)), smoothIndices);
    smoothPeriodogram = plot(Comparison.Stimulus(c).FrequenciesKHz(smoothIndices), dbSmooth, 'Color', [0, 0, 0.5]);
    
    % ... audiogram...

    
    % ... rectangle corresponding to frequency range
    Figures(c).yl = ylim;
    
    % Label figure





    
    Comparison.Stimulus(c).LowF = lowF;
    Comparison.Stimulus(c).HighF = highF;
    
end

% Make both figures have same y range
maxY = max([max(Figures(1).yl), max(Figures(2).yl)]);
minY = min([min(Figures(1).yl), min(Figures(2).yl)]);
yRange = [minY maxY];

for s = 1:2
    figure(Figures(s).fig);
    ylim(yRange);


    savefig(strcat(['stim', num2str(Comparison.Stimulus(s).Recording.StimID)]));
end

Comparison.ScaleFactor = Comparison.Stimulus(1).Integral/Comparison.Stimulus(2).Integral;
save('Stim1vsStim2.mat', 'Comparison');
%}

end