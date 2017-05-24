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
        function eval(obj, tgtMin, tgtMax)
            if (tgtMin < obj.MinF)
                warning('Desired minimum stimulus frequency outside of speaker range');
            end
            if (tgtMax > obj.MaxF)
                warning('Desired maximum stimulus frequency outside of speaker range');
            end
        end
    end
end