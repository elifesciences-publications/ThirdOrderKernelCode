function analysis = CreateMotionLayerMovie(flyResp,epochs,params,~,dataRate, ~,interleaveEpoch,varargin)

%(Z, imgFramesInit, movieBounds, inTime)
%Function asks the user for a tif input file (one taken from a loop grab of
%scanimage) and outputs an AVI file that puts together all the images
%grabbed in the loop like a movie.
changeableVarargin = {'roiMask', 'dataPath', 'saveMovieLocation','epochsForMovie'};
saveMovieLocation = '';
epochsForMovie = '';

for ii = 1:2:length(varargin)
    if any(strcmp(changeableVarargin,    varargin{ii}))
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    else
        continue
    end
end

numFlies = length(flyResp);

for ff = 1:numFlies
    roiMaskHere = roiMask{ff}{1};
    %% Read in photodiode
    % Discarding the flyback line means the lines per frame go from,
    % say, 128 to 127, because that last line happens when the mirrors
    % are repositioning to the top corner of the frame
    imageDescription = LoadImageDescription(dataPath{ff});
    [photoDiode, highResLinesPerFrame] = ReadInPhotodiode(imageDescription, dataPath{ff});
    
    %% get epoch list
    [epochBegin, epochEnd, ~] = GetStimulusBounds(photoDiode, highResLinesPerFrame, dataRate);
    
    alDt = []; % Just for mask, can get this elsewhere
    zoomLevel = []; % again for mask, not necessary here
%     if ~exist('filterMovie', 'var')
        filterMovie = 1; % we don't filter the movies...
%     end
    if ~exist('backgroundSubtractMovie', 'var')
        backgroundSubtractMovie = 0; % we want this plotted on the raw movie...
    end
    if ~exist('useAlignedData', 'var')
        useAlignedData = 1;
    end
    
    
    % Get processed movie and correctly cut out beginning/end/surroundings
    processedMovie = LoadAndProcessMovieData(dataPath{ff}, alDt, zoomLevel, filterMovie, backgroundSubtractMovie, useAlignedData);
    
    mvSz = size(processedMovie);
    mvSz = mvSz(1:2);
    mskSz = size(roiMaskHere);
    rowCol = (mvSz-mskSz)/2;
    processedMovie = processedMovie(rowCol(1)+1:end-rowCol(1), rowCol(2)+1:end-rowCol(2), round(epochBegin):round(epochEnd));
    
    %% get epoch durations
    % these may fluctuate a bit so save the duration of each trial
    numEpochs = length(params{ff});
    epochStartTimes = cell(numEpochs,1);
    epochDurations = cell(numEpochs,1);
    
    epochList = epochs{ff}(:, 1);
    for ee = 1:length(epochStartTimes)
        chosenEpochs = [0; epochList==ee; 0];
        startTimes = find(diff(chosenEpochs)==1);
        endTimes = find(diff(chosenEpochs)==-1)-1;
        
        epochStartTimes{ee} = startTimes;
        epochDurations{ee} = endTimes-startTimes+1;
    end
    
    
    %% Grab indexes we care about
    if ~isempty(epochsForMovie)
        
        %         for i=1:length(epochsForMovie)
        selectedEpoch = ConvertEpochNameToIndex(params{ff},epochsForMovie{1});
        startMovieInd = min(cat(1, epochStartTimes{selectedEpoch}));
        selectedEpoch = ConvertEpochNameToIndex(params{ff},epochsForMovie{2});
        endMovieInd = min(cat(1, epochStartTimes{selectedEpoch})+ cat(1, epochDurations{selectedEpoch})-1);
        endMovieInd = endMovieInd + round(mean(cat(1, epochDurations{selectedEpoch}))/2);
        %         end
    else
        startMovieInd = 1;
        endMovieInd = size(backgroundSubtractedMovie, 3);
    end
    
