function analysis = OutlineRecordingOnZStack(flyResp,epochs,params,~ ,dataRate,dataType,~,varargin)



for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

numFlies = length(flyResp);

if numFlies==0
    analysis = [];
    return
end


for ff = 1:numFlies
    dataPathsForFly = dataPathsOut{ff};
    numFlyReps = length(dataPathsForFly);
    for rr = 1:numFlyReps
        %Doing this unwrapping of dataPathsOut because if there are two
        %recordings from the same fly we want both outlines (probably)
        zStackPath = GetZStackPathFromDatabase(dataPathsForFly{rr});
        
        [zStack, zStackTiffHandle] = GrabZStackTiff(zStackPath);
        if isempty(zStackTiffHandle)
            continue
        end
        
        imageDescription = zStackTiffHandle.getTag('ImageDescription');
        close(zStackTiffHandle)
        
        
        
        imageDescription = strsplit(imageDescription, sprintf('\r'));
        evalString = strcat('tempZstack.', imageDescription, ';');
        evalString = [evalString{:}];
        
        eval(evalString);
        
        % Load required parameters from z stack
        imgSizeZStack = size(zStack);
        xPositionZStack = tempZstack.state.motor.absXPosition;
        yPositionZStack = tempZstack.state.motor.absYPosition;
        zStartZStack = tempZstack.state.motor.absZPosition;
        zoomZStack = tempZstack.state.acq.zoomFactor;
        rotationZStack = tempZstack.state.acq.scanRotation;
        stepSizeZStack = tempZstack.state.acq.zStepSize;
        
        
        % Load movie information
        tempMovie = load(fullfile(dataPathsForFly{rr}, 'imageDescription.mat' ));
        
        % Load required parameters from movie
        imgSizeMovie = [tempMovie.state.acq.linesPerFrame-tempMovie.state.acq.slowDimDiscardFlybackLine tempMovie.state.acq.pixelsPerLine];
        xPositionMovie = tempMovie.state.motor.absXPosition;
        yPositionMovie = tempMovie.state.motor.absYPosition;
        zPositionMovie = tempMovie.state.motor.absZPosition;
        zoomMovie = tempMovie.state.acq.zoomFactor;
        rotationMovie = tempMovie.state.acq.scanRotation;
        
        % Calculate any shift that may have happened to acquire z stack
        displacementX = xPositionMovie - xPositionZStack;
        displacementY  = yPositionMovie - yPositionZStack;
        rotationShift = rotationZStack - rotationMovie;
        
        % Calculate zoom ratio and initial frame points
        zoomRatio = zoomZStack/zoomMovie;
        frameX = [-imgSizeMovie(2)/2 imgSizeMovie(2)/2 imgSizeMovie(2)/2 -imgSizeMovie(2)/2 -imgSizeMovie(2)/2]*zoomRatio;
        frameY = [-imgSizeMovie(1)/2 -imgSizeMovie(1)/2 imgSizeMovie(1)/2 imgSizeMovie(1)/2 -imgSizeMovie(1)/2]*zoomRatio;
        framePts = [frameX; frameY];
        
        % Calculate points based on rotation and displacement
        rotationMatrix = [cosd(rotationShift) -sind(rotationShift); sind(rotationShift) cosd(rotationShift)];
        rotatedFramePts = rotationMatrix*framePts;
        finalFramePts = rotatedFramePts(1, :)+displacementX+imgSizeZStack(2)/2;
        finalFramePts = [finalFramePts; rotatedFramePts(2, :) + displacementY+imgSizeZStack(1)/2];
        
        % Calculate which z-stack frame the movie came from
        depthFromZStackTop = zPositionMovie - zStartZStack;
        correctSlice = depthFromZStackTop/stepSizeZStack + 1;
        
        % Interpolate if it came from between stacks
        percentPreviousSlice = mod(correctSlice, 1);
        percentNextSlice = 1-percentPreviousSlice;
        
        previousFrame = zStack(:, :, floor(correctSlice));
        nextFrame = zStack(:, :, ceil(correctSlice));
        zImage = previousFrame*percentPreviousSlice + nextFrame*percentNextSlice;
        
        MakeFigure;
        imagesc(zImage);
        hold on
        plot(finalFramePts(1, :), finalFramePts(2, :), 'r');
        axis off
        
        title(dataPathsForFly{rr}, 'interpreter', 'none');
    end

end

analysis = [];
