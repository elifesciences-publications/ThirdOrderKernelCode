function [varExplainedByMeanTest,varExplainedByMeanTrain] = roiAnalysis_OneRoi_VarRepSeg_OneCV_NonInterp(respByTrial,respRepByTrialTimeLag,trainTrialInd,testTrialInd)
% use interpolated data to compute the mean response;
nSeg = size(respRepByTrialTimeLag,2);
nSegTest = sum(testTrialInd);
respFull = nan(size(respRepByTrialTimeLag));

for ss = 1:1:nSeg
    respFull(respRepByTrialTimeLag(:,ss),ss) = respByTrial{ss};
end

% first, calculate the mean response using respFull. Theremight be ana,
% deal with it carefully. 
% it is possible that 
meanRespTrain = nanmean(respFull(:,trainTrialInd),2); % what if there is nan in one time point. that would still be nan, do not worry...
% it is possible that there is ana in meanRespTrain;

meanRespTestByTrial = cell(nSegTest,1);
testTrial = find(testTrialInd ~= 0);
for ss = 1:1:nSegTest
    meanRespTestByTrial{ss} = meanRespTrain(respRepByTrialTimeLag(:,testTrial(ss)));
end
respTestByTrial = respByTrial(testTrialInd);
% do the cross validation.
meanTestMat = cell2mat(meanRespTestByTrial);
respTestMat = cell2mat(respTestByTrial);

respTestMat(isnan(meanTestMat)) = [];
meanTestMat(isnan(meanTestMat)) = [];
varExplainedByMeanTest = corr(meanTestMat,respTestMat); % it should not be square...

% might be useless. but still calculate that.

nSegTrain = sum(trainTrialInd);
meanRespTrainByTrial = cell(nSegTrain,1);
trainTrial = find(trainTrialInd ~= 0);
for ss = 1:1:nSegTrain;
    meanRespTrainByTrial{ss} = meanRespTrain(respRepByTrialTimeLag(:,trainTrial(ss)));
end
respTrainByTrial = respByTrial(trainTrialInd);
% do the cross validation.
meanTrainMat = cell2mat(meanRespTrainByTrial);
respTrainMat = cell2mat(respTrainByTrial);

respTrainMat(isnan(meanTrainMat)) = [];
meanTrainMat(isnan(meanTrainMat)) = [];
varExplainedByMeanTrain = corr(meanTrainMat,respTrainMat);
% ana = roiAnalysis_OneRoi_VarRepSeg_ComputeVar(respTestMat,meanTestMat);
% ana.varExplainedByMean 
% you can compute all kinds of result. 
end