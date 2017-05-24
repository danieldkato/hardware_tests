function validateMic(name, min, max)
    load('Mics.mat');
    for i = 1:length(Mics)
        if strcmp(name, Mics(i).Name)
            if min < Mics(i).MinF      
                warning('Desired minimum stimulus frequency outside of microphone range'); 
            end
            if max > Mics(i).MaxF
                warning('Desired maximum stimulus frequency outside of microphone range');
            end
        end
    end