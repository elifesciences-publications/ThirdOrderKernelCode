function [varExplainedByMeanTest,varExplainedByMeanTrain] = roiAnalysis_OneRoi_VarRepSeg_OneCV(respFull,respByTrial,respRepByTrialTimeLag,trainTrialInd,testTrialInd)
% use interpolated data to compute the mean response;
nSegTest = sum(testTrialInd);
meanRespTrain = mean(respFull(:,trainTrialInd),2);

meanRespTestByTrial = cell(nSegTest,1);
testTrial = find(testTrialInd ~= 0);
for ss = 1:1:nSegTest
    meanRespTestByTrial{ss} = meanRespTrain(respRepByTrialTimeLag(:,testTrial(ss)));
end
respTestByTrial = respByTrial(testTrialInd);
% do the cross validation.
meanTestMat = cell2mat(meanRespTestByTrial);
respTestMat = cell2mat(respTestByTrial);
varExplainedByMeanTest = corr(meanTestMat,respTestMat);

% you might just want one number? 
% ana.varExplainedByMean 

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

varExplainedByMeanTrain = corr(meanTrainMat,respTrainMat);

% you could do signal to noise estimation on the data set as well... is
% that insane to do this cross-validation? It that insane? pretty insane
% actually....

end