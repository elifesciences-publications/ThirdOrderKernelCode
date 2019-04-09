function [texStr,stimData] = SquareOpposingColors(Q)
    params = Q.stims.currParam;
    updateNum = Q.timing.framenumber - Q.timing.framelastchange + 1; %number of frame changes since start of epoch
    stimData = Q.stims.stimData;
    
    texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
    texStr.dim = 2; % or 2
    texStr.scale = [1 1 1]; % using the different lengthscales appropriately.
    
    %DLP displays in BRG order
    meanLuminance = [params.meanLuminanceBlue params.meanLuminanceRed params.meanLuminanceGreen];
    contrast = [params.contrastBlue params.contrastRed params.contrastGreen];
    
    wavelengthRadians = [params.wavelengthDegreesBlue params.wavelengthDegreesRed params.wavelengthDegreesGreen]*pi/180;
    velocityRadians = [params.velocityDegreesBlue params.velocityDegreesRed params.velocityDegreesGreen]*pi/180;
    
    if params.numDeg == 0
        sizeX = 1;
        sizeY = 1;
    else
        sizeX = round(360/params.numDeg);
        sizeY = round(2/tan(params.numDeg*pi/180));
    end
    
    framesPerUpdate = params.framesPerUp;
    framesPerColor = framesPerUpdate/3;
    theta = 2*pi*(0:sizeX-1)/sizeX; %theta in radians
    theta = repmat(theta,[sizeY,1]);
    bitmap = zeros(sizeY,sizeX,framesPerUpdate);
    
    if ~isfield(stimData,'prevEpochLastPhase')
            stimData.prevEpochLastPhase = zeros(3,sizeY,sizeX);
    end
    if ~isfield(stimData,'thisEpochLastPhase')
            stimData.thisEpochLastPhase = zeros(3,sizeY,sizeX);
    end
    if updateNum == 1 %We are in a new epoch
        stimData.prevEpochLastPhase = stimData.thisEpochLastPhase;
        stimData.thisEpochLastPhase = zeros(3,sizeY,sizeX);
    end
    if isfield(params,'resetPhase') && params.resetPhase
        stimData.prevEpochLastPhase = zeros(3,sizeY,sizeX);
    end
    
    for f = 1:framesPerUpdate
        t =(updateNum-1)*(1/60);
        color = ceil((f/framesPerColor) - 0.00001); %Small value to ensure we undershoot integers and then ceil to them
        phase = t*velocityRadians(color)*ones(sizeY,sizeX) + squeeze(stimData.prevEpochLastPhase(color,:,:));
        stimData.thisEpochLastPhase(color,:,:) = phase;
        bitmap(:,:,f) = square(2*pi*(theta - phase)/wavelengthRadians(color));
        bitmap(:,:,f) = meanLuminance(color)*(1 + bitmap(:,:,f)*contrast(color));
    end
    texStr.tex = CreateTexture(bitmap,Q);
end