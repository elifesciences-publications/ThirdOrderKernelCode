function polarityInfo = roiAnalysis_OneRoi_1D_Kernel_FindContour_OnUpSam(roi)
barRange = 5:15;
timeRange = 1:45;

kernel = roi.filterInfo.firstKernelAdjusted;
mapWindow = zeros(size(kernel));
mapWindow(timeRange,barRange) = true;


kernelScaleFactor = 10;
% smooth the kernel first.
h_smooth = fspecial('gaussian',10);
kernel_smooth = imfilter(kernel,h_smooth,'replicate');


% upsampling the kernel.
kernel_upSampling = imresize(kernel_smooth,kernelScaleFactor);
window_upSampling = imresize(double(mapWindow),kernelScaleFactor,'method','nearest');

% the upSampled version looks so nice....
% do the map thing on the new guy....

% first, find the extream values
nPixel = 4000;
[~,indSort] = sort(kernel_upSampling(:),'descend');
kernelExtremeValue = zeros(size(kernel_upSampling));
kernelExtremeValue(indSort(1:nPixel)) = 1;
kernelExtremeValue(indSort(end : - 1: end - nPixel)) = -1;
kernelExtremeValue = reshape(kernelExtremeValue,size(kernel_upSampling));

negMap = zeros(size(kernel_upSampling));
posMap = zeros(size(kernel_upSampling));

negMap(kernelExtremeValue == -1) = 1;
posMap(kernelExtremeValue == 1) = 1;

negMap = negMap.*window_upSampling;
posMap = posMap.*window_upSampling;

%%
negInfo = roiAnalysis_1D_Kernel_FindCenterAndMask_ConnectedRegion_OnUpSam(negMap);
posInfo = roiAnalysis_1D_Kernel_FindCenterAndMask_ConnectedRegion_OnUpSam(posMap);

if negInfo.flag 
    boundary = MyBWBoundaries(negInfo.mask);
    negBoundary = boundary{1};
    negBoundary = negBoundary/kernelScaleFactor + 0.5;
    negInfo.center = negInfo.center/kernelScaleFactor + 0.5;
    negInfo.bd = negBoundary + 0.;
else
    negInfo.bd = [];
end
if posInfo.flag 
    boundary = MyBWBoundaries(posInfo.mask);
    posBoundary = boundary{1};
    % before you do the scale factor, you move everything to be 
    posBoundary = posBoundary/kernelScaleFactor + 0.5;
    posInfo.center = posInfo.center/kernelScaleFactor + 0.5;
    posInfo.bd =  posBoundary;
else
    posInfo.bd = [];
end

polarityInfo.neg = negInfo;
polarityInfo.pos = posInfo;

% MakeFigure;
% subplot(3,3,1);
% quickViewOneKernel(kernel,1);
% subplot(3,3,2);
% quickViewOneKernel(kernel_smooth,1);
% subplot(3,3,3);
% quickViewOneKernel(kernel_upSampling,1);
% subplot(3,3,4);
% quickViewOneKernel(negMap,1);
% subplot(3,3,5);
% quickViewOneKernel(posMap,1);
% if negInfo.flag
%     boundary = MyBWBoundaries(negInfo.mask);
%     negBoundary = boundary{1};
%     negBoundary = negBoundary/kernelScaleFactor + 0.5;
% 
%     subplot(3,3,7);
%     quickViewOneKernel(negInfo.mask,1);
%     hold on
%     plot(boundary{1}(:,2),boundary{1}(:,1),'k');
%     hold off
%     
%     subplot(3,3,1);
%     hold on
%     plot(negBoundary(:,2),negBoundary(:,1),'k');
%     hold off
% end
% if posInfo.flag
%     boundary = MyBWBoundaries(posInfo.mask);
%     posBoundary = boundary{1};
%     posBoundary = posBoundary/kernelScaleFactor + 0.5;
% 
%     subplot(3,3,8);
%     quickViewOneKernel(posInfo.mask,1);
%     hold on
%     plot(boundary{1}(:,2),boundary{1}(:,1),'k');
%     hold off
%     
%     subplot(3,3,1);
%     hold on
%     plot(posBoundary(:,2),posBoundary(:,1),'k');
%     hold off
% end

end