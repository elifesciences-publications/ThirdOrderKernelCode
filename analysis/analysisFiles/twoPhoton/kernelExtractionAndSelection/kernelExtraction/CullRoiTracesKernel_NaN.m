function Z = CullRoiTracesKernel_NaN(Z)
% First attempt to get rid of data points where there is too much motion

ySize = Z.params.imgSize(2);
xSize = Z.params.imgSize(1);
dSize = sqrt(ySize^2 + xSize^2);

alignmentData = Z.grab.alignmentData;

fullShift = sqrt(alignmentData(:, 1).^2 + alignmentData(:, 2).^2);

overMovedFrames = alignmentData(:, 1)>xSize*.1 | alignmentData(:, 1)>ySize*.1 | fullShift > dSize*.1;

% response is zeros...
Z.filtered.roi_avg_intensity_filtered_normalized(overMovedFrames, :) = NaN;
Z.filtered.removeOverMovedFrameFlag = true;
Z.filtered.removeOverMovedFrames = overMovedFrames; 

