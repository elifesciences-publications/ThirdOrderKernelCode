function roi = roiAnalysis_OneRoi_RepSegAnalysis_Power(roi)
[respFull,respRepByTrial,respRepByTrialTimeLag,~,~] = roiAnalysis_OneRoi_getResponseRepSeg(roi);

% S = GetSystemConfiguration;
% kernelPath = S.kernelSavePath;
% flickpath = [kernelPath,roi.stimInfo.flickPath];
% this is for simulated data...
% [~,~,~,~,repStimuIndInFram,~,respNoiselessUpSampled] = GetStimResp_ReverseCorr(flickpath, roi.stimInfo.roiNum);
% respNoiselessUpSampledRep = respNoiselessUpSampled(repStimuIndInFram(61:end,1)); % reshape;
% powerSignal = var(respNoiselessUpSampledRep,0);

% you might be interested in the short version? okay...
[powerSignalEst,powerNoiseEst,V] = roiAnalysis_OneRoi_RepSegAnalysis_Power_Utils_SigPower(respRepByTrial,respRepByTrialTimeLag,'nonInterp');

% estimate the power of noise... how do you do that? power of the response,
% minus the power of the signal.

roi.repSegInfo.power.estSignal = powerSignalEst;
roi.repSegInfo.power.estSignalError = V;
% roi.repSegInfo.power.signal = powerSignal;
roi.repSegInfo.power.noise = powerNoiseEst;

% work work work...
end