function diffKernelAve = Simulation_KernelErrorEstimation_Utils_CalError(kernelSimu,kernelStd)
% nRoi = size(kernelStim,3);
sizeKernel = numel(kernelStd);
diffKernel = bsxfun(@minus,kernelSimu,kernelStd);
diffKernel = diffKernel.^2;
diffKernelSum = sum(diffKernel,1); 
diffKernelSum = sum(diffKernelSum,2);
diffKernelAve = squeeze(diffKernelSum/sizeKernel);
end