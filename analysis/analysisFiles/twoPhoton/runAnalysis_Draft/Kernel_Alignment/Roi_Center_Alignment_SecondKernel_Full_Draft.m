function second_kernel_full_aligned_flipped = Roi_Center_Alignment_SecondKernel_Full_Draft(roi,second_kernel_full)
barCenter = roiAnalysis_FindFirstKernelCenter(roi,'methodFilterCenter','prob');
% calculating bar center is time consuming
flyEye = roi.flyInfo.flyEye;
nMultiBars = length(second_kernel_full);

barNum = 1:nMultiBars;
barNumCentered = roiAnalysis_AverageFirstKernel_AlignOneFilter(barNum,barCenter);
dxBank = 0:19;

second_kernel_full_aligned = cell(nMultiBars,1);
second_kernel_full_aligned_flipped = cell(nMultiBars,1);
for xx = 1:1:nMultiBars
    dx = dxBank(xx);
    if strcmp(flyEye,'right') || strcmp(flyEye,'Right')
        barNumLeftSelf = [barNumCentered(nMultiBars - (dx - 1):nMultiBars ),barNumCentered(1:nMultiBars - dx)];
        % second, flip the sequence...
        barNumFlip = fliplrKernel(barNumLeftSelf ,1);
        % third, flip the left bar and right bar....
        second_kernel_full_aligned{xx} = second_kernel_full{xx}(:,barNumFlip);
        second_kernel_full_aligned_flipped{xx} = fliplrKernel(second_kernel_full_aligned{xx},2);
    else
        second_kernel_full_aligned{xx} = second_kernel_full{xx}(:,barNumCentered);
        second_kernel_full_aligned_flipped{xx} = second_kernel_full_aligned{xx};
    end

end
end