function roi = roiAnalysis_OneRoi_AlignThirdKernel(roi)
barCenter = roiAnalysis_FindFirstKernelCenter(roi,'methodFilterCenter','prob');
flyEye = roi.flyInfo.flyEye;
nMultiBars = size(roi.filterInfo.secondKernel.dx1.Original,2);

barNum = 1:nMultiBars;
barNumCentered = roiAnalysis_AverageFirstKernel_AlignOneFilter(barNum,barCenter);

OriginalKernel = roi.filterInfo.thirdKernel.Original;
nCorrType = length(OriginalKernel);
if strcmp(flyEye,'right') || strcmp(flyEye,'Right')
    AlignedKernel = cell(4,1);
    barNumCenteredFlip = fliplr(barNumCentered);
    AlignedKernel{1} = OriginalKernel{2}(:,barNumCenteredFlip);
    AlignedKernel{2} = OriginalKernel{1}(:,barNumCenteredFlip);
    AlignedKernel{3} = OriginalKernel{4}(:,barNumCenteredFlip);
    AlignedKernel{4} = OriginalKernel{3}(:,barNumCenteredFlip);
    
else
    AlignedKernel = cell(4,1);
    for cc = 1:1:nCorrType
        kernelThis = OriginalKernel{cc};
        AlignedKernel{cc} = kernelThis(:,barNumCentered);
    end
end
roi.filterInfo.thirdKernel.Aligned = AlignedKernel;