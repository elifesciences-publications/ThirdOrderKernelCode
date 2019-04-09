function [texStr,stimData] = ScintillatorAnyHzRound(Q)
    %There are a couple things that should be noted about your choice for flick
    %and mot. The ratio of mot to flick can never be greater than 1:2. The
    %final contrast of the stimulus is = sqrt(flicker)
    %so try to keep the contrast below 0.5 so that 2 standard deviations of the
    %mean are between max and min. put it at 0.33 for 3 standard deviations
    
    sii = Q.stims.currStimNum;
    p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
    f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
    stimData = Q.stims.stimData;
    flickL = p.flickerL;
    motL = p.motionL;
    flickR = p.flickerR;
    motR = p.motionR;
    updateL = p.updateL;
    updateR = p.updateR;
    delayL = p.delayL;
    delayR = p.delayR;
    dirXL = p.dirXL; %direction and amplitude of the motion
    dirYL = p.dirYL;
    dirXR = p.dirXR;
    dirYR = p.dirYR;
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
    rotateMap = 0;
    if isfield(p,'rotateMap')
        rotateMap = p.rotateMap;
    end
    phiL = p.phiL;
    phiR = p.phiR;
    mlumL = p.lumL;
    mlumR = p.lumR;
    
    noiseUpL = updateL;
    if isfield(p,'noiseUpL')
        noiseUpL = p.noiseUpL;
    end
    noiseUpR = updateR;
    if isfield(p,'noiseUpR')
        noiseUpR = p.noiseUpR;
    end
    
    texStr.opts = 'full'; % see drawTexture for deets
    texStr.dim = 2; % or 2
    texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

    checkForTwoEyes = 0;

    if f == 1
        % in the first frame of this epoch see whether the sin wave subfields
        % exist. if they don't initialize them. If they already exist they will
        % be used in the normal loop below to be continuous between epochs
        if ~isfield(stimData,'scintAL')
            stimData.maxDelayL = 0;
            stimData.maxDelayR = 0;
            
            for ii = 1:size(Q.stims.params,2)
                
                % add 1 to max delay because to correlate at the max delay you need
                % stimData.mat(maxDelay+1)
                
                if Q.stims.params(ii).delayL >= stimData.maxDelayL
                    stimData.maxDelayL = Q.stims.params(ii).delayL + 1;
                end

                if Q.stims.params(ii).delayR >= stimData.maxDelayR
                    stimData.maxDelayR = Q.stims.params(ii).delayR + 1;
                end
        
                checkForTwoEyes = checkForTwoEyes + Q.stims.params(ii).twoEyes;
            end
            
            stimData.scintAL = randn(sizeY,sizeX,stimData.maxDelayL);
        end

        if ~isfield(stimData,'scintBL');
            stimData.scintBL = randn(sizeY,sizeX);
        end
        
        if checkForTwoEyes ~= 0
            if ~isfield(stimData,'scintAR')
                stimData.scintAR = randn(sizeY,sizeX,stimData.maxDelayR);
            end
            
            if ~isfield(stimData,'scintBR');
                stimData.scintBR = randn(sizeY,sizeX);
            end
        end
    end

    %%%%% note this stimulus is designed so that the first correlation occurs
    %%%%% on the first timepoint of a new epoch, but this does NOT work if
    %%%%% there is an updateL difference between the two epochs

    AL = sqrt(motL);
    BL = sqrt(flickL-2*motL);
    if ~isreal(BL)
        error('b is imaginary');
    end
    bitMap = zeros(sizeY,sizeX,framesPerUp);
    hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;
    updateFrameL = mod(hzFrame-1,updateL) == 0;
    updateNoiseL = mod(hzFrame-1,noiseUpL) == 0;

    for cc = 1:framesPerUp
        if updateFrameL(cc)
            % create a new matrix at front and shift all the left eye
            % matricies back one. Keep all right eye matricies untouched.
            % Appened a new white noise left eye matrix to the end and keep
            % the white noise right eye matrix
            if sizeY == size(stimData.scintAL,1) && sizeX == size(stimData.scintAL,2)
                stimData.scintAL = cat(3,randn(sizeY,sizeX),stimData.scintAL(:,:,1:end-1));
            else
                stimData.scintAL = randn(sizeY,sizeX,stimData.maxDelayL);
            end
        end
        
        if updateNoiseL(cc)
            stimData.scintBL = randn(sizeY,sizeX);
        end

        bitMap(:,:,cc) = AL*stimData.scintAL(:,:,1)+phiL*AL*circshift(stimData.scintAL(:,:,delayL+1),[dirYL,dirXL])+BL*stimData.scintBL;
    end
    
    bitMap = round(mlumL*(bitMap+1));

    if flickL == 0
        bitMap = zeros(sizeY,sizeX,framesPerUp)+0.5;
    end
    
    if p.twoEyes
        AR = sqrt(motR);
        BR = sqrt(flickR-2*motR);
        
        rightEye = zeros(sizeY,sizeX,framesPerUp);
        updateFrameR = mod(hzFrame-1,updateR) == 0;
        updateNoiseR = mod(hzFrame-1,noiseUpR) == 0;
        
        for cc = 1:framesPerUp
            if updateFrameR(cc)
                % create a new matrix at front and shift all the left eye
                % matricies back one. Keep all right eye matricies untouched.
                % Appened a new white noise left eye matrix to the end and keep
                % the white noise right eye matrix
                if sizeY == size(stimData.scintAR,1) && sizeX == size(stimData.scintAR,2)
                    stimData.scintAR = cat(3,randn(sizeY,sizeX),stimData.scintAR(:,:,1:end-1));
                else
                    stimData.scintAR = randn(sizeY,sizeX,stimData.maxDelayR);
                end
            end

            if updateNoiseR(cc)
                stimData.scintBR = randn(sizeY,sizeX);
            end

            rightEye(:,:,cc) = AR*stimData.scintAR(:,:,1)+phiR*AR*circshift(stimData.scintAR(:,:,delayR+1),[dirYR,dirXR])+BR*stimData.scintBR;
        end

        rightEye = round(mlumR*(rightEye+1));
        
        if flickR == 0
            rightEye = zeros(sizeY,sizeX,framesPerUp)+0.5;
        end
        
        bitMap = CombEyes(bitMap,rightEye,p,f);
    end

    if rotateMap
        for cc = 1:framesPerUp
            bitMap(:,:,cc) = circshift(bitMap(:,:,cc),[1,size(bitMap(:,:,cc),2)/4]);
        end
    end
    %always include this line in a stim function to make the texture from the
    %bitmap
    texStr.tex = CreateTexture(bitMap,Q);
end
