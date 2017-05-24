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
            if min < Mics(i).MinF      
                warning('Desired minimum stimulus frequency outside of microphone range'); 
            end
            if max > Mics(i).MaxF
                warning('Desired maximum stimulus frequency outside of microphone range');
            end
        end
    end
    
    if match == 0
        warning('No match for specified microphone found in microphone definitions. Make sure that specified name exactly matches a name in definitions file. If no exact match exists, requested stimulus frequencies may be outside microphone range.');
    end