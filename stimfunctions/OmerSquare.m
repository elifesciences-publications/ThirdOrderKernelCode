function [texStr,stimData] = OmerSquare(Q)
    params = Q.stims.currParam;
    updateNum = Q.timing.framenumber - Q.timing.framelastchange + 1; %number of frame changes since start of epoch
    stimData = Q.stims.stimData;
    
    texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
    texStr.dim = 2; % or 2
    texStr.scale = [1 1 1]; % using the different lengthscales appropriately.
    
    %DLP displays in BRG order
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
    
    framesPerUpdate = params.framesPerUp;
    theta = 2*pi*(0:sizeX-1)/sizeX; %theta in radians
    theta = repmat(theta,[sizeY,1]);
    bitmap = zeros(sizeY,sizeX,framesPerUpdate);
    
    if ~isfield(stimData,'prevEpochLastPhase')
            stimData.prevEpochLastPhase = zeros(sizeY,sizeX);
    end
    if ~isfield(stimData,'thisEpochLastPhase')
            stimData.thisEpochLastPhase = zeros(sizeY,sizeX);
    end
    if updateNum == 1 %We are in a new epoch
        stimData.prevEpochLastPhase = stimData.thisEpochLastPhase;
        stimData.thisEpochLastPhase = zeros(sizeY,sizeX);
    end
    if isfield(params,'resetPhase') && params.resetPhase
        stimData.prevEpochLastPhase = zeros(sizeY,sizeX);
    end
    
    for f = 1:framesPerUpdate
        t =(updateNum-1)*(1/60) + f*(1/60)*(1/framesPerUpdate);
        phase = t*velocityRadians*ones(sizeY,sizeX) + squeeze(stimData.prevEpochLastPhase(:,:));
        stimData.thisEpochLastPhase(:,:) = phase;
        bitmap(:,:,f) = square(2*pi*(theta - phase)/wavelengthRadians);
        bitmap(:,:,f) = meanLuminance*(1 + bitmap(:,:,f)*contrast);
    end
    texStr.tex = CreateTexture(bitmap,Q);
end