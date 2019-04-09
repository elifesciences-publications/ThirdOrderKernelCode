function FigPlot3_MeanSecondFilter(roiData,varargin)

nFigSave = 3;
figFileType = {'fig','eps','png'};

nMultiBars = 20;
saveFigFlag = false;
MainName = 'Fig3';
barWidth = roiData{1}.stimInfo.barWidth;
dx = 1; % you might need both...
meanMethod = 'mean';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% there are four types, each four types, you need at least four rois.
nType = 4;
switch meanMethod
    case 'mean'
        normFlag = false;
    case 'norm'
        normFlag = true;
end
meanKernelEachType = roiAnalysis_AverageFunction_OverFly(roiData,'dx',dx,'whichValue','secondKernel','normFlag',normFlag);
meanKernel = zeros(size(meanKernelEachType{1},1),nType);
for tt = 1:1:nType
    meanKernel(:,tt) = mean(meanKernelEachType{tt},2);
end
% get how many kernels in how many flys.
numStat = roiAnalysis_FlyRoiKernelStat(roiData);
nKernel = cell(4,1);
for tt = 1:1:nType
    switch dx
        case 1
            nKernelThisType = numStat.nSecondKernelPerFly(tt,:,1);
        case 2
            nKernelThisType = numStat.nSecondKernelPerFly(tt,:,2);
        case 0
            nKernelThisType = sum(numStat.nSecondKernelPerFly(tt,:,:),3);
    end
    nKernelThisType(nKernelThisType == 0) = [];
    nKernel{tt} = nKernelThisType;
end
MakeFigure;
maxFilterValue = max(abs(meanKernel(:)));

titleStr = {'progressive T4','regressive T4','progressive T5','regressive T5'};
for tt = 1:1:nType
    subplot(2,2,tt);
    quickViewOneKernel_Smooth(meanKernel(:,tt),2,'labelFlag',true,'posUnit',barWidth,'timeUnit',1/60,'limPreSetFlag',false,'maxValue',maxFilterValue);
    
    titleStrThisType = {[titleStr{tt},'  nKernel:',num2str(sum(nKernel{tt})),' nfly:', num2str(length(nKernel{tt}))],
        ['kernelsPerFly:',StrGeneration_KernelOrRoiPerFly(nKernel{tt}),]};
    title(titleStrThisType)
end

if saveFigFlag
    secondaryName = ['2oMeanKernel',num2str(barWidth),'_',meanMethod,'_DX',num2str(dx)];
    MySaveFig_Juyue(gcf,MainName, secondaryName ,'nFigSave',nFigSave,'fileType',figFileType);
end
end