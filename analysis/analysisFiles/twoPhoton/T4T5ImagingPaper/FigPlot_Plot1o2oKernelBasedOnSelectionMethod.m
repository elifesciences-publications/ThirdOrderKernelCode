function FigPlot_Plot1o2oKernelBasedOnSelectionMethod(roiData,folderStr,saveFigFlag,varargin)
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
%% first order kernel
figFileType = {'fig'};
nFigSave = 1;
nType = 4;
meanKernel = FigPlot_FK_MeanKernel(roiData,'aveBy','fly','kernelTypeUse',[3],'normRoiFlag',false,'MainName','1o_',...
    'saveFigFlag',saveFigFlag,'figFileType',figFileType,'nFigSave',nFigSave,'smoothFlag',smoothFlag);
typeBank = {'T4 Pro','T4 Reg','T5 Pro','T5 Reg'};
% for tt = 1:1:4
%     % do you also want to plot them out, that would be a really nice plot
%     try
%         quickViewKernelsFirst(meanKernel{tt},'subplotHt',4);
%         if saveFigFlag
%             MySaveFig_Juyue(gcf,'1o_Individual_Kernel_' ,typeBank{tt},'nFigSave',nFigSave,'fileType',figFileType);
%         end
%     catch
%     end
% end

% plot the average
% what is wrong here, why it is so bad?
% %% plot the average
% % what is wrong here, why it is so bad?
barUseBank = {[9,10,11,12],[8,9,10,11],[9,10,11,12],[8,9,10,11]};
dtLength = length(roiData{1}.simu.sK.glider.dt);
dt = reshape(roiData{1}.simu.sK.glider.dt,[dtLength,1]);
for dx = 1:1:2
    MakeFigure;
    [meanGlider,norm] = roiAnalysis_AverageFunction_OverFly_IndividualBars(roiData,'whichValue','glider','dx',dx,'kernelTypeUse',[1,2,3],...
        'normRoiFlag',false,'normKernelFlag',normKernelFlag);

    for tt = 1:1:nType
        subplot(4,5,1 + (tt - 1)*5);
        % averaged kernel over several bars, but not
        meanGliderRespThisType = mean(meanGlider{tt},3); % all 20 of them
        meanGliderRespOverBars = mean(meanGliderRespThisType(:,barUseBank{tt}),2);

        % in order to estimate the the error bar, do the average over bars
        % first.
        gliderRespOverBarsFirst = mean(meanGlider{tt}(:,barUseBank{tt},:),2);
        stdGliderResp  = std(gliderRespOverBarsFirst,1,3);
        semGliderResp = stdGliderResp./sqrt(norm(tt));
        maxValue = 0;
        PlotXY_Juyue(dt,meanGliderRespOverBars,'errorBarFlag',true,'sem',semGliderResp ,'limPreSetFlag',false,'maxValue',maxValue * 1.5,...
            'colorMean',[1,0,0],'colorError',[1,0,0]);
%         FigPlot_SK_Utils_GliderSignificance(dt,meanGliderRespOverBars,alpha,plotVerValue,false)
        title([typeBank{tt},' Mean 2o Kernel']);
        for qq = 1:1:4
            subplot(4,5,1 + qq + (tt - 1) * 5);
            PlotXY_Juyue(dt, meanGliderRespThisType(:,barUseBank{tt}(qq)),'errorBarFlag',false,'sem',semGliderResp ,'limPreSetFlag',false,'maxValue',maxValue * 1.5,...
            'colorMean',[1,0,0],'colorError',[1,0,0]);
        end

    end
end
barUseBank = {[9,10,11,12],[8,9,10,11],[9,10,11,12],[8,9,10,11]};
dtLength = length(roiData{1}.simu.sK.glider.dt);
dt = reshape(roiData{1}.simu.sK.glider.dt,[dtLength,1]);
for dx = 1:1:2
    MakeFigure;
    [meanGlider,norm] = roiAnalysis_AverageFunction_OverFly_IndividualBars(roiData,'whichValue','glider','dx',dx,'kernelTypeUse',[1,2,3],...
        'normRoiFlag',false,'normKernelFlag',normKernelFlag);

    for tt = 1:1:nType
        subplot(4,5,1 + (tt - 1)*5);
        % averaged kernel over several bars, but not
        meanGliderRespThisType = mean(meanGlider{tt},3); % all 20 of them
        meanGliderRespOverBars = mean(meanGliderRespThisType(:,barUseBank{tt}),2);

        % in order to estimate the the error bar, do the average over bars
        % first.
        gliderRespOverBarsFirst = mean(meanGlider{tt}(:,barUseBank{tt},:),2);
        stdGliderResp  = std(gliderRespOverBarsFirst,1,3);
        semGliderResp = stdGliderResp./sqrt(norm(tt));
        maxValue = 0;
        PlotXY_Juyue(dt,meanGliderRespOverBars,'errorBarFlag',true,'sem',semGliderResp ,'limPreSetFlag',false,'maxValue',maxValue * 1.5,...
            'colorMean',[1,0,0],'colorError',[1,0,0]);
%         FigPlot_SK_Utils_GliderSignificance(dt,meanGliderRespOverBars,alpha,plotVerValue,false)
        title([typeBank{tt},' Mean 2o Kernel']);
        for qq = 1:1:4
            subplot(4,5,1 + qq + (tt - 1) * 5);
            PlotXY_Juyue(dt, meanGliderRespThisType(:,barUseBank{tt}(qq)),'errorBarFlag',false,'sem',semGliderResp ,'limPreSetFlag',false,'maxValue',maxValue * 1.5,...
            'colorMean',[1,0,0],'colorError',[1,0,0]);
        end

    end
