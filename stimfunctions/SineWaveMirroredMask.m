function [texStr,stimData] = SineWaveMirroredMask(Q)
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
    % convert stimSize from degrees to indicies
    segmentSize = round(p.segmentSize/p.numDeg);
    blankSize = (p.blankSize/p.numDeg);
    reverseSeg = p.reverseSeg;
    balance = p.balance;

    %% left eye
    %stimData.mat(1) is used as the wave phase. stimData.mat(2) is the velocity which
    %is constant unless noise is added
    
    if isfield(Q.stims.params(end),'nextEpoch')
        interleaveEpoch = Q.stims.params(end).nextEpoch;
    else
        interleaveEpoch = 1;
    end
    
    if f == 1
        if ~isfield(stimData,'sinPhase')
            stimData.sinPhase = 2*pi*rand;
            stimData.cutPhase = floor(2*(segmentSize+blankSize)*rand);
        elseif Q.stims.currStimNum == interleaveEpoch
            stimData.cutPhase = floor(2*(segmentSize+blankSize)*rand);
        end
    end

    theta = (0:segmentSize-1)/sizeX*2*pi; %theta in radians
    blankSeg = zeros(1,blankSize);
    bitMap(1,sizeX,framesPerUp) = 0;

    for cc = 1:framesPerUp
        stimData.sinPhase = stimData.sinPhase + vel/(60*framesPerUp);
        
        stimSeg = c*sin(2*pi*(theta-stimData.sinPhase)/lambda);
        
        reverseStimSeg = stimSeg;
        
        if reverseSeg
            reverseStimSeg = fliplr(reverseStimSeg);
        end
            
        if balance
            reverseStimSeg = -reverseStimSeg;
        end
        
        repeatedSegment = [stimSeg blankSeg reverseStimSeg blankSeg];
        shiftedRepeatedSegment = circshift(repeatedSegment,[1 stimData.cutPhase]);
        
        numRepeats = ceil(sizeX/(2*(segmentSize+blankSize)));
        initialBitMap = repmat(shiftedRepeatedSegment,[1 numRepeats]);

        bitMap(1,:,cc) = initialBitMap(1:sizeX);
        
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