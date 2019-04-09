function [texStr,stimData] = SineSlit(Q)
    params = Q.stims.currParam;
    updateNum = Q.timing.framenumber - Q.timing.framelastchange + 1; %number of frame changes since start of epoch
    stimData = Q.stims.stimData;
    
    texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
    texStr.dim = 2; % or 2
    texStr.scale = [1 1 1]; % using the different lengthscales appropriately.
    
    meanLuminance = params.meanLuminance;
    contrast = params.contrast;
    
    wavelengthRadians = params.wavelengthDegrees*pi/180;
    velocityRadians = params.velocityDegrees*pi/180;
    
    if params.numDeg == 0
        sizeX = 1;
        sizeY = 1;
    else
        sizeX = round(360/params.numDeg);
        sizeY = round(2/tan(params.numDeg*pi/180));
    end
    
    framesPerUpdate = params.projectorFrequency/60;
    theta = 2*pi*(0:sizeX-1)/sizeX; %theta in radians
    theta = repmat(theta,[sizeY,1]);
    bitmap = zeros(sizeY,sizeX,framesPerUpdate);
    
    if ~isfield(stimData,'lastPhase')
            stimData.lastPhase = zeros(sizeY,sizeX);
    end
    if ~isfield(stimData,'thisEpochLastPhase')
            stimData.thisEpochLastPhase = zeros(sizeY,sizeX);
    end
    if updateNum == 1 %We are in a new epoch
        stimData.prevEpochLastPhase = stimData.thisEpochLastPhase;
        stimData.thisEpochLastPhase = zeros(sizeY,sizeX);
    end
    
    for f = 1:framesPerUpdate
        t =(updateNum-1)*(1/60)+f*(1/params.projectorFrequency);
        phase = t*velocityRadians*ones(sizeY,sizeX) + stimData.prevEpochLastPhase;
        bitmap(:,:,f) = sin(2*pi*(theta - phase)/wavelengthRadians);
    end
    
    stimData.thisEpochLastPhase = phase;
    
    %slit calculations: a*tand(numDeg) = 1
    %                   a*tand(offset-height/2) = slitEnd
    %                   a*tand(offset+height/2) = slitStart
    %start and end are relative to the 0 angle: middle of sizeY
    slit = zeros(sizeY,sizeX,framesPerUpdate);
    adjacent = 1/tand(params.numDeg);
    slitStart = round(round(sizeY/2) - adjacent*tand(params.yOffset+params.height/2));
    slitEnd   = round(round(sizeY/2) - adjacent*tand(params.yOffset-params.height/2));
    slit(slitStart:slitEnd,:,:) = 1;
    
    bitmap = bitmap.*slit;
    
    bitmap = meanLuminance*(1 + bitmap*contrast);
    
    texStr.tex = CreateTexture(bitmap,Q);
end