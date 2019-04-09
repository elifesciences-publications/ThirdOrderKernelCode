function FigPlot_SK_MeanDtSineWave(roiData,varargin)

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

%% remmember to change it to true again...
limPreSetFlag = true;
dt = roiData{1}.simu.sK.glider.dt';
% omega = roiData{1}.simu.sK.sine.stim.omega';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

nType = 4;
switch aveBy
    case 'fly'
        [meanKernel,a] = roiAnalysis_AverageFunction_OverFly(roiData,'dx',dx,'whichValue','secondKernel','normKernelFlag',normKernelFlag,'normRoiFlag',normRoiFlag);
        %         [sineResp,b] = roiAnalysis_AverageFunction_OverFly(roiData,'dx',dx,'whichValue','sinewave');
        [gliderResp,c] = roiAnalysis_AverageFunction_OverFly(roiData,'dx',dx,'whichValue','glider');
        [skQuant,nNorm] = roiAnalysis_AverageFunction_OverFly(roiData,'dx',dx,'whichValue','quantification');
    case 'roi'
        [meanKernel,a] = roiAnalysis_AverageFunction_OverRoi(roiData,'dx',dx,'whichValue','secondKernel');
        %         [sineResp,b] = roiAnalysis_AverageFunction_OverRoi(roiData,'dx',dx,'whichValue','sinewave');
        [gliderResp,c] = roiAnalysis_AverageFunction_OverRoi(roiData,'dx',dx,'whichValue','glider');
        [skQuant,nNorm] = roiAnalysis_AverageFunction_OverRoi(roiData,'dx',dx,'whichValue','quantification');
    case 'kernel'
        [meanKernel,a] = roiAnalysis_AverageFuncion_OverKernel(roiData,'dx',dx,'whichValue','secondKernel','normKernelFlag',normKernelFlag,'normRoiFlag',normRoiFlag);
        %         [sineResp,b] = roiAnalyis_AverageFuncion_OverKernel(roiData,'dx',dx,'whichValue','sinewave');
        [gliderResp,c] = roiAnalysis_AverageFuncion_OverKernel(roiData,'dx',dx,'whichValue','glider');
        [skQuant,nNorm] = roiAnalysis_AverageFuncion_OverKernel(roiData,'dx',dx,'whichValue','quantification');
end

% plot the thing that you need..

typeStr = {'T4 Pro','T4 Reg','T5 Pro','T5 Reg'};
numStat = roiAnalysis_FlyRoiKernelStat(roiData);
nRois = sum(numStat.nRoiPerFly,2);
nfly = sum(numStat.nRoiPerFly > 0,2);
nRoisPerFly = cell(4,1);
for tt = 1:1:4
    nRoisPerFly{tt} = numStat.nRoiPerFly(tt,numStat.nRoiPerFly(tt,:) > 0);
end

% plot each typeIndivudually...
subplotNumKernel = [1,2,3,4];
subplotNumGlider = [5,6,7,8];
subplotNumOpponency = [9,10,11,12];

% determine the limit for mean kernel
%%
maxValueKernel = 0;
maxValueGlider = 0;
maxValueOpponency = 0;
for tt = 1:1:nType
    meanKernelThisType = mean(meanKernel{tt},2);
    maxValueKernel = max(maxValueKernel,max(abs(meanKernelThisType(:))));
    meanGliderResp = mean(gliderResp{tt},2);
    maxValueGlider = max(maxValueGlider,max(abs(meanGliderResp(:)) * 1.7));
    meanOpponency = mean(skQuant{tt},2);
    maxValueOpponency = max(maxValueOpponency,max(abs(meanOpponency) * 1.7));
end

