function [texStr,stimData] = TernaryScint(Q)
    %There are a couple things that should be noted about your choice for flick
    %and mot. The ratio of mot to flick can never be greater than 1:2. The
    %final contrast of the stimulus is = sqrt(flicker)
    %so try to keep the contrast below 0.5 so that 2 standard deviations of the
    %mean are between max and min. put it at 0.33 for 3 standard deviations
    
    sii = Q.stims.currStimNum;
    p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
    f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
    stimData = Q.stims.stimData;
    cL = p.cL;
    cR = p.cR;
    
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
    
    phiL = p.phiL;
    phiR = p.phiR;
    mlumL = p.lumL;
    mlumR = p.lumR;
    
    texStr.opts = 'full'; % see drawTexture for deets
    texStr.dim = 2; % or 2
    texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

    maxDelayL = 0;
    maxDelayR = 0;
    checkForTwoEyes = 0;

    if f == 1
        % in the first frame of this epoch see whether the sin wave subfields
        % exist. if they don't initialize them. If they already exist they will
        % be used in the normal loop below to be continuous between epochs
        if ~isfield(stimData,'I1L')
            for ii = 1:size(Q.stims.params,2)
                
                % add 1 to max delay because to correlate at the max delay you need
                % stimData.mat(maxDelay+1)
                
                if Q.stims.params(ii).delayL >= maxDelayL
                    maxDelayL = Q.stims.params(ii).delayL + 1;
                end

                if Q.stims.params(ii).delayR >= maxDelayR
                    maxDelayR = Q.stims.params(ii).delayR + 1;
                end
        
                checkForTwoEyes = checkForTwoEyes + Q.stims.params(ii).twoEyes;
            end
            
            stimData.I1L = 2*round(rand(sizeY,sizeX,maxDelayL))-1;
            stimData.corrMatL = 2*round(rand(sizeY,sizeX))-1;
        end
        
        if checkForTwoEyes ~= 0
            if ~isfield(stimData,'I1R')
                stimData.I1R = 2*round(rand(sizeY,sizeX,maxDelayR))-1;
                stimData.corrMatR = 2*round(rand(sizeY,sizeX))-1;
            end
        end
    end

    %%%%% note this stimulus is designed so that the first correlation occurs
    %%%%% on the first timepoint of a new epoch, but this does NOT work if
    %%%%% there is an updateL difference between the two epochs

    bitMap = zeros(sizeY,sizeX,framesPerUp);
    hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;
    updateFrameL = mod(hzFrame-1,updateL) == 0;

    for cc = 1:framesPerUp
        if updateFrameL(cc)
            % create a new matrix at front and shift all the left eye
            % matricies back one. Keep all right eye matricies untouched.
            % Appened a new white noise left eye matrix to the end and keep
            % the white noise right eye matrix
            stimData.I1L = cat(3,2*round(rand(sizeY,sizeX))-1,stimData.I1L(:,:,1:end-1));
        
            if delayL == 0 && dirXL == 0 && dirYL == 0;
                stimData.corrMatL = 2*round(rand(sizeY,sizeX))-1;
            else
                stimData.corrMatL = phiL*circshift(stimData.I1L(:,:,delayL+1),[dirYL,dirXL]);
            end
        end
        
%         temp = 1/2*(stimData.I1L(:,:,1)+phiL*circshift(stimData.I1L(:,:,delayL+1),[dirYL,dirXL]));
%         
%         if updateFrameL(cc)
%             stimData.I2L = 2*round(rand(size(temp(temp==0))))-1;
%         end
%         
%         temp(temp==0) = stimData.I2L;

        
        
        bitMap(:,:,cc) = cL/2*(stimData.I1L(:,:,1)+stimData.corrMatL);
    end
    
    bitMap = mlumL*(bitMap+1);

    if p.twoEyes
        rightEye = zeros(sizeY,sizeX,framesPerUp);
        hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;
        updateFrameR = mod(hzFrame-1,updateR) == 0;

        for cc = 1:framesPerUp
            if updateFrameR(cc)
                % create a new matrix at front and shift all the left eye
                % matricies back one. Keep all right eye matricies untouched.
                % Appened a new white noise left eye matrix to the end and keep
                % the white noise right eye matrix
                stimData.I1R = cat(3,2*round(rand(sizeY,sizeX))-1,stimData.I1R(:,:,1:end-1));
            
                if delayR == 0 && dirXR == 0 && dirYR == 0;
                    stimData.corrMatR = 2*round(rand(sizeY,sizeX))-1;
                else
                    stimData.corrMatR = phiR*circshift(stimData.I1R(:,:,delayR+1),[dirYR,dirXR]);
                end
            end

    %         temp = 1/2*(stimData.I1R(:,:,1)+phiR*circshift(stimData.I1R(:,:,delayR+1),[dirYR,dirXR]));
    %         
    %         if updateFrameR(cc)
    %             stimData.I2R = 2*round(rand(size(temp(temp==0))))-1;
    %         end
    %         
    %         temp(temp==0) = stimData.I2R;

            

            rightEye(:,:,cc) = cR/2*(stimData.I1R(:,:,1)+stimData.corrMatR);
        end

        rightEye = mlumR*(rightEye+1);
        bitMap = CombEyes(bitMap,rightEye,p,f);
    end

    %always include this line in a stim function to make the texture from the
    %bitmap
    texStr.tex = CreateTexture(bitMap,Q);
end
