function result = roiAnalysis_OneRoi_OLS_Utils_ComputeCorr(respRep,predRespRep,respRepByTrial,predRespByTrial,respRepByTrialUpSample,predRespRepByTrialUpSample)
overall = corr(respRep,predRespRep);
% do not do this by order. you have to use sort function
nSeg = length(respRepByTrial);
byTrial = zeros(nSeg,1);
for ss = 1:1:nSeg
byTrial(ss) = corr(respRepByTrial{ss},predRespByTrial{ss});
end
% correlation between response and mean response. interp one or non interp.
% how are you going to correlate that? how are you going to do this? just
% do it? both are interpolated one. 
% assume the first 5 points and last 5 points is set to zeros.
predVSMeanResp = corr(mean(respRepByTrialUpSample(6:end-4,:),2),mean(predRespRepByTrialUpSample(6:end-4,:),2)); % there are zeros, would it be correct? what is the correct way to do it?

result.overall = overall;
result.byTrial = byTrial;
result.predVSMeanResp = predVSMeanResp;
end