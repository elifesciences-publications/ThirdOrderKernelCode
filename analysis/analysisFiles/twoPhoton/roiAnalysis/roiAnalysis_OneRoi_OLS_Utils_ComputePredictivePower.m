function result = roiAnalysis_OneRoi_OLS_Utils_ComputePredictivePower(respRepByTrial,predRespByTrial)
nSeg = length(respRepByTrial);
% power in the response...
% mean square distance between data and model
powerOfResponse = zeros(nSeg,1);
powerOfError = zeros(nSeg,1);
for ss = 1:1:nSeg
    powerOfResponse(ss) = var(respRepByTrial{ss},0);
    powerOfError(ss) = var(respRepByTrial{ss} - predRespByTrial{ss},0);
end
result.powerOfResponse = mean(powerOfResponse);
result.powerOfError = mean( powerOfError);
result.predictivePower = result.powerOfResponse - result.powerOfError;
end