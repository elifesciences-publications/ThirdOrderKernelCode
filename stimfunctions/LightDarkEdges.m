function [texStr,stimData] = LightDarkEdges(Q)
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
    
    polL = p.polL;
    polR = p.polR;

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

    framesPerUp = p.framesPerUp;
    
    duration = p.duration;

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
        stimData.sinPVL = zeros(2,1);
        stimData.sinPVR = zeros(2,1);
        
        if ~isfield(stimData,'sinWNL');
            stimData.sinWNL = randn(sizeY,sizeX);
            stimData.sinWNR = randn(sizeY,sizeX);
        end
    end

    sinWNL = zeros(sizeY,sizeX,framesPerUp);
    hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;
    upPosL = mod(hzFrame-1,stimUpRateL) == 0;
    upVelL = mod(hzFrame-1,stimUpRateL*velUpRateL) == 0;
    upWNL = mod(hzFrame-1,wnUpRateL) == 0;

    theta = (0:sizeX-1)/sizeX*2*pi; %theta in radians

    bitMap = zeros(1,sizeX,framesPerUp)-1;

    duration = abs(lambdaL/velL*60)+p.startDelayL+2; %in frames
%      mod(f+1,duration)
%     disp(mod(f, duration))
    for cc = 1:framesPerUp
        if mod(f+1,duration) == 0
            stimData.flash=true;
        end
        if mod(f+1, duration) > p.startDelayL
            if upVelL(cc) == 1
                stimData.sinPVL(2) = randn*velSTDL+velL;
            end

            if upPosL(cc) == 1
                stimData.sinPVL(1) = stimData.sinPVL(1) + stimUpRateL*stimData.sinPVL(2)/(60*framesPerUp);
            end
        end

        [~,edgeLocL] = min(abs(abs(stimData.sinPVL(1))-theta));
        edgeLocL = ((velL>0)*2-1)*(edgeLocL-2);
        
        if abs(stimData.sinPVL(1)) > lambdaL
            stimData.sinPVL(1) = 0;
        end
        
        for pp = 0:lambdaL:2*pi
            [~,ppInd] = min(abs(pp-theta));
            
            if velL > 0
                bitMap(1,ppInd:min([ppInd+edgeLocL size(bitMap,2)]),cc) = 1;
            else
                bitMap(1,max([ppInd+edgeLocL 1]):ppInd,cc) = 1;
            end
        end
        
        if upWNL(cc) == 1
            stimData.sinWNL = randn(sizeY,sizeX);
        end

        sinWNL(:,:,cc) = stimData.sinWNL;

        stimData.mat(2*cc-1:2*cc) = stimData.sinPVL;
    end

    bitMap = repmat(bitMap,[sizeY,1]);

    bitMap = mlumL*(1 + polL*cL*bitMap + wnCL*sinWNL);

    
    %always include this line in a stim function to make the texture from the
    %bitmap

    texStr.tex = CreateTexture(bitMap,Q);
end
