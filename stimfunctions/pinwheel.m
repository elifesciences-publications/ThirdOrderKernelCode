function [texStr,stimData] = pinwheel(Q)
%     tic;
    params = Q.stims.currParam.flat;
    updateNum = Q.timing.framenumber - Q.timing.framelastchange + 1; %number of frame changes since start of epoch
    if isfield(Q.stims,'flatStimData');
        stimData = Q.stims.flatStimData;
    else
        stimData = struct;
    end
    
    texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
    texStr.dim = 2; % or 2
    texStr.scale = [1 1 1]; % using the different lengthscales appropriately.
    
    % Lightcrafter 4500 displays in GRB order
    % For now I am determining that this runs at 2 bit, 12 updates per
    % frame, 60*12 = 720Hz
    
    meanLuminance = params.meanLuminance;
    contrast = params.contrast;
    
    wavelengthRadians = params.wavelengthDegrees*pi/180;
    velocityRadians = params.velocityDegrees*pi/180;
    
    colorSelectArray = repmat({'green','red','blue'},[1 4]);
    selectedColorArray = repmat({params.color},[1 12]);
    selectedColorFrames = cellfun(@strcmp,colorSelectArray,selectedColorArray);
%     setupTime = toc;
%     disp(['Setup time = ' num2str(setupTime)]);
%     tic;
    
    
    sizeY = 100;
    sizeX = sizeY;
    bitMap(sizeY,sizeX,12) = 0;
    [X,Y] = meshgrid(1:sizeY,1:sizeX);
    center = [sizeX/2 sizeY/2];
    theta = atan((Y-center(2))./(X-center(1)));

    if ~isfield(stimData,'thisEpochLastPhase')
            stimData.thisEpochLastPhase = 0;
    end
    if updateNum == 1 %We are in a new epoch
        stimData.prevEpochLastPhase = stimData.thisEpochLastPhase; %"this" epoch is actually the last one
    end
    
    if updateNum == 60
        x = 1;
    end
%     nonloop = toc;
%     disp(['nonloop time = ' num2str(nonloop)]);
%     tic
    
    for f = 1:12
        if selectedColorFrames(f)
            t = (updateNum-1)/60 + (f-1)/720;
            phase = t*velocityRadians + stimData.prevEpochLastPhase;
            bitMap(:,:,f) = sin((theta-phase)*2*pi/wavelengthRadians);
            bitMap(:,:,f) = meanLuminance*(1 + bitMap(:,:,f)*contrast);
        else
            bitMap(:,:,f) = 0;
        end
    end
    
    stimData.thisEpochLastPhase = phase;
    texStr.tex = CreateTexture(bitMap,Q);
end