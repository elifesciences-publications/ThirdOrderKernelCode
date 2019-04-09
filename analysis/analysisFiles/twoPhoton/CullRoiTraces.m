function Z = CullRoiTraces(Z)
% First attempt to get rid of data points where there is too much motion

ySize = Z.params.imgSize(2);
xSize = Z.params.imgSize(1);
dSize = sqrt(ySize^2 + xSize^2);


alignmentData = Z.grab.alignmentData;

if Z.params.linescan == 0
fullShift = sqrt(alignmentData(:, 1).^2 + alignmentData(:, 2).^2);

% diffShift = [0 0; diff(alignmentData(:, 1:2))];
% diffFullShift = sqrt(diffShift(:, 1).^2 + diffShift(:, 2).^2);

% We're tracking the diffShift here for if the image ends up at a resting
% state...
overMovedFrames = (alignmentData(:, 1)>xSize*.1 | alignmentData(:, 1)>ySize*.1 | fullShift > dSize*.1);% & (diffShift(:, 1)>xSize*.1 | diffShift(:, 1)>ySize*.1 | diffFullShift > dSize*.1);

% response is zeros...
Z.filtered.roi_avg_intensity_filtered_normalized(overMovedFrames, :) = NaN;
end

