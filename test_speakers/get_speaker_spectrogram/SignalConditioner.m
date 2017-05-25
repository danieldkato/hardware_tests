classdef SignalConditioner
    properties
        Mfr % manufacturer
        Mdl % model #
        Description
        MinF % minimum frequency (within -%5 of max signal), in Hz
        MaxF % maximum frequency (within -%5 of max signal), in Hz
    end
    methods
        function obj = SignalConditioner(mdl, min, max)
            obj.Mdl = mdl;
            obj.MinF = min;
            obj.MaxF = max;
        end
    end
end