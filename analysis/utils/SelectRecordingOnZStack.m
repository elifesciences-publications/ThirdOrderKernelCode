function SelectRecordingOnZStack(Z)

connDb = connectToDatabase;
sysConfig = GetSystemConfiguration;

relativeDataPath = Z.params.pathName(length(sysConfig.twoPhotonDataPath)+1:end-1);
relativeDataPath(relativeDataPath == '/') = '\';

zStackPath = fetch(connDb, sprintf('select relativePath from fly as f join stimulusPresentation as sP on f.flyId=sP.fly where sP.relativeDataPath like "%s"', relativeDataPath));
dirFiles = dir(fullfile(sysConfig.twoPhotonDataPath,zStackPath{1}));
fileNames = {dirFiles.name};
zStackName = fileNames{~cellfun('isempty', strfind(lower(fileNames), 'zstack'))};

zStackTiff = Tiff(fullfile(sysConfig.twoPhotonDataPath,zStackPath{1}, zStackName));

imageDescription = zStackTiff.getTag('ImageDescription');
close(zStackTiff)

zStack = LoadTiffStack(fullfile(sysConfig.twoPhotonDataPath,zStackPath{1}, zStackName));

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


evalString = strcat('tempMovie.', Z.params.imageDescription, ';');
evalString = [evalString{:}];


eval(evalString);

% Load required parameters from movie
imgSizeMovie = Z.params.imgSize;
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
