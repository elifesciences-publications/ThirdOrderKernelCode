function [respNonRep,predRespNonRep,respRep,predRespRep,respRepByTrialUpSample,predRespByTrialUpSample,respRepByTrial,predRespByTrial] = ...
    roiAnalysis_OneRoi_OLS_PredResp_RepAndNonRep(nonRepData,repData,kernel)

stimNonRep = nonRepData.stim; % huge matrix; 60Hz.
respNonRep = nonRepData.resp;

stimRep = repData.stim;
stimRepByTrial = repData.stimRepByTrial;
% stimRepByTrialUpSample = repData.stimRepByTrialUpSample;
respRep = repData.resp;
respRepByTrial = repData.respRepByTrial; %
respRepByTrialTimeLag = repData.respRepByTrialTimeLag;

% first,
% use the kernels to predict response
predRespNonRep = Kernel_Pred_OLS_AllBar_Linear(stimNonRep,kernel);
predRespRep = Kernel_Pred_OLS_AllBar_Linear(stimRep ,kernel);

% you should check whether you need upsampling here...
respRepByTrialUpSample = MultibarFlicker_alignResponseInRepSeg(respRepByTrial,respRepByTrialTimeLag);
% predRespByTrialUpSample_FullStim =  Kernel_Pred_OLS_AllBar_Linear(stimRepByTrialUpSample,kernel); % this guy has higher frequency, not comparable with the response...

nSeg = length(respRepByTrial);
predRespByTrial = cell(nSeg,1);
for ss = 1:1:nSeg
    predRespByTrial{ss} = Kernel_Pred_OLS_AllBar_Linear( stimRepByTrial(ss,:,:),kernel);
end
predRespByTrialUpSample  =   MultibarFlicker_alignResponseInRepSeg( predRespByTrial,respRepByTrialTimeLag);

end