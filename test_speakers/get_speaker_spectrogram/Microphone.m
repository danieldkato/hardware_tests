classdef Microphone
    properties
        Name % microphone name
        MinX % minimum frequency (within +/- 1 dB of max response), in Hz
        MaxF % maximum frequency (within +/- 1 dB of max response), in Hz
    end
    methods
        function obj = Microphone(name, min, max)
            obj.Name = name;
            obj.MinX = min;
            obj.MaxF = max;
        end
    end
end