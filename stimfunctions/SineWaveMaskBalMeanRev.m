function [texStr,stimData] = SineWaveMaskBalMeanRev(Q)
    % this is to provide the general structure for the texture generating codes
    % to be used with PTB in this framework. 

    % NOTE: when you create a new stimulus function, you must update the
    % stimlookup table in the folder paramfiles. paramfiles will also hold the
    % text file giving lists of parameters that comprise an experiment

    %when choosing noise values for the sine wave make sure that:
    %noiseContrast <= (1-mlum*(contrast+1))/(3*mlum)
    %this insures that 3 std of the noise keeps you below a luminence of 1

    sii = Q.stims.currStimNum;
    p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
    f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
    stimData = Q.stims.stimData;
    floc = Q.flyloc; % could potentially use this to update the stimulus as well

    texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
    texStr.dim = 2; % or 2
    texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

    if p.numDeg == 0
        sizeX = 1;
        sizeY = 1;
    else
        sizeX = round(360/p.numDeg);
        sizeY = round(Q.cylinder.cylinderHeight/(Q.cylinder.cylinderRadius*tan(p.numDeg*pi/180)));
    end

    mlumL = p.lumL;
    mlumR = p.lumR;

    cL = p.contrastL;
    cR = p.contrastR;

    velL = p.velocityL*pi/180; % degree/s into rad/s
    velR = p.velocityR*pi/180; % degree/s into rad/s

    lambdaL = p.lambdaL*pi/180; %wavelength in radians
    lambdaR = p.lambdaR*pi/180; %wavelength in radians

    velSTDL = p.velSTDL*pi/180;
    velSTDR = p.velSTDR*pi/180;

    stimUpRateL = p.stimUpRateL;
    stimUpRateR = p.stimUpRateR;

    velUpRateL = p.velUpRateL;
    velUpRateR = p.velUpRateR;

    wnUpRateL = p.wnUpRateL;
    wnUpRateR = p.wnUpRateR;

    wnCL = p.wnCL;
    wnCR = p.wnCR;
    
    leftEye = 1;
    
    if (wnUpRateL == 0) && (wnUpRateR == 0)
        sizeY = 1;
    end
    
    framesPerUp = p.framesPerUp;

    if velUpRateL == 0
        velUpRateL = 1;
    end

    if velUpRateR == 0
        velUpRateR = 1;
    end
    
    if f == 1
        % in the first frame of this epoch see whether the sin wave subfields
        % exist. if they don't initialize them. If they already exist they will
        % be used in the normal loop below to be continuous between epochs
        if ~isfield(stimData,'sinPVL')
            stimData.sinPVL = zeros(2,1);
            stimData.sinPVR = zeros(2,1);
            stimData.sinWNL = randn(sizeY,sizeX);
            stimData.sinWNR = randn(sizeY,sizeX);
        end
    end
    
    %% left eye
    %stimData.mat(1) is used as the wave phase. stimData.mat(2) is the velocity which
    %is constant unless noise is added

    sinWNL = zeros(sizeY,sizeX,framesPerUp);
    hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;
    upPosL = mod(hzFrame-1,stimUpRateL) == 0;
    upVelL = mod(hzFrame-1,stimUpRateL*velUpRateL) == 0;
    upWNL = mod(hzFrame-1,wnUpRateL) == 0;

    theta = (0:sizeX-1)/sizeX*2*pi; %theta in radians

    grabGridUnit;
    bitMap = zeros(1,sizeX,framesPerUp);

    for cc = 1:framesPerUp
        if upVelL(cc) == 1
            stimData.sinPVL(2) = randn*velSTDL+velL;
        end

        if upPosL(cc) == 1
            stimData.sinPVL(1) = stimData.sinPVL(1) + stimUpRateL*stimData.sinPVL(2)/(60*framesPerUp);
        end

        set0 = cL*sin(2*pi*(theta(1:length(gridUnit))-stimData.sinPVL(1))/lambdaL);
        setPi = fliplr(cL*sin(2*pi*(theta(1:length(gridUnit))-stimData.sinPVL(1))/lambdaL+pi));
        setMat = repmat([set0 setPi],[1 ceil(sizeX/size(gridUnit,2))]);
        
        bitMap(1,:,cc) = setMat(1:sizeX);

        if upWNL(cc) == 1
            stimData.sinWNL = randn(sizeY,sizeX);
        end

        sinWNL(:,:,cc) = stimData.sinWNL;

        stimData.mat(2*cc-1:2*cc) = stimData.sinPVL;
    end

    bitMap = repmat(bitMap,[sizeY,1]);
    
    maskStim;

    bitMap = mlumL*(1 + bitMap + wnCL*sinWNL);

    %% right eye
    if p.twoEyes
        leftEye = 0;
        sinWNR = zeros(sizeY,sizeX,framesPerUp);
        upPosR = mod(hzFrame-1,stimUpRateR) == 0;
        upVelR = mod(hzFrame-1,stimUpRateR*velUpRateR) == 0;
        upWNR = mod(hzFrame-1,wnUpRateR) == 0;

        rightEye = zeros(1,sizeX,framesPerUp);

        for cc = 1:framesPerUp
            % update sitmulus by changing the 
            if upVelR(cc) == 1
                stimData.sinPVR(2) = randn*velSTDR+velR;
            end

            if upPosR(cc) == 1
                stimData.sinPVR(1) = stimData.sinPVR(1) + stimUpRateR*stimData.sinPVR(2)/(60*framesPerUp);
            end

            set0 = cR*sin(2*pi*(theta(1:length(gridUnit))-stimData.sinPVR(1))/lambdaR);
            setPi = fliplr(cR*sin(2*pi*(theta(1:length(gridUnit))-stimData.sinPVR(1))/lambdaR+pi));
            setMat = repmat([setPi set0],[1 ceil(sizeX/size(gridUnit,2))]);

            rightEye(1,:,cc) = setMat(1:sizeX);

            if upWNR(cc) == 1
                stimData.sinWNR = randn(sizeY,sizeX);
            end

            sinWNR(:,:,cc) = stimData.sinWNR;

            stimData.mat(2*cc-1+framesPerUp*2:2*cc+framesPerUp*2) = stimData.sinPVR;
        end

        rightEye = repmat(rightEye,[sizeY,1]);
        
        maskStim

        rightEye = mlumR*(1 + rightEye + wnCR*sinWNR);

        bitMap = CombEyes(bitMap,rightEye,p,f);
    end
    
    %always include this line in a stim function to make the texture from the
    %bitmap

    texStr.tex = CreateTexture(bitMap,Q);
end