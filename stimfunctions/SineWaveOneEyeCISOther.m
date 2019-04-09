function [texStr,stimData] = SineWaveOneEyeCISOther(Q)
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
    
    lambda = p.lambda*pi/180; %wavelength in radians
    if ~isfield(p,'temporalFrequency')
        temporalFrequency = p.velocity/p.lambda;
    else
        temporalFrequency = p.temporalFrequency;
    end
    
    if (strcmp(p.direction,'progressive') && strcmp(p.sinEye,'left' )) || ...
       (strcmp(p.direction,'regressive' ) && strcmp(p.sinEye,'right'))
        direction = -1;
    else
        direction = 1;
    end
    
    vel = temporalFrequency*lambda;
    
    framesPerUp = p.framesPerUp;

    if f == 1
        stimData.sinPhase = 0;
        stimData.cisTimePhase = 0;
        stimData.cisSpacePhase = rand()*2*pi;
        
        stimData.mat(framesPerUp*2+1) = stimData.cisSpacePhase;
    end

    theta = (0:sizeX-1)/sizeX*2*pi; %theta in radians
    sinEye(1,sizeX,framesPerUp) = 0;
    cisEye(1,sizeX,framesPerUp) = 0;

    for cc = 1:framesPerUp
        dt = 1/(60*framesPerUp);
        stimData.sinPhase = stimData.sinPhase + direction*vel*dt;
        stimData.cisTimePhase = stimData.cisTimePhase + 2*pi*dt*temporalFrequency;

        sinEye(1,:,cc) = c*sin(2*pi*(theta-stimData.sinPhase)/lambda);
        cisEye(1,:,cc) = c*sin(stimData.cisTimePhase)...
                          *cos(2*pi*(theta+stimData.cisSpacePhase)/lambda);
        
        stimData.mat((cc-1)*2 + 1) = stimData.sinPhase;
        stimData.mat((cc-1)*2 + 2) = stimData.cisTimePhase;
        
    end

    sinEye = mlum*(1 + sinEye);
    cisEye = mlum*(1 + cisEye);

    if strcmp(p.sinEye,'left')
        bitMap = CombEyes(sinEye,cisEye,p,f);
    else
        bitMap = CombEyes(cisEye,sinEye,p,f);
    end

    %always include this line in a stim function to make the texture from the
    %bitmap

    texStr.tex = CreateTexture(bitMap,Q);
end