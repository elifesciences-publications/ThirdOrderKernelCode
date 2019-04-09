function FigPlot_SK_MeanDtSineWave_T5T4Blend(roiData,varargin)

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


dt = roiData{1}.simu.sK.glider.dt';
% omega = roiData{1}.simu.sK.sine.stim.omega';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end


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

typeStr = {'Pro','Reg'};
numStat = roiAnalysis_FlyRoiKernelStat(roiData);
nRois = sum(numStat.nRoiPerFly,2);
nfly = sum(numStat.nRoiPerFly > 0,2);
nRoisPerFly = cell(4,1);
for tt = 1:1:4
    nRoisPerFly{tt} = numStat.nRoiPerFly(tt,numStat.nRoiPerFly(tt,:) > 0);
end


nType = 2;
% plot each typeIndivudually...
subplotNumKernel = [1,4];
subplotNumGlider = [2,5];
subplotNumOpponency = [3,6];

meanKernelT4T5 = {cat(2,meanKernel{1},meanKernel{3});cat(2,meanKernel{2},meanKernel{4})};
gliderRespT4T5 = {cat(2,gliderResp{1},gliderResp{3});cat(2,gliderResp{2},gliderResp{4})};
skQuantT4T5 = {cat(2,skQuant{1},skQuant{3});cat(2,skQuant{2},skQuant{4})};
nRoisPerFlyT4T5 = {cat(2,nRoisPerFly{1},nRoisPerFly{3});cat(2,nRoisPerFly{2},nRoisPerFly{4})};

% determine the limit for mean kernel
%%
maxValueKernel = 0;
maxValueGlider = 0;
maxValueOpponency = 0;
for tt = 1:1:nType
    meanKernelThisType = mean(meanKernelT4T5{tt},2);
    maxValueKernel = max(maxValueKernel,max(abs(meanKernelThisType(:))));
    meanGliderResp = mean(gliderRespT4T5{tt},2);
    maxValueGlider = max(maxValueGlider,max(abs(meanGliderResp(:)) * 1.7));
    meanOpponency = mean(skQuantT4T5{tt},2);
    maxValueOpponency = max(maxValueOpponency,max(abs(meanOpponency) * 1.7));
end
limPreSetFlag = true;
MakeFigure;

% there are only two types, not four types from this point. 
% progressive and regressive. 



for tt = 1:1:nType
    % first, deal with the mean kernel
    %% second order kernel, plot all the things together...
    
    meanKernelThisType = mean(meanKernelT4T5{tt},2);
    subplot(2,3,subplotNumKernel(tt));
    quickViewOneKernel_Smooth(meanKernelThisType,2,'labelFlag',true,'posUnit',barWidth,'timeUnit',1/60,'limPreSetFlag',false,'maxValue',maxValueKernel,'colorbarFlag',false);
    title(typeStr{tt});
    %   % plot the contour on the mean filter...how are you going to do that?
    hold on
    FigPlot_SK_Utils_PlotContourOfIntegration(maxTau,dtMax,tMax,direction);
    hold off
    
    titleStrThisType = {[typeStr{tt},'  nRois:',num2str(sum(nRoisPerFlyT4T5{tt})),' nfly:', num2str(length(nRoisPerFlyT4T5{tt}))],...
        ['roisPerFly:',StrGeneration_KernelOrRoiPerFly(nRoisPerFlyT4T5{tt}),]};
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
    meanGliderResp = mean(gliderRespT4T5{tt},2);
    stdGliderResp  = std(gliderRespT4T5{tt},1,2);
    semGliderResp = stdGliderResp./sqrt(nNorm(tt));
    subplot(2,3,subplotNumGlider(tt));
    PlotXY_Juyue(dt,meanGliderResp,'errorBarFlag',true,'sem',semGliderResp,'limPreSetFlag',limPreSetFlag,'maxValue', maxValueGlider);
    title('glider');
    
    % for glider response, you have to do Z test on whether individual
    % points is significant. label the p value, and label the significance,
    % use Z test, compare to 0....
    gliderRespZ = (meanGliderResp - 0)./semGliderResp;
    gliderRespP = 2 * normcdf(-abs(gliderRespZ ),0,1);
    alpha = 0.05;
    plotVerValue = 0.8  * maxValueGlider;
    FigPlot_SK_Utils_GliderSignificance(dt,gliderRespP,alpha,plotVerValue,false)
    
    
    %% opponency...
    meanOpponency = mean(skQuantT4T5{tt},2);
    stdOpponency = std(skQuantT4T5{tt},1,2);
    semOpponency = stdOpponency./sqrt(nNorm(tt));
    subplot(2,3,subplotNumOpponency(tt));
    BarXY_Juyue([1,2],meanOpponency,'errorBarFlag',true,'sem',semOpponency,'xTickStr',{'pro lobe','reg lobe'},'limPreSetFlag',limPreSetFlag, 'maxValue',maxValueOpponency);
    title('opponency');
    
    opponencyZ = (meanOpponency - 0)./ semOpponency;
    opponencyP = 2 * normcdf(-abs(opponencyZ),0,1);
    alpha = 0.05;
    plotVerValue = 0.8 *  maxValueOpponency;
    FigPlot_SK_Utils_OpponencySignificance([1,2],opponencyP,alpha,plotVerValue)
    
end

if saveFigFlag
    secondaryName = [num2str(barWidth),'_DX',num2str(dx),'_aveBy',aveBy];
    MySaveFig_Juyue(gcf,MainName, secondaryName ,'nFigSave',nFigSave,'fileType',figFileType);
end
end