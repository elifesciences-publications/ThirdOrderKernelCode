function [texStr,stimData] = alternatingContrastFullFieldAnyRepeat(Q)
    % this function *should* give a 15 second segment that repeats every
    % minute, with everything else random.
    % hopefully.
    
    % implementing this by reading in a text file.
        sii = Q.stims.currStimNum;
        p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
        f = Q.timing.framenumber - Q.timing.framelastchange; % relative frame number
        stimData = Q.stims.stimData;
        
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
%     if isfield(p, 'repeatBlock')
%     repeatBlock = p.repeatBlock;
% else
%     warning('No repeat chunk will be included in this presentation!');
%     repeatBlock = 0;
% end
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
    

    if mod(frameInFlicker, blockLength)==0
        stimData.prevSeedState = rng(0);
    elseif mod(frameInFlicker, blockLength) == repeatLength
        rng(stimData.prevSeedState);
    end
% elseif f==0
%     if reseed
%         rng(Q.timing.framenumber);
%     else
%         rng shuffle
%     end



    for i = 1:framesPerUp
        frame = (f)*3+i-1; 
        framesOff = mod(frame, flashPeriod);
        if ~framesOff

           % full field flicker 
           bitMapVal = 2*p.stdv*(randi(2)-1.5);
          % bitMapVal = 2*p.stdv*(stimData.rngVals(Q.timing.framenumber-stimData.firstFrame+1) - 1.5);
           bitMap(:,:,i) = bitMapVal;
            stimData.prevVal = bitMap(:, :, i);
            stimData.mat(5) = bitMapVal;
            stimData.mat(6) = Q.timing.framenumber;

        else
            bitMap(:, :, i)= stimData.prevVal;
            stimData.mat(5) = stimData.prevVal;
            stimData.mat(6) = Q.timing.framenumber;
        end
    end
    

    bitMap =  mlum * ( 1 + bitMap );
  
    stimData.mat(1)=p.stdv;
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