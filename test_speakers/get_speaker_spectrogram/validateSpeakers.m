function validateSpeaker(name, min, max)
    load('Speakers.mat');
    for i = 1:length(Speakers)
        if strcmp(name, Speakers(i).Name)
            if min < Speakers(i).MinF      
                warning('Desired minimum stimulus frequency outside of speaker range'); 
            end
            if max > Speakers(i).MaxF
                warning('Desired maximum stimulus frequency outside of speaker range');
            end
        end
    end