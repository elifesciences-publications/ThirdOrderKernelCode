function contourInfo = roiAnalysis_OneRoi_1D_Kernel_FindContour(roi)
%%
threshZ = 1.7;
kernel = roi.filterInfo.firstKernel.smoothZAdjusted;
kernelWindow = zeros(size(kernel));
barRange = 5:15;
timeRange = 2:45;
kernelWindow(timeRange, barRange) = 1;
kernel = kernel .* kernelWindow;

% get a window 
levels = [-threshZ,threshZ];
c= contourc(kernel,levels);
[~,maxPointsInEachLevel,~,traceToPlot] = MyContour2poly(c,levels);

if maxPointsInEachLevel(1) > 0
    negC = traceToPlot{1};
else 
    negC = [];
end

if maxPointsInEachLevel(2) > 0 
    posC = traceToPlot{2};
else
    posC = [];
end
%

contourInfo.neg.maxPerim = maxPointsInEachLevel(1);
contourInfo.neg.c = negC;
contourInfo.pos.maxPerim = maxPointsInEachLevel(2);
contourInfo.pos.c = posC;


% %% return the largest postive and negtive traces back...
% MakeFigure;
% subplot(2,2,1);
% quickViewOneKernel(kernel,1);
% hold on
% [c,h] = contour(kernel,levels);
% [cstruct,maxPointsInEachLevel,whichContour,traceToPlot] = TryContour2poly(c,levels);
% 
% h.LineWidth = 3;
% hold off
% subplot(2,2,2);
% quickViewOneKernel(kernel,1);
% hold on
% plot(traceToPlot{1}(:,1),traceToPlot{1}(:,2),'color',[0,0,1],'lineWidth',3);
% plot(traceToPlot{2}(:,1),traceToPlot{2}(:,2),'color',[1,0,0],'lineWidth',3);
% disp(['negative num ',num2str(maxPointsInEachLevel(1)),'  positve num ',num2str(maxPointsInEachLevel(2))]);
% hold off
% clear c h
end