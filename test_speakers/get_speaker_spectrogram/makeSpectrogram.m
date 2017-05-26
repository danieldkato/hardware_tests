function makeSpectrogram(path)

%Load data and metadata from secondary storage:
load(path);
preStimDur = Session.preStimDur.value;
trueSampleRate = Session.trueSampleRate.value;
stimDur = Session.stimDur.value;
stimMinFreq = Session.stimMinFreq.value;
stimMaxFreq = Session.stimMaxFreq.value;

%Calculate fft:
stimData = Session.data(ceil(preStimDur*trueSampleRate):end);
xfft = abs(fft(stimData));

%Avoid taking the log of 0.
index = find(xfft == 0);
xfft(index) = 1e-17;

%Convert to decibels:
blocksize = stimDur * trueSampleRate;
mag = 20*log10(xfft);
mag = mag(1:floor(blocksize/2));
f = (0:length(mag)-1)*trueSampleRate/blocksize;
f = f(:);

%Plot fft:
figure;
plot(f,mag);
grid on
%ylabel('Magnitude (dB)');
%xlabel('Frequency (Hz)');


%{
speakerName = speakers{spkrInd}{1};
micName = mics{micInd}{1};
scName = signalConditioners{scInd}{1};
%}
% titleStr = strcat(['Frequency components of ', Session.speakerName, ', ', num2str(stimMinFreq),'-',num2str(stimMaxFreq), ' Hz white noise' ]);
titleStr = {strcat([num2str(floor(stimMinFreq/1000)), '-', num2str(floor(stimMaxFreq/1000)), ' kHz noise']);
            strcat(['acquired from speaker ', Session.Speaker, ' ', Session.Date]);
            strcat(['Mic: ', Session.Microphone]);
            strcat(['Signal Conditioner: ', Session.SignalConditioner, ', Gain: x', num2str(Session.sigCondGain)]);
            };
title(titleStr);

%{
legendStr = strcat([micName, ' with ', scName]);
legend(legendStr);
%}

%Create spectrogram:
%WARNING: Calling spectrogram on hs05bruno ('') has raises errors related to memory issues.
figure;
hold on;
spectrogram(Session.data, 128, 120, [], 'yaxis');
%titleStr2 = strcat(['Spectrogram of ', speakerName, ', ', num2str(stimMinFreq),'-',num2str(stimMaxFreq), ' Hz white noise' ]);
title(titleStr);


disp('Done');