function [respNonRep,predRespNonRep,respRep,predRespRep] = roiAnalysis_OneRoi_RevCorr_PredResp_RepAndNonRep(nonRepData,repData,kernel,order,dx)

stimNonRep = nonRepData.stim; % huge matrix; 60Hz.
respNonRep = nonRepData.resp;

stimRep = repData.stim;
respRep = repData.resp;

% given kernel, predict resposne. return them together.
% only use the bar which is not zeros
barUsed = find(sum(kernel,1) ~= 0); % will be several for first order kernel, only one effective for second order kernel! good!
windMask = false(size(kernel,1),1); % to make it work faster, you should constrain the windMask.
windMask(kernel(:,barUsed(1))~= 0) = true;
[~,~,predRespNonRep,respNonRep] = RevCorr_ModelSelection_1o2o_Utils_PredResp_AllTrials(respNonRep,stimNonRep,kernel,barUsed,windMask,order,dx);
[~,~,predRespRep,respRep] = RevCorr_ModelSelection_1o2o_Utils_PredResp_AllTrials(respRep,stimRep,kernel,barUsed,windMask,order,dx);

end