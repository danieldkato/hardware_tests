classdef SignalConditioner
    properties
        Name
        MinF
        MaxF
    end
    methods
        function obj = SignalConditioner(name, min, max)
            obj.Name = name;
            obj.MinF = min;
            obj.MaxF = max;
        end
    end
end