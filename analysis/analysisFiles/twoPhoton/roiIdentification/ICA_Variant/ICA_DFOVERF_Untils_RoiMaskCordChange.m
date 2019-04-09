function roiMaskPad = ICA_DFOVERF_Untils_RoiMaskCordChange(windMask,roiMask,imageSize)
% roiMask
% windMask
% imageSize

% just calculate how many zeros had to be pad.

windStart = find(windMask(:),1,'first');
windEnd = find(windMask(:),1, 'last');


[verStart,horStart] = ind2sub(imageSize,windStart);
[verEnd,horEnd] = ind2sub(imageSize,windEnd);

% pad vertical first...
roiMaskPad = zeros(imageSize);
roiMaskPad(verStart:verEnd,horStart:horEnd) = roiMask;
% MakeFigure;
% imagesc(roiMaskPad)
end