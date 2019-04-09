function PlotOneRoi_Kernel_BarUseKnown(roi,barUse,varargin)
% PlotOneRoi_Kernel(roi,saveFigFlag,'kernelExtractionMethod','reverse','centerFirstKernelFlag',true);
saveFigFlag = false;
additionalTitleFlag = false;
additionalTitle = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

roiNumber  = roi.stimInfo.roiNum;
roiType = roi.typeInfo.edgeType;
roiName = roi.typeInfo.edgeName;
filename = roi.stimInfo.filename;

titleStr = [];
% change the structure... roiName + filename + roiNumber + subname
if roiType < 5
    titleStr = [roiName,'_ ',filename,'_ Roi_ ', num2str(roiNumber)];
elseif roiType >= 5 && roiType <= 20
    titleStr = [roiName{1},'_ ',roiName{2},filename,'_ Roi_ ', num2str(roiNumber)];
else
    titleStr =['NotClear',filename,'_ Roi_ ', num2str(roiNumber)];
end

firstKernel = roi.filterInfo.firstKernel;
secondKernel = roi.filterInfo.secondKernel;

MakeFigure;
subplot(2,2,1);
quickViewOneKernel_Smooth(firstKernel.Adjusted,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
% put + on the barUse.
% you need x, x+ 1, x + 2; two bars
if ~isempty(barUse{1});
    subplot(2,2,3)
    secondKernelShow = secondKernel.dx1.Adjusted(:,barUse{1});
    barUseX = barUse{1}(1);
    
    %     flyEye = roi.flyInfo.flyEye;
    %     if strcmp(flyEye,'right') || strcmp(flyEye,'Right')
    %         barBack = fliplr(barBack);
    %     end
    quickViewOneKernel_Smooth(secondKernelShow(:,1),2,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
    [barLeft,barRight] = PlotOneRoi_Kernel_BarUseKnown_Utils_CalBarPos(roi,barUseX,1);
    title(['bar L:',num2str(barLeft),' & R: ',num2str(barRight)]);
    
    if length(barUse{1}) > 1
        subplot(2,2,4)
        barUseX = barUse{1}(2);
        quickViewOneKernel_Smooth(secondKernelShow(:,2),2,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
        [barLeft,barRight] = PlotOneRoi_Kernel_BarUseKnown_Utils_CalBarPos(roi,barUseX,1);
        title(['bar L:',num2str(barLeft),' & R: ',num2str(barRight)]);
        
    end
end

if ~isempty(barUse{2})
    subplot(2,2,2)
    secondKernelShow = secondKernel.dx2.Adjusted(:,barUse{2});
    barUseX = barUse{2};
    quickViewOneKernel_Smooth(secondKernelShow(:,1),2,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
    [barLeft,barRight] = PlotOneRoi_Kernel_BarUseKnown_Utils_CalBarPos(roi,barUseX,2);
    title(['bar L:',num2str(barLeft),' & R: ',num2str(barRight)]);
end

if saveFigFlag
    PlotOneRoi_Save(gcf,titleStr,'kernel');
    % save the data, by type, name, number and name
end
