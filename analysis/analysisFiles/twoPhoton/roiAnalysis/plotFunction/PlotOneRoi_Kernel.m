function PlotOneRoi_Kernel(roi,varargin)
% PlotOneRoi_Kernel(roi,saveFigFlag,'kernelExtractionMethod','reverse','centerFirstKernelFlag',true);
kernelExtractionMethod = 'OLS';
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



filterInfo = roi.filterInfo;
kernelType = roi.filterInfo.kernelType;
% some times, you are required to plot the prefered direction... do one
% more step transformation here.
% firstKernelStim = filterInfo.firstKernelOriginal;
% barCenter = find(roi.filterInfo.firstBarSelected,1,'last');
% firstFilterStim = roiAnalysis_AverageFirstKernel_AlignOneFilter(firstKernelStim,barCenter);
% % firstKernel = filterInfo.firstKernelAdjusted;
% dirStim = roi.prob.PStim.dirTypeEdge;
% if dirStim == 1
%     firstFilter = firstFilterStim;
% else
%     firstFilter = fliplrKernel(firstFilterStim ,1);
% end
% for the old 5B and 10..

secondKernel = roi.filterInfo.secondKernelOriginal;

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
        barSelectedFirst = [0;barSelectedFirst(1:end - 1)];
        barSelectedSecond = roi.filterInfo.secondBarSelected;
        barSelected = barSelectedFirst | barSelectedSecond;
        barUse = find(barSelected);
end
% expand to left a little bit...
minBar = min(barUse);
barUse = [mod(minBar  - 2,20) + 1;barUse];

if length(barUse) >= 5
    barUse = barUse(1:5);
end
MakeFigure;
subplot(3,4,1);
quickViewOneKernel_Smooth(filterInfo.firstKernelOriginal,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
% set(gca,'xTick',sort(barUse),'xTickLabel','+');

if additionalTitleFlag
    title([additionalTitle,'  kernelType',num2str(kernelType)]);
else
    title(['kernelType',num2str(kernelType)]);
end

for ii = 1:1:length(barUse)
    qq = barUse(ii);
    subplot(3,4,ii + 1);
    
    quickViewOneKernel_Smooth(secondKernel(:,qq),2,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
    title(['bar #',num2str(barUse(ii)),' & ',num2str(mod(barUse(ii),20)+1)]);
end

if isfield(roi.filterInfo,'secondKernelNotNearestAdjusted')
    secondKernel = roi.filterInfo.secondKernelNotNearestOriginal;
    for ii = 1:1:length(barUse)
        qq = barUse(ii);
        subplot(3,4,ii + 1 + length(barUse));
        
        quickViewOneKernel_Smooth(secondKernel(:,qq),2,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
        title(['bar #',num2str(barUse(ii)),' & ',num2str(mod(barUse(ii)+1,20)+1)]);
    end
end

if saveFigFlag
    PlotOneRoi_Save(gcf,titleStr,'kernel');
    % save the data, by type, name, number and name
end
