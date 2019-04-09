function roi = roiAnalysis_OneRoi_AlignSecondKernel_full(roi)
barCenter = roiAnalysis_FindFirstKernelCenter(roi,'methodFilterCenter','prob');
flyEye = roi.flyInfo.flyEye;
nMultiBars = length( roi.filterInfo.secondKernel.dx_full);

barNum = 1:nMultiBars;
barNumCentered = roiAnalysis_AverageFirstKernel_AlignOneFilter(barNum,barCenter);
dxBank = 0:19;
dx_full.Original = cell(nMultiBars,1);
dx_full.Aligned = cell(nMultiBars,1);
for xx = 1:1:nMultiBars
    dx = dxBank(xx);
    if strcmp(flyEye,'right') || strcmp(flyEye,'Right')
        barNumLeftSelf = [barNumCentered(nMultiBars - (dx - 1):nMultiBars ),barNumCentered(1:nMultiBars - dx)];
        % second, flip the sequence...
        barNumFlip = fliplrKernel(barNumLeftSelf ,1);
        % third, flip the left bar and right bar....
        
        dx_full.Original{xx} = roi.filterInfo.secondKernel.dx_full{xx};
        
        secondKernelAligned = dx_full.Original{xx}(:,barNumFlip);
        secondKernelAlignedFlipped = fliplrKernel(secondKernelAligned,2);
        dx_full.Aligned{xx} = secondKernelAlignedFlipped;
        
    else
        dx_full.Original{xx} = roi.filterInfo.secondKernel.dx_full{xx};
        dx_full.Aligned{xx} = dx_full.Original{xx}(:,barNumCentered);
    end

end
roi.filterInfo.secondKernel.dx_full = dx_full.Aligned;
% the original dx_full is deleted, and is replace by new aligned... 
end