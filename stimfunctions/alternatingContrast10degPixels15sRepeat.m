function [texStr,stimData] = alternatingContrast10degPixels15sRepeat(Q)
    
        sii = Q.stims.currStimNum;
        p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
        f = Q.timing.framenumber - Q.timing.framelastchange; % relative frame number
        stimData = Q.stims.stimData;
     
    if ~isfield(stimData, 'firstPresentation')
        stimData.firstPresentation = Q.timing.framenumber;
        frameInFlicker = 0;
    else
        frameInFlicker = Q.timing.framenumber - stimData.firstPresentation;
    end
    
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
    
%     if seed_val ~= 0 && mod(f, p.duration) == 0
%         rng(seed_val);
%     end
    
    %reseed every minute?
%     Q.timing.framenumber;
%     if seed_val ~= 0 && (mod(Q.timing.framenumber, 3600) == 0 || Q.timing.framenumber == 1)
%         rng(seed_val);
%        % fprintf('reseeded')
%     end
    
    mlum = p.lum;
    
    texStr.opts = 'full'; % see drawTexture for deets
    texStr.dim = 2; % or 2
    texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

    if mod(frameInFlicker, 3600)==0
        stimData.prevSeedState = rng(0);
    elseif mod(frameInFlicker, 3600) == 900
        rng(stimData.prevSeedState);
     end
    
    bitMap = zeros(36,36,framesPerUp);
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
           % full field flicker 
           bitMapVal = 2*p.stdv*(randi(2, [36 36])-1.5);
           bitMap(:,:,i) = bitMapVal;
           stimData.prevVal = bitMap(:, :, i);
           stimData.mat(5) = Q.timing.framenumber;
           stimData.mat(6) = p.stdv;
        else
            bitMap(:, :, i)= stimData.prevVal;
        end
    end
    
    bitMap =  mlum * ( 1 + bitMap );

    if periodPosition < period
        stimData.periodPosition = periodPosition+1;
    else
        stimData.periodPosition = 1 ;
        stimData.flash = true;
    end


    %always include this line in a stim function to make the texture from the
    %bitmap
    texStr.tex = CreateTexture(bitMap,Q);
    stimData.scurr = rng;
end