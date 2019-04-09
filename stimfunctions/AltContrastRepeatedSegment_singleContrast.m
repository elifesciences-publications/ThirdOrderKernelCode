function [texStr,stimData] = AltContrastRepeatedSegment_singleContrast(Q)
    % this is to provide the general structure for the texture generating codes
    % to be used with PTB in this framework. 

    % NOTE: when you create a new stimulus function, you must update the
    % stimlookup table in the folder paramfiles. paramfiles will also hold the
    % text file giving lists of parameters that comprise an experiment

        sii = Q.stims.currStimNum;
        p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
        f = Q.timing.framenumber - Q.timing.framelastchange; % relative frame number
        stimData = Q.stims.stimData;
        
    if ~isfield(stimData, 'firstFrame')
        stimData.firstFrame = Q.timing.framenumber;
        fileID = fopen('allValues.txt','r');
        stimData.rngVals = fscanf(fileID,'%d'); 
        fclose(fileID);
        %fprintf('here')
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
    
%     if seed_val ~= 0 && mod(f, p.duration) == 0
%         rng(seed_val);
%     end
    
%     
%     s = stimData.currentRngState;
%     rng(s);
%     if mod((Q.timing.framenumber-stimData.firstFrame),2700) == 0 && Q.timing.framenumber-stimData.firstFrame ~=0
%         s = rng;
%         stimData.origSeedState = s;        
%         rng(2);
%         stimData.lastChange = Q.timing.framenumber;
%     end
%     if isfield(stimData, 'lastChange') && Q.timing.framenumber-1 == stimData.lastChange+900
%         s = stimData.origSeedState;
%         rng(s);
%     end
    

    if f == 0
        % reseed the rng at the start of each epoch
        rng(0);
    end
    mlum = p.lum;
    
    texStr.opts = 'full'; % see drawTexture for deets
    texStr.dim = 2; % or 2
    texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

    %bitMap = zeros(sizeY,sizeX,framesPerUp);
    % divide screen into 50 sections
    %bitMap = zeros(50,50,framesPerUp);
    bitMap = zeros(sizeY,sizeX,framesPerUp);
    %No need to do each frame separately since we're just looking at random
    %noise
    if mod(180, flashRate)
        error('The flashRate must be a clean divisor of 180 and cleanly divisible by 3');
    else
        flashPeriod = 180/flashRate;
    end
    stdv = p.stdv;
    if p.interleave == 1
        stdv = 0;
    end
    for i = 1:framesPerUp
        frame = (f)*3+i-1; 
        framesOff = mod(frame, flashPeriod);
        if ~framesOff

           % full field flicker 
           if p.interleave == 1
               stdv = 0;
           end
           bitMapVal = 2*stdv*(randi(2)-1.5);
           bitMap(:,:,i) = bitMapVal;
            stimData.prevVal = bitMap(:, :, i);
            stimData.mat(5) = bitMapVal;

        else
            bitMap(:, :, i)= stimData.prevVal;
            stimData.mat(5) = stimData.prevVal;
        end
    end
    

    bitMap =  mlum * ( 1 + bitMap );
  
    stimData.mat(1)=stdv;
    stimData.mat(2:4) = bitMap(1,1,:);

    if periodPosition < period
        stimData.periodPosition = periodPosition+1;
    else
        stimData.periodPosition = 1 ;
        stimData.flash = true;
    end


    %always include this line in a stim function to make the texture from the
    %bitmap
    texStr.tex = CreateTexture(bitMap,Q);
%     s = rng;
%     stimData.currentRngState = s;
end