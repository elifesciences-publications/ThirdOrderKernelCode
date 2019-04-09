function PlotOneRoi_Kernel_First(roi,varargin)
% PlotOneRoi_Kernel_First(roi,saveFigFlag,'kernelExtractionMethod','reverse','centerFirstKernelFlag',true);
kernelExtractionMethod = 'OLS';
saveFigFlag = false;
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

filterInfo = roi.filterInfo;

kernelType = roi.filterInfo.kernelType;

firstKernelStim = filterInfo.firstKernel.Original; 
barCenter = roiAnalysis_FindFirstKernelCenter(roi,'method','prob');
% barCenter = find(roi.filterInfo.firstBarSelected,1,'last');  % bar Center is not good....barCenter...
firstFilterStimCentered = roiAnalysis_AverageFirstKernel_AlignOneFilter(firstKernelStim,barCenter);

%%
barSelected = filterInfo.firstKernel.barSelected; % you have to shift to right for at least two.
% last is not a good thing to do....
% change your way of assigning barSelected...
% barSelected(find(barSelected,1,'last') + 1) = 1;
% barSelected = [0;barSelected(1:end - 1)];
firstFilterSelected = firstKernelStim;
firstFilterSelected(:,~barSelected) = 0; 
% firstKernel = filterInfo.firstKernelAdjusted;
dirStim = roi.prob.PStim.dirTypeEdge;
if dirStim == 1
    firstFilter = firstFilterStimCentered;
else
    firstFilter = fliplrKernel(firstFilterStimCentered,1);
end

subplot(2,4,1);
switch kernelExtractionMethod
    case 'OLS'
        quickViewOneKernel_Smooth(filterInfo.firstKernel.Adjusted,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
        title('aligned,centered,smoothed');
    case 'reverse'
        quickViewOneKernel(filterInfo.firstKernel.Adjusted,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
        title('aligned and centered');
end

subplot(2,4,2);
switch kernelExtractionMethod
    case 'OLS'
        quickViewOneKernel_Smooth(firstKernelStim,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
        title('origninal(smoothed)');
    case 'reverse'
        quickViewOneKernel(firstKernelStim,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
        title('original');
end

subplot(2,4,3)
switch kernelExtractionMethod
    case 'OLS'
        quickViewOneKernel_Smooth(firstFilterSelected,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
        title('origninal(smoothed, showSelectedBar)');
    case 'reverse'
        quickViewOneKernel(firstFilterSelected,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
        title('original,showSelectedBar');
end



if saveFigFlag
    PlotOneRoi_Save(gcf,titleStr,'first_kernel');
    % save the data, by type, name, number and name
end
