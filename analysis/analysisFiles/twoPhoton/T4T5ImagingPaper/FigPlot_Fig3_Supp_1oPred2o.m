function FigPlot_Fig3_Supp_1oPred2o(roiData,folderStr,saveFigFlag,varargin)
smoothFlag = false;
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

normKernelFlag = false; % normalize individual kernels within one roi, and then do any calculation from there. it should be false.
normRoiFlag = false;

barWidth = roiData{1}.stimInfo.barWidth;
%% first order kernel
figFileType = {'fig'};
nFigSave = 1;
nType = 4;
typeStr = {'T4 Pro','T4 Reg','T5 Pro','T5 Reg'};
[meanKernel,norm] = roiAnalysis_AverageFunction_OverFly_IndividualBars(roiData,'whichValue','firstKernel','kernelTypeUse',[1,2,3],...
    'normRoiFlag',false,'normKernelFlag',false);
% do not plot the indiviual one. make the glider and kernel into one plot.
% tighter...
dtLength = length(roiData{1}.simu.sK.glider.dt);
dt = reshape(roiData{1}.simu.sK.glider.dt,[dtLength,1]);
%% for 1o prediction...
MakeFigure;
[meanKernel,norm] = roiAnalysis_AverageFunction_OverFly_IndividualBars(roiData,'whichValue','firstKernel','kernelTypeUse',[1,2,3],...
    'normRoiFlag',false,'normKernelFlag',false);
MakeFigure;
for tt = 1:1:nType
    subplot(3,4,tt);
    meanKernelThisType = mean(meanKernel{tt},3);
    quickViewOneKernel_Smooth(meanKernelThisType,1,'labelFlag',true,'posUnit',barWidth,'timeUnit',1/60,'cutFilterFlag',false,...
        'limPreSetFlag',false,'maxValue',0);
    title(typeStr{tt})
end

dx = 1;
[meanKernel,norm] = roiAnalysis_AverageFunction_OverFly_IndividualBars(roiData,'whichValue','pred2o','dx',dx,'kernelTypeUse',[1,2,3],...
    'normRoiFlag',false);
[meanGlider,norm] = roiAnalysis_AverageFunction_OverFly_IndividualBars(roiData,'whichValue','predGlider','dx',dx,'kernelTypeUse',[1,2,3],...
    'normRoiFlag',false,'normKernelFlag',normKernelFlag);
barUseBank = {[10,11,12],[8,9,10],[10,11,12],[8,9,10]};

for tt = 1:1:nType
    subplot(3,4,tt + 4);
    % averaged kernel over several bars, but not
    meanKernelThisType = mean(meanKernel{tt},3); % all 20 of them
    meanKernelOverBars = mean(meanKernelThisType(:,barUseBank{tt}),2);
    quickViewOneKernel_Smooth(meanKernelOverBars, 2);
    title([typeStr{tt},'Predicted 2o Kernel']);
    
    subplot(3,4,8+ tt);
    % averaged kernel over several bars, but not
    meanGliderRespThisType = mean(meanGlider{tt},3); % all 20 of them
    meanGliderRespOverBars = mean(meanGliderRespThisType(:,barUseBank{tt}),2);
    gliderRespOverBarsFirst = mean(meanGlider{tt}(:,barUseBank{tt},:),2);
    stdGliderResp  = std(gliderRespOverBarsFirst,1,3);
    semGliderResp = stdGliderResp./sqrt(norm(tt));
    maxValue = 0;
    PlotXY_Juyue(dt,meanGliderRespOverBars,'errorBarFlag',false,'sem',semGliderResp ,'limPreSetFlag',true,'maxValue',0.4,...
        'colorMean',[1,0,0],'colorError',[1,0,0]);
    
end
if saveFigFlag
    MySaveFig_Juyue(gcf,'2o_Kernel_PredByFirst',typeStr{tt} ,'nFigSave',nFigSave,'fileType',figFileType);
end
cd(currFolder)
% you are so tired and hungry...
end
