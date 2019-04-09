function [texStr,stimData] = FullScreenSine(Q)
    params = Q.stims.currParam.flat;
    updateNum = Q.timing.framenumber - Q.timing.framelastchange + 1; %number of frame changes since start of epoch
    if isfield(Q.stims,'flatStimData');
        stimData = Q.stims.flatStimData;
    else
        stimData = 0;
    end
    
    texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
    texStr.dim = 2; % or 2
    texStr.scale = [1 1 1]; % using the different lengthscales appropriately.
    
    frequencyHz = params.frequencyHz;
    
    [~,frameColors,numFrames] = Q.lightCrafter4500.getPatternAttributes;
    selectedColorArray = repmat({params.color},[1 numFrames]);
    selectedColorFrames = cellfun(@strcmp,frameColors,selectedColorArray);
    
    bitMap = ones(1,1,numFrames);
    for f = 1:numFrames
        t = (updateNum-1)/60 + (f-1)/720;
        bitMap(:,:,f) = sin(t*frequencyHz*(2*pi));
        if selectedColorFrames(f)
            bitMap(:,:,f) = params.meanLuminance*(1 + bitMap(:,:,f)*params.contrast);
        else
            bitMap(:,:,f) = 0;
        end
    end
    
    texStr.tex = CreateTexture(bitMap,Q);
end