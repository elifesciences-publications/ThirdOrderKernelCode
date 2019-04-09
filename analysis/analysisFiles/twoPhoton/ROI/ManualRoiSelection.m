function [roiTracesOut,roiMasks,extraVars] = ManualRoiSelection(backgroundSubtractedMovie,deltaFOverF, epochStartTimes,epochDurations,~,varargin)
% Manual ROI selection for non-linescan images. 

movieSize = size(backgroundSubtractedMovie);
roiImage = mean(backgroundSubtractedMovie, 3);

imagesc(roiImage);
axis off;axis equal;axis tight;
colormap(b2r(min(roiImage(:)), max(roiImage(:))));
%     imshow(roiImage/max(roiImage(:)), 'InitialMagnification', 'fit');

numRoisCell = inputdlg('How many ROIs are there?', 'ROI Count', 1, {'0'}, struct('WindowStyle', 'normal'));
numRoisStr = numRoisCell{1};
numRois = str2num(numRoisStr);

%linear ROI
title(['Create a polygon surrounding your ROI for the ' numRoisStr ' ROI(s). Double click twice to finish each one.']);

%We're gonna store these rois in a cell
%     roi_data = cell(0);
roiTracesOut = zeros(movieSize(3),numRois);
frameStartIndexes = 0:movieSize(1)*movieSize(2):movieSize(1)*movieSize(2)*(movieSize(3)-1);
for i = 1:numRois
    [roiMask,~,~] = roipoly;
    
    roiIndexOnMask = find(roiMask);
    roiIndexInMovie = bsxfun(@plus, roiIndexOnMask, repmat(frameStartIndexes, length(roiIndexOnMask), 1));
    selectedPixels=  deltaFOverF(roiIndexInMovie);
    selectedPixels = reshape(selectedPixels,[length(roiIndexOnMask) movieSize(3)]);
    roiTracesOut(:,i) = mean(selectedPixels,1);
    
    roiMasks(roiMask) = i;
end

extraVars = [];
    
end