MakeFigure;
for tt = 1:1:nType
    % first, deal with the mean kernel
    %% second order kernel, plot all the things together...
    
    meanKernelThisType = mean(meanKernel{tt},2);
    subplot(3,4,subplotNumKernel(tt));
    quickViewOneKernel_Smooth(meanKernelThisType,2,'labelFlag',true,'posUnit',barWidth,'timeUnit',1/60,'limPreSetFlag',false,'maxValue',maxValueKernel,'colorbarFlag',false);
    title(typeStr{tt});
    %   % plot the contour on the mean filter...how are you going to do that?
    hold on
    FigPlot_SK_Utils_PlotContourOfIntegration(maxTau,dtMax,tMax,direction);
    hold off
    
    titleStrThisType = {[typeStr{tt},'  nRois:',num2str(sum(nRoisPerFly{tt})),' nfly:', num2str(length(nRoisPerFly{tt}))],...
        ['roisPerFly:',StrGeneration_KernelOrRoiPerFly(nRoisPerFly{tt}),]};
    title(titleStrThisType)
    
    % label the number of rois and flies for this kernel...
    %% sinewave;
    %     meanSineResp = mean(sineResp{tt},2);
    %     stdSineResp  = std(sineResp{tt},1,2);
    %     semSineResp = stdSineResp./sqrt(nNorm(tt));
    %     subplot(2,2,2);
    %     PlotXY_Juyue(omega,meanSineResp,'errorBarFlag',true,'sem',semSineResp);
    %     title('sinewave');
    %% glider response.
    meanGliderResp = mean(gliderResp{tt},2);
    stdGliderResp  = std(gliderResp{tt},1,2);
    semGliderResp = stdGliderResp./sqrt(nNorm(tt));
    subplot(3,4,subplotNumGlider(tt));
    PlotXY_Juyue(dt,meanGliderResp,'errorBarFlag',true,'sem',semGliderResp,'limPreSetFlag',limPreSetFlag,'maxValue', maxValueGlider);
    title('glider');
    
    % for glider response, you have to do Z test on whether individual
    % points is significant. label the p value, and label the significance,
    % use Z test, compare to 0....
    
    % z test here. change it to Wilcoxon rank sum test...
    
    %     gliderRespZ = (meanGliderResp - 0)./semGliderResp;
    %     gliderRespP = 2 * normcdf(-abs(gliderRespZ ),0,1);
    % it is wrong to use mean value. use the 
    gliderRespP = zeros(length(meanGliderResp),1);
    for ii = 1:1:length(meanGliderResp)
    gliderRespP(ii) = ranksum(gliderResp{tt}(ii,:),zeros(length(gliderResp{tt}(ii,:)),1));
    end
    alpha = 0.05;
    plotVerValue = 0.8  * maxValueGlider;
    FigPlot_SK_Utils_GliderSignificance(dt,gliderRespP,alpha,plotVerValue,false)
    
    
    %% opponency...
    meanOpponency = mean(skQuant{tt},2);
    stdOpponency = std(skQuant{tt},1,2);
    semOpponency = stdOpponency./sqrt(nNorm(tt));
    subplot(3,4,subplotNumOpponency(tt));
    BarXY_Juyue([1,2],meanOpponency,'errorBarFlag',true,'sem',semOpponency,'xTickStr',{'pro lobe','reg lobe'},'limPreSetFlag',limPreSetFlag, 'maxValue',maxValueOpponency);
    title('opponency');
    
    %     opponencyZ = (meanOpponency - 0)./ semOpponency;
    %     opponencyP = 2 * normcdf(-abs(opponencyZ),0,1);
    opponencyP = zeros(length(meanOpponency),1);
    for ii = 1:1:length(meanOpponency)
      opponencyP(ii) =  ranksum(skQuant{tt}(ii,:),zeros(length(skQuant{tt}(ii,:)),1)');
    end
    alpha = 0.05;
    plotVerValue = 0.8 *  maxValueOpponency;
    FigPlot_SK_Utils_OpponencySignificance([1,2],opponencyP,alpha,plotVerValue)
    
end

if saveFigFlag
    secondaryName = [num2str(barWidth),'_DX',num2str(dx),'_aveBy',aveBy];
    MySaveFig_Juyue(gcf,MainName, secondaryName ,'nFigSave',nFigSave,'fileType',figFileType);
end
end