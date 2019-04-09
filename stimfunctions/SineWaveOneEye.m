function [texStr,stimData] = SineWaveOneEye(Q)
    % basic sinewave stimulus. Can produce rotation and translation where
    % the opposite eye is the first eye's mirror image

    p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
    f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
    stimData = Q.stims.stimData;

    if p.numDeg == 0
        sizeX = 1;
    else
        sizeX = round(360/p.numDeg);
    end

    mlumL = p.lumL;
    cL = p.contrastL;
    lambdaL = p.lambdaL*pi/180; %wavelength in radians
    
    mlumR = p.lumR;
    cR = p.contrastR;
    lambdaR = p.lambdaR*pi/180; %wavelength in radians
    
    framesPerUp = p.framesPerUp;
    
    % size of the stimulation, hard code to 90 degrees for now
    % we'll make half of the window and then reflect it to get the other
    % half, so 1/8th of the total scene.
    windowSize = 1/8;
    
    if ~isfield(p,'temporalFrequencyL')
        velL = p.velocityL*pi/180; % degree/s into rad/s
    else
        velL = p.temporalFrequencyL*p.lambdaL*pi/180;
    end
    
    if ~isfield(p,'temporalFrequencyR')
        velR = p.velocityR*pi/180; % degree/s into rad/s
    else
        velR = p.temporalFrequencyR*p.lambdaR*pi/180;
    end
    
    sideSize = ceil(sizeX*windowSize);
    sideSize2 = floor(sizeX*windowSize);
    fullSize = sideSize+sideSize2;

    %% left eye
    %stimData.mat(1) is used as the wave phase. stimData.mat(2) is the velocity which
    %is constant unless noise is added

    if f == 1
        stimData.sinPhaseL = 0;
        stimData.sinPhaseR = 0;
    end

    theta = (0:sizeX-1)/sizeX*2*pi; %theta in radians
    thetaSide = theta(1:sideSize);
    eyeL = zeros(1,sizeX,framesPerUp)+0.5;
    
    for cc = 1:framesPerUp
        stimData.sinPhaseL = stimData.sinPhaseL + velL/(60*framesPerUp);
        oneSide = sin(2*pi*(thetaSide-stimData.sinPhaseL)/lambdaL);
        bothSides = [oneSide fliplr(oneSide(1:sideSize2))];
        eyeL(1,sideSize2+1:fullSize*2-sideSize,cc) = bothSides;
        
        stimData.mat(cc) = stimData.sinPhaseL;
    end
    
    eyeL = mlumL*(1 + cL*eyeL);

    %% right eye
    eyeR = zeros(1,sizeX,framesPerUp)+0.5;
    
    for cc = 1:framesPerUp
        stimData.sinPhaseR = stimData.sinPhaseR + velR/(60*framesPerUp);
        oneSide = sin(2*pi*(thetaSide-stimData.sinPhaseR)/lambdaR);
        bothSides = [oneSide fliplr(oneSide(1:sideSize2))];
        eyeR(1,sideSize+1:fullSize*2-sideSize,cc) = bothSides;

        stimData.mat(cc) = stimData.sinPhaseR;
    end

    eyeR = fliplr(mlumR*(1 + cR*eyeR));

    bitMap = CombEyes(eyeL,eyeR,p,f);
    
    %always include this line in a stim function to make the texture from the
    %bitmap

    texStr.tex = CreateTexture(bitMap,Q);
end