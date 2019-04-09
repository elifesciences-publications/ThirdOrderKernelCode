function [texStr,stimData] = ScintillatorTernaryMirrored(Q)
    %There are a couple things that should be noted about your choice for flick
    %and mot. The ratio of mot to flick can never be greater than 1:2. The
    %final contrast of the stimulus is = sqrt(flicker)
    %so try to keep the contrast below 0.5 so that 2 standard deviations of the
    %mean are between max and min. put it at 0.33 for 3 standard deviations
    
    sii = Q.stims.currStimNum;
    p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
    f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
    stimData = Q.stims.stimData;
    mot = p.motion;
    flick = p.flicker;
    
    % This allows for either an updateRate approach (in Hz) or an update
    % field (in frames)--the updateRate field takes precedence!
    if isfield(p, 'updateRate')
        update = (60*p.framesPerUp)/p.updateRate;
    elseif isfield(p, 'update')
        update = p.update;
    end
    
    if isfield(p, 'fullFieldFlickAdd')
        C = p.fullFieldFlickAdd;
    else
        C = 0;
    end
    
    
    if rem(update,1) ~= 0
        error('update is less than 1, check requrested update rate and framesPerUp');
    end
    
    delay = p.delay;
    dirX = p.dirX; %direction and amplitude of the motion
    dirY = p.dirY;
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
    
    phi = p.phi;
    mlum = p.lum;
    
    texStr.opts = 'full'; % see drawTexture for deets
    texStr.dim = 2; % or 2
    texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

    A = sqrt(mot);
    B = sqrt(flick-2*mot);
    
    if flick-2*mot<0
        error('B is imaginary');
    end
    
    maxDelay = 0;
    checkForTwoEyes = 0;

    if f == 1
        % in the first frame of this epoch see whether the sin wave subfields
        % exist. if they don't initialize them. If they already exist they will
        % be used in the normal loop below to be continuous between epochs
        if ~isfield(stimData,'I1') || sizeY ~= size(stimData.I1, 1) || sizeX ~= size(stimData.I1, 2)
            for ii = 1:size(Q.stims.params,2)
                
                % add 1 to max delay because to correlate at the max delay you need
                % stimData.mat(maxDelay+1)
                
                if Q.stims.params(ii).delay >= maxDelay
                    maxDelay = Q.stims.params(ii).delay + 1;
                end

        
                checkForTwoEyes = checkForTwoEyes + Q.stims.params(ii).twoEyes;
            end
            
            stimData.noiseMat = 2*round(rand(sizeY,sizeX))-1;
            maskNoise = rand(sizeY,sizeX)<p.density;
            stimData.noiseMat = stimData.noiseMat.*maskNoise;
            
            stimData.I1 = 2*round(rand(sizeY,sizeX,maxDelay))-1;
            maskMat = rand(sizeY,sizeX,maxDelay)<p.density;
            stimData.I1 = stimData.I1.*maskMat;
            stimData.corrMat = zeros(size(stimData.I1));
        end
    end

    %%%%% note this stimulus is designed so that the first correlation occurs
    %%%%% on the first timepoint of a new epoch, but this does NOT work if
    %%%%% there is an updateL difference between the two epochs

    bitMap = zeros(sizeY,sizeX,framesPerUp);
    hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;
    updateFrame = mod(hzFrame-1,update) == 0;

    for cc = 1:framesPerUp
        if updateFrame(cc)
            % create a new matrix at front and shift all the left eye
            % matricies back one. Keep all right eye matricies untouched.
            % Appened a new white noise left eye matrix to the end and keep
            % the white noise right eye matrix
            newMat = 2*round(rand(sizeY,sizeX))-1;
            maskMat = rand(sizeY,sizeX)<p.density;
            newMat = newMat.*maskMat;
            stimData.I1 = cat(3,newMat,stimData.I1(:,:,1:end-1));
            
            stimData.noiseMat = 2*round(rand(sizeY,sizeX))-1;
            maskNoise = rand(sizeY,sizeX)<p.density;
            stimData.noiseMat = stimData.noiseMat.*maskNoise;
            stimData.addContrast = ones(sizeY, sizeX)*2*(randi(2)-1.5);
            if delay == 0 && dirX == 0 && dirY == 0;
                stimData.corrMat = 2*round(rand(sizeY,sizeX))-1;
            else
                stimData.corrMat = phi*circshift(stimData.I1(:,:,delay+1),[dirY,dirX]);
            end
        end

        bitMap(:,:,cc) = A*stimData.I1(:,:,1)+A*stimData.corrMat+B*stimData.noiseMat+C*stimData.addContrast;
    end
    
    bitMap = mlum*(bitMap+1);

    if p.twoEyes
        rightEye = fliplr(bitMap);
        
        bitMap = CombEyes(bitMap,rightEye,p,f);
    end

    %always include this line in a stim function to make the texture from the
    %bitmap
    texStr.tex = CreateTexture(bitMap,Q);
end
