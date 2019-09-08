function outVar = UpdateLoop(varargin)
    inVar = varargin{1};

    switch length(varargin)
        case 2
            gain = varargin{2};
        
            outVar = gain*inVar;
        case 3
            gain = varargin{2};
            offSet = varargin{3};
            
            outVar = gain*inVar+offSet;
        case 5
            inLowLimit = varargin{2};
            inHighLimit = varargin{3};
            outLowLimit = varargin{4};
            outHighLimit = varargin{5};
            
            if inVar > inHighLimit
                outVar = outHighLimit;
            elseif inVar < inLowLimit
                outVar = outLowLimit;
            else
                inVar = inVar - inLowLimit;
                gain = (outHighLimit - outLowLimit)/(inHighLimit - inLowLimit);
                outVar = inVar*gain;
            end
        otherwise
            error('wrong number of inputs to updateLoop');
    end
        
end