function validateMic(name, min, max)
    
    try
        load('Mics.mat');
    catch ME
        warning(ME, 'Microphone defintions not found, skipping validation. Requested stimulus frequencies may be outside of microphone range.');
        return
    end
    
    match = 0;
    
    for i = 1:length(Mics)
        if strcmp(name, Mics(i).Name)
            match = 1;
            
            if isnan(Mics(i).MinF)
                warning('Minimum frequency not specified in selected microphone definition. Specified stimulus may be outside of microphone frequency range.');
            elseif min < Mics(i).MinF      
                warning('Desired minimum stimulus frequency outside of microphone range'); 
            end
            
            if isnan(Mics(i).MaxF)
                warning('Maximum frequency not specified in selected microphone definition. Specified stimulus may be outside of microphone frequency range.');
            elseif max > Mics(i).MaxF
                warning('Desired maximum stimulus frequency outside of microphone range');
            end
        end
    end
    
    if match == 0
        warning('No match for specified microphone found in microphone definitions. Make sure that specified name exactly matches a name in definitions file. If no exact match exists, requested stimulus frequencies may be outside microphone range.');
    end