%     startEndTimes = [startTimes; endTimes];
%     sortedStartEnd = sort(startEndTimes);
%     firstInterleave = find(epochList==interleaveEpoch, 1, 'first');
%     sortedStartEnd(sortedStartEnd>firstInterleave) = []; % We only want things in the probe stimulus
%     diffStartEnd = diff([-1; sortedStartEnd]); % Include -1 because we want the first diff to come up as >1
%     firstStartInds = find(diffStartEnd > 1, 2, 'first');
%     distToFirstEnd = find(diffStartEnd(firstStartInds(1):firstStartInds(2))==1, 1, 'last');
    
    movieBounds = [startMovieInd endMovieInd];
    
    numRois = length(unique(roiMaskHere)) - 1; %omit 0 which means no ROI
    roiPoints = cell(1, numRois);
    for i = 1:numRois
        roiPoints(i) = bwboundaries(roiMaskHere==i);
    end
   
    % [imgFramesInit, imgData] = twoPhotonImageParser(Z);
    % imgFramesInit = imgFrames;
    % imgFramesInit = imgFramesInit/(mean(imgFramesInit(:))+3*std(imgFramesInit(:)));
    % imgFramesInit(imgFramesInit==0) = min(imgFramesInit(imgFramesInit~=0));
    processedMovie = processedMovie(:, :, movieBounds(1):movieBounds(2));% log(imgFramesInit(:, :, movieBounds(1):movieBounds(2)));
    % gaussFilterSigma = [1,1];
    % gaussFilterSize = [5,5];
    % imgFramesInit = imgaussfilt(imgFramesInit, gaussFilterSigma, 'FilterSize', gaussFilterSize);
    % parfor i = 1:size(imgFramesInit, 3)
    %     imgFramesInit(:, :, i) = medfilt2(imgFramesInit(:, :, i));
    % end
    mxImage = max(processedMovie(:));
    processedMovie = processedMovie/mxImage;
    avgFiltered = flyResp{ff}(movieBounds(1):movieBounds(2), :);
    
    fnEnd = ['Bounds' num2str(movieBounds(1)) '-' num2str(movieBounds(2))];
    
    
    
    
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
    
    if isempty('saveMovieLocation')
        saveMovieLocation = dataPath{ff};
    end
    
    
    
    
    % processedMovie already got normalized above
    threshVal = 0.5;
    processedMovie(processedMovie>threshVal) = threshVal;
    processedMovie = processedMovie/threshVal;
    
    lowVal = 0.0*mxImage;
    processedMovie(processedMovie<lowVal) = 0;
    
    MakeFigure
    pngDir = fullfile(saveMovieLocation, ['pngFilesFly' num2str(ff)]);
    mkdir(pngDir);
    
    fs = imageDescription.acq.frameRate;
    tVals = linspace(0, size(processedMovie,3)/fs, size(processedMovie, 3));
    lineColors = lines(length(roiPoints));
    % avgFiltered = bsxfun(@minus, avgFiltered, mean(avgFiltered(find(tVals<1), :)));
    minResp = min(avgFiltered(:));
    maxResp = max(avgFiltered(:));
    
    
    lengthArr = 0.1*size(processedMovie, 2);
    
    previousEpochNum = [];
    epochBoundary = [];
        epochNamesList = {params{ff}.epochName};
    for ind = 1:size(processedMovie, 3);
        clf
        if ~mod(ind, 100)
            disp(['Making frame ' num2str(ind)])
        end
        epochNum = epochList(ind+movieBounds(1)-1);
        epochName = epochNamesList{epochNum};
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
        frameToPlot = processedMovie(:, :, ind);
        imgAx = imagesc(frameToPlot);axis off;axis tight;caxis([0, threshVal]);
        set(imgAx.Parent, 'YDir', 'normal');
        colormap gray
        hold on
        c = [1 size(processedMovie, 2)];
        r = [1 size(processedMovie, 1)];
        for i = 1:length(roiPoints)
            tempYPoints = roiPoints{i}(:, 1) - c(1)+1;
            
            tempXPoints = roiPoints{i}(:, 2) - r(1)+1;
            
            xPoints = tempXPoints(tempXPoints>0 & tempYPoints>0);
            yPoints = tempYPoints(tempXPoints>0 & tempYPoints>0);
            xPoints(end+1) = xPoints(1);
            yPoints(end+1) = yPoints(1);
            h = plot(xPoints, yPoints, 'Color', lineColors(i, :));
            h.LineWidth = 10;
        end
        ptch = patch(Xarr+c(end)-.75*lengthArr-c(1), Yarr+.75*lengthArr, 'red');
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
    
end

analysis=[];

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

function epochNum = epochFromIndex(Z, ind)

fields = fieldnames(Z.params.trigger_inds);
epochNum = 1;
for epoch  = fields'
    bounds = Z.params.trigger_inds.(epoch{1}).bounds;
    if any(bounds(2, :)>=ind & ind>bounds(1, :))
        break;
    end
    epochNum = epochNum+1;
end
