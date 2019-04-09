function shiftedSnipMat = CircShiftTimeTraces(snipMat,locMap,params,dataRate)
    numRois = size(snipMat,2);
    numEpochs = size(snipMat,1);
    shiftedSnipMat = cell(size(snipMat));
    epochVelocity = 0;
    
    for ee = 1:numEpochs
        % find the epoch velocity
        if isfield(params(ee),'velocityL')
            if ~isempty(params(ee).velocityL)
                epochVelocity = params(ee).velocityL;
            end
        end
            
        if isfield(params(ee),'velocity') && epochVelocity ~= 0
            if ~isempty(params(ee).velocity)
                epochVelocity = params(ee).velocity;
            end
        end
            
        if isfield(params(ee),'temporalFrequency') && isfield(params(ee),'lambda') && epochVelocity ~= 0
            if ~isempty(params(ee).temporalFrequency) && ~isempty(params(ee).lambda)
                epochVelocity = params(ee).temporalFrequency*params(ee).lambda;
            end
        end
        
        if epochVelocity == 0
            epochVelocity = 1;
        end
        
        for rr = 1:numRois
            % convert locMap from degrees to seconds
            shiftInSeconds = locMap(rr)/epochVelocity;
            % convert shiftInSeconds from seconds to frames
            shiftInFrames = round(shiftInSeconds*dataRate);
            % shift the time traces the appropriate number of frames
            shiftedSnipMat{ee,rr} = circshift(snipMat{ee,rr},[(-shiftInFrames) 1]);
        end
    end
end

