function [texStr,stimData] = fullScreenSquareAltColors(Q)
    params = Q.stims.currParam.flat;
    updateNum = Q.timing.framenumber - Q.timing.framelastchange + 1; %number of frame changes since start of epoch
    stimData = Q.stims.flatStimData;
    
    texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
    texStr.dim = 2; % or 2
    texStr.scale = [1 1 1]; % using the different lengthscales appropriately.
    
    % Lightcrafter 4500 displays in GRB order
    % For now I am determining that this runs at 2 bit, 12 updates per
    % frame, 60*12 = 720Hz
    
    frequencyHz = params.frequencyHz;
    
    colorSelectArray = repmat({'green','red','blue'},[1 4]);
    specifiedColors = {params.colorOne{1},params.colorTwo{1}};
    
    bitMap = ones(1,1,12);
    for f = 1:12
        t = (updateNum-1)/60 + (f-1)/720;
        %Switch colors at half the frequency of the brightness changes
        thisFrameColorIndex = 1+(1+square(t*(frequencyHz/2)*(2*pi)))/2;
        thisFrameColor = specifiedColors(thisFrameColorIndex);
        bitMap(:,:,f) = square(t*frequencyHz*(2*pi));
        if strcmp(thisFrameColor,colorSelectArray(f))
            bitMap(:,:,f) = params.meanLuminance*(1 + bitMap(:,:,f)*params.contrast);
        else
            bitMap(:,:,f) = 0;
        end
    end
    
    texStr.tex = CreateTexture(bitMap,Q);
end