% first, load the data.
clear
clc
% roiMethodType = 'ICA_NNMF_LN_DFFOnlyOnWhiteNoise';
tic
% roiMethodType = 'ICA_NNMF_InterpResp_InformByNon_1oKernelSelected';
roiMethodType = 'ICA_NNMF_LN_DFFOnlyOnWhiteNoise_1o2oKernelSelected_NoCov_Glider_StillTrace';
stimulusType = '5B';
roiData = getData_Juyue(stimulusType,roiMethodType);
isnanVar = isnan(cellfun(@(roi) mean(roi.repSegInfo.varExplainedByMeanNonInterp),roiData));
roiData(isnanVar) = [];
load('D:\kernels\T4T5_Imaging_Paper\simulation\processed\firstAndSecond\simuDatafirstAndSecond8.mat');
roiDataSimu_LM = roiDataSimu_LM(1:end - 1);
% compute the power....
nRoi = length(roiDataSimu_LM);
for rr = 1:1:nRoi
roiDataSimu_LM{rr} = roiAnalysis_OneRoi_RepSegAnalysis_Power(roiDataSimu_LM{rr});
end
roiSelectedEdgeTrace = Main_AnlyzeAllFly_Utils_GetRoiSelectedEdgeAnaTrace(roiData);
pFirst = cellfun(@(roi)roi.filterInfo.firstKernel.ZTest.p,roiData);
roiSelected = roiSelectedEdgeTrace & pFirst < 0.0025;
varExp = cellfun(@(roi) mean(roi.repSegInfo.varExplainedByMeanNonInterp),roiData);
%%
roi = roiDataSimu_LM{1};
[respInterp,respRepByTrial,respRepByTrialTimeLag,respRepByTrialShort,respRepByTrialTimeLagShort] = roiAnalysis_OneRoi_getResponseRepSeg(roi);
nSeg = size(respInterp,2);
S = GetSystemConfiguration;
kernelPath = S.kernelSavePath;
flickpath = [kernelPath,roi.stimInfo.flickPath];
[respData,stimData,stimIndexes,repCVFlag,repStimuIndInFram,respNoiseless,respNoiselessUpSampled] = GetStimResp_ReverseCorr(flickpath, roi.stimInfo.roiNum);
respNoiselessUpSampledRep = respNoiselessUpSampled(repStimuIndInFram(:,1)); % reshape;
T = length(respNoiselessUpSampledRep);
%%
% first, reshape everything...
nSamples = 200;
nSamplePerPoint = 20;
nSampleNSRPoint = 10;
%%
nsrVec = cellfun(@(roi) roi.simuInfo.reciprocalSNR, roiDataSimu_LM);
nsr = reshape(nsrVec,[nSamplePerPoint,nSampleNSRPoint]);
nsr  = nsr(1,:);

varExplainedSimuVec = cellfun(@(roi) mean(roi.repSegInfo.varExplainedByMeanNonInterp),roiDataSimu_LM);
varExplainedSimu = reshape(varExplainedSimuVec,[nSamplePerPoint,nSampleNSRPoint])';
varExplainedSimuMean = mean(varExplainedSimu,2);
varExplainedSimuSem = std(varExplainedSimu,0,2)./sqrt(nSamplePerPoint);

powerSignal = var(respNoiselessUpSampledRep,0) *ones(length(nsr),1 ); % biased estimation.

estPowerSignalVec = cellfun(@(roi) roi.repSegInfo.power.estSignal,roiDataSimu_LM);
estPowerSignal  = reshape(estPowerSignalVec ,[nSamplePerPoint,nSampleNSRPoint])';
estPowerSignalMean = mean(estPowerSignal,2);
estPowerSignalSem = std(estPowerSignal,0,2);

noiseSignalVec = cellfun(@(roi) roi.repSegInfo.power.noise, roiDataSimu_LM);
estNoisePowerSignal  = reshape(noiseSignalVec,[nSamplePerPoint,nSampleNSRPoint])';
estNoiseMean = mean(estNoisePowerSignal   ,2);
noiseSignal = std(estNoisePowerSignal   ,0,2);
%%

