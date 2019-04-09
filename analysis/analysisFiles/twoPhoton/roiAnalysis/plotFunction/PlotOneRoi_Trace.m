function PlotOneRoi_Trace(roi,varargin)
%  PlotOneRoi_KernelAndTrace(roi,true,'kernelExtractionMethod','reverse',
%  'centerFirstKernelFlag',true)

cord = 'eye';
saveFigFlag  =false;
traceToDraw = 'meanTrace';
% cord = 'stim';
for ii = 1:2:length(varargin)
    eval([varargin{ii} ,'= varargin{',num2str(ii + 1),'};']);
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

MakeFigure;
switch cord
    case 'eye'
        allTrace  = roi.typeInfo.trace;
        name = roi.typeInfo.edgeName;
        % PlotTrace_ProbingStimulus(allTrace,'traceToDraw','meanTrace','coordinates','eye','legendLabel','typeOnly','legendValue',[],'titleStr',name,'colorBank',edgeTypeColorRGB);
        subplot(2,1,1);
        PlotTrace_ProbingStimulus(allTrace,'traceToDraw',traceToDraw,'coordinates','eye','legendLabel','typeOnly','legendValue',[],'titleStr',name,'whichProb','edge');
        subplot(2,1,2);
        PlotTrace_ProbingStimulus(allTrace,'traceToDraw',traceToDraw,'coordinates','eye','legendLabel','typeOnly','legendValue',[],'titleStr',name,'whichProb','square');
    case 'stim'
        allTrace  = roi.prob.PStim.trace;
        name = roi.prob.PStim.edgeName;
        % PlotTrace_ProbingStimulus(allTrace,'traceToDraw','meanTrace','coordinates','eye','legendLabel','typeOnly','legendValue',[],'titleStr',name,'colorBank',edgeTypeColorRGB);
        subplot(2,1,1);
        PlotTrace_ProbingStimulus(allTrace,'traceToDraw',traceToDraw,'coordinates','stim','legendLabel','typeOnly','legendValue',[],'titleStr',name,'whichProb','edge');
        subplot(2,1,2);
        PlotTrace_ProbingStimulus(allTrace,'traceToDraw',traceToDraw,'coordinates','stim','legendLabel','typeOnly','legendValue',[],'titleStr',name,'whichProb','square');

end
if saveFigFlag
    PlotOneRoi_Save(gcf,titleStr,'all + trace');
    % save the data, by type, name, number and name
end
end

