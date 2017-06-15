% not working yet
%----------------------Parallel Switch Class------------------------
classdef ParallelSwitch < Adaptor % the class for parallel 3-port adaptors
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
            %             obj.KidLeft = KidLeft; % connect the left 'child'
            %             obj.KidRight = KidRight; % connect the right 'child'
            %             obj.G2 = 1/KidLeft.PortRes; % G2 is the inverse port resistance from kidleft
            %             obj.G3 = 1/KidRight.PortRes; % G3 is the inverse port resistance from kidright
            %             obj.PortRes = (KidLeft.PortRes - KidRight.PortRes)/(KidLeft.PortRes + KidRight.PortRes);% obj.G2+obj.G3; % parallel adapt. port facing the root
            
            obj.KidLeft = KidLeft; % this is the connected
            obj.KidRight = KidRight; % this is connected with the switch state
            R1 = KidLeft.PortRes;
            R2 = KidRight.PortRes;
            
            R = (R1 * R2)/(R1 + R2);
            
            obj.PortRes = R;
            obj.gamma = (R1 - R2)/(R1 + R2); % fettweis 49
            
        end
        function WU = WaveUp(obj) % the up-going wave at the adapted port
            obj.a1 = WaveUp(obj.KidLeft);
            obj.a2 = WaveUp(obj.KidRight);
            WU = obj.a1 + obj.gamma*(obj.a2 - obj.a1);
            obj.WU = WU;
            if obj.state == 1
                WaveDown(obj.KidRight, WU); % set state
            end
        end
        function WD = WaveDown(obj) %  sets the down-going wave
            if obj.state == 1
                % set the down-going wave for the adaptor
                % set the waves to the 'children' according to the scattering rules
                
                % obj.a1 = WaveUp(obj.KidLeft);
                %obj.a2 = WaveUp(obj.KidRight);
                b1 = obj.a2 + obj.gamma*(obj.a2 - obj.a1);
                %  b2 = obj.a1 + obj.gamma*(obj.a2 - obj.a1);
                %  WaveDown(obj.KidRight,b2);
                WaveDown(obj.KidLeft,b1);
                
                WD = obj.a2;
                obj.WD = WD;
            else
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
            if or(isa(obj.KidLeft,'Parallel'),isa(obj.KidLeft,'Series'))
                updateValue(obj.KidLeft);
            end
            if or(isa(obj.KidRight,'Parallel'),isa(obj.KidRight,'Series'))
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
