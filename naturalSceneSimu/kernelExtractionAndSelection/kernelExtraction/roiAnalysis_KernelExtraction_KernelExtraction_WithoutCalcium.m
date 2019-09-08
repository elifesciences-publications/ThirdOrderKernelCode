function roiData = roiAnalysis_KernelExtraction_KernelExtraction_WithoutCalcium(roiData)
nRoi = length(roiData);
for rr = 1:1:nRoi
    roi = roiData{rr};
    barUse = find(roi.filterInfo.secondBarSelected);
    roi = roiAnalysis_OneRoi_KernelExtraction_WithoutCalcium(roi,'barUse',barUse,'order',1);
    tic
    roi = roiAnalysis_OneRoi_KernelExtraction_WithoutCalcium(roi,'barUse',barUse,'order',2);
    toc
    roiData{rr} = roi;
%     PlotOneRoi_FS(roi,'barUse',barUse);
end
end