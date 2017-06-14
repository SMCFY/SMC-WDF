classdef TubeRT < audioPlugin
% Vacuum-tube model from WAVE DIGITAL SIMULATION OF A VACUUM-TUBE AMPLIFIER by Matti Karjalainen and Jyri Pakarinen    
    properties
        gain = 1
        dist = 1
        mix = 0.5
    end
    
    properties (Constant)
        % audioPluginInterface manages the number of input/output channels
        % and uses audioPluginParameter to generate plugin UI parameters.
        PluginInterface = audioPluginInterface(...
            audioPluginParameter('mix','DisplayName','Mix','Label','','Mapping',{'lin',0 1}),...
            audioPluginParameter('dist','DisplayName','Distortion','Label','','Mapping',{'lin',0.1 20}),...
            audioPluginParameter('gain','DisplayName','Gain','Label','','Mapping',{'lin',0 3}));
    end
    
    properties (Access = private)
        pSR
        model 
    end
    
    methods
        function obj = TubeRT()
           obj.pSR = getSampleRate(obj);  
           obj.model = TriodeModel(obj.pSR);
        end      
        function reset(obj)
            obj.pSR = getSampleRate(obj);   
        end
        
        function out = process(obj, x)
            output = process(obj.model, x, obj.gain, obj.dist);
            % Mix clean and dirty sound
            out = output*obj.mix + (1-obj.mix)*x;
        end
    end
end
