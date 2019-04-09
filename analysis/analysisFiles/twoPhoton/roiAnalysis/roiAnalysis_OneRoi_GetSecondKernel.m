function [secondKernel,barUse] = roiAnalysis_OneRoi_GetSecondKernel(roi,dx,whichKernel,normKernelFlag,normRoiFlag)

switch dx
    case 1
        kernelInfo = roi.filterInfo.secondKernel.dx1;
    case 2
        kernelInfo = roi.filterInfo.secondKernel.dx2;
end

if isfield(kernelInfo,'barSelected')
    barSelected = kernelInfo.barSelected;
else
    barSelected = true(size(kernelInfo.Original,2),1);
end
barUse = find(barSelected);
% quality = kernelInfo.quality(barUse);
% give out all the second order kernels, the function who calls this
% function would deal with the selection....
switch whichKernel
    case 'ZAdjusted'
        secondKernel = kernelInfo.ZAdjusted;
    case 'smoothZAdjusted'
        secondKernel = kernelInfo.smoothZAdjusted;
    case 'Original'
        secondKernel = kernelInfo.Original;
    case 'Adjusted'
        secondKernel = kernelInfo.Adjusted;
    case 'Aligned' % it is used for individual second order bars.
        secondKernel = kernelInfo.Aligned;
        barUse = (1:size(secondKernel,2))';
end
[maxTauSquared,~] = size(secondKernel);
if normKernelFlag
    A = sqrt(sum(secondKernel.^2,1));
    secondKernel = secondKernel./repmat(A,[maxTauSquared,1]);
end
if normRoiFlag
    meanKernel = mean(secondKernel,2);
    A = sqrt(sum(meanKernel.^2,1));
    meanKernelNorm = meanKernel/A;
    secondKernel = repmat(meanKernelNorm,[1,length(barSelected)]);
end