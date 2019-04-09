function roi = roiAnalysis_OneRoi_RevCorr_R_1o2o_Combine(roi)
% first, get the response and predicted response from the first order
% kernel.
predByTrialFirst = roi.LM.firstOrder.predResp_L_ByTrial;
predByTrialSecond = roi.LM.secondOrder.predResp_L_ByTrial;
respByTrial = roi.LM.firstOrder.respRepByTrial;
nSeg = length(predByTrialFirst);

predByTrialFirstAlign = cell(nSeg,1);
predByTrialSecondAlign = cell(nSeg,1);
respByTrialAlign = cell(nSeg,1);
predAlignedFirstPlusSecond = cell(nSeg,1);
%%
nT = round(13.5 * 60); % hard warded
for ss = 1:1:nSeg
    predByTrialFirstAlign{ss} = predByTrialFirst{ss}(end - nT:end);
    predByTrialSecondAlign{ss} =predByTrialSecond{ss}(end - nT:end);
    respByTrialAlign{ss} =respByTrial {ss}(end - nT:end);
    predAlignedFirstPlusSecond{ss} = predByTrialFirstAlign{ss} + predByTrialSecondAlign{ss};
end


ana.predResp_L_ByTrial = predAlignedFirstPlusSecond;
ana.respRepByTrial = respByTrialAlign;

ana.r1o2o = roiAnalysis_OneRoi_RevCorr_Utils_ComputeCorr(respByTrialAlign,predAlignedFirstPlusSecond);
ana.predPower1o2o = roiAnalysis_OneRoi_RevCorr_Utils_ComputePredictivePower(respByTrialAlign,predAlignedFirstPlusSecond);


roi.LM.firstPlusSecond = ana;
end