function roiData = roiAnalysis_SecondKernelSelection_SelectAll(roiData)
nRoi = length(roiData);
for rr = 1:1:nRoi
    roi = roiData{rr};
    
    % you would keep all kernels in.
    kernelType = roi.filterInfo.kernelType;
    if kernelType == 1 || kernelType == 3
        
        roi.filterInfo.kernelType = 3;
    else
        roi.filterInfo.kernelType = 2;
    end
    
    roi.filterInfo.secondKernel.dx1.barSelected = true(20,1);
    roi.filterInfo.secondKernel.dx2.barSelected = true(20,1);
    
    roiData{rr} = roi;
end
end