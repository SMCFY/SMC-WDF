%----------------------Two Port Parallel Adaptor with Switch Class------------------------
classdef ParallelSwitch < Adaptor
    properties
        WD = 0;% this is the down-going wave at the adapted port
        WU = 0;% this is the up-going wave at the adapted port
        pb2 = 0;
        a1 = 0;
        a2 = 0;
        gamma = 0;
        state = 0;
    end
    methods
        function obj = ParallelSwitch(KidLeft,KidRight) % constructor function
            obj.KidLeft = KidLeft; % this is the connected
            obj.KidRight = KidRight; % this is connected with the switch state
            R1 = KidLeft.PortRes;
            R2 = KidRight.PortRes;
            
            R = (R1 * R2)/(R1 + R2);
            
            obj.PortRes = R; % not needed
            obj.gamma = (R1 - R2)/(R1 + R2); % fettweis 49
            
        end
        function WU = WaveUp(obj) % the up-going wave at the adapted port
            if obj.state == 1 % if the switch is on  
                obj.a1 = WaveUp(obj.KidLeft);
                obj.a2 = WaveUp(obj.KidRight);
                WU = obj.a1 + obj.gamma*(obj.a2 - obj.a1);
                obj.WU = WU;
                WaveDown(obj.KidRight, WU); % set state
            else 
                obj.a1 = WaveUp(obj.KidLeft);
                WU = obj.a1; % Open circuit b[n] = a[n]
                obj.WU = WU;
            end
        end
        function WD = WaveDown(obj) %  sets the down-going wave
            if obj.state == 1
                % a2 is the incoming wave from the switch
                b1 = obj.a2 + obj.gamma*(obj.a2 - obj.a1);
                WaveDown(obj.KidLeft,b1);
                
                WD = obj.a2;
                obj.WD = WD;
            else
                % open circuit
                WD = obj.WU;
                obj.WD = WD;
                b1 = WD;
                WaveDown(obj.KidLeft, b1);
            end
        end
        function changeState(obj) % always make the state the opposite of what it was
            if obj.state == 1
                obj.state = 0;
            else
                obj.state = 1;
            end
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
            obj.gamma = (R1 - R2)/(R1 + R2); % fettweis 49
        end
    end
end
