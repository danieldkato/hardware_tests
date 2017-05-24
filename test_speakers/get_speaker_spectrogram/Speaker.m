classdef Speaker
    properties
        Name
        MinF
        MaxF
    end
    methods
        function obj = Speaker(name, min, max)
            obj.Name = name;
            obj.MinF = min;
            obj.MaxF = max;
        end
    end
end