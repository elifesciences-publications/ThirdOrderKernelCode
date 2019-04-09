function FigPlot2_MeanKernel(roiData,varargin)
saveFigFlag = false;
MainName = 'Fig2';
nFigSave = 3;
figFileType = {'fig','eps','png'};
kernelOrZ = 'kernel';
titleStr ={'Progressive T4','Regressive T4','Progressive T5','Regressive T5'};
cutFilterFlag = false;
meanMethod = 'mean';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

nRoi = length(roiData);
edgeType = zeros(nRoi,1);
% firstKernelMag = zeros(nRoi,1);
for rr = 1:1:nRoi
    roi = roiData{rr};
    edgeType(rr) = roi.typeInfo.edgeType;
end
barWidth = roiData{1}.stimInfo.barWidth;
% plot the averaged filter...
% calculate mean filter four each type..
% roiData_Aligned  = roiAnalysis_AlignedKernelCenter_Main(roiData);
[meanKernel,numStat] = roiAnalysis_AverageFirstKernel(roiData,'typeSelected',[1,2,3,4],'kernelOrZ',kernelOrZ,'meanMethod',meanMethod);
maxFilterValue = max(abs(meanKernel(:)));
% you also wants to know, howmany rois is there...
MakeFigure;
for tt = 1:1:4
    subplot(2,2,tt);
    quickViewOneKernel_Smooth(meanKernel(:,:,tt),1,'labelFlag',true,'posUnit',barWidth,'timeUnit',1/60,'cutFilterFlag',cutFilterFlag,'barRange',[5:15],'timeRange',1:45,...
        'limPreSetFlag',false,'maxValue',maxFilterValue);
    titleStrThisType = [titleStr{tt},'  nRoi:',num2str(sum(numStat.nKernel{tt})),' nfly:', num2str(length(numStat.nKernel{tt}))...
        '  roisPerFly:',StrGeneration_KernelOrRoiPerFly(numStat.nKernel{tt}),];
    title(titleStrThisType)
    %     quickViewOneKernel_Smooth(meanKernel(:,:,tt),1,'labelFlag',false,'posUnit',barWidth,'timeUnit',1/60);
end

if saveFigFlag
    MySaveFig_Juyue(gcf,MainName,'_b_kernel','nFigSave',nFigSave,'fileType',figFileType);
end
end