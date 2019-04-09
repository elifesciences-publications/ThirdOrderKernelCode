function optimalKernel = Simulation_KernelErrorEstimation_Utils_GetOptimalCV(kernel,kernelStd)
    optimalPosition = kernelStd ~= 0; 
    optimalKernel = zeros(size(kernelStd));
    
    optimalKernel(optimalPosition) = kernel(optimalPosition);
end