function [ROICOM, roiMasks] = getROICOM(roiMasksInitial)

nRoi = max(roiMasksInitial(:));

roiMasks = zeros([size(roiMasksInitial), nRoi]);
for rr = 1:1:nRoi
    roiMasks(:, :, rr) = roiMasksInitial == rr;
end

roiCenterOfMass = zeros(size(roiMasks, 3), 2);
nRoi = size(roiMasks, 3);
for rr = 1:1:nRoi
    [indRows, indCols] = find(roiMasks(:, :, rr));
    roiCenterOfMass(rr, :) = [mean(indRows) mean(indCols)];
end

ROICOM = roiCenterOfMass;


end

