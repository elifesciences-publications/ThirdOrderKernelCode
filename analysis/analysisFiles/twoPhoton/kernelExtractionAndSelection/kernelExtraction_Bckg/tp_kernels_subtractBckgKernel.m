function  kernelsRoiWithoutBckg = tp_kernels_subtractBckgKernel(kernels,roi_exp_fit)
% there are two ways to subtract of background kernels. 
% In this function, the background kernel is subtracted from the kernel
% calculated with filtered traces, the autoflourescence is being tooken
% care of already.
    kernelBckg = kernels(:,:,end);
    kernelsRoi = kernels;
    
    mean_roi_exp_fit = mean(roi_exp_fit,1);
    kernelBackNorm = bsxfun(@rdivide,permute(repmat(kernelBckg,[1,1,size(kernelsRoi,3)]),[3,1,2]),mean_roi_exp_fit');
    kernelsRoiWithoutBckg = kernelsRoi - permute(kernelBackNorm,[2,3,1]);
    
    MakeFigure;
    subplot(2,2,1);
    quickViewOneKernel(kernelBckg,1);
    title('kernel extracted from background');
    subplot(2,2,2);
    quickViewOneKernel(mean(kernelsRoi,3),1);
    title('mean kernels from rois without background subtracted')
    subplot(2,2,3)
    quickViewOneKernel(mean(kernelsRoiWithoutBckg,3),1);
    title('mean kernels from rois after background kernel subtracted')

end
