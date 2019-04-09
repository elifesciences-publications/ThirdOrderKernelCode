function output = FilterTrials(inSnipMat,filterFcn)
% Takes in a snipMat and a filterFnc which takes in a time X trials X 2
% tensor and outputs a bool vector of length trial where 1 is a kept trial
% and 0 is a rejected trial.
    trialSnipMat = cellfun(@(x)filterFcn(x),inSnipMat,'UniformOutput',false);
    output = cellfun(@(epoch,trials)epoch(:,trials,:),inSnipMat,trialSnipMat,'UniformOutput',false);
end