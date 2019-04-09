function [value,barUse] = roiAnalysis_OneRoi_GetQuantificationResult(roi,dx,whichQuant)

switch whichQuant
    case 'max'
        quant = roi.SKquant.mag.max;
    case 'mean'
        quant = roi.SKquant.mag.mean;
    case 'time'
        quant = roi.SKquant.time.max;
end

switch dx
    case 1
        kernelInfo = roi.filterInfo.secondKernel.dx1;
        value = quant.dx1;
    case 2
        kernelInfo = roi.filterInfo.secondKernel.dx2;
        value = quant.dx2;
end
barUse = find(kernelInfo.barSelected);