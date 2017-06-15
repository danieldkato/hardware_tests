classdef Speaker
    properties
        Mfr % manufacturer
        Mdl % model #
        Description % speaker name
        MinF % minimum frequency according to specification, in Hz
        MaxF % maximum frequency according to specification, in Hz
    end
    methods
        function obj = Speaker(mdl, min, max)
            obj.Mdl = mdl;
            obj.MinF = min;
            obj.MaxF = max;
        end
    end
end