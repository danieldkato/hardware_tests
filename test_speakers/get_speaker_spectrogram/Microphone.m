classdef Microphone
    properties
        Name % microphone name
        MinF % minimum frequency (within +/- 1 dB of max response), in Hz
        MaxF % maximum frequency (within +/- 1 dB of max response), in Hz
    end
    methods
        function obj = Microphone(name, min, max)
            obj.Name = name;
            obj.MinF = min;
            obj.MaxF = max;
        end
    end
end