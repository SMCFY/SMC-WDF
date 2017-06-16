%----------------------Parallel Class------------------------
classdef Parallel < Adaptor % the class for parallel 3-port adaptors
    properties
        WD = 0;% this is the down-going wave at the adapted port
        WU = 0;% this is the up-going wave at the adapted port
        pb2 = 0;
        a1 = 0;
        a2 = 0;
        gamma = 0;
    end
    methods
        function obj = Parallel(KidLeft,KidRight) % constructor function
            obj.KidLeft = KidLeft; % connect the left 'child'
            obj.KidRight = KidRight; % connect the right 'child'
            
            R1 = KidLeft.PortRes;
            R2 = KidRight.PortRes;
            
            R = (R1 * R2)/(R1 + R2);
            obj.PortRes = R;
            obj.gamma = R/KidLeft.PortRes;
        end
        function WU = WaveUp(obj) % the up-going wave at the adapted port
            obj.a1 = WaveUp(obj.KidLeft);
            obj.a2 = WaveUp(obj.KidRight);
            obj.pb2 = obj.gamma * (obj.a1 - obj.a2); % 36a fettweis
            WU = obj.pb2 + obj.a2;  % 36b fettweis
            obj.WU = WU;
        end
        function WaveDown(obj,WaveFromParent) %  sets the down-going wave
            obj.WD = WaveFromParent; % set the down-going wave for the adaptor
            
            % Scattering according to fettweis theory and practice
            b3 = obj.pb2 + obj.a2; % 36b fettweis
            a3 = WaveFromParent;
            
            left = b3 + (a3 - obj.a1); % 32b fettweis
            right = b3 + (a3 - obj.a2);% 32b fettweis
            
            WaveDown(obj.KidLeft, left);
            WaveDown(obj.KidRight, right);
        end
        function updateValue(obj)
            % Update the adaptor port resistances
            if isa(obj.KidLeft, 'Adaptor')
                updateValue(obj.KidLeft);
            end
            if isa(obj.KidRight, 'Adaptor')
                updateValue(obj.KidRight);
            end
            % set the new port resistance
            R1 = obj.KidLeft.PortRes;
            R2 = obj.KidRight.PortRes;
            
            R = (R1 * R2)/(R1 + R2);
            obj.PortRes = R;
            obj.gamma = R/obj.KidLeft.PortRes;
        end
    end
end
