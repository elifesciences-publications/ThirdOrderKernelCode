function FigPlot_SecondOrderKernel_ImpulseResponse(roiData,folderStr,saveFigFlag,varargin)
smoothFlag = false;
limPreSetFlag = false;
dx = 1;
barUseBank = {[9,10,11,12],[8,9,10,11],[9,10,11,12],[8,9,10,11]};
MainName = '2o_Kernel_Mean';
sortMethod = 'flyId';
chopFlag = true;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
currFolder = pwd;

try
    cd(folderStr)
catch
    mkdir(folderStr);
    cd(folderStr)
end

[meanKernel,norm] = roiAnalysis_AverageFunction_OverFly_IndividualBars(roiData,'whichValue','secondKernel','dx',dx,'kernelTypeUse',[1,2,3],...
    'normRoiFlag',false,'sortMethod',sortMethod);

nType = 4;
for tt = 1:1:nType
    meanKernel{tt} = 1/2 * meanKernel{tt};
end

maxValueSecond = zeros(nType,1);
for tt = 1:1:nType
    meanKernelThisType = mean(meanKernel{tt},3);
    meanKernelOverBars = mean(meanKernelThisType(:,barUseBank{tt}),2);
    maxValueSecond(tt) = max(abs(meanKernelOverBars (:)));
end
meanKernelFourType = zeros(size(meanKernel{tt},1),4);

figFileType = {'fig'};
nFigSave = 1;
nType = 4;
typeStr = {'T4 Pro','T4 Reg','T5 Pro','T5 Reg'};


MakeFigure;
for tt = 1:1:nType
    % averaged kernel over several bars
    meanKernelThisType = mean(meanKernel{tt},3);
    meanKernelOverBars = mean(meanKernelThisType(:,barUseBank{tt}),2);
    meanKernelFourType(:,tt) = meanKernelOverBars;
    subplot(2,2,tt)
    quickViewSecondKernel_Impulse(meanKernelOverBars,'limPreSetFlag',limPreSetFlag,'maxValue',prctile(maxValueSecond,50),'mode',2,'smoothFlag',smoothFlag,'chopFlag',chopFlag);
    % all of them...
    title([typeStr{tt},' Mean 2o Kernel']);
    
end
if saveFigFlag
    MySaveFig_Juyue(gcf,MainName,['Impulse_dx',num2str(dx),'sF',num2str(smoothFlag),'s',num2str(chopFlag)] ,'nFigSave',nFigSave,'fileType',figFileType);
end
% get t

% give an example...

for tt = 1:1:nType
    % averaged kernel over several bars
    meanKernelThisType = mean(meanKernel{tt},3);
    meanKernelOverBars = mean(meanKernelThisType(:,barUseBank{tt}),2);
    meanKernelFourType(:,tt) = meanKernelOverBars;
    MakeFigure;
    subplot(2,2,1)
    if smoothFlag
        quickViewOneKernel_Smooth(meanKernelOverBars, 2,'limPreSetFlag',limPreSetFlag,'maxValue',prctile(maxValueSecond,50));
    else
        quickViewOneKernel(meanKernelOverBars, 2,'limPreSetFlag',limPreSetFlag,'maxValue',prctile(maxValueSecond,50));
    end
    title([typeStr{tt},' Mean 2o Kernel']);
    limPreSetFlag = false;
    subplot(2,2,2)
    quickViewSecondKernel_Impulse(meanKernelOverBars,'limPreSetFlag',limPreSetFlag,'maxValue',max(abs(meanKernelOverBars)),'mode',1,'smoothFlag',smoothFlag);
    % all of them...
    title([typeStr{tt},' Mean 2o Kernel']);
    
    subplot(2,2,3)
    quickViewSecondKernel_Impulse(meanKernelOverBars,'limPreSetFlag',limPreSetFlag,'maxValue',max(abs(meanKernelOverBars)),'mode',2,'smoothFlag',smoothFlag,'boxFlag',true);
    
    subplot(2,2,4)
    quickViewSecondKernel_Impulse(meanKernelOverBars,'limPreSetFlag',limPreSetFlag,'maxValue',max(abs(meanKernelOverBars)),'mode',2,'smoothFlag',smoothFlag,'chopFlag',true);
   
    if saveFigFlag
        MySaveFig_Juyue(gcf,['2o',typeStr{tt}],['Impulse_dx',num2str(dx),'sF',num2str(smoothFlag),'s',num2str(chopFlag)] ,'nFigSave',nFigSave,'fileType',figFileType);
    end
end

% get t

% give an example...


cd(currFolder)
% you are so tired and hungry...
end
