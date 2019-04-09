function roiIndsOfInterest = ExtractRoisBySize(Z)
% Implement size, brightness

loadFlexibleInputs(Z);

roiSize = sum(sum(Z.ROI.roiMasks));
roiSize = roiSize(:);

roiIndsOfInterest = roiSize(1:end-1)>minRoiSize;