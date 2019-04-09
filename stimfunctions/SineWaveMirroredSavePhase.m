function [texStr,stimData] = SineWaveMirrored(Q)
    % basic sinewave stimulus. Can produce rotation and translation where
    % the opposite eye is the first eye's mirror image

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
    
    if ~isfield(p,'temporalFrequency')
        vel = p.velocity*pi/180; % degree/s into rad/s
    else
        vel = p.temporalFrequency*p.lambda*pi/180;
    end
    
    lambda = p.lambda*pi/180; %wavelength in radians
    framesPerUp = p.framesPerUp;

    %% left eye
    %stimData.mat(1) is used as the wave phase. stimData.mat(2) is the velocity which
    %is constant unless noise is added

    if f == 1
        if ~isfield(stimData,'sinPhase')
            stimData.sinPhase = 0;
        end
    end

    theta = (0:sizeX-1)/sizeX*2*pi; %theta in radians
    bitMap(1,sizeX,framesPerUp) = 0;

    for cc = 1:framesPerUp
        stimData.sinPhase = stimData.sinPhase + vel/(60*framesPerUp);

        bitMap(1,:,cc) = c*sin(2*pi*(theta-stimData.sinPhase)/lambda);
        
        stimData.mat(cc) = stimData.sinPhase;
    end

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