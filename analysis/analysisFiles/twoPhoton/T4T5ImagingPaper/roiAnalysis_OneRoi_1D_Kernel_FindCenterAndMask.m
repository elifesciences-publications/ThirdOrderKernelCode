function polarityInfo = roiAnalysis_OneRoi_1D_Kernel_FindCenterAndMask(roi)
% get the largest values in the kernel
% for the first order....
threshZ = 2;
barRange = 5:15;
timeRange = 2:45;
kernel = roi.filterInfo.firstKernel.smoothZAdjusted;

mapWindow = zeros(size(kernel));
mapWindow(timeRange,barRange) = true;

negMap = kernel < - threshZ;
posMap = kernel > threshZ;


negInfo = roiAnalysis_1D_Kernel_FindCenterAndMask_BasedOnConnectedLargeZ(negMap, mapWindow);
posInfo = roiAnalysis_1D_Kernel_FindCenterAndMask_BasedOnConnectedLargeZ(posMap, mapWindow);

polarityInfo.neg = negInfo;
polarityInfo.pos = posInfo;
end
% should you change the size of the mask once they come out?
% MakeFigure;
% subplot(3,3,1)
% quickViewOneKernel_Smooth(kernel,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
% subplot(3,3,2)
% quickViewOneKernel(kernel_smooth,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
% subplot(3,3,3)
% quickViewOneKernel(kernelExtremeValue,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
% 
% % negMap
% subplot(3,3,4);
% quickViewOneKernel(negMap,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
% subplot(3,3,5);
% negMapDilate = imdilate(negMap,[1,1,1;1,1,1;1,1,1]);
% quickViewOneKernel(negMapDilate,1);
% subplot(3,3,6);
% quickViewOneKernel(negInfo.mask,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
% % posMap
% subplot(3,3,7);
% quickViewOneKernel(posMap,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
% subplot(3,3,8);
% posMapDilate = imdilate(posMap,[1,1,1;1,1,1;1,1,1]);
% quickViewOneKernel(posMapDilate,1);
% subplot(3,3,9)
% quickViewOneKernel(posInfo.mask,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
% 
% % if the mask is positive, plot that outline out...
% if negInfo.flag
%     maskTemp = imdilate(negInfo.mask(:,:),[0 1 0; 1 1 1;0 1 0],'same');
%     subplot(3,3,6);
%     
%     
%     %     quickViewOneKernel(maskTemp,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
%     lobeBoundaries = MyBWBoundaries(maskTemp(:,:));
%     %     hold on
%     %     plot( lobeBoundaries{1}(:,2),lobeBoundaries{1}(:,1),'lineWidth',1,'color',[0,0,0]);
%     %     hold off
%     subplot(3,3,1);
%     hold on
%     plot( lobeBoundaries{1}(:,2),lobeBoundaries{1}(:,1),'lineWidth',1,'color',[0,0,0]);
%     hold off
% end
% if posInfo.flag
%     maskTemp = imdilate(posInfo.mask(:,:),[0 1 0; 1 1 1;0 1 0],'same');
%     subplot(3,3,9);
%     %     quickViewOneKernel(maskTemp,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
%     lobeBoundaries = MyBWBoundaries(maskTemp(:,:));
%     %     hold on
%     %     plot( lobeBoundaries{1}(:,2),lobeBoundaries{1}(:,1),'lineWidth',1,'color',[0,0,0]);
%     %     hold off
%     subplot(3,3,1);
%     hold on
%     plot( lobeBoundaries{1}(:,2),lobeBoundaries{1}(:,1),'lineWidth',1,'color',[0,0,0]);
%     hold off
% end
% 
%%
% previous version,
% you are using the largest value in one kernel
% kernel = roi.filterInfo.firstKernelZAdjusted;
% % to do this job, you might have to do a larger smoothing...
% h_smooth = fspecial('gaussian',10);
% kernel_smooth = imfilter(kernel,h_smooth,'replicate');
% [~,indSort] = sort(kernel_smooth(:),'descend');
% nPixel = 60;
% 
% kernelExtremeValue = zeros(size(kernel));
% kernelExtremeValue(indSort(1:nPixel)) = 1;
% kernelExtremeValue(indSort(end : - 1: end - nPixel)) = -1;
% kernelExtremeValue = reshape(kernelExtremeValue,size(kernel));
% 
% negMap = zeros(size(kernel));
% posMap = zeros(size(kernel));
% 
% negMap(kernelExtremeValue == -1) = 1;
% posMap(kernelExtremeValue == 1) = 1;
% negMap = negMap .* mapWindow;
% posMap = posMap .* mapWindow;
% negInfo = roiAnalysis_1D_Kernel_FindCenterAndMask_ConnectedRegion(negMap);
% posInfo = roiAnalysis_1D_Kernel_FindCenterAndMask_ConnectedRegion(posMap);