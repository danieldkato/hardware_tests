classdef SignalConditioner
    properties
        Name % signal conditioner name
        MinF % minimum frequency (within -%5 of max signal), in Hz
        MaxF % maximum frequency (within -%5 of max signal), in Hz
    end
    methods
        function obj = SignalConditioner(name, min, max)
            obj.Name = name;
            obj.MinF = min;
            obj.MaxF = max;
        end
    end
end