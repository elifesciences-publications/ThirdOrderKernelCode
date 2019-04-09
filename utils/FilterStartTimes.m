function filtered = FilterStartTimes(epochStartTimes,durations,maxRange,runLength)

    [numEpochs,numFlies] = size(epochStartTimes);
    for epoch = 1:numEpochs
        for fly = 1:numFlies
            startTimes = epochStartTimes{epoch,fly};
            adjustedStartTimes = startTimes + maxRange(1);
            adjustedEndTimes = startTimes + durations(epoch) + maxRange(2);
            filtered{epoch,fly} = startTimes(adjustedStartTimes > 0 ...
                                                       & ...
                                                       adjustedEndTimes < runLength);
        end
    end