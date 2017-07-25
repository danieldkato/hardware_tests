function Comparison = noiseScaleFactor2(cond1path, cond2path, varargin);
%% Check if audiogram was defined, and if not, use default audiogram

audiogramPath = 'audiogram_Heffner2002';

if length(varargin)>0
    audiogramPath = varargin{1};
end

Comparison.AudiogramPath = audiogramPath;
Comparison.Speaker = 'unknown';

load(audiogramPath); 
Audiogram.ThreshPa.Raw = db2pa(Audiogram.ThreshDBSPL); % convert from dB SPL to pascals

conditions = {cond1path, cond2path};


%% For each stimulus condition, compute the mean DFT:

for c = 1:length(conditions)
    
    cd(conditions{c});
    recordingDirs = dir;
    disp('recordingDirs');
    disp(recordingDirs);
    
    % Compute the DFT for each recording within the current stimulus condition:
    for r = 3:length(recordingDirs)
        old = cd(recordingDirs(r).name);
        files = dir;
        
        % In the directory for the current recording, find and load the file that ends in .mat:
        out = cellfun(@(a) strfind(a, '.mat'), {files.name}, 'UniformOutput', 0);
        out2 = cellfun(@(c) isempty(c), out);
        matFileName = files(~out2).name;
        load(matFileName); % this loads a struct called `Recording` into the workspace
        disp(Recording);
        cd(old);
        
        
        % Get the Fourier transform of the recording in pascals RMS:
        Comparison.Condtn(c).Recording(r).DFT = dftRMS(Recording); 
        disp('size DFT');
        disp(size(Comparison.Condtn(c).Recording(r).DFT));
      
    end
    
    %Comparison.Condtn(c).MeanDFT = mean();
    
end    
    

  

%%
    
%{    
    % Load Recording, get metadata
    load(conditions{c});
    Comparison.Stimulus(c).Path = conditions{c};
    Comparison.Stimulus(c).Recording = Recording;
    
    Comparison.Speaker = Recording.Speaker;
    
    % Compute integral of ratio of periodogram to audiogram
    Comparison.Condtn(c).Recording(r).FrequenciesKHz = Comparison.Stimulus(c).DFT.FrequenciesHz/1000; % convert frequencies associated with the DFT from Hz to KHz
    Audiogram.ThreshPa.Interpolated = interp1(Audiogram.FreqKHz, Audiogram.ThreshPa.Raw, Comparison.Stimulus(c).FrequenciesKHz)';
    Rat = Comparison.Stimulus(c).DFT.AmplitudesPaRMS./Audiogram.ThreshPa.Interpolated; % want to take this ratio in pascals, not decibels
    frequencyStep = max(Comparison.Stimulus(c).FrequenciesKHz)/length(Comparison.Stimulus(c).FrequenciesKHz); % frequency step size, in KHz per step
    lowF = (Recording.VI.Stim.StartFreqs.val(Recording.StimID))/1000; % remember to convert to kHz
    highF = lowF + (Recording.VI.Stim.FreqRange.val)/1000; % remember to convert to kHz
    indices = floor([lowF, highF]./frequencyStep);
    Comparison.Stimulus(c).Integral = sum(Rat(indices));
    
    % Plot...
    Comparison.Stimulus(c).DFT.AmplitudesDBSPL = pa2db(Comparison.Stimulus(c).DFT.AmplitudesPaRMS); % convert amplitudes associated with the DFT from pascals RMS into decibels; PLOTTING PURPOSES ONLY
    Audiogram.ThreshDB.Interpolated = pa2db(Audiogram.ThreshPa.Interpolated); % for plotting purposes only
    
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
    audiogramPlot = plot(Comparison.Stimulus(c).FrequenciesKHz, Audiogram.ThreshDB.Interpolated, 'LineWidth', 1.5, 'Color', [1, 0, 0]);
    
    % ... rectangle corresponding to frequency range
    Figures(c).yl = ylim;
    
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
    recY = [yRange fliplr(yRange)];
    p1 = patch([Comparison.Stimulus(s).LowF Comparison.Stimulus(s).LowF Comparison.Stimulus(s).HighF Comparison.Stimulus(s).HighF], recY, [0.95, 0.95, 0.25], 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    savefig(strcat(['stim', num2str(Comparison.Stimulus(s).Recording.StimID)]));
end

Comparison.ScaleFactor = Comparison.Stimulus(1).Integral/Comparison.Stimulus(2).Integral;
save('Stim1vsStim2.mat', 'Comparison');
%}

end