function analysis = CreateLayerMovie(flyResp,epochs,params,stim,dataRate,dataType,interleaveEpoch,varargin)%(Z, imgFramesInit, movieBounds, inTime)
%Function asks the user for a tif input file (one taken from a loop grab of
%scanimage) and outputs an AVI file that puts together all the images
%grabbed in the loop like a movie.

%Varargin defaults!
movieFps = []; %becomes capture frame rate if nothing else is assigned to it
movieBounds = [];
filename = 'movieOut';
inTime = false;
filterMovie = 0;
backgroundSubtractMovie = true;
useAlignedData = true;
percMotionThresh = 5;
epochsForMovie = [];
roisPlot = []; % allows you to select specific ROIs from a complex mask

changeableVarargin = {'imgFramesInit', 'movieBounds', 'inTime', 'movieFps', 'filename', 'roiMask', 'dataPathsOut', 'filterMovie', 'backgroundSubtractMovie', 'useAlignedData', 'percMotionThresh', 'epochsForMovie', 'roisPlot'};
for ii = 1:2:length(varargin)
    if any(strcmp(changeableVarargin, varargin{ii}))
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    else
        continue
    end
end

if isempty(movieBounds)
    if ~isempty(epochsForMovie)
        %% Calculate epoch start times
        epochList = epochs{1}(:, 1);
        numEpochs = length(unique(epochList));
        epochStartTimes = cell(numEpochs,1);
        epochDurations = cell(numEpochs,1);
        
        for ee = 1:length(epochStartTimes)
            chosenEpochs = [0; epochList==ee; 0];
            startTimes = find(diff(chosenEpochs)==1);
            endTimes = find(diff(chosenEpochs)==-1)-1;
            
            epochStartTimes{ee} = startTimes;
            epochDurations{ee} = endTimes-startTimes+1;
        end
        
        %% Get movie bounds
        epochsForMovie = ConvertEpochNameToIndex(params{1},epochsForMovie);
        epForIdStartTimes = [];
        epForIdEndTimes = [];
        for i=1:length(epochsForMovie)
            if ~isnan(epochsForMovie(i))
                epForIdStartTimes = [epForIdStartTimes; cat(1, epochStartTimes{epochsForMovie(i)})];
                epForIdEndTimes = [epForIdEndTimes; cat(1, epochStartTimes{epochsForMovie(i)})+cat(1, epochDurations{epochsForMovie(i)})-1];
            end
            %             firstStartTime = min([firstStartTime; epochStartTimes{selectedEpoch}]);
            %             lastEndTime = max([lastEndTime; epochStartTimes{selectedEpoch}+epochDurations{selectedEpoch}-1]);
        end
        [epForIdStartTimes, sortInds] = sort(epForIdStartTimes(:));
        epForIdEndTimes = epForIdEndTimes(:);
        epForIdEndTimes = epForIdEndTimes(sortInds);
        
        framesAnalyze = [];
        for i = 1:length(epForIdStartTimes)
            framesAnalyze = [framesAnalyze epForIdStartTimes(i):epForIdEndTimes(i)];
        end
        jumpLoc = find(diff(framesAnalyze)~=1, 1, 'first');
        if ~isempty(jumpLoc)
            warning('We are only making a movie of the first set of cohesive epochs');
            framesAnalyze = framesAnalyze(1:jumpLoc);
        end
        movieBounds = [min(framesAnalyze) max(framesAnalyze)];
    else
        
        movieBounds = [1, size(flyResp{1}, 1)];
    end
elseif inTime
    movieBounds = ceil(movieBounds.*dataRate+0.001);
end


masks = cellfun(@(msk) msk{1}, roiMask, 'UniformOutput', false);
dataPathsOut = cellfun(@(dpO) dpO{1}, dataPathsOut, 'UniformOutput', false);

if isempty(roisPlot)
    roisPlot = unique(masks{1});
    roisPlot(1) = []; % omit background
end

roiPoints = cell(length(roisPlot), 1);
for roiInd = 1:length(roisPlot)
    roiPoints{roiInd} = mask2poly(masks{1} == roisPlot(roiInd), 'Inner', 'CW');
end


%% Load movie
imageDescription = LoadImageDescription(dataPathsOut{1});
zoomLevel = imageDescription.acq.zoomFactor;
linescan = ~imageDescription.acq.scanAngleMultiplierSlow;

[photodiodeData, highResLinesPerFrame] = ReadInPhotodiode(imageDescription, dataPathsOut{1});

[epochBegin, epochEnd, ~, ~] = GetStimulusBounds(photodiodeData, highResLinesPerFrame, dataRate, linescan);

filesInMainDirectory = dir(dataPathsOut{1});
fileNames = {filesInMainDirectory.name};
alignmentFile = fileNames(~cellfun('isempty', strfind(fileNames, 'disinterleaved_alignment')));
alignmentData = dlmread(fullfile(dataPathsOut{1}, alignmentFile{1}), '\t');
alignmentData = alignmentData(round(epochBegin):round(epochEnd),:);


            
            
