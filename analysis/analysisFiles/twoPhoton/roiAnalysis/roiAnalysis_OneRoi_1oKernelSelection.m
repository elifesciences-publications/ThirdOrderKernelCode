function roi = roiAnalysis_OneRoi_KernelSelection_MD_Utils_DistRank(roi)
    kernelD = roi.filterInfo.firstKernel.ZTest.kernelD_Bar;
    shuffleD = roi.filterInfo.firstKernel.ZTest.kernelShuffleD_Bar;
    nless = sum(shuffleD <  kernelD);
    nequal = sum(shuttleD == kernelD);
    roi.filterInfo.firstKernel.ZTest.nlessAndEqual = nless + nequal;
end