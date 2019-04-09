function result = roiAnalysis_OneRoi_RevCorr_Utils_ComputePredictivePower(respRepByTrial,predRespByTrial)
nSeg = length(respRepByTrial);
% power in the response...
% mean square distance between data and model
powerOfResponse = zeros(nSeg,1);
powerOfError = zeros(nSeg,1);
% before calculating the residual, you will do mean subtraction first, same
% for LN model! you forget it... before. Thanks Damon.
for ss = 1:1:nSeg
    powerOfResponse(ss) = var(respRepByTrial{ss},0);
    zeroMeanResp = respRepByTrial{ss} - mean(respRepByTrial{ss});
    zeroMeanPred = predRespByTrial{ss} - mean(predRespByTrial{ss});
    powerOfError(ss) = var(zeroMeanResp - zeroMeanPred,0);
end
result.powerOfResponse = mean(powerOfResponse);
result.powerOfError = mean(powerOfError);
result.predictivePower = result.powerOfResponse - result.powerOfError;
end