classdef Microphone
    properties
        Name
        MinX
        MaxF
    end
    methods
        function obj = Microphone(name, min, max)
            obj.Name = name;
            obj.MinX = min;
            obj.MaxF = max;
        end
    end
end