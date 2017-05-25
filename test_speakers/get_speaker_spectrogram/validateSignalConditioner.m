function validateSignalConditioner(name, min, max)
    
    try
        load('SignalConditioners.mat');
    catch ME
        warning(ME, 'Signal conditioner defintions not found, skipping validation. Requested stimulus frequencies may be outside of signal conditioner range.');
        return
    end
    
    match = 0;
    
    for i = 1:length(SignalConditioners)
        if strcmp(name, SignalConditioners(i).Name)
            match = 1;
            if min < SignalConditioners(i).MinF      
                warning('Desired minimum stimulus frequency outside of signal conditioner range'); 
            end
            if max > SignalConditioners(i).MaxF
                warning('Desired maximum stimulus frequency outside of signal conditioner range');
            end
        end
    end
    
    if match == 0
        warning('No match for specified signal conditioner found in signal conditioner definitions. Make sure that specified name exactly matches a name in definitions file. If no exact match exists, requested stimulus frequencies may be outside signal conditioner range.');
    end