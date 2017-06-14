classdef TriodeModel < handle
    % Vacuum-tube model from WAVE DIGITAL SIMULATION OF A VACUUM-TUBE AMPLIFIER by Matti Karjalainen and Jyri Pakarinen   
    properties    
    end
    properties (Access = private)
        Fs
        % initialise component variables
        R0
        C0
        A1
        V
        A2
        Rk
        Ck
        A3
        A4
        % and other private variables
        R
        Vk = 0;
        Vpk = 0;
    end
    
    methods
        function obj = TriodeModel(Fs)
            obj.Fs = Fs;
            
            obj.R0 = Resistor(1e6);
            obj.C0 = Capacitor(10e-9, Fs);
            
            obj.A1 = Series(obj.C0,obj.R0);
            
            obj.V = TerminatedVs(250,100e3);
            
            obj.A2 = Parallel(obj.V, obj.A1);
            
            obj.Rk = Resistor(1e3);
            
            obj.Ck = Capacitor(10e-6,Fs);
            
            obj.A3 = Parallel(obj.Ck,obj.Rk);
            
            obj.A4 = Series(obj.A3,obj.A2);
            % R0 port resistance
            obj.R = obj.A1.PortRes;
            
        end
        function [ b, Vpk ] = NL(obj, a, R, Vgk, Vpk)
            % 12AX7 model with New-Raphson solver
            % using Wave Digital Filters
            % From WAVE DIGITAL SIMULATION OF A VACUUM-TUBE AMPLIFIER by Matti Karjalainen and Jyri Pakarinen
            
            maxIter = 5;   % maximun number of iterations
            dx = 1e-6;      % delta x
            err =  1e-6;    % error
            epsilon = 1e-9; % a value close to 0 to stop the iteration if the equation is converging
            iter = 1;        % reset iter to 1
            % Newton-Raphson algorithm
            x = Vpk;
            while (abs(err) / abs(x) > epsilon )
                diffX = x + dx;
                f = x + R * Ip(obj, Vgk,x) - a; % (7)
                df = diffX + R * Ip(obj, Vgk, diffX) - a;
                newVpk = x - (dx*f)/(df - f);
                x = newVpk;
                iter = iter + 1;
                if (iter > maxIter)         % if iter is larger than the maximum nr of iterations
                    break;                  % break out from the while loop
                end
            end
            Vpk = x;
            b = Vpk - R * Ip(obj, Vgk,Vpk); % (8)
            
        end
        function [ Ip ] = Ip(obj, Vgk, Vpk)
            mu = 100;
            kx = 1.4;
            kg1 = 1060;
            kp = 600;
            kvb = 300;
            % E1 = Vpk/kp * log10(1 + exp(kp * (1/u + Vgk/ sqrt(kvb + Vpk^2))))
            E1 = (Vpk/kp) * log10(1 + exp(kp * ((1/mu) + Vgk/sqrt(kvb + Vpk^2)))); % (2)
            Ip = ((E1^kx)/kg1) * (1 + sign(E1)); % (3)
            
        end
        function [output] = process(obj, x, gain, Vg)
            [numSamples,m] = size(x);
            output = zeros(size(x));
            input = gain*sum(x,m)/m;
            %Vg = obj.dist;
            for n = 1:numSamples % run each time sample until N
                obj.V.E = input(n); % read the input signal for the voltage source
                % Calculate up-going waves
                a = WaveUp(obj.A4);
                % Calculate Vgk
                Vgk = Vg - obj.Vk;
                % Nonlinear triode calculations goes in here
                [b, z] = NL(obj, a, obj.R, Vgk, complex(obj.Vpk));
                obj.Vpk = real(z);
                % Send the wave down the tree
                WaveDown(obj.A4, real(b));
                % update Vk, unit delay
                obj.Vk = Voltage(obj.Rk);
                % Read output voltage at R0
                output(n,:) = Voltage(obj.R0);
            end     
        end
    end 
end

