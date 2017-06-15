classdef BrightSwitchRT < audioPlugin
    properties
        vol = 0.5
        state = 'Off'
        mix = 0.5
    end
    
    properties (Constant)
        % audioPluginInterface manages the number of input/output channels
        % and uses audioPluginParameter to generate plugin UI parameters.
        PluginInterface = audioPluginInterface(...
            audioPluginParameter('mix','DisplayName','Mix','Label','','Mapping',{'lin',0 1}),...
            audioPluginParameter('state','DisplayName','State','Label','','Mapping',{'enum','Off','Onn'}),...
            audioPluginParameter('vol','DisplayName','Volume','Label','','Mapping',{'lin',0.0001 0.9999}));
    end
    
    properties (Access = private)
        pSR
        model 
    end
    
    methods
        function obj = BrightSwitchRT()
           obj.pSR = getSampleRate(obj);  
           obj.model = BrightSwitch(obj.vol, obj.pSR);
           if obj.state == 'Onn'
               changeState(obj.model);
           end
        end      
        function reset(obj)
            obj.pSR = getSampleRate(obj);   
        end
        
        function out = process(obj, x)
            output = process(obj.model, x);
            % Mix clean and dirty sound
            out = output*obj.mix + (1-obj.mix)*x;
        end
        function set.vol(obj, vol)
            obj.vol = vol;
            changeVolume(obj.model, vol);
        end
        function set.state(obj, state)
            obj.state = state;
            changeState(obj.model);
        end
    end
end
