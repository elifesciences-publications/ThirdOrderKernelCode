function [barLeft,barRight] = PlotOneRoi_Kernel_BarUseKnown_Utils_CalBarPos(roi,barUseX,dx)
    barSelected  = false(1,20);
    barSelected(barUseX) = true;
    barCenter = roi.filterInfo.barCenter;
    barSelectedShifted  = roiAnalysis_AverageFirstKernel_AlignOneFilter(barSelected,barCenter);
    
    flyEye = roi.flyInfo.flyEye;
    % do you also have to flip barcenter? yes!
    if strcmp(flyEye,'right') || strcmp(flyEye,'Right')
        barSelectedFlip = fliplr(barSelectedShifted);
    else
        barSelectedFlip = barSelectedShifted;
    end
    barUseXShow = find(barSelectedFlip);
    if strcmp(flyEye,'right') || strcmp(flyEye,'Right')
        barRight = barUseXShow;
        barLeft = barRight - dx;
    else
        barLeft = barUseXShow;
        barRight = barLeft + dx;
    end
end