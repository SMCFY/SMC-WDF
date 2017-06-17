classdef ParallelDiodeClipperModel < handle
    % Two Capacitor Diode Clipper Circuit
    % As described in SIMULATING GUITAR DISTORTION CIRCUITS USING WAVE DIGITAL
    % AND NONLINEAR STATE-SPACE FORMULATIONS by David Yeh and Julius Smith.

    properties (Access = private)
        V1 % create a source with 0 (initial) voltage and 1 Ohm ser. res.
        R1 % create an 80Ohm resistor
        C1  % create the capacitance
        C2
        A1
        A2
        
        b = 0; % outgoing wave
        
        % Diode model parameters
        Is = 2.52e-9;
        Vt = 45.3e-3;
        
        Rp     
    end
    
    methods
        function obj = ParallelDiodeClipperModel(Fs)
            % Device parameters for the following simulations are
            % Rs = 2.2kOhm, Ch = 0.47uF, Cl = 0.01uF, Is = 2.52 × 10-9 A, and Vt = 45.3mV.
            % Terminated voltage source V1
            obj.V1 = TerminatedVs(0, 2200);
            
            % Capacitor C1 with Ch value
            Ch = 0.47e-6; % the capacitance value in Farads
            obj.C1 = Capacitor(Ch,Fs); % create the capacitance
            
            % Capacitor C2 with Cl value
            Cl = 0.01e-6;
            obj.C2 = Capacitor(Cl,Fs);
            
            % Connect V1 and C1 in series
            obj.A1 = Series(obj.V1, obj.C1);
            
            % Connect A1 and C2 in parallel
            obj.A2 = Parallel(obj.A1, obj.C2);
            
            % Diode port resistance
            obj.Rp = (obj.A2.PortRes*obj.C2.PortRes)/(obj.A2.PortRes+obj.C2.PortRes);
        end
        function solveNL(obj, a)
            % Newton Raphson variables
            maxIter = 10;
            dx = 1e-6;
            err =  1e-6;
            epsilon = 1e-9;
            
            iter = 1;
            % NR Algorithm
            while (abs(err) / abs(obj.b) > epsilon )
                f = 2*obj.Is*sinh((a + obj.b)/(2*obj.Vt)) - (a - obj.b)/(2*obj.Rp);
                df = 2*obj.Is*sinh((a + (obj.b+dx))/(2*obj.Vt)) - (a-(obj.b+dx))/(2*obj.Rp);
                newB = obj.b - (dx*f)/(df - f);
                obj.b = newB;
                iter = iter + 1;
                if (iter > maxIter)
                    break;
                end
            end
        end
        function output = process(obj, x)
            [numSamples,m] = size(x);
            output = zeros(size(x));
            input = sum(x,m)/m;
            for n = 1:numSamples % run each time sample until N
                obj.V1.E = input(n); % read the input signal for the voltage source
                a = WaveUp(obj.A2);
                solveNL(obj, a);
                WaveDown(obj.A2, obj.b); % evaluate the wave leaving the diode (root element)
                output(n,:) = Voltage(obj.A2);
            end
        end
    end
    
end

