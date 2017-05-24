classdef Speaker
    properties
        Name % speaker name
        MinF % minimum frequency according to specification, in Hz
        MaxF % maximum frequency according to specification, in Hz
    end
    methods
        function obj = Speaker(name, min, max)
            obj.Name = name;
            obj.MinF = min;
            obj.MaxF = max;
        end
    end
end