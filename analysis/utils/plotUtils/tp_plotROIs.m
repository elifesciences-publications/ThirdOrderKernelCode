function tp_plotROIs( Z, colorROIs )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
loadFlexibleInputs(Z)

if nargin>1
    roiColor = colorROIs;
else
    roiColor = [];
end

roiImage = mean(Z.rawTraces.movieMean, 3);
roiData = Z.ROI;

MakeFigure
colormap(gray(256))
imagesc(roiImage);
axis off
hold on
colors = [0 0 1];


masks = roiData.roiMasks;
if isfield(Z.ROI, 'roiIndsOfInterest')
    if islogical(Z.ROI.roiIndsOfInterest);
        indsToHighlight = find(Z.ROI.roiIndsOfInterest);
    else
        indsToHighlight = Z.ROI.roiIndsOfInterest;
    end
    masks = roiData.roiMasks(:, :, indsToHighlight);
    if ~isempty(roiColor)
        colors = roiColor;
        roiData.roiMasks = roiData.roiMasks(:, :, indsToHighlight);
    end
else
    indsToHighlight = [];
end

% masksCell = mat2cell(masks, size(masks, 1), size(masks, 2), ones(size(masks, 3), 1));
% masksCell = cellfun(@(layer) bwmorph(layer,'close'), masksCell, 'UniformOutput', false);
% boundedMasksCell = cellfun(@(layer) bwboundaries(layer), masksCell);
% boundarySize = max(cellfun(@(boundary) size(boundary, 1), boundedMasksCell));
% boundaries = cellfun(@(boundary) boundary([1:end repmat(end, [1, boundarySize-end])], :), boundedMasksCell, 'UniformOutput', false);
% boundariesMatrix = cell2mat(boundaries);
% boundariesMatrix = reshape(boundariesMatrix, [size(boundariesMatrix, 1), size(boundariesMatrix, 2)*size(boundariesMatrix, 3)]);
% 
% boundaryXVals = boundariesMatrix(:, 1:2:end);
% boundaryYVals = boundariesMatrix(:, 2:2:end);
% 
% 
% plot(boundaryYVals, boundaryXVals, 'Color', colors);

roiDisplayImage = zeros([size(roiImage), 3]);
alph = zeros(size(roiImage));
colors = jet(size(roiData.roiMasks, 3));
for i = 1:size(roiData.roiMasks, 3)
    roiMask = logical(roiData.roiMasks(:, :, i));
    otherLayerMask = logical(zeros(size(roiMask)));
    alph = alph | roiMask;
    roiDisplayImage(cat(3, roiMask, otherLayerMask, otherLayerMask)) = colors(i, 1);
    roiDisplayImage(cat(3, otherLayerMask, roiMask, otherLayerMask)) = colors(i, 2);
    roiDisplayImage(cat(3, otherLayerMask, otherLayerMask, roiMask)) = colors(i, 3);
    %     x = roi_data.points{i}(:, 1);
    %     y = roi_data.points{i}(:, 2);
    %It's colors(i+2) because of how the plotting works later on;
    %this allows the roi colors to match the signal trace colors
    %     plot(x, y, 'Color', colors(i,:));
end
h = imagesc(roiDisplayImage);
set(h, 'AlphaData', .5*alph);

if isempty(roiColor)
    for i = 1:size(roiData.roiMasks, 3)
        if any(indsToHighlight == i)
            color = [1 1 1];
        else
            color = [0 0  0];
        end
        text(roiData.roiCenterOfMass(i, 2), roiData.roiCenterOfMass(i, 1), num2str(i), 'HorizontalAlignment', 'center', 'Color',  color);
    end
end


end



