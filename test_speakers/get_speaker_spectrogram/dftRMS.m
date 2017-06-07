function f2rms = dftRMS(Recording)

% DOCUMENTATION TABLE OF CONTENTS
% I. SYNTAX
% II. OVERVIEW
% III. REQUIREMENTS
% IV. INPUTS
% V. OUTPUTS


%%
% I. SYNTAX
% f2rms = dftRMS(Recording)


% II. OVERVIEW
% This function takes a time-series vector of an audio recording and
% returns a vector of rms amplitudes for each frequency component. In other
% words, for each frequency, it gives the rms amplitude of the sinusoid of
% that frequency that would be needed to reconstruct the original stimulus.


% III. REQUIREMENTS
% 


% IV. INPUTS
% 1) Recording - a struct containing data and metadat from an audio
% recording. It must have at least the following fields:
%   Data % actual recording data
%   TrueSampleRate % actual sample rate, in Hz, of recording 
%   PreStimDuration.val % pre-stimulus period duration, in seconds (can be 0)
%   PostStimDuration.val % post-stimulus period duration, in seconds (can be 0)
%   Microphone % model number of microphone used to make recording


% V. OUTPUTS
% 1) f2rms - a 1 x N vector where the i-th element specifies the RMS
% amplitude of the i-th frequency component of the original signal. 


% TODO:
% 1) Provide alternative syntax to accept HDF5 inputs?
% 2) Provide alternative syntax to accept non-struct, non-HDF5 inputs?


%% Load voltage trace and get recording metadata    
preStimDur = Recording.PreStimDuration.val;
postStimDur = Recording.PostStimDuration.val;
stimVolts = Recording.Data(ceil(preStimDur*trueSampleRate):length(Recording.Data) - ceil(postStimDur * Recording.TrueSampleRate));

% Get mic sensitivity by looking it up; might want to offer alternative
% ways of entering mic sensitivity if make this optional if mic database is
% not available
load('Mics.mat') % load microphone specs
for m = 1:length(Mics)
        if strcmp(Mics(m).Mdl, Recording.Microphone)
            sensitivity = Mics(m).Sensitivity * 1000; % convert from mV/Pa to V/Pa
        end
end


%%
N = length(stimVolts);
P = stimVolts/sensitivity; % convert voltage trace to pressure trace in pascals

% Get DFT of pressure trace using fft(). In order to convert this to an
% peak-to-peak *amplitude* spectrum (as opposed to a power spectrum), take
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
f2rms = DFT/sqrt(2);

end