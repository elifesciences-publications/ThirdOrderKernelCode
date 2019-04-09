function roi = roiAnalysis_OneRoi_KernelSelection_MD_Utils_DistRank(roi)
    kernelD = roi.filterInfo.firstKernel.ZTest.kernelD_Bar;
    nMultiBars = length(kernelD);
    kernelD_Sum = sum(kernelD);
    kernelShuffleD_Bar = roi.filterInfo.firstKernel.ZTest.kernelShuffleD_Bar;
    nShuffle = length(kernelShuffleD_Bar);
    % you need a seed and you need to sum them together..
    rng(0);
    nShuffleSum = 10000;
    kernelShuffleD_Sum = zeros(nShuffleSum,1);
    for ii = 1:1:nShuffleSum
        kernelShuffleD_Sum(ii) = sum(kernelShuffleD_Bar(randi([1 nShuffle],[1,nMultiBars])));
    end
    nlessOrEqual = sum(kernelShuffleD_Sum <  kernelD_Sum | kernelShuffleD_Sum == kernelD_Sum);
    roi.filterInfo.firstKernel.ZTest.nlessAndEqual =  nlessOrEqual;
end