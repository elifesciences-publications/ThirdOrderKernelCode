function [texStr,stimData] = CLScintillatorAnyHz(Q)

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
    sizeX = round(360/p.numDegX);
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

    maxDelayL = 0;
    maxDelayR = 0;
    checkForTwoEyes = 0;
    for ii = 1:size(Q.stims.params,2)
        if Q.stims.params(ii).delayL > maxDelayL
            maxDelayL = Q.stims.params(ii).delayL;
        end

        if Q.stims.params(ii).delayR > maxDelayR
            maxDelayR = Q.stims.params(ii).delayR;
        end
        
        checkForTwoEyes = checkForTwoEyes + p.twoEyes;
    end
    
    if checkForTwoEyes == 0
        maxDelayR = 0;
    end

    % add 1 to max delay because to correlate at the max delay you need
    % stimData.mat(maxDelay+1)
    maxDelayL = maxDelayL + 1;
    maxDelayR = maxDelayR + 1;
    
    % take care of loop stuff
    closeTheLoop;
    
    %%%%% note this stimulus is designed so that the first correlation occurs
    %%%%% on the first timepoint of a new epoch, but this does NOT work if
    %%%%% there is an updateL difference between the two epochs

    if Q.timing.framenumber == 1
        stimData.mat = randn(sizeY,sizeX,maxDelayL+maxDelayR+2);
    end

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
            stimData.mat = cat(3,randn(sizeY,sizeX),stimData.mat(:,:,[1:maxDelayL-1 maxDelayL+1:maxDelayL+maxDelayR]),stimData.mat(:,:,maxDelayL+maxDelayR+1),stimData.mat(:,:,maxDelayL+maxDelayR+2));
        end
        
        if updateNoiseL(cc)
            stimData.mat = cat(3,stimData.mat(:,:,1:maxDelayL+maxDelayR),randn(sizeY,sizeX),stimData.mat(:,:,maxDelayL+maxDelayR+2));
        end

        bitMap(:,:,cc) = AL*stimData.mat(:,:,1)+phiL*AL*circshift(stimData.mat(:,:,delayL+1),[dirYL,dirXL])+BL*stimData.mat(:,:,maxDelayL+maxDelayR+1);
    end
    
    bitMap = mlumL*(bitMap+1);

    if p.twoEyes
        AR = sqrt(motR);
        BR = sqrt(flickR-2*motR);
        
        rightEye = zeros(sizeY,sizeX,framesPerUp);
        updateFrameR = mod(hzFrame-1,updateR) == 0;
        updateNoiseR = mod(hzFrame-1,noiseUpR) == 0;
        
        for cc = 1:framesPerUp
            if updateFrameR(cc)
                stimData.mat = cat(3,stimData.mat(:,:,1:maxDelayL),randn(sizeY,sizeX),stimData.mat(:,:,maxDelayL+1:maxDelayL+maxDelayR-1),stimData.mat(:,:,maxDelayL+maxDelayR+1),stimData.mat(:,:,maxDelayL+maxDelayR+2));
            end
            
            if updateNoiseR(cc)
                stimData.mat = cat(3,stimData.mat(:,:,1:maxDelayL+maxDelayR+1),randn(sizeY,sizeX));
            end

            rightEye(:,:,cc) = AR*stimData.mat(:,:,maxDelayL+1)+phiR*AR*circshift(stimData.mat(:,:,maxDelayL+delayR+1),[dirYR,dirXR])+BR*stimData.mat(:,:,maxDelayL+maxDelayR+2);
        end

        rightEye = mlumR*(rightEye+1);
        
        bitMap = CombEyes(bitMap,rightEye,p,f);
    end

    if rotateMap
        for cc = 1:framesPerUp
            bitMap(:,:,cc) = circshift(bitMap(:,:,cc),[1,size(bitMap(:,:,cc),2)/4]);
        end
    end
    
    % stimData.mat(11) = min(bitMap(:));
    % stimData.mat(12) = max(bitMap(:));
    % stimData.mat(13) = mean(bitMap(:));
    % stimData.mat(14) = std(bitMap(:));
    % stimData.mat(15:20) = bitMap(1,1:6,1);

    %always include this line in a stim function to make the texture from the
    %bitmap
    texStr.tex = CreateTexture(bitMap,Q);
end
