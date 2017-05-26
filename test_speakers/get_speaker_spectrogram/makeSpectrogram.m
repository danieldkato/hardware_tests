function makeSpectrogram()

%Calculate fft:
stimData = data(preStimDur*trueSampleRate:end);
xfft = abs(fft(stimData));

%Avoid taking the log of 0.
index = find(xfft == 0);
xfft(index) = 1e-17;

%Convert to decibels:
blocksize = stimDur * trueSampleRate;
mag = 20*log10(xfft);
mag = mag(1:floor(blocksize/2));
f = (0:length(mag)-1)*Fs/blocksize;
f = f(:);

%Plot fft:
figure;
plot(f,mag);
grid on
ylabel('Magnitude (dB)');
xlabel('Frequency (Hz)');
speakerName = speakers{spkrInd}{1};
micName = mics{micInd}{1};
scName = signalConditioners{scInd}{1};
titleStr = strcat(['Frequency components of ', speakerName, ', ', num2str(stimMinFreq),'-',num2str(stimMaxFreq), ' Hz white noise' ]);
title(titleStr);
legendStr = strcat([micName, ' with ', scName]);
legend(legendStr);


%Create spectrogram:
%WARNING: Calling spectrogram on hs05bruno ('') has raised errors related
%to memory issues before. It may be necessary to actually the data offline
%on another computer.
if strcmp(getenv('computername'), 'HS05BRUNO8') == 0
    spectrogram(data, 128, 120, [], 'yaxis');
    titleStr2 = strcat(['Spectrogram of ', speakerName, ', ', num2str(stimMinFreq),'-',num2str(stimMaxFreq), ' Hz white noise' ]);
    title(titleStr2);
end 


disp('Done');