[imgFramesInit, ~, ~] = LoadAndProcessMovieData(dataPathsOut{1}, alignmentData, zoomLevel, linescan, filterMovie, backgroundSubtractMovie, useAlignedData, percMotionThresh, varargin{:});
imgFramesInit = imgFramesInit(:, :, round(epochBegin):round(epochEnd));
imgFramesInit = imgFramesInit(:, :, movieBounds(1):movieBounds(2));% log(imgFramesInit(:, :, movieBounds(1):movieBounds(2)));


% gaussFilterSigma = [1,1];
% gaussFilterSize = [5,5];
% imgFramesInit = imgaussfilt(imgFramesInit, gaussFilterSigma, 'FilterSize', gaussFilterSize);
% parfor i = 1:size(imgFramesInit, 3)
%     imgFramesInit(:, :, i) = medfilt2(imgFramesInit(:, :, i));
% end
mxImage = max(imgFramesInit(:));
imgFramesInit = imgFramesInit/mxImage;
avgFiltered = flyResp{1}(movieBounds(1):movieBounds(2), roisPlot);

fnEnd = ['bounds' num2str(movieBounds(1)) '-' num2str(movieBounds(2))];




% if isempty(movieFps)
%     %Grab frame rate that capture occurred at
%     fpsCell = regexp(imgData.description, 'frameRate=(\d+.*\d+)', 'tokens');
%     fpsSmallCell = [fpsCell{~cellfun('isempty', fpsCell)}];
%     movieFps = str2double(fpsSmallCell{:});
% end
if ~isempty(fnEnd)
    %DAT UNDAHSCO'!
    fnEnd = ['_' fnEnd];
end

outFilename = fullfile(dataPathsOut{1}, 'movie', [filename '.avi']); %default output filename

% masksCell = mat2cell(masks, size(masks, 1), size(masks, 2), ones(size(masks, 3), 1));
% boundedMasksCell = cellfun(@(layer) bwperim(layer), masksCell, 'UniformOutput', false);
% boundariesMatrix = cell2mat(boundedMasksCell);
% boundariesMatrix = any(boundariesMatrix, 3);




%Gotta reconvert imgFrames to a 4D with each 4th dimension being a 3D
% %frame
% windowMask = logical(windowMovie(imgFramesInit(:, :, 1), Z.params.linescan, Z.grab.alignmentData(movieBounds(1):movieBounds(2), :)));
% [r, c] = find(windowMask);
% imgFrames = zeros(r(end)-r(1)+1, c(end)-c(1)+1, 3, size(imgFramesInit, 3));
mxImg = max(imgFramesInit(:));
threshVal = 0.5*mxImg;
imgFramesInit(imgFramesInit>threshVal) = threshVal;

lowVal = 0.0*mxImg;
imgFramesInit(imgFramesInit<lowVal) = 0;

imgFramesInit = imgFramesInit/max(imgFramesInit(:));
MakeFigure;
pngDir = fullfile(dataPathsOut{1}, 'pngFigure');
mkdir(pngDir);
tVals = linspace(0, size(imgFramesInit,3)/dataRate, size(imgFramesInit, 3));
lineColors = lines(length(roiPoints));
% avgFiltered = bsxfun(@minus, avgFiltered, mean(avgFiltered(find(tVals<1), :)));
minResp = min(avgFiltered(:));
maxResp = max(avgFiltered(:));


lengthArr = 0.1*size(imgFramesInit, 2);

previousEpochNum = [];
epochBoundary = [];
for ind = 1:size(imgFramesInit, 3);
    clf
    if ~mod(ind, 100)
        disp(['Making frame ' num2str(ind)])
    end
    epochNum = epochList(ind+movieBounds(1));
    epochName = params{1}(epochNum).epochName;
    
    if any(strfind(epochName, 'Right'))
        rotation = 0;
    elseif any(strfind(epochName, 'Left'))
        rotation = 180;
    elseif any(strfind(epochName, 'Up'))
        rotation = 90;
    elseif any(strfind(epochName, 'Down'))
        rotation = -90;
    else
        rotation = NaN;
    end
    
    [Xarr, Yarr] = arrow(lengthArr, rotation);

    
    subplot(10, 10, 1:80)
