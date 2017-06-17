classdef ParallelDiodeClipperRT < audioPlugin
    
    properties
        gain = 1
        mix = 0.5
    end
    
    properties (Constant)
        % audioPluginInterface manages the number of input/output channels
        % and uses audioPluginParameter to generate plugin UI parameters.
        PluginInterface = audioPluginInterface(...
            audioPluginParameter('mix','DisplayName','Mix','Label','','Mapping',{'lin',0 1}),...
            audioPluginParameter('gain','DisplayName','Gain','Label','','Mapping',{'lin',0 5}));
    end
    
    properties (Access = private)
        pSR     % sampling rate   
        model   % circuit model
    end
    
    methods
        function obj = ParallelDiodeClipperRT()
            obj.pSR = getSampleRate(obj);
            obj.model = ParallelDiodeClipperModel(obj.pSR);     
        end
        
        function reset(obj)
            obj.pSR = getSampleRate(obj);    
        end
    
        function out = process(obj, x)
            output = process(obj.model, x*obj.gain);
            out = output*obj.mix + (1-obj.mix)*x;
        end
    end
end
