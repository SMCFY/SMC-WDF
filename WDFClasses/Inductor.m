%----------------------Inductor Class------------------------
classdef Inductor < OnePort
    properties
        State % this is the one-sample internal memory of the WDF inductor
    end
    methods
        function obj = Inductor(PortRes, Fs) % constructor function
            T = 1/Fs;
            obj.PortRes = 2*PortRes/T; % set the port resistance
            obj.State = 0; % initialization of the internal memory
        end
        function WU = WaveUp(obj) % get the up-going wave
            WU = -obj.State; % in practice, this implements the unit delay with a sign inversion
            obj.WU = WU;
        end
    end
end