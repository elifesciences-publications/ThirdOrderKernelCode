function [nonRepData,repData] = roiAnalysis_OneRoi_OLS_PrepareStimResp_NonRepAndRep(respData,stimData,stimIndexes,repStimuIndInFrame,order,dx,maxTau,nMultiBars)
repSegFlag = false;
% 6 second to generate the full stimulus and response.
% set a flag in this function, to make sure the the data in the second
% order kernel is the same as the first order kerne. 
[OLSMat] = tp_Compute_OLSMat_NonRepOrRep(respData,stimData,stimIndexes,repStimuIndInFrame,repSegFlag,'order',order,'dx',dx,'maxTau',maxTau,'nMultiBars', nMultiBars);
nonRepData.stim = OLSMat.stim;
nonRepData.resp = OLSMat.resp{1};

repSegFlag = true;
% this is purely for the first order kernel, you have to compute the same
% thing for the second order. might be slower for the second order.
OLSMat = tp_Compute_OLSMat_NonRepOrRep(respData,stimData,stimIndexes,repStimuIndInFrame,repSegFlag,'order',order,'dx',dx,'maxTau',maxTau,'nMultiBars', nMultiBars);
repData.stim = OLSMat.stim;
repData.resp = OLSMat.resp{1};
repData.respRepByTrial = OLSMat.respByTrial{1};
repData.stimRepByTrial = OLSMat.stimMatrixByTrial;
repData.stimRepByTrialUpSample = OLSMat.stimRepByTrialUpSample ;
repData.respRepByTrialTimeLag = OLSMat.relativeTimePointsEachTrial{1};
end