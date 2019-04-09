function [texStr,stimData] = gaussianFlicker_Contrastv2(Q)
    %There are a couple things that should be noted about your choice for flick
    %and mot. The ratio of mot to flick can never be greater than 1:2. The
    %final contrast of the stimulus is = sqrt(flicker)
    %so try to keep the contrast below 0.5 so that 2 standard deviations of the
    %mean are between max and min. put it at 0.33 for 3 standard deviations
    
    
    sii = Q.stims.currStimNum;
    p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
    f = Q.timing.framenumber - Q.timing.framelastchange; % relative frame number
    stimData = Q.stims.stimData;
    %ans = Q.timing.framenumber-1;
    if Q.timing.framenumber-1 == p.duration
        combosused = zeros(2,length(p.stdv));
        %fprintf('here')
        save('combosused.mat', 'combosused');
    end
    
    % param file assumes 9600 frams probe (squareWaveStillLeftRightProbe,
    % for example)
    if Q.timing.framenumber-1 == p.duration
        if exist('currentIndex.mat', 'file') == 2
            delete('currentIndex.mat')
        end
        if exist('currentPerm.mat', 'file') == 2
            delete('currentPerm.mat')
        end
    end
    
    if exist('currentIndex.mat', 'file') == 2
        load('currentIndex.mat');
    else
        index = 0;
    end

    if (Q.timing.framenumber-1) == p.duration || index == 0
       perm = randperm(length(p.stdv));
       p.stdv(:) = p.stdv(perm);
       devMatrix = p.stdv;
       combosused(1,:) = devMatrix;
       save('combosused.mat', 'combosused');
       save('currentPerm.mat', 'devMatrix');
       index = 0;
       save('currentIndex.mat', 'index');
    else
        load('currentPerm.mat');
        load('currentIndex.mat');
        p.stdv = devMatrix;
    end
    
    if (mod(Q.timing.framenumber-1, p.duration) == 0 || index == 0)
        index = index+1;
        save('currentIndex.mat', 'index');
        if index == 6
            index = 1;
            save('currentIndex.mat', 'index');
        end
    end
    
    %if f == 0
     %   index = randi(5);
      %  save('currentIndex.mat', 'index');
    %else
     %   load('currentIndex.mat');
    %end
    
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
    
    if seed && mod(f, p.duration) == 0
        rng(seed_val);
    end
    
    mlum = p.lum;
    
    texStr.opts = 'full'; % see drawTexture for deets
    texStr.dim = 2; % or 2
    texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

    %bitMap = zeros(sizeY,sizeX,framesPerUp);
    bitMap = zeros(50,50,framesPerUp);
    
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
            for j = 1:50
                for k = 1:50
            bitMap(j,k,i) = randn*p.stdv(index);
            stimData.prevVal = bitMap(:, :, i);
                end
            end
        else
            bitMap(:, :, i)= stimData.prevVal;
        end
    end
    
    bitMap = round(mlum*(bitMap+1));
    %stimData.mat=2*(bitMap(1, 1, :)-0.5);%save the contrast
    stimData.mat(1, 1)=p.stdv(index);
    currentstdv = p.stdv(index);
    save('currentstdv.mat', 'currentstdv');
    
    if periodPosition < period
        stimData.periodPosition = periodPosition+1;
    else
        stimData.periodPosition = 1 ;
        stimData.flash = true;
    end


    %always include this line in a stim function to make the texture from the
    %bitmap
    texStr.tex = CreateTexture(bitMap,Q);
end
