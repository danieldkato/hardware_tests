function validateSignalConditioner(name, min, max)
    load('SignalConditioners.mat');
    for i = 1:length(SignalConditioners)
        if strcmp(name, SignalConditioners(i).Name)
            if min < SignalConditioners(i).MinF      
                warning('Desired minimum stimulus frequency outside of signal conditioner range'); 
            end
            if max > SignalConditioners(i).MaxF
                warning('Desired maximum stimulus frequency outside of signal conditioner range');
            end
        end
    end