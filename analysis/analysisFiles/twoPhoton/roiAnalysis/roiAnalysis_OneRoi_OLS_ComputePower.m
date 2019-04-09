function roi = roiAnalysis_OneRoi_OLS_ComputePower(roi)

S = GetSystemConfiguration;
kernelPath = S.kernelSavePath;
flickpath = [kernelPath,roi.stimInfo.flickPath];

roiNum = roi.stimInfo.roiNum;
[respData,stimData,stimIndexes,repCVFlag,repStimuIndInFrame] = GetStimResp_ReverseCorr(flickpath, roiNum);
repSegFlag = true;
% first order kernel.
dx = 1;
order = 1;
[maxTau,nMultiBars] = size(roi.filterInfo.firstKernel.Original);
OLSMat = tp_Compute_OLSMat_NonRepOrRep(respData,stimData,stimIndexes,repStimuIndInFrame,repSegFlag,'order',order,'dx',dx,'maxTau',maxTau,'nMultiBars',nMultiBars);
respRepByTrial = OLSMat.respByTrial{1};
predRespRepByTrial = roi.LM.firstOrder.predResp_L_ByTrial;
roi.LM.firstOrder.predPower  = roiAnalysis_OneRoi_RevCorr_Utils_ComputePredictivePower(respRepByTrial,predRespRepByTrial);
% second order kernel
order = 2;
maxTau = round(sqrt(size(roi.filterInfo.secondKernel.dx1.Original,1)));
% might be too slow... bad idea...
% [~,repData] = roiAnalysis_OneRoi_OLS_PrepareStimResp_NonRepAndRep(respData,stimData,stimIndexes,repStimuIndInFrame,order,dx,maxTau,1);

OLSMat = tp_Compute_OLSMat_NonRepOrRep(respData,stimData,stimIndexes,repStimuIndInFrame,repSegFlag,'order',order,'dx',dx,'maxTau',maxTau,'nMultiBars',nMultiBars);
respRepByTrial = OLSMat.respByTrial{1};
predRespRepByTrial = roi.LM.secondOrder.predResp_L_ByTrial;
roi.LM.secondOrder.predPower  = roiAnalysis_OneRoi_RevCorr_Utils_ComputePredictivePower(respRepByTrial,predRespRepByTrial);
% 1 and 2 kernel
respRepByTrial = roi.LM.firstPlusSecond.respRepByTrial;
predRespRepByTrial = roi.LM.firstPlusSecond.predResp_L_ByTrial;
roi.LM.firstPlusSecond.predPower  = roiAnalysis_OneRoi_RevCorr_Utils_ComputePredictivePower(respRepByTrial,predRespRepByTrial);

% power of signal and power of noise.
roi = roiAnalysis_OneRoi_RepSegAnalysis_Power(roi);

end