%     imgFramesHere = imgFramesInit(:, :, ind);
%     frameToPlot = reshape(imgFramesHere(windowMask), [r(end)-r(1)+1, c(end)-c(1)+1]);
    imgAx = imagesc(imgFramesInit(:, :, ind));axis off;axis tight;caxis([0, threshVal]);
    colormap gray
    hold on
    for i = 1:length(roiPoints)
        tempXPoints = roiPoints{i}(:, 1) +1;
        
        tempYPoints = roiPoints{i}(:, 2) +1;
        
        xPoints = tempXPoints(tempXPoints>0 & tempYPoints>0);
        yPoints = tempYPoints(tempXPoints>0 & tempYPoints>0);
        xPoints(end+1) = xPoints(1);
        yPoints(end+1) = yPoints(1);
        h = plot(xPoints, yPoints, 'Color', lineColors(i, :));
        h.LineWidth = 10;
    end
    
    xPlt = Xarr-.75*lengthArr+size(imgFramesInit, 2);
    yPlt = Yarr+.75*lengthArr;
    bkgdX = [min(xPlt)-0.1*lengthArr, max(xPlt)+0.1*lengthArr, max(xPlt)+0.1*lengthArr, min(xPlt)-0.1*lengthArr];
    bkgdY = [min(yPlt)-0.1*lengthArr, min(yPlt)-0.1*lengthArr, max(yPlt)+0.1*lengthArr, max(yPlt)+0.1*lengthArr];
    if any(strfind(epochName, 'Dark'))
        patch(bkgdX, bkgdY, 'white');
        ptch = patch(xPlt, yPlt, 'black');
    elseif any(strfind(epochName, 'Light'))
        patch(bkgdX, bkgdY, 'black');
        ptch = patch(xPlt, yPlt, 'white');
    else
        ptch = patch(xPlt, yPlt, 'red');
    end
    ptch.LineStyle = 'none';
    hold off
    
    subplot(10, 10, 81:100);
    hold on
    axisLines = plot([0, 1], [minResp, minResp], 'k-', [0, 0], [minResp, 1], 'k-');
    [axisLines.LineWidth] = deal(3);
    dfText = text(-0.1*(1-minResp), (1-minResp)/2+minResp, '\Delta F/F = 1');
    dfText.Rotation = 90;
    dfText.VerticalAlignment = 'bottom';
    dfText.HorizontalAlignment = 'center';
    dfText.FontSize = 20;
    tText = text(0.5, minResp-0.1*(1-minResp), '1s');
    tText.VerticalAlignment = 'top';
    tText.FontSize = 20;
    for i = 1:length(roiPoints)
        timeTrace = plot(tVals(1:ind), avgFiltered(1:ind, i), 'Color', lineColors(i, :));
        timeTrace.LineWidth = 2;
        axis([tVals(1) tVals(end) minResp maxResp]);
        axis off;
    end
    
    if ~isempty(previousEpochNum) && previousEpochNum ~= epochNum
        epochBoundary = [epochBoundary ind];
    end
    previousEpochNum = epochNum;
    for i = 1:length(epochBoundary);
        boundLines = plot(tVals([epochBoundary(i) epochBoundary(i)]), [minResp, maxResp], 'k--');
        boundLines.LineWidth = 2;
    end
    hold off
    
    axisHandle = gcf;
    pause(0.001)
    set(axisHandle,'PaperPositionMode','auto');
    print(axisHandle,fullfile(pngDir, ['frame_' num2str(ind)]),'-dpng','-r0');

%     frameLayerR = reshape(imgFramesHere(windowMask), [r(end)-r(1)+1, c(end)-c(1)+1]);
% %     frameLayerR(boundariesMatrix) = 1;
%     frameLayerG = reshape(imgFramesHere(windowMask), [r(end)-r(1)+1, c(end)-c(1)+1]);
% %     frameLayerG(boundariesMatrix) = 0;
%     frameLayerB = reshape(imgFramesHere(windowMask), [r(end)-r(1)+1, c(end)-c(1)+1]);
%     frameLayerB(boundariesMatrix) = 0;
%     imgFrames(:, :, :, ind) = cat(3, frameLayerR,frameLayerG,frameLayerB);
end

% if verLessThan('matlab', '8.5')
%     imgMov = immovie(imgFrames);%, map);
%     movie2avi(imgMov, outFilename, 'fps', movieFps);
% else
% %     maxPerFrame = max(max(max(imgFrames)));
% %     maxFrameSet = repmat(maxPerFrame, [size(imgFrames, 1), size(imgFrames, 2), size(imgFrames, 3), 1]);
% %     imgFrames = imgFrames./mxImage;%maxFrameSet;
%     outFilename(end-3:end) = '.mp4';
%     movieObj = VideoWriter(outFilename);
%     movieObj.FrameRate = movieFps;
%     open(movieObj);
%     writeVideo(movieObj, imgFrames);
%     close(movieObj);
%     
% end
analysis.finalMoviePath = pngDir;

function [X, Y] = arrow(lengthArr, rotation)
% Creates an arrow with (if pointing right) the left midpoint at (0, 0)
if isnan(rotation)
    theta = linspace(0, 2*pi);
    X = lengthArr/2*cos(theta);
    Y = lengthArr/2*sin(theta);
else
    arrowLength = 2;
    shaftLength = 1;
    % The proportions look nice
    tipWidth = arrowLength;
    shaftWidth = tipWidth/2;
    
    halfTW = tipWidth/2;
    halfSW = shaftWidth/2;
    
    X = [0 shaftLength shaftLength arrowLength shaftLength shaftLength 0];
    Y = [-halfSW -halfSW -halfTW 0 halfTW halfSW halfSW];
    
    normFactor = 1/max(X);
    X = normFactor*X - 0.5; % Center it around 0
    Y = normFactor*Y;
    
    X(end+1) = X(1);
    Y(end+1) = Y(1);
    
    rotMatrix = [cosd(rotation) -sind(rotation); sind(rotation) cosd(rotation)];
    
    XY = rotMatrix*(lengthArr*[X; Y]);
    
    X = XY(1, :);
    Y = XY(2, :);
end


