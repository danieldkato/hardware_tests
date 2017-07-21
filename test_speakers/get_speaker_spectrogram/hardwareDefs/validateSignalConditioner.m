function warnings = validateSignalConditioner(name, min, max)
    
    warnings = {};

    try
        load('SignalConditioners.mat');
    catch ME
        warning(ME, 'Signal conditioner defintions not found, skipping validation. Requested stimulus frequencies may be outside of signal conditioner range.');
        warnings = horzcat(warnings, {lastwarn});
        return
    end
    
    match = 0;
    
    for i = 1:length(SignalConditioners)
        if strcmp(name, SignalConditioners(i).Mdl)
            match = 1;
            
            if isnan(SignalConditioners(i).MinF)
                warning('Minimum frequency not specified in selected signal conditioner definition. Specified stimulus may be outside of signal conditioner frequency range.');
                warnings = horzcat(warnings, {lastwarn});
            elseif min < SignalConditioners(i).MinF      
                warning('Requested minimum stimulus frequency outside of signal conditioner range'); 
                warnings = horzcat(warnings, {lastwarn});
            end

            if isnan(SignalConditioners(i).MaxF)
                warning('Maximum frequency not specified in selected signal conditioner definition. Specified stimulus may be outside of signal conditioner frequency range.');
                warnings = horzcat(warnings, {lastwarn});
            elseif max > SignalConditioners(i).MaxF
                warning('Requested maximum stimulus frequency outside of signal conditioner range');
                warnings = horzcat(warnings, {lastwarn});
            end
        end
    end
    
    if match == 0
        warning('No match for specified signal conditioner found in signal conditioner definitions. Make sure that specified name exactly matches a name in definitions file. If no exact match exists, requested stimulus frequencies may be outside signal conditioner range.');
        warnings = horzcat(warnings, {lastwarn});
    end
    