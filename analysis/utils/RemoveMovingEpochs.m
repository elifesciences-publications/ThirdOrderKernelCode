function droppedNaNTraces = RemoveMovingEpochs(flyRespSnipMat)

% Get rid of epochs with too many NaNs
thresholdNaNs = 0.1;
epochsWithFewNans = cellfun(@(x) sum(isnan(x), 1)/size(x, 1)<thresholdNaNs, flyRespSnipMat, 'UniformOutput', false);
droppedNaNTraces = cellfun(@(fewNans, timeTraces)... we take in a logical for good epoch columns and the columns of time traces
    reshape(...
    timeTraces(...
    repmat(fewNans, [size(timeTraces,1), 1])... repeat the logical vector for the length of the columns
    ),... index the time traces so they only get the true columns (i.e. columns with < thresholdNaNs)
    [size(timeTraces, 1) sum(fewNans)]),... the answer is logically indexed so it comes out as a column vector; reshape it to the appropriate size
    epochsWithFewNans, flyRespSnipMat, 'UniformOutput', false);