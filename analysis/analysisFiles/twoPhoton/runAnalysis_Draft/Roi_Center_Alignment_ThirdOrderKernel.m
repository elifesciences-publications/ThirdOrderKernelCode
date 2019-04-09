function AlignedKernel = Roi_Center_Alignment_ThirdOrderKernel(roi,thirdKernel, thirdKernel_mirror)

barCenter = roiAnalysis_FindFirstKernelCenter(roi,'methodFilterCenter','prob');
flyEye = roi.flyInfo.flyEye;
nMultiBars = size(thirdKernel,2);
barNum = 1:nMultiBars;
barNumCentered = roiAnalysis_AverageFirstKernel_AlignOneFilter(barNum,barCenter); 
% should work.
if strcmp(flyEye,'right') || strcmp(flyEye,'Right')
    barNumCenteredFlip = fliplr(barNumCentered);
    AlignedKernel= thirdKernel_mirror(:,barNumCenteredFlip); % is this true???
else
    AlignedKernel = thirdKernel(:,barNumCentered);
end
end