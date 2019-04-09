function  tp_PickUpKernels( linPath, noiseLinPath, quadPath,noiseQuadPath)

     %% Load the things you will need
    
    % first order.
    load(linPath);
    linearFilters = saveKernels.kernels;
    ROIuse = saveKernels.ROIuse;
    maxTau(1) = saveKernels.maxTau;
    
    load(noiseLinPath);
    linearNoiseFilters = saveKernels.noiseKernels;
    
    % second order.
    load(quadPath);
    quadFilters = saveKernels.kernels;
    assert(all(ROIuse == saveKernels.ROIuse));
    maxTau(2) = saveKernels.maxTau;
    
    
    load(noiseQuadPath);
    quadNoiseFilters = saveKernels.noiseKernels;
    
    
    
    alpha = 1e-4;
    minPixel = 10;
    [roiBarPicekdFirst] = BS_Kernel_Selection(linearFilters,linearNoiseFilters,1,alpha,minPixel,1);
    
    alpha = 5 * 1e-4;
    minPixel = 30;
    [roiBarPicekdQuad] = BS_Kernel_Selection(quadFilters,quadNoiseFilters,2,alpha,minPixel,1);
    
    
    
end