end
% %% plot the everything for the fly selected... predictive power first/second scatter plot. beta. signal power. noise power. several summary plot...easy!
% % first, get the noise and signal....
% predictivePowerStrBank = {'predPower1o','predPower2o','predPower1o+2o','predPower-Poly','predPower-Rec'};
% nModel = 5;
% predictivePower  = cell(nModel,1);
% for nn = 1:1:nModel
%     [predictivePower{nn},norm] = roiAnalysis_AverageFunction_OverFly_IndividualBars(roiData,'whichValue',predictivePowerStrBank{nn},'kernelTypeUse',3,...
%         'normRoiFlag',false);
% end
% powerStrBank = {'signalPower','noisePower'};
% nPower = 2;
% powerSignalNoise = cell(nPower,1);
% for nn = 1:1:nPower
%     [powerSignalNoise{nn},norm] = roiAnalysis_AverageFunction_OverFly_IndividualBars(roiData,'whichValue',powerStrBank{nn},'kernelTypeUse',3,...
%         'normRoiFlag',false);
% end
%
% predictivePowerEachType = cell(4,1); %
% powerSignalNoiseEachType = cell(4,1);
% ratioEachType = cell(4,1);
% nType = 4;
% for tt = 1:1:nType
%     % four each cell type, there would be a value data matrix.
%     predictivePowerEachType{tt} = zeros(norm(tt),nModel);
%     for nn = 1:1:nModel
%         predictivePowerEachType{tt}(:,nn) = squeeze(predictivePower{nn}{tt});
%     end
%     powerSignalNoiseEachType{tt} = zeros(norm(tt),nPower);
%     for nn = 1:1:nPower
%         powerSignalNoiseEachType{tt}(:,nn) = squeeze(powerSignalNoise{nn}{tt});
%     end
%     ratioEachType{tt} = bsxfun(@rdivide,predictivePowerEachType{tt}, powerSignalNoiseEachType{tt}(:,1));
% end
% typeBank = {'T4 Pro','T4 Reg','T5 Pro','T5 Reg'};
% MakeFigure;
% for tt = 1:1:nType
%     subplot(5,4,tt);
%     % judge wether there is negative number...
%     titleStr = typeBank{tt};
% %     if sum(sum(predictivePowerEachType{tt} < 0))
% %         titleStr = [typeBank{tt},'  Negative'];
% %     else
% %         titleStr = [typeBank{tt}];
% %     end
%     FigPlot_ScatterPlot_Corr(predictivePowerEachType{tt},'xTickStr',{'1o','2o','LN-Poly','LN-Rec','1o+2o'},'yLabelStr','predictive power','titleStr',titleStr,...
%         'limPreSetNeg',false,'logScaleFlag',false);
%     subplot(5,4,tt + 4);
% %     if sum(sum(ratioEachType{tt} < 0))
% %         titleStr = [typeBank{tt},'  Negative'];
% %     else
% %         titleStr = [typeBank{tt}];
% %     end
%     FigPlot_ScatterPlot_Corr(ratioEachType{tt},'xTickStr',{'1o','2o','LN-Poly','LN-Rec','1o+2o'},'yLabelStr','predictive power/signal power','titleStr',titleStr,...
%         'limPreSetNeg',false,'logScaleFlag',false);
%     subplot(5,4,tt + 8);
%
% %     if sum(sum(powerSignalNoiseEachType{tt}(:,1) < 0))
% %         titleStr = [typeBank{tt},'  Negative'];
% %     else
% %         titleStr = [typeBank{tt}];
% %     end
%     FigPlot_ScatterPlot_Corr(powerSignalNoiseEachType{tt}(:,1),'xTickStr',{'signal power'},'yLabelStr','','titleStr',titleStr,...
%         'limPreSetNeg',false,'logScaleFlag',false);
%
%     subplot(5,4,tt + 12);
% %     if sum(sum(powerSignalNoiseEachType{tt}(:,2) < 0))
% %         titleStr = [typeBank{tt},'  Negative'];
% %     else
% %         titleStr = [typeBank{tt}];
% %     end
%     FigPlot_ScatterPlot_Corr(powerSignalNoiseEachType{tt}(:,2),'xTickStr',{'noise power'},'yLabelStr','','titleStr',titleStr,...
%         'limPreSetNeg',false,'logScaleFlag',false);
%
%     subplot(5,4,tt + 16);
% %     if sum(sum(powerSignalNoiseEachType{tt}(:,2) < 0))
% %         titleStr = [typeBank{tt},'  Negative'];
% %     else
% %         titleStr = [typeBank{tt}];
% %     end
%     FigPlot_ScatterPlot_Corr(powerSignalNoiseEachType{tt}(:,1)./powerSignalNoiseEachType{tt}(:,2),'xTickStr',{'signal power / noise power'},'yLabelStr','','titleStr',titleStr,...
%         'limPreSetNeg',false,'logScaleFlag',false);
%
% end
% if saveFigFlag
%     MySaveFig_Juyue(gcf,'Power' ,'PredictiveAndSignal','nFigSave',nFigSave,'fileType',figFileType);
% end
%

% %% glider resposne. final result.(Is this a good way to do it?)
% % get the glider response. you should calculate it before it gets into
% % also do something else for sure...
%
% %
cd(currFolder)
% you are so tired and hungry...
end
