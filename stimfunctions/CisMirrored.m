function [texStr,stimData] = CisMirrored(Q)
    % Contrast inverting 

    p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
    f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
    stimData = Q.stims.stimData;

    if p.numDeg == 0
        sizeX = 1;
    else
        sizeX = round(360/p.numDeg);
    end

    mlum = p.lum;
    c = p.contrast;
    
    lambda = p.lambda*pi/180; %spatial wavelength in radians
    if lambda == 0 %lambda = 0 implies we want full field 
        lambda = inf;
    end
    framesPerUp = p.framesPerUp;

    %% left eye

    if f == 1
        stimData.spacePhase = rand()*2*pi;
        stimData.timePhase = 0;
    end

    theta = (0:sizeX-1)/sizeX*2*pi; %theta in radians
    bitMap(1,sizeX,framesPerUp) = 0;

    dt = (1/framesPerUp)*(1/60);
    for cc = 1:framesPerUp
        stimData.timePhase = stimData.timePhase + 2*pi*dt*p.temporalFrequency;

        bitMap(1,:,cc) = c*sin(stimData.timePhase)...
                          *cos(2*pi*(theta+stimData.spacePhase)/lambda);
        
        stimData.mat(cc) = stimData.timePhase;
    end
    stimData.mat(framesPerUp+1) = stimData.spacePhase;
    bitMap = mlum*(1 + bitMap);

    %% right eye
    if p.twoEyes
        rightEye = fliplr(bitMap);
        
        bitMap = CombEyes(bitMap,rightEye,p,f);
    end

    %always include this line in a stim function to make the texture from the
    %bitmap

    texStr.tex = CreateTexture(bitMap,Q);
end