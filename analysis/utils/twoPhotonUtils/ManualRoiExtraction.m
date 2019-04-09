function [roiTracesOut,roiMasks,extraVars] = ManualRoiExtraction(backgroundSubtractedMovie,deltaFOverF,epochStartTimes,epochDurations,params,varargin)
% Manual ROI selection for non-linescan images. 

extraVars = [];
movieInds = [];
epochsForIdentification = varargin([false strcmp(varargin, 'epochsForIdentificationForFly')]);
if ~isempty(epochsForIdentification)
    epochsForIdentification = epochsForIdentification{1};
    extraVals.epochsForIdentificationForFly = epochsForIdentification;
    
    firstStartTime = size(backgroundSubtractedMovie, 3);
    lastEndTime = 1;
    for i=1:length(epochsForIdentification)
        selectedEpoch = ConvertEpochNameToIndex(params,epochsForIdentification{i});
        for selEpInds = 1:length(selectedEpoch)
            movieInds = [movieInds epochStartTimes{selectedEpoch(selEpInds)}:epochStartTimes{selectedEpoch(selEpInds)}+epochDurations{selectedEpoch(selEpInds)}-1];
        end
    end
else
    firstStartTime = 1;
    lastEndTime = size(backgroundSubtractedMovie, 3);
    movieInds = firstStartTime:lastEndTime;
end

movieSize = size(backgroundSubtractedMovie);
roiImage = mean(backgroundSubtractedMovie(:, :, movieInds), 3);

roiSelFig = MakeFigure;
imagesc(roiImage);
axis off;axis equal;axis tight;
% colormap(b2r(min(roiImage(:)), max(roiImage(:))));
    imshow(roiImage/max(roiImage(:)), 'InitialMagnification', 'fit');
    colormap gray

numRoisCell = inputdlg('How many ROIs are there?', 'ROI Count', 1, {'0'}, struct('WindowStyle', 'normal'));
numRoisStr = numRoisCell{1};
numRois = str2num(numRoisStr);

%linear ROI
title(['Create a polygon surrounding your ROI for the ' numRoisStr ' ROI(s). Double click twice to finish each one.']);

%We're gonna store these rois in a cell
%     roi_data = cell(0);
roiTracesOut = zeros(movieSize(3),numRois);
frameStartIndexes = 0:movieSize(1)*movieSize(2):movieSize(1)*movieSize(2)*(movieSize(3)-1);
roiMasks = zeros(size(backgroundSubtractedMovie, 1), size(backgroundSubtractedMovie, 2));
for i = 1:numRois
    [roiMask,~,~] = roipoly;
    
    roiIndexOnMask = find(roiMask);
    roiIndexInMovie = bsxfun(@plus, roiIndexOnMask, repmat(frameStartIndexes, length(roiIndexOnMask), 1));
    selectedPixels=  deltaFOverF(roiIndexInMovie);
    selectedPixels = reshape(selectedPixels,[length(roiIndexOnMask) movieSize(3)]);
    roiTracesOut(:,i) = mean(selectedPixels,1);
    
    roiMasks(roiMask) = i;
end

close(roiSelFig);
    
end

