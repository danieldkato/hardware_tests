function Comparison = noiseScaleFactor2(cond1path, cond2path, varargin);
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
        %Comparison.Condtn(c).Recording(r-2).Path = strcat[cd filesep ]
        
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

end


%% Compute the scale factor:

% Interpolate audiogram and convert from dB SPL to RMS pascals:
Audiogram.InterpolatedThreshDB = interp1(Audiogram.FreqKHz, Audiogram.ThreshDBSPL, Comparison.Condtn(1).Recordings(1).DFT.FrequenciesKHz)'; % Interpolate audiogram:
Audiogram.InterpolatedThreshPa = db2pa(Audiogram.InterpolatedThreshDB); 

% Compute frequency step: 
frequencyStep = max(Comparison.Condtn(1).Recordings(1).DFT.FrequenciesKHz)/length(Comparison.Condtn(1).Recordings(1).DFT.FrequenciesKHz); % frequency step size, in KHz per step; TODO: include way of confirming that FrequenciesKHz is identical for all recordings?

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