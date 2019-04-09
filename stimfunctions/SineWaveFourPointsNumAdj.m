function [texStr,stimData] = SineWaveFourPointsNumAdj(Q)
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

    sizeX = round(360/p.numDeg);
    sizeY = round(Q.cylinder.cylinderHeight/(Q.cylinder.cylinderRadius*tan(p.numDeg*pi/180)));

    mlumL = p.lumL;
    mlumR = p.lumR;

    cL = p.contrastL;
    cR = p.contrastR;

    contFreqL = p.contFreqL;
    contFreqR = p.contFreqR;

    phaseOffsetL = p.phaseOffsetL*pi/180;
    phaseOffsetR = p.phaseOffsetR*pi/180;

    cfSTDL = p.cfSTDL*pi/180;
    cfSTDR = p.cfSTDR*pi/180;

    stimUpRateL = p.stimUpRateL;
    stimUpRateR = p.stimUpRateR;

    cfUpRateL = p.cfUpRateL;
    cfUpRateR = p.cfUpRateR;

    wnUpRateL = p.wnUpRateL;
    wnUpRateR = p.wnUpRateR;

    wnCL = p.wnCL;
    wnCR = p.wnCR;

    framesPerUp = p.framesPerUp;

    if cfUpRateL == 0
        cfUpRateL = 1;
    end

    if cfUpRateR == 0
        cfUpRateR = 1;
    end
    
    %% left eye
    %stimData.mat(1) is used as the wave phase. stimData.mat(2) is the velocity which
    %is constant unless noise is added

    if f == 1
        % in the first frame of this epoch see whether the sin wave subfields
        % exist. if they don't initialize them. If they already exist they will
        % be used in the normal loop below to be continuous between epochs
        if ~isfield(stimData,'sin4pPVL')
            stimData.sin4pPVL = zeros(2,1);
        end

        if ~isfield(stimData,'sin4pPVR')
            stimData.sin4pPVR = zeros(2,1);
        end

        if ~isfield(stimData,'sin4pWNL');
            stimData.sin4pWNL = randn(sizeY,sizeX);
        end

        if ~isfield(stimData,'sin4pWNR');
            stimData.sin4pWNR = randn(sizeY,sizeX);
        end

        fMat = [1 3 2 4];
        rMat = [2 4 1 3];
        
        if p.numAdjL == 0
            stimData.sin4pPhaseL = floor(4*rand(1,sizeX))+1;
        else
            fListL = repmat(fMat,[1,floor((p.numAdjL+1)/4)+1]);
            fListL = fListL(1:p.numAdjL+1);

            rListL = repmat(rMat,[1,floor((p.numAdjL+1)/4)+1]);
            rListL = rListL(p.numAdjL+1:-1:1);

            combListL = [fListL(1) rListL(end) fListL rListL(1) fListL(end) rListL];

            stimData.sin4pPhaseL = repmat(combListL,[1 ceil(sizeX/size(combListL,2))]);
            stimData.sin4pPhaseL = stimData.sin4pPhaseL(1:sizeX);
        end

        if p.numAdjR == 0
            stimData.sin4pPhaseR = floor(4*rand(1,sizeX))+1;
        else
            fListR = repmat(fMat,[1,floor((p.numAdjR+1)/4)+1]);
            fListR = fListR(1:p.numAdjR+1);

            rListR = repmat(rMat,[1,floor((p.numAdjR+1)/4)+1]);
            rListR = rListR(p.numAdjR+1:-1:1);

            combListR = [fListR(1) rListR(end) fListR rListR(1) fListR(end) rListR];
            
            stimData.sin4pPhaseR = repmat(combListR,[1 ceil(sizeX/size(combListR,2))]);
            stimData.sin4pPhaseR = stimData.sin4pPhaseR(1:sizeX);
        end
    end
    
    sin4pWNL = zeros(sizeY,sizeX,framesPerUp);
    hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;
    upPosL = mod(hzFrame-1,stimUpRateL) == 0;
    upVelL = mod(hzFrame-1,stimUpRateL*cfUpRateL) == 0;
    upWNL = mod(hzFrame-1,wnUpRateL) == 0;
    phaseSetL = [0 pi phaseOffsetL phaseOffsetL+pi];

    bitMap = zeros(1,sizeX,framesPerUp);

    for cc = 1:framesPerUp
        if upVelL(cc) == 1
            stimData.sin4pPVL(2) = randn*cfSTDL+contFreqL;
        end

        if upPosL(cc) == 1
            stimData.sin4pPVL(1) = stimData.sin4pPVL(1) + stimUpRateL*stimData.sin4pPVL(2)/(60*framesPerUp);
        end

        bitMap(1,:,cc) = cL*sin(2*pi*(stimData.sin4pPVL(1))+phaseSetL(stimData.sin4pPhaseL));

        if upWNL(cc) == 1
            stimData.sin4pWNL = randn(sizeY,sizeX);
        end

        sin4pWNL(:,:,cc) = stimData.sin4pWNL;

        stimData.mat(2*cc-1:2*cc) = stimData.sin4pPVL;
    end
    
    bitMap = repmat(bitMap,[sizeY,1]);

    bitMap = mlumL*(1 + bitMap + wnCL*sin4pWNL);

    %% right eye
    if p.twoEyes
        sin4pWNR = zeros(sizeY,sizeX,framesPerUp);
        upPosR = mod(hzFrame-1,stimUpRateR) == 0;
        upVelR = mod(hzFrame-1,stimUpRateR*cfUpRateR) == 0;
        upWNR = mod(hzFrame-1,wnUpRateR) == 0;
        phaseSetR = [0 pi phaseOffsetR phaseOffsetR+pi];

        rightEye = zeros(1,sizeX,framesPerUp);

        for cc = 1:framesPerUp
            if upVelR(cc) == 1
                stimData.sin4pPVR(2) = randn*cfSTDR+contFreqR;
            end

            if upPosR(cc) == 1
                stimData.sin4pPVR(1) = stimData.sin4pPVR(1) + stimUpRateR*stimData.sin4pPVR(2)/(60*framesPerUp);
            end

            rightEye(1,:,cc) = cR*sin(2*pi*(stimData.sin4pPVR(1))+phaseSetR(stimData.sin4pPhaseR));

            if upWNR(cc) == 1
                stimData.sin4pWNR = randn(sizeY,sizeX);
            end

            sin4pWNR(:,:,cc) = stimData.sin4pWNR;

            stimData.mat(2*cc-1:2*cc) = stimData.sin4pPVR;
        end

        rightEye = repmat(rightEye,[sizeY,1]);

        rightEye = mlumR*(1 + rightEye + wnCR*sin4pWNR);

        bitMap = CombEyes(bitMap,rightEye,p,f);
    end

    %always include this line in a stim function to make the texture from the
    %bitmap

    texStr.tex = CreateTexture(bitMap,Q);
end