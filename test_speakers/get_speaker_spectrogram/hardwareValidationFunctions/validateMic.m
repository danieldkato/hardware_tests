function warnings = validateMic(name, min, max)
    
    warnings = {};

    try
        load('Mics.mat');
    catch ME
        warning(ME, 'Microphone defintions not found, skipping validation. Requested stimulus frequencies may be outside of microphone range.');
        warnings = horzcat(warnings, {lastwarn});
        return
    end
    
    match = 0;
    
    for i = 1:length(Mics)
        if strcmp(name, Mics(i).Mdl)
            match = 1;
            
            if isnan(Mics(i).MinF)
                warning('Minimum frequency not specified in selected microphone definition. Specified stimulus may be outside of microphone frequency range.');
                warnings = horzcat(warnings, {lastwarn});
            elseif min < Mics(i).MinF      
                warning('Requested minimum stimulus frequency outside of microphone range'); 
                warnings = horzcat(warnings, {lastwarn});
            end
            
            if isnan(Mics(i).MaxF)
                warning('Maximum frequency not specified in selected microphone definition. Specified stimulus may be outside of microphone frequency range.');
                warnings = horzcat(warnings, {lastwarn});
            elseif max > Mics(i).MaxF
                warning('Requested maximum stimulus frequency outside of microphone range');
                warnings = horzcat(warnings, {lastwarn});
            end
        end
    end
    
    if match == 0
        warning('No match for specified microphone found in microphone definitions. Make sure that specified name exactly matches a name in definitions file. If no exact match exists, requested stimulus frequencies may be outside microphone range.');
    end
    