MakeFigure;
subplot(221)
h = cell(2,1);
h{1} = histogram(varExp); hold on
title('all our data');
h{2} =histogram(varExp(roiSelected));
Histogram_Untils_SetBinWidthLimitsTheSame(h,'normByProbabilityFlag',true);
legend('all Roi','selected roi');
meanCorrMeanRespAtRepSeg = mean(varExp);
meanCorrMeanRespAtRepSegSel = mean(varExp(roiSelected));
yLim = get(gca,'yLim');
plot([meanCorrMeanRespAtRepSeg,meanCorrMeanRespAtRepSeg],yLim,'b');
plot([meanCorrMeanRespAtRepSegSel,meanCorrMeanRespAtRepSegSel],yLim,'r');
xlabel('corr(mean resp,resp)');

% Scatter Version
subplot(222)
corrTheoreticalLine = 1./(sqrt(1 +nsrVec.^2) .* sqrt(1 + nsrVec.^2/(3.8673))); % this should be theoretical line...? is that true...
scatter(nsrVec,varExplainedSimuVec,'filled'); hold on
scatter(nsrVec,corrTheoreticalLine,'filled'); 
set(gca,'xscale','log');
set(gca,'yscale','log');
xlabel('NSR : std(noise)/std(signal)');
ylabel('corr(mean resp,resp)');
legend('1/(sqrt(1 + nsr^2)*(1 + nsr^2/3.8673))','corr(mean resp,resp)');
LProperty.Location = 'northeast';

xlabel('NSR : std(noise)/std(signal)');
ylabel('corr(mean resp,resp)');
legend('corr(mean resp,resp)','1/(sqrt(1 + nsr^2)*(1 + nsr^2/3.8673))');
LProperty.Location = 'northeast';
% plot the line you want/
xLim = get(gca, 'XLim');
yLim = get(gca,'yLim');
% find out the x lim... and find out what is the y.

% where is the nsr?
corrTheoEq = @(x)(1./(sqrt(1 + x.^2) .* sqrt(1 + x.^2/(3.8673))) - meanCorrMeanRespAtRepSeg);
nsrForRealData = fsolve(@(x)(1./(sqrt(1 + x.^2) .* sqrt(1 + x.^2/(3.8673))) - meanCorrMeanRespAtRepSeg),10);
nsrForREalDataSel = fsolve(@(x)(1./(sqrt(1 + x.^2) .* sqrt(1 + x.^2/(3.8673))) - meanCorrMeanRespAtRepSegSel),10);

set(gca,'xscale','log');
set(gca,'yscale','log');
% also write the text there/?
% plot([nsrForRealData,nsrForRealData],yLim,'b-');
% plot([nsrForREalDataSel,nsrForREalDataSel],yLim,'r-');
% plot(xLim,[meanCorrMeanRespAtRepSeg,meanCorrMeanRespAtRepSeg],'b-');
% plot(xLim,[meanCorrMeanRespAtRepSegSel,meanCorrMeanRespAtRepSegSel],'r-');
scatter(nsrForRealData,meanCorrMeanRespAtRepSeg,'b+');
scatter(nsrForREalDataSel,meanCorrMeanRespAtRepSegSel,'r+');

text(nsrForRealData,meanCorrMeanRespAtRepSeg,['nsr : ',num2str(nsrForRealData),' r : ',num2str(meanCorrMeanRespAtRepSeg)],'FontSize',10)
text(nsrForREalDataSel,meanCorrMeanRespAtRepSegSel,['nsr : ',num2str(nsrForREalDataSel),' r : ',num2str(meanCorrMeanRespAtRepSegSel)],'FontSize',10)

subplot(223)
scatter(nsrVec,estPowerSignalVec,'filled'); hold on
scatter(nsrVec,powerSignal(1) * ones(length(nsrVec),1),'filled');
set(gca,'xscale','log');
xlabel('NSR : std(noise)/std(signal)');
ylabel('estimated signal power');
legend('estimated power of the signal','power of the signal')



% load the 


