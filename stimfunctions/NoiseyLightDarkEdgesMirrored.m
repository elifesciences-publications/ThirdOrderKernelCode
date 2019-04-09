function [texStr,stimData] = NoiseyLightDarkEdgesMirrored(Q)
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

    numDeg = p.numDeg;
    noiseContrast = p.noiseContrast;
    if numDeg == 0
        sizeX = 1;
    else
        sizeX = round(360/numDeg);
    end

    mlum = p.lum;
    c = p.contrast;
    pol = p.pol;
    vel = p.velocity*pi/180; % degree/s into rad/s
    startDelay = p.startDelay;
    distBetweenEdges = p.distBetweenEdges*pi/180; % distance between new in radians
    framesPerUp = p.framesPerUp;
    %% left eye

    if f == 1
        stimData.edgePhase = 0;
    end

    bitMap = zeros(1,sizeX,framesPerUp)-1;

    % create variable that represents one edge. repmat this to get the full
    % bitmap
    sizeEdge = round(distBetweenEdges*180/pi/numDeg);
    edge = zeros(1,sizeEdge)-1;
    
    for cc = 1:framesPerUp
        if f>startDelay
            stimData.edgePhase = stimData.edgePhase + abs(vel)/(60*framesPerUp);
            stimData.edgePhase = mod(stimData.edgePhase,distBetweenEdges);
        end
        
        edgeLoc = round(stimData.edgePhase*180/pi/numDeg);
        
        edge(1,1:edgeLoc) = 1;
        
        tempMap = repmat(edge,[1 ceil(sizeX/sizeEdge)]);
        bitMap(:,:,cc) = tempMap(1,1:sizeX);
    end
    
    if vel < 0
        bitMap = fliplr(bitMap);
    end
    
     %% right eye
    if p.twoEyes
        rightEye = fliplr(bitMap);
        
        bitMap = CombEyes(bitMap,rightEye,p,f);
    end
    noise = noiseContrast*(2*round(rand(1,sizeX, framesPerUp))-1);
    bitMap(bitMap==-1) = 0;
    bitMap = mlum*(1 + pol*c*bitMap + noise);
    
    %always include this line in a stim function to make the texture from the
    %bitmap

    texStr.tex = CreateTexture(bitMap,Q);
end
