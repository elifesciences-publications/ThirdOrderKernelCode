function tp_niceMovie(Z, imgFramesInit, movieBounds, inTime)
%Function asks the user for a tif input file (one taken from a loop grab of
%scanimage) and outputs an AVI file that puts together all the images
%grabbed in the loop like a movie.

%Varargin defaults!
movieFps = []; %becomes capture frame rate if nothing else is assigned to it
fnEnd = '';
if nargin<3 || isempty(movieBounds)
    movieBounds = [1, size(Z.filtered.roi_avg_intensity_filtered_normalized, 1)];
elseif nargin==4 && inTime
    movieBounds = ceil(movieBounds.*Z.params.fps+0.001);
end

masks = Z.ROI.roiMasks;
if isfield(Z.ROI, 'roiIndsOfInterest')
    indsToPlot = Z.ROI.roiIndsOfInterest;%subtract one to get rid of average ind
    if ~any(indsToPlot)
        warning('No roiIndsOfInterest were extracted! Plotting all masks');
    else
        masks = masks(:, :, indsToPlot);
    end
end

for i = 1:size(masks, 3)-1 %omit background
    roiPoints{i} = mask2poly(Z.ROI.roiMasks(:,:, i), 'Inner', 'CW');
end

% Receive input variables
loadFlexibleInputs(Z);

% [imgFramesInit, imgData] = twoPhotonImageParser(Z);
% imgFramesInit = imgFrames;
% imgFramesInit = imgFramesInit/(mean(imgFramesInit(:))+3*std(imgFramesInit(:)));
% imgFramesInit(imgFramesInit==0) = min(imgFramesInit(imgFramesInit~=0));
imgFramesInit = imgFramesInit(:, :, movieBounds(1):movieBounds(2));% log(imgFramesInit(:, :, movieBounds(1):movieBounds(2)));
% gaussFilterSigma = [1,1];
% gaussFilterSize = [5,5];
% imgFramesInit = imgaussfilt(imgFramesInit, gaussFilterSigma, 'FilterSize', gaussFilterSize);
% parfor i = 1:size(imgFramesInit, 3)
%     imgFramesInit(:, :, i) = medfilt2(imgFramesInit(:, :, i));
% end
mxImage = max(imgFramesInit(:));
imgFramesInit = imgFramesInit/mxImage;
avgFiltered = Z.filtered.roi_avg_intensity_filtered_normalized(movieBounds(1):movieBounds(2), :);

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

outFilename = fullfile(Z.params.pathName, [Z.params.name, fnEnd, '.avi']); %default output filename

% masksCell = mat2cell(masks, size(masks, 1), size(masks, 2), ones(size(masks, 3), 1));
% boundedMasksCell = cellfun(@(layer) bwperim(layer), masksCell, 'UniformOutput', false);
% boundariesMatrix = cell2mat(boundedMasksCell);
% boundariesMatrix = any(boundariesMatrix, 3);




%Gotta reconvert imgFrames to a 4D with each 4th dimension being a 3D
%frame
windowMask = logical(windowMovie(imgFramesInit(:, :, 1), Z.params.linescan, Z.grab.alignmentData(movieBounds(1):movieBounds(2), :)));
[r, c] = find(windowMask);
% imgFrames = zeros(r(end)-r(1)+1, c(end)-c(1)+1, 3, size(imgFramesInit, 3));
mxImg = max(imgFramesInit(:));
threshVal = 0.5*mxImg;
imgFramesInit(imgFramesInit>threshVal) = threshVal;

lowVal = 0.0*mxImg;
imgFramesInit(imgFramesInit<lowVal) = 0;

imgFramesInit = imgFramesInit/max(imgFramesInit(:));
MakeFigure
pngDir = fullfile(pathName, 'pngFigure');
mkdir(pngDir);
tVals = linspace(0, size(imgFramesInit,3)/fs, size(imgFramesInit, 3));
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
    epochNum = epochFromIndex(Z,ind+movieBounds(1));
    
    epochName = Z.stimulus.params(epochNum).epochName;
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
    imgFramesHere = imgFramesInit(:, :, ind);
    frameToPlot = reshape(imgFramesHere(windowMask), [r(end)-r(1)+1, c(end)-c(1)+1]);
    imgAx = imagesc(frameToPlot);axis off;axis tight;caxis([0, threshVal]);
    colormap gray
    hold on
    for i = 1:length(roiPoints)
        tempXPoints = roiPoints{i}(:, 1) - c(1)+1;
        
        tempYPoints = roiPoints{i}(:, 2) - r(1)+1;
        
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

