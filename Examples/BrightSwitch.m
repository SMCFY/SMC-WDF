classdef BrightSwitch < handle
    % Bright switch described by David T. Yeh and Julius O. Smith in
    % SIMULATING GUITAR DISTORTION CIRCUITS USING WAVE DIGITAL AND NONLINEAR STATE-SPACE FORMULATIONS
    properties
    end
    properties(Access = private)
        M = 1000000;
        Vs
        Rv
        S
        Rt
        P
        C
        P2
    end
    
    methods
        function obj = BrightSwitch(vol, Fs)
            %obj.vol = vol;
            obj.Vs = TerminatedVs(0, 100e3); % 100kOhm
            obj.Rv = Resistor(vol*obj.M);
            obj.S = Series(obj.Vs, obj.Rv);
            obj.Rt = Resistor((1-vol)*obj.M);
            obj.P = Parallel(obj.Rt, obj.S);
            obj.C = Capacitor(120e-12,Fs);
            obj.P2 = ParallelSwitch(obj.P,obj.C);
        end
        function changeVolume(obj, vol)
            obj.Rv.PortRes = vol*obj.M;
            obj.Rt.PortRes = (1-vol)*obj.M;
            updateValue(obj.P2);
        end
        function out = process(obj, x)
            [numSamples,m] = size(x);
            out = zeros(size(x));
            input = sum(x,m)/m;
            for n = 1:numSamples
                obj.Vs.E = input(n);
                WaveUp(obj.P2);
                WaveDown(obj.P2);
                out(n,:) = Voltage(obj.Rv);
            end
        end
        function changeState(obj)
            changeState(obj.P2);
        end
    end
end

