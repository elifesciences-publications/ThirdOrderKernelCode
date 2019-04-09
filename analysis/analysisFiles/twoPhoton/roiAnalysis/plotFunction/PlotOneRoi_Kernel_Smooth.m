function PlotOneRoi_Kernel_Smooth(roi,saveFigFlag,varargin)
% PlotOneRoi_Kernel(roi,saveFigFlag,'kernelExtractionMethod','reverse','centerFirstKernelFlag',true);
kernelExtractionMethod = 'OLS';
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


switch kernelExtractionMethod
    case 'OLS'
        filterInfo = roi.filterInfoNew;
    case 'reverse'
        filterInfo = roi.filterInfo;
end



kernelType = roi.filterInfo.kernelType;
firstKernel = filterInfo.firstKernelAdjusted;
% for the old 5B and 10..
if kernelType >= 2
    switch kernelExtractionMethod
        case 'OLS'
    secondKernel = roi.filterInfoNew.secondKernelAdjusted;
        case 'reverse'
            secondKernel = roi.filterInfo.secondKernelAdjusted;
    end
else
    %     if you did not compute the second order filter using new method. use the old one.
    secondKernel = roi.filterInfo.secondKernelAdjusted;
end

%
switch kernelType
    case 0
        error('this roi is classified as no good filter');
        % look at the bar which is selected by first order kernel
        %         barUse = find(roi.filterInfo.firstBarSelected);
        %         barUse = 1; % default. because it is judged as bad kernel.
    case 1 % if kernel is
        barUse = find(roi.filterInfo.firstBarSelected);
%         barUse = mod(barUse + 1,20) + 1;
    case 2
        barUse = find(roi.filterInfo.secondBarSelected);
        
    case 3
        barSelectedFirst = roi.filterInfo.firstBarSelected; % you can find the top three...
        % you have to shift it to left 1 or 2...
        barSelectedFirst = [0;barSelectedFirst(1:end - 1)];
        barSelectedSecond = roi.filterInfo.secondBarSelected;
        barSelected = barSelectedFirst | barSelectedSecond;
        barUse = find(barSelected);
end

subplot(2,4,1);

quickViewOneKernel(firstKernel,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
if strcmp(roi.prob.PStim.dirName,'Right')
    barUseShow = 20 - barUse + 1;
else
    barUseShow = barUse;
end
set(gca,'xTick',sort(barUseShow),'xTickLabel','+');
title(['kernelType',num2str(kernelType)]);

for ii = 1:1:length(barUse)
    qq = barUse(ii);
    subplot(2,4,ii + 1);
    
    quickViewOneKernel_Smooth(secondKernel(:,qq),2,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
    title(['bar #',num2str(barUseShow(ii))]);
end

% adjusted first order kernel so that it is moved to good position.
% if centerFirstKernelFlag
%     firstKernel = CenterizeFirstKernel(firstKernel,barUse);
% end

% quickViewKernelOneRoi(firstKernel,secondKernel,barUse,kernelType);
%
if saveFigFlag
    PlotOneRoi_Save(gcf,titleStr,'kernel');
    % save the data, by type, name, number and name
end
