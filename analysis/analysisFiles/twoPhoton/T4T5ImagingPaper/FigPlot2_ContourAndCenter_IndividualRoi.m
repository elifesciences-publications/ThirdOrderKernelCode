% find our the strange roi...

function FigPlot2_ContourAndCenter_IndividualRoi(roiData)
nRoi = length(roiData);
[~,~,DarkLightColor] = FigPlot1ColorCode();
threshPerim = 20;
threshArea = 15;
for rr = 1:1:nRoi
    roi = roiData{rr};
    
    contourInfo = roi.filterInfo.contourInfo;
    if contourInfo.neg.maxPerim > threshPerim
        neg.flag = true;
        neg.c = contourInfo.neg.c;
    else
        neg.flag = false;
    end
    
    if contourInfo.pos.maxPerim > threshPerim
        pos.flag = true;
        pos.c = contourInfo.pos.c;
    else
        pos.flag = false;
    end
    
    centerInfo = roi.filterInfo.centerInfo;
    if centerInfo.neg.maxArea > threshArea
        center.neg.flag = true;
        center.neg.center = centerInfo.neg.center;
    else
        center.neg.flag = false;
    end
    
    if centerInfo.pos.maxArea > threshArea
        center.pos.flag = true;
        center.pos.center = centerInfo.pos.center;
    else
        center.pos.flag = false;
    end
    
    disp(['negArea : ',num2str(centerInfo.neg.maxArea),'  posArea :', num2str(centerInfo.pos.maxArea)]);
    disp(['negPerim : ',num2str(contourInfo.neg.maxPerim),'  posPerim : ', num2str(contourInfo.pos.maxPerim)]);
    MakeFigure;
    
    kernelSmoothZ = roi.filterInfo.firstKernelSmoothZAdjusted;
    
    subplot(2,2,1);
    quickViewOneKernel(kernelSmoothZ,1);
    title(roi.typeInfo.edgeName);
    subplot(2,2,2);
    quickViewOneKernel(zeros(size(kernelSmoothZ)),1);
    if neg.flag
        hold on
        plot(neg.c(:,1),neg.c(:,2),'color',DarkLightColor(2,:));
        hold off
    end
    if pos.flag
        hold on
        plot(pos.c(:,1),pos.c(:,2),'color',DarkLightColor(1,:));
        hold off
    end
    
    
    if center.neg.flag
        hold on
        plot(center.neg.center(2),center.neg.center(1),'+','color',DarkLightColor(2,:));
        hold off
    end
    if center.pos.flag
        hold on
        plot(center.pos.center(2),center.pos.center(1),'+','color',DarkLightColor(1,:));
        hold off
    end
end
end