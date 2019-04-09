function [texStr,stimData] = ConInvSineArbitraryMirrored(Q)
    % basic sinewave stimulus. Can produce rotation and translation where
    % the opposite eye is the first eye's mirror image
    
    p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
    f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
    stimData = Q.stims.stimData;

    if p.numXDeg == 0
        sizeX = 1;
    else
        sizeX = round(360/p.numXDeg);
    end
    
    if p.numYDeg == 0
        sizeY = 1;
    else
        sizeY = round(Q.cylinder.cylinderHeight/(Q.cylinder.cylinderRadius*tan(p.numYDeg*pi/180)));
    end

    mlum = p.lum;
    cA = p.contrastA;
    cB = p.contrastB;
    
    if ~isfield(p,'temporalFrequencyA')
        velA = p.velocityA*pi/180; % degree/s into rad/s
        velB = p.velocityB*pi/180; % degree/s into rad/s
    else
        velA = p.temporalFrequencyA*p.lambdaA*pi/180;
        velB = p.temporalFrequencyB*p.lambdaB*pi/180;
    end
    
    lambdaA = p.lambdaA*pi/180; %wavelength in radians
    lambdaB = p.lambdaB*pi/180;
    framesPerUp = p.framesPerUp;
    
    psiA = p.psiA*pi/180; % vertical angle to rad/s
    psiB = p.psiB*pi/180;

    %% left eye
    %stimData.mat(1) is used as the wave phase. stimData.mat(2) is the velocity which
    %is constant unless noise is added

    if f == 1 && ~isfield(stimData,'sinPhaseA')
        stimData.sinPhaseA = 0;
        stimData.sinPhaseB = 0;
    end
    
    thetaX = (0:sizeX-1)/sizeX*2*pi; %thetaX in radians
    % fraction of cylinder height to cylinder circumference
    circToHeight = Q.cylinder.cylinderHeight/(2*Q.cylinder.cylinderRadius*pi);
    thetaY = (0:sizeY-1)/sizeY*2*pi*circToHeight; %thetaY in radians
    [thetaXMat,thetaYMat] = meshgrid(thetaX,thetaY);
    
    thetaCombA = cos(-psiA)*thetaXMat+sin(-psiA)*thetaYMat;
    thetaCombB = cos(-psiB)*thetaXMat+sin(-psiB)*thetaYMat;
    
    bitMap(sizeY,sizeX,framesPerUp) = 0;
    
    for cc = 1:framesPerUp
        stimData.sinPhaseA = stimData.sinPhaseA + velA/(60*framesPerUp);
        stimData.sinPhaseB = stimData.sinPhaseB + velB/(60*framesPerUp);
        
        bitMapA = cA*sin(2*pi*(thetaCombA-stimData.sinPhaseA)/lambdaA);
        bitMapB = cB*sin(2*pi*(thetaCombB-stimData.sinPhaseB)/lambdaB);

        bitMap(:,:,cc) = bitMapA+bitMapB;
        stimData.mat(cc) = stimData.sinPhaseA;
        stimData.mat(cc+framesPerUp) = stimData.sinPhaseB;
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