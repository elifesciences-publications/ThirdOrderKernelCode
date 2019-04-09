function PlotOneRoi_Kernel_Second(roi,varargin)
% PlotOneRoi_Kernel_Second(roi,saveFigFlag,'kernelExtractionMethod','reverse','centerFirstKernelFlag',true);
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

% kernelType = roi.filterInfo.kernelType;
secondKernel = roi.filterInfo.secondKernelAdjusted;

for qq = 1:1:20
    subplot(4,5,qq);
    quickViewOneKernel_Smooth(secondKernel(:,qq),2,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
%     title(['bar #',num2str(qq),'nSig',]);
end
%
if saveFigFlag
    PlotOneRoi_Save(gcf,titleStr,'kernel_second');
    % save the data, by type, name, number and name
end
