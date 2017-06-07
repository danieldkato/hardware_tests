function F2PaRMS = dftPaRMS(recording)

% DOCUMENTATION TABLE OF CONTENTS
% I. SYNTAX
% II. OVERVIEW
% III. REQUIREMENTS
% IV. INPUTS
% V. OUTPUTS


%%
% I. SYNTAX
% DFTPa = DFT2Pa(stimData)

% II. OVERVIEW
% This function takes a time-series of an analog of an auditory
% stimulus and returns its discrete fourier transform expressed in Pascals.
% In other words, for each frequency, it gives the amplitude of the wave of
% that frequenct that would be needed to reconstruct the original stimulus.

% III. REQUIREMENTS
% 

% IV. INPUTS



%% Load voltage trace and get recording metadata    
load(recording);
preStimDur = Recording.PostStimDuration.val;
postStimDur = Recording.PostStimDuration.val;
trueSampleRate = Recording.TrueSampleRate.val;
stimDur = Recording.StimDur.val;
stimMinFreq = Recording.StimMinFreq.val;
stimMaxFreq = Recording.StimMaxFreq.val;
stimVolts = Recording.Data(ceil(preStimDur*trueSampleRate):length(Recording.Data) - ceil(postStimDur * trueSampleRate));
currentMic = Recording.Microphone;

% Get mic sensitivity by looking it up; might want to offer alternative
% ways of entering mic sensitivity if make this optional if mic database is
% not available
load('Mics.mat') % load microphone specs
for m = 1:length(Mics)
        if strcmp(Mics(m).Mdl, currentMic)
            sensitivity = Mics(m).Sensitivity * 1000; % convert from mV/Pa to V/Pa
        end
end


%%
N = length(stimVolts);
P = stimVolts/sensitivity; % convert voltage trace to pressure trace in pascals

% Get DFT of pressure trace using fft(). In order to convert this to an
% *amplitude* spectrum (as opposed to a power spectrum), take
% abs(fft(x)/N). In other words, if you add sine waves of frequency F and G
% with amplitudes A and B, respectively, and want to obtain a transform
% where the F-th frequency component will be A, and the G-th frequency
% component will be B, then take abs(fft(x)/N). See documentation for fft()
% at https://www.mathworks.com/help/matlab/ref/fft.html for illustration.
DFT = fft(P);
DFT = abs(DFT/N); 

% Convert DFT from double-sided to single-sided amplitude spectrum. The
% amplitude of the F-th frequency component will actually be A/2, because
% fft() returns a symmetrical 'double-sided' amplitude spectrum that
% includes both positive- and negative-valued frequencies, and the
% magnitude of the F-th component is divided between the positive and
% negative halves. We are not interested in representing negative
% frequencies, however, so we discard the negative frequencies (in the
% second half of the DFT) and multiply the magnitude of the positive
% frequencies (in the first half of the DFT, excluding the first
% element,which represents DC) by 2. Again, see the documentation for fft()
% at https://www.mathworks.com/help/matlab/ref/fft.html for an
% illustration.
DFT = DFT(1:N/2+1);
DFT(2:end-1) = 2*DFT(2:end-1);

% Convert peak-to-peak amplitudes to RMS amplitudes. We need to do this
% because we ultimately want to compare these pressure values to hearing
% thresholds in dB SPL, and dB SPL is computed from the RMS amplitude of a
% sound wave. For sinusoids, RMS amplitude is peak-to-peak amplitude
% divided by sqrt(2):
% https://en.wikipedia.org/wiki/Root_mean_square
% https://dsp.stackexchange.com/questions/14808/spl-values-from-fft-of-microphone-signal
F2PaRMS = DFT/sqrt(2);


end