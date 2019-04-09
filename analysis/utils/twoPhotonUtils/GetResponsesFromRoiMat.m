function [averagedEpochs,epochLoc] = GetResponsesFromRoiMat(timeByRois,epochStartTimes,epochDurations,epoch)
    numRois = size(timeByRois,2);
    
    startTimes = epochStartTimes{epoch};
    durations = epochDurations{epoch};
    endTimes = startTimes+durations-1;
    
    epochLoc = startTimes+durations/2;
    
    numSnips = length(startTimes);
    averagedEpochs = zeros(numSnips,numRois);
    
    for ss = 1:numSnips
        averagedEpochs(ss,:) = nanmean(timeByRois(startTimes(ss):endTimes(ss),:));
    end
end