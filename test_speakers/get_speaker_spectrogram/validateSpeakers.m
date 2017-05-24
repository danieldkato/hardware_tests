function validateSpeaker(name, min, max)
    
    try
        load('Speakers.mat');
    catch ME
        warning(ME, 'Speaker defintions not found, skipping validation. Requested stimulus frequencies may be outside of speaker range.');
        return
    end
    
    match = 0;
    
    for i = 1:length(Speakers)
        if strcmp(name, Speakers(i).Name)
            match = 1;
            if min < Speakers(i).MinF      
                warning('Desired minimum stimulus frequency outside of speaker range'); 
            end
            if max > Speakers(i).MaxF
                warning('Desired maximum stimulus frequency outside of speaker range');
            end
        end
    end
    
    if match == 0
        warning('No match for specified speaker found in speaker definitions. Make sure that specified name exactly matches a name in definitions file. If no exact match exists, requested stimulus frequencies may be outside speaker range.');
    end