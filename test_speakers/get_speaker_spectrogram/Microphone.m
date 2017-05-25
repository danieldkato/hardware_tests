classdef Microphone
    properties
        Mfr % manufacturer
        Mdl % model #
        Description
        MinF % minimum frequency (within +/- 1 dB of max response), in Hz
        MaxF % maximum frequency (within +/- 1 dB of max response), in Hz
    end
    methods
        function obj = Microphone(mdl, min, max)
            obj.Mdl = mdl;
            obj.MinF = min;
            obj.MaxF = max;
        end
    end
end