function FigPlot_SK_MeanDtSineWave_IndividualBars(roiData,varargin)

% you want to plot glider, sinewave and integration together....
nFigSave = 3;
figFileType = {'fig','eps','png'};

nMultiBars = 20;
saveFigFlag = false;
MainName = 'Fig3';
barWidth = roiData{1}.stimInfo.barWidth;
dx = 1; % you might need both...
aveBy = 'fly';
normFlag = true;

maxTau = 64;
dtMax = 15;
tMax = 45;
direction = 0;


normKernelFlag = false; % normalize individual kernels within one roi, and then do any calculation from there. it should be false.
normRoiFlag = true;

kernelTypeUse = [1,2,3];

dtLength = length(roiData{1}.simu.sK.glider.dt);
dt = reshape(roiData{1}.simu.sK.glider.dt,[dtLength,1]);

% for different
% for progressive, it goes from
barUseEachType = {[9:12],[8:11],[9:12],[8:11]};
% barUseEachType  = {[1:20],[1:20],[1:20],[1:20]};
% omega = roiData{1}.simu.sK.sine.stim.omega';
alpha = 0.05;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

nType = 4;
switch aveBy
    % have not debud the average over fly and average over roi individual
    % bars.
    case 'fly'
        [meanKernel,a] = roiAnalysis_AverageFunction_OverFly_IndividualBars(roiData,'dx',dx,'whichValue','secondKernel','kernelTypeUse',kernelTypeUse,...
            'normKernelFlag',normKernelFlag,'normRoiFlag',normRoiFlag);
        [gliderResp,a] = roiAnalysis_AverageFunction_OverFly_IndividualBars(roiData,'dx',dx,'whichValue','glider','normKernelFlag',false,'normRoiFlag',false,'kernelTypeUse',kernelTypeUse);
        [skQuant,nNorm] = roiAnalysis_AverageFunction_OverFly_IndividualBars(roiData,'dx',dx,'whichValue','quantification','kernelTypeUse',kernelTypeUse);
    case 'roi'
        [meanKernel,a] = roiAnalysis_AverageFunction_OverRoi_IndividualBars(roiData,'dx',dx,'whichValue','secondKernel','kernelTypeUse',kernelTypeUse,...
            'normKernelFlag',normKernelFlag,'normRoiFlag',normRoiFlag);
        [gliderResp,a] = roiAnalysis_AverageFunction_OverRoi_IndividualBars(roiData,'dx',dx,'whichValue','glider','normKernelFlag',false,'normRoiFlag',false,'kernelTypeUse',kernelTypeUse);
        [skQuant,nNorm] = roiAnalysis_AverageFunction_OverRoi_IndividualBars(roiData,'dx',dx,'whichValue','quantification','kernelTypeUse',kernelTypeUse);
        % average over kernels is the same with average over roi....
end

% plot the thing that you need..

