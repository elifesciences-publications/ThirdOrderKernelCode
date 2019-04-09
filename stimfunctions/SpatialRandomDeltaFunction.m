function [texStr,stimDataOut] = SpatialRandomDeltaFunction(Q)
    
    sii = Q.stims.currStimNum;
    p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
    updateNum = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number

    pixelLum = p.pixelLuminance;
    
    if isfield(p,'backgroundLuminance')
        backgroundLum = p.backgroundLuminance;
    else
        backgroundLum = 0;
    end
    
    framesPerUp = p.framesPerUp;
    
    if isfield(p,'updatesPerPixel')
        updatesPerPixel = p.updatesPerPixel;
    else
        updatesPerPixel = 1;
    end
    
    if isfield(p,'numUpdatesOn')
        numUpdatesOn = p.numUpdatesOn;
    else
        numUpdatesOn = updatesPerPixel; % Keep pixel on for the entire time
    end
    
    if isfield(p,'numDeg')
        numDegX = p.numDeg;
        numDegY = p.numDeg;
    else
        numDegX = p.numDegX;
        numDegY = p.numDegY;
    end
    
    if numDegX == 0
        sizeX = 1;
    else
        sizeX = round(360/numDegX);
    end
    
    if numDegY == 0
        sizeY = 1;
    else
        sizeY = round(Q.cylinder.cylinderHeight/(Q.cylinder.cylinderRadius*tan(numDegY*pi/180)));
    end
    
    texStr.opts = 'full'; % see drawTexture for deets
    texStr.dim = 2; % or 2
    texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

    % If this is the first time running this stimfunction, set up datastore
    if ~isfield(Q.stims.stimData,'spatialRandomDeltaFunction')
        [xCoords, yCoords] = GenerateRandomCoordinates(sizeX,sizeY);
        stimData.xCoords = xCoords;
        stimData.yCoords = yCoords;
        stimData.updatesThisPixel = 1;
        stimData.thisPixelIndex = 1;
    else
        stimData = Q.stims.stimData.spatialRandomDeltaFunction;
    end
    stimDataMat = Q.stims.stimData.mat;
    
    % If we are done with the current pixel, move on to the next one
    if stimData.updatesThisPixel > updatesPerPixel
        stimData.thisPixelIndex = stimData.thisPixelIndex+1;
        stimData.updatesThisPixel = 1;
    end
    
    % If we have activated all pixels, make a new random list to go through
    if stimData.thisPixelIndex > length(stimData.xCoords)
        [xCoords, yCoords] = GenerateRandomCoordinates(sizeX,sizeY);
        stimData.xCoords = xCoords;
        stimData.yCoords = yCoords;
        stimData.updatesThisPixel = 1;
        stimData.thisPixelIndex = 1;
    end

    % Determine current pixel to activate and save for later analysis
    xCoord = stimData.xCoords(stimData.thisPixelIndex);
    yCoord = stimData.yCoords(stimData.thisPixelIndex);
    stimDataMat(1:2) = [xCoord,yCoord];
    
    % Generate the stimulus
    bitMap = zeros(sizeY,sizeX,framesPerUp)+backgroundLum;
    if stimData.updatesThisPixel <= numUpdatesOn;
        bitMap(yCoord,xCoord,:) = pixelLum;
    end
    
    stimData.updatesThisPixel = stimData.updatesThisPixel + 1;
    
    stimDataOut = Q.stims.stimData;
    stimDataOut.spatialRandomDeltaFunction = stimData;
    stimDataOut.mat = stimDataMat;

    %always include this line in a stim function to make the texture from the
    %bitmap
    texStr.tex = CreateTexture(bitMap,Q);
    end

    function [xCoords, yCoords] = GenerateRandomCoordinates(sizeX,sizeY)
            randomPixelIndices = randperm(sizeX*sizeY);
            [xCoords, yCoords] = ind2sub([sizeX,sizeY],randomPixelIndices);
    end