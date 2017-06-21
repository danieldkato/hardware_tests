% this script can be just for plotting

%% Define desired frequency bands:
range1 = [4 8];
range2 = [15 19];


%% Create periodogram of recording:
load(nm); 
DFTpa = dftRMS(Recording); % get the Fourier transform of the recording in pascals RMS
KHz = DFTpa.Frequencies/1000; % convert frequencies associated with the DFT from Hz to KHz
db = pa2db(DFTpa.Amplitudes); % convert amplitudes associated with the DFT from pascals RMS into decibels; PLOTTING PURPOSES ONLY


%% Load audiogram:
load('audiogram_Heffner2002'); 

Audiogram.ThreshPa = db2pa(Audiogram.ThreshDBSPL);

% Interpolate audiogram for comparison with periodogram;
% output will have the same length as rmsPa.Amplitudes 
interpolatedAudiogramPa = interp1(Audiogram.FreqKHz, Audiogram.ThreshPa, KHz)';
interpolatedAudiogramDBSPL = interp1(Audiogram.FreqKHz, Audiogram.ThreshDBSPL, KHz)'; % for plotting purposes only


%% Compute scale factor: 
Ratio = DFTpa.Amplitudes./interpolatedAudiogramPa; % want to take this ratio in pascals, not decibels

% Convert bounds of desired frequency ranges from KHz into indices into Ratio:
frequencyStep = max(KHz)/length(KHz); % frequency step size, in KHz per step
range1indices = floor(range1./frequencyStep); 
range2indices = floor(range2./frequencyStep);

range1int = sum(Ratio(range1indices(1):range1indices(2)));
range2int = sum(Ratio(range2indices(1):range2indices(2)));
scaleFactor = range1int/range2int;


%% Create figure with audiogram superimposed on periodogram:
figure;
hold on;
plot(KHz, db);

% Smooth the periodogram:
boxWidth = 100;
smoothIndices = (boxWidth/2:1:length(db)-boxWidth/2);
dbSmooth = arrayfun(@(a) mean(db(a-boxWidth/2+1:a+boxWidth/2)), smoothIndices);
plot(KHz(smoothIndices), dbSmooth, 'Color', [0, 0, 0.5]);

% Plot audiogram:
plot(KHz, interpolatedAudiogramDBSPL, 'LineWidth', 1.5);
xlabel('Frequency (kHz)');
ylabel('Volume (dB SPL)');

% Plot rectangles corresponding to target frequency ranges:
yl = ylim;
recY = [yl fliplr(yl)];
p = patch([range1(1) range1(1) range1(2) range1(2)], recY, [0.75, 0.0, 0.0], 'FaceAlpha', 0.2, 'EdgeColor', 'none');
p = patch([range2(1) range2(1) range2(2) range2(2)], recY, [0.75, 0.0, 0.0], 'FaceAlpha', 0.2, 'EdgeColor', 'none');


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


