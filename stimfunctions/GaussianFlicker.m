function [texStr,stimData] = gaussianFlicker(Q)
    %There are a couple things that should be noted about your choice for flick
    %and mot. The ratio of mot to flick can never be greater than 1:2. The
    %final contrast of the stimulus is = sqrt(flicker)
    %so try to keep the contrast below 0.5 so that 2 standard deviations of the
    %mean are between max and min. put it at 0.33 for 3 standard deviations
    
    sii = Q.stims.currStimNum;
    p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
    f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
    stimData = Q.stims.stimData;
    
   
    
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
    if isfield(p, 'period')
        period = p.period;
    else
        period = 60;
    end
    
    
    stimData.flash = false;
    if ~isfield(stimData,'periodPosition')
        periodPosition = 0;
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
    
    if seed && mod(f-1, p.duration) == 0
        rng(seed_val);
    end
    
    mlum = p.lum;
    
    texStr.opts = 'full'; % see drawTexture for deets
    texStr.dim = 2; % or 2
    texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

    bitMap = zeros(sizeY,sizeX,framesPerUp);

    %No need to do each frame separately since we're just looking at random
    %noise
    bitMap(:,:,:) = randn(size(bitMap))*p.stdv;
    
    stimData.mat=bitMap(1, 1, :);%save the contrast
    bitMap = mlum*(bitMap+1);
    
    if periodPosition < period
        stimData.periodPosition = periodPosition+1;
    else
        stimData.periodPosition = 1;
        stimData.flash = true;
    end


    %always include this line in a stim function to make the texture from the
    %bitmap
    texStr.tex = CreateTexture(bitMap,Q);
end
