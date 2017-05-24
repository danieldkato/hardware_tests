classdef SignalConditioner
    properties
        Name
        MinF
        MaxF
    end
    methods
        function obj = SingalConditioner(name, min, max)
            obj.Name = name;
            obj.min = min;
            obj.max = max;
        end
    end
end