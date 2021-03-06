function warnings = validateSpeaker(name, min, max)
    
    warnings = {};
    
    try
        load('Speakers.mat');
    catch ME
        warning(ME, 'Speaker defintions not found, skipping validation. Requested stimulus frequencies may be outside of speaker range.');
        warnings = horzcat(warnings, {lastwarn});
        return
    end
    
    match = 0;
    
    for i = 1:length(Speakers)
        if strcmp(name, Speakers(i).Mdl)
            match = 1;
            
            if isnan(Speakers(i).MinF)
                warning('Minimum frequency not specified in selected speaker definition. Specified stimulus may be outside of speaker frequency range.');
                warnings = horzcat(warnings, {lastwarn});
            elseif min < Speakers(i).MinF      
                warning('Desired minimum stimulus frequency outside of speaker range'); 
                warnings = horzcat(warnings, {lastwarn});
            end
            
            if isnan(Speakers(i).MaxF)
                warning('Maximum frequency not specified in selected speaker definition. Specified stimulus may be outside of speaker frequency range.');            
                warnings = horzcat(warnings, {lastwarn});
            elseif max > Speakers(i).MaxF
                warning('Desired maximum stimulus frequency outside of speaker range');
                warnings = horzcat(warnings, {lastwarn});
            end
        end
    end
    
    if match == 0
        warning('No match for specified speaker found in speaker definitions. Make sure that specified name exactly matches a name in definitions file. If no exact match exists, requested stimulus frequencies may be outside speaker range.');
        warnings = horzcat(warnings, lastwarn);
    end