typeStr = {'T4 Pro','T4 Reg','T5 Pro','T5 Reg'};
for tt = 1:1:nType
    %% second presentation method, plot only used bars. and plot the kernel with the glider/opponency. with test and opponency test.
    
    barUse = barUseEachType{tt};
    
    meanKernelThisType = mean(meanKernel{tt},3);
    
    meanGliderResp = mean(gliderResp{tt},3);
    stdGliderResp  = std(gliderResp{tt},1,3);
    semGliderResp = stdGliderResp./sqrt(nNorm(tt));
    gliderRespZ = (meanGliderResp - 0)./semGliderResp;
    gliderRespP = 2 * normcdf(-abs(gliderRespZ ),0,1);
    
    
    meanOpponency = mean(skQuant{tt},3);
    stdOpponency = std(skQuant{tt},1,3);
    semOpponency = stdOpponency./sqrt(nNorm(tt));
    opponencyZ = (meanOpponency - 0)./ semOpponency;
    opponencyP = 2 * normcdf(-abs(opponencyZ),0,1);
    
    
    % only four bars....
    MakeFigure;
    subplotNumKernel = [1,2,3,4];
    maxValue = max(abs(meanKernelThisType(:)));
    for qq = 1:1:length(barUse)
        barThis = barUse(qq);
        subplot(2,4,subplotNumKernel(qq));
        quickViewOneKernel_Smooth(meanKernelThisType(:,barThis),2,'labelFlag',true,'posUnit',barWidth,'timeUnit',1/60,'limPreSetFlag',true,'maxValue',maxValue,'colorbarFlag',false);
        title(['bar',num2str(barThis),'&',num2str(barThis + dx)]);
    end
    
    subplotNumGlider = [9,10,11,12];
    maxValue = max(abs(meanGliderResp(:))) + max(abs(semGliderResp(:)));
    for qq = 1:1:length(barUse)
        barThis = barUse(qq);
        subplot(4,4,subplotNumGlider(qq));
        hold on
        PlotXY_Juyue(dt,meanGliderResp(:,barThis),'errorBarFlag',true,'sem',semGliderResp(:,barThis),'limPreSetFlag',true,'maxValue',maxValue * 1.5,...
            'colorMean',[1,0,0],'colorError',[1,0,0]);
        plotVerValue = 1.1 * maxValue;
        hold off
        FigPlot_SK_Utils_GliderSignificance(dt,gliderRespP(:,barThis),alpha,plotVerValue,false)
    end
    
    subplotNumOpponency = [13,14,15,16];
    maxValue = max(abs(meanOpponency(:))) + max(abs(semOpponency(:)));
    for qq = 1:1:length(barUse)
        barThis = barUse(qq);
        subplot(4,4,subplotNumOpponency(qq));
        BarXY_Juyue([1,2],meanOpponency(:,barThis),'errorBarFlag',true,'sem',semOpponency(:,barThis),'xTickStr',{'pro lobe','reg lobe'},'limPreSetFlag',true,'maxValue',maxValue * 1.5);
        plotVerValue = 1.1 * maxValue;
        FigPlot_SK_Utils_OpponencySignificance([1,2],opponencyP(:,barThis),alpha,plotVerValue)
        
    end
    
    if saveFigFlag
        secondaryName = [num2str(barWidth),'_DX',num2str(dx),'_',typeStr{tt},'_aveBy',aveBy];
        MySaveFig_Juyue(gcf,MainName, secondaryName ,'nFigSave',nFigSave,'fileType',figFileType);
    end
     %% first presentation method, plot all 20 bars.
    %     barUse = barUseEachType{tt};
    %     meanKernelThisType = mean(meanKernel{tt},3);
    %     quickViewKernelsSecond(meanKernelThisType(:,barUse),'smoothFlag',true,'subplotHt',4,'subplotWd',5,'titleFlag',false);
    %     title(typeStr{tt});
    %     if saveFigFlag
    %         secondaryName = [num2str(barWidth),'_DX',num2str(dx),'_',typeStr{tt},'_aveBy',aveBy];
    %         MySaveFig_Juyue(gcf,['Kernel',MainName], secondaryName ,'nFigSave',nFigSave,'fileType',figFileType);
    %     end
    %
    %     meanGliderResp = mean(gliderResp{tt},3);
    %     stdGliderResp  = std(gliderResp{tt},1,3);
    %     semGliderResp = stdGliderResp./sqrt(nNorm(tt));
    %     dtPlot = repmat(dt,[1,size(meanGliderResp,2)]);
    %     %
    %     quickView_PlotXY(dtPlot(:,barUse),meanGliderResp(:,barUse),'subplotHt',4,'subplotWd',5,'errorBarFlag',true,'sem',semGliderResp(:,barUse),'limPreSetFlag',true);
    %     title(typeStr{tt});
    %     if saveFigFlag
    %         secondaryName = [num2str(barWidth),'_DX',num2str(dx),'_',typeStr{tt},'_aveBy',aveBy];
    %         MySaveFig_Juyue(gcf,['GliderResp',MainName], secondaryName ,'nFigSave',nFigSave,'fileType',figFileType);
    %     end
    %
    %     meanOpponency = mean(skQuant{tt},3);
    %     stdOpponency = std(skQuant{tt},1,3);
    %     semOpponency = stdOpponency./sqrt(nNorm(tt));
    %     xPlot = repmat([1,2]',[1,size(semOpponency,2)]);
    %     quickView_BarXY(xPlot(:,barUse),meanOpponency(:,barUse),'subplotHt',4,'subplotWd',5,'errorBarFlag',true,'sem',semOpponency(:,barUse),'limPreSetFlag',true);
    %     title(typeStr{tt});
    %     if saveFigFlag
    %         secondaryName = [num2str(barWidth),'_DX',num2str(dx),'_',typeStr{tt},'_aveBy',aveBy];
    %         MySaveFig_Juyue(gcf,['Opponency',MainName], secondaryName ,'nFigSave',nFigSave,'fileType',figFileType);
    %     end
    
end

end