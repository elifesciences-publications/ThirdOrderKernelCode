function roiSelected = RoiSelectionBySize(roiMasks,minPixelNum)
nRoi = size(roiMasks,3);
sizeMasks = zeros(nRoi,1);
for rr = 1:1:nRoi
    sizeMasks(rr) = sum(sum(roiMasks(:,:,rr)));
end
roiSelected = sizeMasks > minPixelNum;
end