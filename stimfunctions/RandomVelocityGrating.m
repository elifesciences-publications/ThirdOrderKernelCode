function [texStr,stimData] = RandomVelocityGrating(Q)
    % this is to provide the general structure for the texture generating codes
    % to be used with PTB in this framework. 

    % NOTE: when you create a new stimulus function, you must update the
    % stimlookup table in the folder paramfiles. paramfiles will also hold the
    % text file giving lists of parameters that comprise an experiment

    %when choosing noise values for the sine wave make sure that:
    %noiseContrast <= (1-mlum*(contrast+1))/(3*mlum)
    %this insures that 3 std of the noise keeps you below a luminence of 1

    
% 1 = 180
% 2 = 90
% 3 = 60

% (or change frames per up, multiples of 3)
% 
% if frames per up = 6
%     (360 / update rate)

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
    repeatBlock = p.repeatBlock;
    
    mlumL = p.lumL;
    mlumR = p.lumR;

    cL = p.contrastL;
    cR = p.contrastR;

    velL = p.velocityL; % degree/s into rad/s
    velR = p.velocityR; % degree/s into rad/s

    lambdaL = p.lambdaL; %wavelength in radians
    lambdaR = p.lambdaR; %wavelength in radians

    velSTDL = p.velSTDL;
    velSTDR = p.velSTDR;

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

    if ~isfield(stimData,'cumMotion')
        stimData.cumMotion = 0; 
        stimData.cumRemain = 0; 
    end
%% Set Up Repeats 
if isfield(p, 'repeatLength')
    repeatLength = p.repeatLength*60;
    blockLength = p.blockLength*60;
else
    repeatLength = 900;
    blockLength = 3600;
end

if ~isfield(stimData, 'firstPresentation')
    stimData.firstPresentation = Q.timing.framenumber;
    frameInFlicker = 0;
else
    frameInFlicker = Q.timing.framenumber - stimData.firstPresentation;
end


if isfield(p, 'repeatBlock')
    repeatBlock = p.repeatBlock;
else
    %warning('No repeat chunk will be included in this presentation!');
    repeatBlock = 0;
end


if repeatBlock
    if mod(frameInFlicker, blockLength)==0
        rng(Q.timing.framenumber);
    elseif mod(frameInFlicker, blockLength) == blockLength-repeatLength
        rng(0);
    end
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

        if ~isfield(stimData,'sinPVR')
            stimData.sinPVR = zeros(2,1);
        end

        if ~isfield(stimData,'sinWNL');
            stimData.sinWNL = randn(sizeY,5*sizeX);
        end

        if ~isfield(stimData,'sinWNR');
            stimData.sinWNR = randn(sizeY,5*sizeX);
        end
 
        s1 = interp1(1:sizeX, 2*(round(rand(sizeY,sizeX,1)))-1,linspace(1,sizeX, 360), 'nearest');
        s2 = interp1(1:sizeX, 2*(round(rand(sizeY,sizeX,1)))-1,linspace(1,sizeX,360), 'nearest');
        stimData.gratMem = cat(3, s1, s2);

    end

    sinWNL(sizeY,5*sizeX,framesPerUp) = 0;
    hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;
    upPosL = mod(hzFrame-1,stimUpRateL) == 0;
    upVelL = mod(hzFrame-1,stimUpRateL*velUpRateL) == 0;
    upWNL = mod(hzFrame-1,wnUpRateL) == 0;

    theta = (0:sizeX-1)/sizeX*2*pi; %theta in radians

    bitMap(1,5*sizeX,framesPerUp) = 0;

    for cc = 1:framesPerUp
        if upVelL(cc) == 1
            stimData.sinPVL(2) = randn*velSTDL+velL;
            %velocityRanGen = (2*(round(rand(1)))-1)*velSTDL+velL;
            velocityRanGen = randn*velSTDL+ velL;

            stimData.mat(1) = velocityRanGen;
            stimData.cumMotion = stimData.cumMotion + velocityRanGen./(framesPerUp*60) + stimData.cumRemain;
            stimData.mat(2) = stimData.cumMotion;
            
        end
        
        if upPosL(cc) == 1
            stimData.sinPVL(1) = stimData.sinPVL(1) + stimUpRateL*stimData.sinPVL(2)/(60*framesPerUp);

        end

        stimData.gratMem = cat(3,ones(sizeY,sizeX*5),stimData.gratMem(:,:,1:end-1));
        if abs(stimData.cumMotion) > 1
            moveBy = fix(stimData.cumMotion);
            stimData.mat(3) = moveBy;
            stimData.cumRemain = stimData.cumMotion - moveBy;
            stimData.cumMotion = 0; 
            stimData.gratMem(:,:,1) = circshift(stimData.gratMem(:,:,2), [1, moveBy]); % stimData.sinPVL(1)/lambdaL
        else
            stimData.gratMem(:,:,1) = stimData.gratMem(:,:,2);
        end
        bitMap(1,:,cc) = stimData.gratMem(:,:,1);

        if upWNL(cc) == 1
            stimData.sinWNL = randn(sizeY,5*sizeX);
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