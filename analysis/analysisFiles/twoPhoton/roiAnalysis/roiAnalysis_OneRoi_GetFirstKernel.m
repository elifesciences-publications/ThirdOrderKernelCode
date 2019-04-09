function firstKernel = roiAnalysis_OneRoi_GetFirstKernel(roi,whichKernel,normFlag)


% quality = kernelInfo.quality(barUse);
% give out all the second order kernels, the function who calls this
% function would deal with the selection....
switch whichKernel
    case 'Adjusted'
        firstKernel = roi.filterInfo.firstKernel.Adjusted;
end
if normFlag
    A = sqrt(sum(firstKernel(:).^2));
    firstKernel = firstKernel/A;
end
