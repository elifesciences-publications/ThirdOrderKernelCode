function [texStr,stimData] = LightDarkEdgesOrthoDirs(Q)
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
        visDegX = 360;
        sizeX = round(visDegX/p.numDeg);
        visRadX = visDegX * pi/180;
        sizeY = Q.cylinder.cylinderHeight/(Q.cylinder.cylinderRadius*tan(p.numDeg*pi/180));
        sizeY = ceil(sizeY);
        visRadY = sizeY * pi/180;
    end

    mlum = p.lum;

    c = p.contrast;
    
    bkgdContrast = p.bkgdContrast;
    
    pol = p.pol;
    
    dir = p.direction;

    vel = p.velocity*pi/180; % degree/s into rad/s

    lambda = p.lambda*pi/180; %wavelength in radians

    stimUpRate = p.stimUpRate;

    velUpRate = p.velUpRate;



    framesPerUp = p.framesPerUp;
    
    duration = p.duration;

    if velUpRate == 0
        velUpRate = 1;
    end

    %% left eye
    %stimData.mat(1) is used as the wave phase.
    
    if f == 1
        stimData.sinPV = zeros(2,1);
        
    end

    hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;
    upPos = mod(hzFrame-1,stimUpRate) == 0;
    
    if cosd(dir) ~= 0
        theta = (0:sizeX-1)/sizeX*visRadX; %theta in radians
        sizeUsed = sizeX;
        visRadUsed = visRadX;
    elseif sind(dir) ~= 0
        theta = (0:sizeY-1)/sizeY*visRadY; %theta in radians
        sizeUsed = sizeY;
        visRadUsed = visRadY;
    else
        error('The direction parameter must be a multiple of 90 for LightDarkEdgesOrthoDirs');
    end
    
    bitMap = bkgdContrast * ones(1,sizeUsed,framesPerUp);
    
    duration = abs(lambda/vel*60)+p.startDelay+2; %in frames
    %      mod(f+1,duration)
    %     disp(mod(f, duration))
    for cc = 1:framesPerUp
        if mod(f+1,duration) == 0
            stimData.flash=true;
        end
        if mod(f+1, duration) > p.startDelay
            if upPos(cc) == 1
                stimData.sinPV(1) = stimData.sinPV(1) + stimUpRate*vel/(60*framesPerUp); % vel is in rad/s, 60*framesPerUp is in fr/s
            end
        else
            break
        end

        [~,edgeLoc] = min(abs(abs(stimData.sinPV(1))-theta)); % Find index of theta whose value is closest to sinPV--this is the index of the edge
        edgeLoc = ((vel>0)*2-1)*(edgeLoc-1);
        
        if abs(stimData.sinPV(1)) > lambda
            stimData.sinPV(1) = 0;
        end
        
        for pp = 0:lambda:2*visRadUsed
            if min(abs(pp-theta))<=mean(diff(theta))
                [~,ppInd] = min(abs(pp-theta));
            else
                ppInd = size(bitMap, 2)+1;
            end
            
            if vel > 0
                bitMap(1,ppInd:min([ppInd+edgeLoc size(bitMap,2)]),cc) = pol*c;
            else
                bitMap(1,max([ppInd+edgeLoc-1 1]):ppInd-1,cc) = pol*c; % The -1 takes care not to count edgeLoc 0 as edgeLoc 1 because it makes 90:90 into 91:90
            end
        end
    
        stimData.mat(2*cc-1:2*cc) = stimData.sinPV;
        stimData.mat(7) = edgeLoc;
        
    end
    
    if cosd(dir) ~= 0
        bitMap = repmat(bitMap,[sizeY,1]);        
        bitMap = mlum*(1 + bitMap);
    elseif sind(dir) ~= 0
        % Indexing of bitMap makes positive vel be up and negative vel be
        % down
        bitMap = repmat(permute(bitMap(:, end:-1:1, :), [2 1 3]),[1, sizeX]);
        bitMap = mlum*(1 + bitMap);
    end
    
    
    
    % always include this line in a stim function to make the texture from
    % the bitmap
    texStr.tex = CreateTexture(bitMap,Q);
end
