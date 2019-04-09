function Z = RoiSelectionPreliminary(Z,flyEye)
[cfRoi,~] = RoiClassification(Z,flyEye);

roiSelectedBySize = RoiSelectionBySize(Z.ROI.roiMasks(:,:,1:end - 1),5);
roiSelectedByDir = RoiSelectionByProbingStimulus(cfRoi,'method','preliminary_LeftRight_Only');
roiSelectedByCorr = RoiSelectionByProbingStimulus(cfRoi,'method','preliminary_repeatability');

roiSelected = roiSelectedByCorr & roiSelectedByDir &  roiSelectedBySize;
roiUse = find(roiSelected);
roiNotUse = find(~roiSelected);

Z.ROI.roiCenterOfMass(roiNotUse,:) = [];
Z.ROI.roiMasks(:,:,roiNotUse) = [];
Z.filtered.roi_avg_intensity_filtered_normalized= Z.filtered.roi_avg_intensity_filtered_normalized(:,roiUse);
Z.rawTraces.roi_intensities = Z.rawTraces.roi_intensities(:,roiUse);
end
