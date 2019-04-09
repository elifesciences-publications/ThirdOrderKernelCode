function first_kernel_aligned = Roi_Center_Alignment_FirstOrderKernel(roi,firstKernel)
flyEye = roi.flyInfo.flyEye;
barCenter = roiAnalysis_FindFirstKernelCenter(roi,'methodFilterCenter','prob');

firstFilterCentered = roiAnalysis_AverageFirstKernel_AlignOneFilter(firstKernel, barCenter);
if strcmp(flyEye,'right') || strcmp(flyEye,'Right')
    first_kernel_aligned = fliplrKernel(firstFilterCentered,1);
else
    first_kernel_aligned = firstFilterCentered;
end
end