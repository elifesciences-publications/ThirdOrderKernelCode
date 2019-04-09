function roi = roiAnalysis_OneRoi_AlignSecondKernel(roi)
barCenter = roiAnalysis_FindFirstKernelCenter(roi,'methodFilterCenter','prob');
nDx = 2;
flyEye = roi.flyInfo.flyEye;
nMultiBars = size(roi.filterInfo.secondKernel.dx1.Original,2);

barNum = 1:nMultiBars;
barNumCentered = roiAnalysis_AverageFirstKernel_AlignOneFilter(barNum,barCenter);
for dx = 1:1:nDx
    
    if strcmp(flyEye,'right') || strcmp(flyEye,'Right')
        barNumLeftSelf = [barNumCentered(nMultiBars - (dx - 1):nMultiBars ),barNumCentered(1:nMultiBars - dx)];
        % second, flip the sequence...
        barNumFlip = fliplrKernel(barNumLeftSelf ,1);
        % third, flip the left bar and right bar....
        switch dx
            case 1
                secondKernel = roi.filterInfo.secondKernel.dx1.Original;
            case 2
                secondKernel = roi.filterInfo.secondKernel.dx2.Original;
        end
        seconKernelAligned = secondKernel(:,barNumFlip);
        seconKernelAlignedFlipped = fliplrKernel(seconKernelAligned,2);
        switch dx
            case 1
                roi.filterInfo.secondKernel.dx1.Aligned = seconKernelAlignedFlipped;
            case 2
                roi.filterInfo.secondKernel.dx2.Aligned = seconKernelAlignedFlipped;
        end
    else
        switch dx
            case 1
                roi.filterInfo.secondKernel.dx1.Aligned = roi.filterInfo.secondKernel.dx1.Original(:,barNumCentered);
            case 2
                roi.filterInfo.secondKernel.dx2.Aligned = roi.filterInfo.secondKernel.dx2.Original(:,barNumCentered);
                
                
        end
    end
end
% how are you doing to test it?
% MakeFigure;
% subplot(221)
% quickViewOneKernel_Smooth(roi.filterInfo.firstKernel.Original,1);
% subplot(222)
% quickViewOneKernel_Smooth(roi.filterInfo.firstKernel.Adjusted,1);
% 
% 
% quickViewKernels(roi.filterInfo.secondKernel.dx1.Original,2);
% quickViewKernels(roi.filterInfo.secondKernel.dx1.Aligned,2);
% quickViewKernels(roi.filterInfo.secondKernel.dx2.Original,2);
% quickViewKernels(roi.filterInfo.secondKernel.dx2.Aligned,2);
end