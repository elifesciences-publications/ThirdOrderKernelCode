function [texStr,stimData] = CosNoMot(Q)
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
    
    contFreqL = p.contFreqL;
    contFreqR = p.contFreqR;
    
    kXL = 1/(p.lambdaXL*pi/180)*(p.lambdaXL ~= -1);
    kXR = 1/(p.lambdaXR*pi/180)*(p.lambdaXR ~= -1);

    kYL = 1/(p.lambdaYL*pi/180)*(p.lambdaYL ~= -1);
    kYR = 1/(p.lambdaYR*pi/180)*(p.lambdaYR ~= -1);

    framesPerUp = p.framesPerUp;

    if (wnUpRateL == 0) && (wnUpRateR == 0)
        sizeY = 1;
    end
    
    if velUpRateL == 0
        velUpRateL = 1;
    end

    if velUpRateR == 0
        velUpRateR = 1;
    end

    %% left eye
    %stimData.mat(1) is used as the wave phase. stimData.mat(2) is the velocity which
    %is constant unless noise is added

    if f == 1
        % in the first frame of this epoch see whether the sin wave subfields
        % exist. if they don't initialize them. If they already exist they will
        % be used in the normal loop below to be continuous between epochs
        if ~isfield(stimData,'sinPVL')
            stimData.sinPVL = zeros(2,1);
        end
        
        stimData.cosLocL = rand*2*pi;
        stimData.cosLocR = rand*2*pi;

        if ~isfield(stimData,'sinPVR')
            stimData.sinPVR = zeros(2,1);
        end
        
        if ~isfield(stimData,'sinWNL');
            stimData.sinWNL = randn(sizeY,sizeX);
        end

        if ~isfield(stimData,'sinWNR');
            stimData.sinWNR = randn(sizeY,sizeX);
        end
    end

    sinWNL(sizeY,sizeX,framesPerUp) = 0;
    hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;
    upPosL = mod(hzFrame-1,stimUpRateL) == 0;
    upVelL = mod(hzFrame-1,stimUpRateL*velUpRateL) == 0;
    upWNL = mod(hzFrame-1,wnUpRateL) == 0;

    thetaX = (0:sizeX-1)/sizeX*2*pi; %theta in radians
    thetaY = (0:sizeY-1)'/sizeY*2*pi;

    bitMap(sizeY,sizeX,framesPerUp) = 0;

    for cc = 1:framesPerUp
        if upVelL(cc) == 1
            stimData.sinPVL(2) = randn*velSTDL+contFreqL;
        end

        if upPosL(cc) == 1
            stimData.sinPVL(1) = stimData.sinPVL(1) + stimUpRateL*stimData.sinPVL(2)/(60*framesPerUp);
        end
        
        bitMap(:,:,cc) = cL*sin(2*pi*stimData.sinPVL(1))*cos(2*pi*kYL*thetaY)*cos(2*pi*kXL*thetaX+stimData.cosLocL);

        if upWNL(cc) == 1
            stimData.sinWNL = randn(sizeY,sizeX);
        end

        sinWNL(:,:,cc) = stimData.sinWNL;

        stimData.mat(2*cc-1+2:2*cc+2) = stimData.sinPVL;
    end
    
    stimData.mat(1) = stimData.cosLocL;

    bitMap = mlumL*(1 + bitMap + wnCL*sinWNL);

    %% right eye
    if p.twoEyes
        sinWNR(sizeY,sizeX,framesPerUp) = 0;
        upPosR = mod(hzFrame-1,stimUpRateR) == 0;
        upVelR = mod(hzFrame-1,stimUpRateR*velUpRateR) == 0;
        upWNR = mod(hzFrame-1,wnUpRateR) == 0;

        rightEye(sizeY,sizeX,framesPerUp) = 0;

        for cc = 1:framesPerUp
            % update sitmulus by changing the 
            if upVelR(cc) == 1
                stimData.sinPVR(2) = randn*velSTDR+contFreqR;
            end

            if upPosR(cc) == 1
                stimData.sinPVR(1) = stimData.sinPVR(1) + stimUpRateR*stimData.sinPVR(2)/(60*framesPerUp);
            end

            rightEye(:,:,cc) = cR*cos(2*pi*stimData.sinPVR(1))*cos(2*pi*kYR*thetaY)*cos(2*pi*kXR*thetaX+stimData.cosLocR);

            if upWNR(cc) == 1
                stimData.sinWNR = randn(sizeY,sizeX);
            end

            sinWNR(:,:,cc) = stimData.sinWNR;

            stimData.mat(2*cc-1+framesPerUp*2+2:2*cc+framesPerUp*2+2) = stimData.sinPVR;
        end
        
        rightEye = mlumR*(1 + rightEye + wnCR*sinWNR);
        stimData.mat(2) = stimData.cosLocR;

        bitMap = CombEyes(bitMap,rightEye,p,f);
    end

    %always include this line in a stim function to make the texture from the
    %bitmap

    texStr.tex = CreateTexture(bitMap,Q);
end