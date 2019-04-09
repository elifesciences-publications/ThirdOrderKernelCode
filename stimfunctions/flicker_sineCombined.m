function [texStr,stimData] = flicker_sineCombined(Q)
    %There are a couple things that should be noted about your choice for flick
    %and mot. The ratio of mot to flick can never be greater than 1:2. The
    %final contrast of the stimulus is = sqrt(flicker)
    %so try to keep the contrast below 0.5 so that 2 standard deviations of the
    %mean are between max and min. put it at 0.33 for 3 standard deviations
    
        sii = Q.stims.currStimNum;
        p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
        f = Q.timing.framenumber - Q.timing.framelastchange; % relative frame number
        stimData = Q.stims.stimData;
    
        
    
    if f <= p.duration/2 
        
    if isfield(p, 'seed')
        seed = p.seed;
    else        
        %By default, reseed at the start of each epoch
        seed = 1;
    end
    if isfield(p, 'seed_val')
        seed_val = p.seed_val;
    else
        %I chose a number as the default seed_val
        seed_val = 1;
    end
    if isfield(p, 'period') %In frames
        period = p.period;
    else
        period = 60;
    end
    if isfield(p, 'flashRate') %In Hz
        flashRate = p.flashRate;
    else
        flashRate = 60;
    end
    
    stimData.flash = false;
    if ~isfield(stimData,'periodPosition')
        periodPosition = 0;
        stimData.periodPosition = periodPosition;
    else
        periodPosition = stimData.periodPosition;
    end
    
    framesPerUp = p.framesPerUp;
    if p.numDegX == 0
        sizeX = 1;
    else
        sizeX = round(360/p.numDegX);
    end
    if p.numDegY == 0
        sizeY = 1;
    else
        sizeY = round(Q.cylinder.cylinderHeight/(Q.cylinder.cylinderRadius*tan(p.numDegY*pi/180)));
    end
    
    if seed && mod(f, p.duration) == 0
        rng(seed_val);
    end
    
    mlum = p.lum;
    
    texStr.opts = 'full'; % see drawTexture for deets
    texStr.dim = 2; % or 2
    texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

    %bitMap = zeros(sizeY,sizeX,framesPerUp);
    bitMap = zeros(50,50,framesPerUp);
    
    %No need to do each frame separately since we're just looking at random
    %noise
    if mod(180, flashRate)
        error('The flashRate must be a clean divisor of 180 and cleanly divisible by 3');
    else
        flashPeriod = 180/flashRate;
    end
    
    
    for i = 1:framesPerUp
        frame = (f)*3+i-1; %To get it in units of the 180Hz frame rate
        framesOff = mod(frame, flashPeriod);
        if ~framesOff
            for j = 1:50
                for k = 1:50
            bitMap(j,k,i) = randn*p.stdv;
            stimData.prevVal = bitMap(:, :, i);
                end
            end
        else
            bitMap(:, :, i)= stimData.prevVal;
        end
    end
    
    bitMap = round(mlum*(bitMap+1));
    %stimData.mat=2*(bitMap(1, 1, :)-0.5);%save the contrast
    stimData.mat(1, 1)=p.stdv;
    currentStdv = p.stdv;
    
    if periodPosition < period
        stimData.periodPosition = periodPosition+1;
    else
        stimData.periodPosition = 1 ;
        stimData.flash = true;
    end


    %always include this line in a stim function to make the texture from the
    %bitmap
    texStr.tex = CreateTexture(bitMap,Q);
    else
    

    
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

     
        velL = p.velocityL*pi/180; 
        velR = p.velocityR*pi/180;
   
    stimData.mat(1, 2)=velL;
    stimData.mat(1,3)=velR;
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

    if f == p.duration/2+1
        % in the first frame of this epoch see whether the sin wave subfields
        % exist. if they don't initialize them. If they already exist they will
        % be used in the normal loop below to be continuous between epochs
        if ~isfield(stimData,'sinPVL')
            stimData.sinPVL = zeros(2,1);
        end

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

    theta = (0:sizeX-1)/sizeX*2*pi; %theta in radians

    bitMap(1,sizeX,framesPerUp) = 0;

    for cc = 1:framesPerUp
        if upVelL(cc) == 1
            stimData.sinPVL(2) = randn*velSTDL+velL;
        end

        if upPosL(cc) == 1
            stimData.sinPVL(1) = stimData.sinPVL(1) + stimUpRateL*stimData.sinPVL(2)/(60*framesPerUp);
        end

        bitMap(1,:,cc) = cL*sin(2*pi*(theta-stimData.sinPVL(1))/lambdaL);

        if upWNL(cc) == 1
            stimData.sinWNL = randn(sizeY,sizeX);
        end

        sinWNL(:,:,cc) = stimData.sinWNL;

%         stimData.mat(2*cc-1:2*cc) = stimData.sinPVL;
    end

    bitMap = repmat(bitMap,[sizeY,1]);

    bitMap = mlumL*(1 + bitMap + wnCL*sinWNL);

    %% right eye
    if p.twoEyes
        % invert velocity because we're going to flip the stimulus so that
        % the phase matches left and right eyes
        %velR = -velR;
        sinWNR(sizeY,sizeX,framesPerUp) = 0;
        upPosR = mod(hzFrame-1,stimUpRateR) == 0;
        upVelR = mod(hzFrame-1,stimUpRateR*velUpRateR) == 0;
        upWNR = mod(hzFrame-1,wnUpRateR) == 0;

        rightEye(1,sizeX,framesPerUp) = 0;

        for cc = 1:framesPerUp
            % update sitmulus by changing the 
            if upVelR(cc) == 1
                stimData.sinPVR(2) = randn*velSTDR+velR;
            end

            if upPosR(cc) == 1
                stimData.sinPVR(1) = stimData.sinPVR(1) + stimUpRateR*stimData.sinPVR(2)/(60*framesPerUp);
            end

            rightEye(1,:,cc) = cR*sin(2*pi*(theta-stimData.sinPVR(1))/lambdaR);

            if upWNR(cc) == 1
                stimData.sinWNR = randn(sizeY,sizeX);
            end

            sinWNR(:,:,cc) = stimData.sinWNR;

            stimData.mat(2*cc-1+framesPerUp*2:2*cc+framesPerUp*2) = stimData.sinPVR;
        end

        rightEye = repmat(rightEye,[sizeY,1]);

        rightEye = mlumR*(1 + rightEye + wnCR*sinWNR);

        bitMap = CombEyes(bitMap,rightEye,p,f);
    end

    %always include this line in a stim function to make the texture from the
    %bitmap

    texStr.tex = CreateTexture(bitMap,Q);
    end
        
end
