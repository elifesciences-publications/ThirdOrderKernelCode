function roi = roiAnalysis_OneRoi_CalculateCovMat(roi)

roi.filterInfo.covMat_full = STC_Utils_SecondKernelToCovMat(roi.filterInfo.secondKernel.dx_full.Aligned);
end