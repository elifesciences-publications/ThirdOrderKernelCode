function FigPlot_PlotDtSweepForIndividualKernels(roiData,folderStr,saveFigFlag,varargin)
smoothFlag = false;
limPreSetFlag = false;
dx = 1;
barUseBank = {[8,9,10,11,12],[7,8,9,10,11],[8,9,10,11,12],[7,8,9,10,11]};
MainName = '2o_Kernel_dt_Individual';
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
% plot the individual kernels.
dtLength = length(roiData{1}.simu.sK.glider.dt);
dt = reshape(roiData{1}.simu.sK.glider.dt,[dtLength,1]);
[meanKernel,norm] = roiAnalysis_AverageFunction_OverFly_IndividualBars(roiData,'whichValue','secondKernel','dx',dx,'kernelTypeUse',[1,2,3],...
    'normRoiFlag',false);
[meanGlider,norm] = roiAnalysis_AverageFunction_OverFly_IndividualBars(roiData,'whichValue','glider','dx',dx,'kernelTypeUse',[1,2,3],...
    'normRoiFlag',false,'normKernelFlag',normKernelFlag);
% glider response should be higher....
% try to get this 10000 glider response out... there should be 10000 of
% them, the data stucture is totally messed up. noooo you are good!
[shuffleGlider,norm] = roiAnalysis_AverageFunction_OverFly_IndividualBars(roiData,'whichValue','shuffleGlider','dx',dx,'kernelTypeUse',[1,2,3],...
    'normRoiFlag',normRoiFlag,'normKernelFlag',normKernelFlag);
% you can have a mean distribution here.
[meanKernel,norm] = roiAnalysis_AverageFunction_OverFly_IndividualBars(roiData,'whichValue','firstKernel','kernelTypeUse',[1,2,3],...
    'normRoiFlag',false,'normKernelFlag',false);
numStat = roiAnalysis_FlyRoiKernelStat(roiData);
MakeFigure;
% tune them in the same way....
maxValueFirst = zeros(nType,1);
for tt = 1:1:nType
    meanKernelThisType = mean(meanKernel{tt},3);
    maxValueFirst(tt) = max(abs(meanKernelThisType(:)));
end
for tt = 1:1:nType
    subplot(6,4,tt);
    meanKernelThisType = mean(meanKernel{tt},3);
    quickViewOneKernel_Smooth(meanKernelThisType,1,'labelFlag',true,'posUnit',barWidth,'timeUnit',1/60,'cutFilterFlag',false,...
        'limPreSetFlag',limPreSetFlag,'maxValue',prctile(maxValueFirst,60));
    % you will get the max value and set it to whatever you want...
    titleStrThisType = {[typeStr{tt},' nfly:', num2str(norm(tt)),' nRoi:', num2str(numStat.nFirstKernelPerType(tt))]};
    title(titleStrThisType);
end

for tt = 1:1:nType
    for qq = 1:1:length(barUseBank{tt})
        subplot(6,4,qq  * 4 + tt);
        barUse = barUseBank{tt}(qq);
        
        meanGliderRespThisType = mean(meanGlider{tt},3);
        meanGliderRespOverBars = meanGliderRespThisType(:,barUseBank{tt}( qq));
        
        gliderRespOverBarsFirst = mean(meanGlider{tt}(:,barUseBank{tt}( qq),:),2);
        stdGliderResp  = std(gliderRespOverBarsFirst,1,3);
        semGliderResp = stdGliderResp./sqrt(norm(tt));
        
        % set the lim.
        PlotXY_Juyue(dt,meanGliderRespOverBars,'errorBarFlag',true,'sem',semGliderResp ,'limPreSetFlag',false,'maxValue',15,...
            'colorMean',[1,0,0],'colorError',[1,0,0]);
        title(['bar',num2str(barUse),'&',num2str(MyMode(barUse + dx,20))]);
%         uncorrelatedResponse = dum(); % first order, second order??
        % both dx = 1 and dx = 2...
    end
    
    
    %     meanGliderRespThisType = mean(meanGlider{tt},3);
    %     meanGliderRespOverBars = mean(meanGliderRespThisType(:,barUseBank{tt}),2);
    %     gliderRespOverBarsFirst = mean(meanGlider{tt}(:,barUseBank{tt},:),2);
    %     stdGliderResp  = std(gliderRespOverBarsFirst,1,3);
    %     semGliderResp = stdGliderResp./sqrt(norm(tt));
    %     maxValue = 0;
    %     % set the lim.
    %     PlotXY_Juyue(dt,meanGliderRespOverBars,'errorBarFlag',true,'sem',semGliderResp ,'limPreSetFlag',true,'maxValue',15,...
    %         'colorMean',[1,0,0],'colorError',[1,0,0]);
    %
    % in order to estimate the the error bar, do the average over bars
    % first.
    
    %     shuffleGliderMeanOverFly = mean(shuffleGlider{tt},3);
    %     shuffleGliderMean = mean(shuffleGliderMeanOverFly,2);
    %     shuffleGliderStd = std(shuffleGliderMeanOverFly,1,2);
    %     % the unit of glider response and shuttle should be the same!
    %     % change the unit of glider response.
    %     stimHz = 60; timeUnit = 1/stimHz;
    %     shuffleGliderMean = shuffleGliderMean/(timeUnit ^2);
    %     shuffleGliderStd = shuffleGliderStd/(timeUnit ^2);
    %     zGlider = (meanGliderRespOverBars - shuffleGliderMean)./shuffleGliderStd;
    %     % one tail or two tail... two tail.
    %     pGlider = 1 - normcdf(abs(zGlider)); pGlider  = 2 * pGlider;
    %     alpha = 0.05;
    %     plotVerValue = 0.8  * max(meanGliderRespOverBars);
    %     hold on; plot(dt,shuffleGliderStd,'b--'); plot(dt,-shuffleGliderStd,'b--');
    %     FigPlot_SK_Utils_GliderSignificance(dt,pGlider,alpha,plotVerValue,false)
end
if saveFigFlag
    MySaveFig_Juyue(gcf,MainName,['dx',num2str(dx)] ,'nFigSave',nFigSave,'fileType',figFileType);
end
cd(currFolder)
% you are so tired and hungry...
end
