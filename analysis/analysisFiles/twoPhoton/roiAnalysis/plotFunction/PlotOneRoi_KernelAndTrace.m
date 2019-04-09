function PlotOneRoi_KernelAndTrace(roi,saveFigFlag,varargin)
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

MakeFigure;
PlotOneRoi_Kernel(roi,false,'kernelExtractionMethod','reverse');
subplot(2,1,2);
[~,edgeTypeColorRGB,~] = FigPlot1ColorCode();
allTrace  = roi.typeInfo.trace;
name = roi.typeInfo.edgeName;
PlotTrace_ProbingStimulus(allTrace,'traceToDraw','meanTrace','coordinates','eye','legendLabel','typeOnly','legendValue',[],'titleStr',name,'colorBank',edgeTypeColorRGB);

%
if saveFigFlag
    PlotOneRoi_Save(gcf,titleStr,'filter + trace');
    % save the data, by type, name, number and name
end
end