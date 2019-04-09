function FigPlot_SecondQuantification(roiData,varargin)
dx = 1;
dt = [-10:1:10];
tMax = 30;
nFigSave = 3;
figFileType = {'fig','eps','png'};


for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
roiData = roiAnalysis_SecondDt(roiData,'dt',dt,'tMax',tMax);
barWidth = roiData{1}.stimInfo.barWidth;

nRoi = length(roiData);
edgeType = zeros(nRoi,1);
kernelType = zeros(nRoi,1);
for rr = 1:1:nRoi
    edgeType(rr) = roiData{rr}.typeInfo.edgeType;
    kernelType(rr) = roiData{rr}.filterInfo.kernelType;
end

%%
dx = 1;
proMean = [];
regMean = [];
proMax = [];
regMax = [];
% for one roi, there might be several kernelType, remember the
edgeTypePerKernel = [];
for rr = 1:1:nRoi
    if kernelType(rr) > 1
        roi = roiData{rr};
        % collect those value... plot scatter plot...
        [value,barUse] = roiAnalysis_OneRoi_GetQuantificationResult(roi,dx,'mean');
        proMean = [proMean;value(1,barUse)'];
        regMean = [regMean;value(2,barUse)'];
        
        [value,barUse] = roiAnalysis_OneRoi_GetQuantificationResult(roi,dx,'max');
        proMax = [proMax;value(1,barUse)'];
        regMax = [regMax;value(2,barUse)'];
        
        edgeTypePerKernel = [edgeTypePerKernel; ones(length(barUse),1) * edgeType(rr)];
    end
end


%%
% plot the scatter plot or the bar plot..
MakeFigure;
subplot(2,2,1)
FigPlot_AnythingScatter(proMean,regMean,edgeTypePerKernel,'proLobe','regLobe',['DX',num2str(dx),'mean']);
subplot(2,2,2)
FigPlot_AnythingScatter(proMax,regMax,edgeTypePerKernel,'proLobe','regLobe',['DX',num2str(dx),'max']);

%%
dx = 2;
proMean = [];
regMean = [];
proMax = [];
regMax = [];
% for one roi, there might be several kernelType, remember the
edgeTypePerKernel = [];
for rr = 1:1:nRoi
    if kernelType(rr) > 1
        roi = roiData{rr};
        % collect those value... plot scatter plot...
        [value,barUse] = roiAnalysis_OneRoi_GetQuantificationResult(roi,dx,'mean');
        proMean = [proMean;value(1,barUse)'];
        regMean = [regMean;value(2,barUse)'];
        
        [value,barUse] = roiAnalysis_OneRoi_GetQuantificationResult(roi,dx,'max');
        proMax = [proMax;value(1,barUse)'];
        regMax = [regMax;value(2,barUse)'];
        
        edgeTypePerKernel = [edgeTypePerKernel; ones(length(barUse),1) * edgeType(rr)];
    end
end
subplot(2,2,3)
FigPlot_AnythingScatter(proMean,regMean,edgeTypePerKernel,'proLobe','regLobe',['DX',num2str(dx),'mean']);
subplot(2,2,4)
FigPlot_AnythingScatter(proMax,regMax,edgeTypePerKernel,'proLobe','regLobe',['DX',num2str(dx),'max']);

%%
if saveFigFlag
    MainName = ['skQuant'];
    secondaryName = [num2str(barWidth),'_DX',num2str(0),'_','dtMax',num2str(max(dt)),'_tMax',num2str(tMax)];
    MySaveFig_Juyue(gcf,MainName, secondaryName ,'nFigSave',nFigSave,'fileType',figFileType);
end
