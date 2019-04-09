function roi = roiAnalysis_OneRoi_OLS_R_1o2o_Combine(roi)
% first, get the response and predicted response from the first order
% kernel.
predByTrialFirst = roi.LM.firstOrder.predResp_L_ByTrial;
respByTrialFirst = roi.LM.firstOrder.respRepByTrial;
relativeTimeFirst = roi.LM.firstOrder.respRepByTrialTimeLag;

predByTrialSecond = roi.LM.secondOrder.predResp_L_ByTrial;
respBtTrialSecond = roi.LM.secondOrder.respRepByTrial;
relativeTimeSecond = roi.LM.secondOrder.respRepByTrialTimeLag;
% relativeTimeSecond = [zeros(4,length);relativeTimeSecond ];
% compare the relativ
nSeg = length(predByTrialFirst);
respAligned = [];
% respAlignedFirst = [];
% respAlignedSecond = [];
predAlignedFirst = [];
predAlignedSecond = [];
predByTrialCombine = cell(nSeg,1);
respByTrialCombine = cell(nSeg,1);
predByFirstAlinged = cell(nSeg,1);
predBySecondAlinged = cell(nSeg,1);
% it will be shorter...
% predByTrialCombineUpSample = zeros(size(relativeTimeSecond));
% respByTrialCombineUpSample = zeros(size(relativeTimeSecond));
relativeTimeNew  = false(size(relativeTimeSecond));
for ss = 1:1:nSeg
    % for every elements of relativeTimeSecond, you will add something.
    % it is really hard, I guess. you should not pad, should you??
    indSec = [zeros(4,1);relativeTimeSecond(:,ss)]; % pad the response and predicted response of second order kernel
    indFirst = relativeTimeFirst(:,ss);
    predFirst = predByTrialFirst{ss};
    respFirst = respByTrialFirst{ss};
    predSecond = predByTrialSecond{ss};
    respSecond = respBtTrialSecond{ss};
    
    % find the inds where they are both happy.
    indBoth = indSec & indFirst;
    % second 
    indSecondUsed = 1:sum(indSec);
    indFirstUsed = (sum(indFirst) - sum(indBoth) + 1):sum(indFirst);
%     isequal(respSecond(indSecondUsed),respFirst(indFirstUsed))
    predByTrialCombine{ss} = predSecond(indSecondUsed) + predFirst(indFirstUsed);
    predByFirstAlinged{ss} = predFirst(indFirstUsed);
    predBySecondAlinged{ss} = predSecond(indSecondUsed);
    respByTrialCombine{ss} = respSecond(indSecondUsed);
    respAligned = [respAligned;respSecond(indSecondUsed)];
%     respAlignedFirst = [respAlignedFirst;respFirst(indFirstUsed)];
%     respAlignedSecond = [respAlignedSecond;respSecond(indSecondUsed)];
    predAlignedFirst = [predAlignedFirst; predFirst(indFirstUsed)];
    predAlignedSecond = [predAlignedSecond; predSecond(indSecondUsed)];
    
    relativeTimeNew(:,ss) = indBoth(5:end) == 1;
end
respByTrialCombineUpSample  =   MultibarFlicker_alignResponseInRepSeg(respByTrialCombine,relativeTimeNew);
predByTrialCombineUpSample  =   MultibarFlicker_alignResponseInRepSeg(predByTrialCombine,relativeTimeNew);
predByTrialFirstAlignedUpSample =  MultibarFlicker_alignResponseInRepSeg(predByFirstAlinged,relativeTimeNew);
predByTrialSecondAlignedUpSample =  MultibarFlicker_alignResponseInRepSeg(predBySecondAlinged,relativeTimeNew);

predAlignedFirstPlusSecond =  predAlignedSecond + predAlignedFirst ;

ana.predResp_L_ByTrial = predByTrialCombine;
ana.respRepByTrial = respByTrialCombine;
ana.predRespByTrialUpSample = predByTrialCombineUpSample; % for the repeated segments.
ana.respByTrialUpSample = respByTrialCombineUpSample;
ana.predResp_L = predAlignedFirstPlusSecond; % prediction of first order and second order kernel will be added together
ana.resp =  respAligned;
ana.r1o2o = roiAnalysis_OneRoi_OLS_Utils_ComputeCorr(predAlignedSecond,predAlignedFirst,...
    predByFirstAlinged,predBySecondAlinged,predByTrialFirstAlignedUpSample,predByTrialSecondAlignedUpSample);
ana.r = roiAnalysis_OneRoi_OLS_Utils_ComputeCorr(respAligned,predAlignedFirstPlusSecond,...
    respByTrialCombine,predByTrialCombine,respByTrialCombineUpSample,predByTrialCombineUpSample);

roi.LM.firstPlusSecond = ana;
end