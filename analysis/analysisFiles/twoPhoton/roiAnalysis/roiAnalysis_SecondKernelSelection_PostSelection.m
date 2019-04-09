function roiData = roiAnalysis_SecondKernelSelection_PostSelection(roiData)

% go through dx = 1 and dx = 2.
nRoi = length(roiData);
for rr = 1:1:nRoi
    roi = roiData{rr};
    kernelType = roi.filterInfo.kernelType;
    
    % dx = 1;
    maxConnectedArea = roi.filterInfo.secondKernel.dx1.maxConnectedArea;
    maxNoiseConnectedArea = roi.filterInfo.secondKernel.dx1.maxNoiseConnectedArea;
    barSelected = maxConnectedArea > max(maxNoiseConnectedArea);
    kernelTypeDx1 = sum(barSelected) > 0;
    roi.filterInfo.secondKernel.dx1.barSelected = barSelected;
 
    % dx = 2;
    maxConnectedArea = roi.filterInfo.secondKernel.dx2.maxConnectedArea;
    maxNoiseConnectedArea = roi.filterInfo.secondKernel.dx2.maxNoiseConnectedArea;
    barSelected = maxConnectedArea > max(maxNoiseConnectedArea);
    kernelTypeDx2 = sum(barSelected) > 0;
    roi.filterInfo.secondKernel.dx2.barSelected = barSelected;
    
    firstKernelFlag = kernelType == 1 | kernelType == 3;
    if kernelTypeDx2 || kernelTypeDx1
        secondKernelFlag = true;
    else
        secondKernelFlag = false;
    end
    
    if firstKernelFlag && ~secondKernelFlag
        kernelType = 1;
    elseif ~firstKernelFlag && secondKernelFlag
        kernelType = 2;
    elseif firstKernelFlag && secondKernelFlag
        kernelType = 3;
    else
        kernelType = 0;
    end
    
    roi.filterInfo.kernelType = kernelType;
    
    
    roiData{rr} = roi;
end

end
