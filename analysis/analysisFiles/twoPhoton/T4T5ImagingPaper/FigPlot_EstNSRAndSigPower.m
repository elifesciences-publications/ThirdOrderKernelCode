function FigPlot_EstNSRAndSigPower(roiData)

varExplained = cellfun(@(roi) mean(roi.repSegInfo.varExplainedByMeanNonInterp),roiData);
nanData = isnan(varExplained);
roiData(nanData) = [];
varExplained = cellfun(@(roi) mean(roi.repSegInfo.varExplainedByMeanNonInterp),roiData);

%%
load('D:\kernels\T4T5_Imaging_Paper\simulation\processed\firstAndSecond\simuDatafirstAndSecond8.mat');
roiDataSimu_LM = roiDataSimu_LM(1:end - 1);
% compute the power....
nRoi = length(roiDataSimu_LM);
for rr = 1:1:nRoi % do you want to compute this for them? properly, other wise, you have to compute this everyt
roiDataSimu_LM{rr} = roiAnalysis_OneRoi_RepSegAnalysis_Power(roiDataSimu_LM{rr});
end
% it takes some time. so store it?
%
roi = roiDataSimu_LM{1};
[respInterp,respRepByTrial,respRepByTrialTimeLag,respRepByTrialShort,respRepByTrialTimeLagShort] = roiAnalysis_OneRoi_getResponseRepSeg(roi);
nSeg = size(respInterp,2);
S = GetSystemConfiguration;
kernelPath = S.kernelSavePath;
flickpath = [kernelPath,roi.stimInfo.flickPath];
[respData,stimData,stimIndexes,repCVFlag,repStimuIndInFram,respNoiseless,respNoiselessUpSampled] = GetStimResp_ReverseCorr(flickpath, roi.stimInfo.roiNum);
respNoiselessUpSampledRep = respNoiselessUpSampled(repStimuIndInFram(:,1)); % reshape;

nSamples = 200;
nSamplePerPoint = 20;
nSampleNSRPoint = 10;

nsrVec = cellfun(@(roi) roi.simuInfo.reciprocalSNR, roiDataSimu_LM);
nsr = reshape(nsrVec,[nSamplePerPoint,nSampleNSRPoint]);
nsr  = nsr(1,:);

powerSignal = var(respNoiselessUpSampledRep,0) *ones(length(nsr),1 ); % biased estimation.
estPowerSignalVec = cellfun(@(roi) roi.repSegInfo.power.estSignal,roiDataSimu_LM);

%%
MakeFigure;
subplot(221)

h = histogram(varExplained); hold on 
h.Normalization = 'probability';
meanCorrMeanRespAtRepSeg = mean(varExplained);
yLim = get(gca,'yLim');
plot([meanCorrMeanRespAtRepSeg,meanCorrMeanRespAtRepSeg],yLim,'b','lineWidth',5);
xlabel('corr(estimated mean from Nth trial,resp of N+1 trial)');
ylabel('frequency');

subplot(223)
corrTheoreticalLine = 1./(sqrt(1 + nsr.^2) .* sqrt(1 + nsr.^2/(3.8673))); % this should be theoretical line...? is that true...
plot(corrTheoreticalLine,1./nsr.^2,'r'); hold on
% maybe just draw the theretical line, and do not show that? 
set(gca,'xscale','log');
set(gca,'yscale','log');
xlabel('corr(estimated mean from Nth trial,resp of N+1 trial)');
ylabel('SNR : power(signal)\power(noise)');
nsrForRealData = fsolve(@(x)(1./(sqrt(1 + x.^2) .* sqrt(1 + x.^2/(3.8673))) - meanCorrMeanRespAtRepSeg),10);
scatter(meanCorrMeanRespAtRepSeg,1/nsrForRealData^2,'b+');
text(meanCorrMeanRespAtRepSeg,1/nsrForRealData^2,['snr : ',num2str(1/nsrForRealData^2),' r : ',num2str(meanCorrMeanRespAtRepSeg)],'FontSize',10)

LProperty.Location = 'northeast';
axis tight

subplot(222)
scatter(1./nsrVec.^2,estPowerSignalVec,'filled'); hold on
scatter(1./nsrVec.^2,powerSignal(1) * ones(length(nsrVec),1),'filled');
set(gca,'xscale','log');
xlabel('SNR : power(signal)\power(noise)');
ylabel('estimated signal power');
legend('estimated power of the signal','power of the signal')
axis tight
plot([1./nsrForRealData^2,1./nsrForRealData^2],get(gca,'YLim'),'b','lineWidth',5);
% also plot here where we were?

end