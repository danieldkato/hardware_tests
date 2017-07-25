function Comparison = noiseScaleFactor2(recordingPath1, recordingPath2, varargin);
%% Check if audiogram was defined, and if not, use default audiogram

audiogramPath = 'audiogram_Heffner2002';

if length(varargin)>0
    audiogramPath = varargin{1};
end

Comparison.AudiogramPath = audiogramPath;
Comparison.Speaker = 'unknown';

load(audiogramPath); 
Audiogram.ThreshPa.Raw = db2pa(Audiogram.ThreshDBSPL); % convert from dB SPL to pascals

%%
recordings = {recordingPath1, recordingPath2};

for i = 1:length(recordings)
    
    % Load Recording, get metadata
    load(recordings{i});
    Comparison.Stimulus(i).Path = recordings{i};
    Comparison.Stimulus(i).Recording = Recording;
    
    Comparison.Speaker = Recording.Speaker;
    
    % Compute integral of ratio of periodogram to audiogram
    Comparison.Stimulus(i).DFT = dftRMS(Recording); % get the Fourier transform of the recording in pascals RMS
    Comparison.Stimulus(i).FrequenciesKHz = Comparison.Stimulus(i).DFT.FrequenciesHz/1000; % convert frequencies associated with the DFT from Hz to KHz
    Audiogram.ThreshPa.Interpolated = interp1(Audiogram.FreqKHz, Audiogram.ThreshPa.Raw, Comparison.Stimulus(i).FrequenciesKHz)';
    Rat = Comparison.Stimulus(i).DFT.AmplitudesPaRMS./Audiogram.ThreshPa.Interpolated; % want to take this ratio in pascals, not decibels
    frequencyStep = max(Comparison.Stimulus(i).FrequenciesKHz)/length(Comparison.Stimulus(i).FrequenciesKHz); % frequency step size, in KHz per step
    lowF = (Recording.VI.Stim.StartFreqs.val(Recording.StimID))/1000; % remember to convert to kHz
    highF = lowF + (Recording.VI.Stim.FreqRange.val)/1000; % remember to convert to kHz
    indices = floor([lowF, highF]./frequencyStep);
    Comparison.Stimulus(i).Integral = sum(Rat(indices));
    
    % Plot...
    Comparison.Stimulus(i).DFT.AmplitudesDBSPL = pa2db(Comparison.Stimulus(i).DFT.AmplitudesPaRMS); % convert amplitudes associated with the DFT from pascals RMS into decibels; PLOTTING PURPOSES ONLY
    Audiogram.ThreshDB.Interpolated = pa2db(Audiogram.ThreshPa.Interpolated); % for plotting purposes only
    
    % ... raw periodogram...
    Figures(i).fig = figure;
    hold on;
    rawPeriodogram = plot(Comparison.Stimulus(i).FrequenciesKHz, Comparison.Stimulus(i).DFT.AmplitudesDBSPL);
    
    % ... smoothed periodogram...
    boxWidth = 100;
    smoothIndices = (boxWidth/2:1:length(Comparison.Stimulus(i).DFT.AmplitudesDBSPL)-boxWidth/2);
    dbSmooth = arrayfun(@(a) mean(Comparison.Stimulus(i).DFT.AmplitudesDBSPL(a-boxWidth/2+1:a+boxWidth/2)), smoothIndices);
    smoothPeriodogram = plot(Comparison.Stimulus(i).FrequenciesKHz(smoothIndices), dbSmooth, 'Color', [0, 0, 0.5]);
    
    % ... audiogram...
    audiogramPlot = plot(Comparison.Stimulus(i).FrequenciesKHz, Audiogram.ThreshDB.Interpolated, 'LineWidth', 1.5, 'Color', [1, 0, 0]);
    
    % ... rectangle corresponding to frequency range
    Figures(i).yl = ylim;
    
    % Label figure
    titleStr = {strcat(['Stim #', num2str(Recording.StimID), ' (', num2str(lowF), '-',  num2str(highF), ' kHz) periodogram & murine audiogram']);
                strcat(['played from speaker ', Recording.Speaker]);
                strcat(['acquired ', Recording.Date, ' ', Recording.Time]);
    };

    title(titleStr);
    xlabel('Frequency (kHz)');
    ylabel('Volume (dB SPL)');
    agName = strcat([Audiogram.Authors{1}{1}, ' et al ', num2str(Audiogram.Year)]);
    legend([rawPeriodogram, audiogramPlot], {strcat(['Stim #', num2str(Recording.StimID), ' periodogram']),
            strcat(['Murine audiogram (', agName, ')'])
    });
    
    Comparison.Stimulus(i).LowF = lowF;
    Comparison.Stimulus(i).HighF = highF;
    
end

% Make both figures have same y range
maxY = max([max(Figures(1).yl), max(Figures(2).yl)]);
minY = min([min(Figures(1).yl), min(Figures(2).yl)]);
yRange = [minY maxY];

for s = 1:2
    figure(Figures(s).fig);
    ylim(yRange);
    recY = [yRange fliplr(yRange)];
    p1 = patch([Comparison.Stimulus(s).LowF Comparison.Stimulus(s).LowF Comparison.Stimulus(s).HighF Comparison.Stimulus(s).HighF], recY, [0.95, 0.95, 0.25], 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    savefig(strcat(['stim', num2str(Comparison.Stimulus(s).Recording.StimID)]));
end

Comparison.ScaleFactor = Comparison.Stimulus(1).Integral/Comparison.Stimulus(2).Integral;
save('Stim1vsStim2.mat', 'Comparison');

end