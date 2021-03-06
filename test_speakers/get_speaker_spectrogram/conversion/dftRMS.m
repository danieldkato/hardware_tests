function D = dftRMS(Recording)

% DOCUMENTATION TABLE OF CONTENTS
% I. OVERVIEW
% II. REQUIREMENTS
% III. INPUTS
% IV. OUTPUTS


%%
% I. OVERVIEW
% This function takes an audio recording in the time domain and returns its
% Fourier tansform in terms of RMS pascals. In other words, for each
% frequency, it gives the amplitude in RMS pascals of the sinusoid of that
% frequency that would be needed to reconstruct the original stimulus.


%% II. REQUIREMENTS
% 1) volts2pascals, available at https://github.com/danieldkato/hardware_tests/tree/master/test_speakers/get_speaker_spectrogram/conversion


%% III. INPUTS
% 1) Recording - a struct containing data and metadat from an audio
% recording. It must have at least the following fields:
%   a) Data - actual recording data
%   b) TrueSampleRate - actual sample rate, in Hz, of recording 
%   c) PreStimDuration.val - pre-stimulus period duration, in seconds (can be 0)
%   d) PostStimDuration.val - post-stimulus period duration, in seconds (can be 0)
%   e) Microphone - model number of microphone used to make recording (necessary for 
%      retrieving the mic's sensitivity, which specifies the conversion from Volts 
%      to pascals)


%% IV. OUTPUTS
% 1) D - a structure with the following fields:
%   a) AmplitudesPaRMS - 1 x N DFT vector where the i-th element specifies the RMS
%      amplitude of the i-th frequency component of the original signal.
%   b) FrequenciesHz - 1 x N vector of the frequencies associated with each
%      frequency component, in Hz


%% TODO:
% 1) Provide alternative syntax to accept HDF5 inputs?
% 2) Provide alternative syntax to accept non-struct, non-HDF5 inputs?


%% Pre-processing:

% Convert voltage to pascals:
pascals = volts2pascals(Recording); 

% Extract data from just the stimulus period:
preStimDur = Recording.PreStimDuration.val; 
postStimDur = Recording.PostStimDuration.val; 
P = pascals(ceil(preStimDur*Recording.TrueSampleRate.val):length(Recording.Data) - ceil(postStimDur * Recording.TrueSampleRate.val));

% Make time-series even-lengthed if it isn't already:
if mod(length(P),2) ~= 0
    P = P(1:end-1);
end
N = length(P);


%% Fourier analysis:

% Get DFT of pressure trace using fft(). In order to convert this to an
% peak-to-peak *amplitude* spectrum (as opposed to a *power* spectrum),
% take abs(fft(x)/N). In other words, the value of the F-th element of
% abs(fft(x)/N) is the peak-to-amplitude of the associated frequency needed
% to reconstruct the original signal. See documentation for fft() at
% https://www.mathworks.com/help/matlab/ref/fft.html for illustration.
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
D.AmplitudesPaRMS = DFT/sqrt(2);

% Get the actual frequencies, in Hz, that each of these components
% correspond to 
f = (0:length(D.AmplitudesPaRMS)-1) * (Recording.TrueSampleRate.val/N);
D.FrequenciesHz = f;

end