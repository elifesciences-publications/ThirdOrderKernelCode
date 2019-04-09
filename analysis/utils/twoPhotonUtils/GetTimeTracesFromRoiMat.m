function [timeTraces,epochLoc] = GetTimeTracesFromRoiMat(timeByRois,epochStartTimes,epochDurations,epoch)
    startTimes = epochStartTimes{epoch};
    duration = round(mean(epochDurations{epoch}));
    endTimes = startTimes+duration-1;
    
    epochLoc = startTimes+duration/2;
    
    numRois = size(timeByRois,2);
    
    numSnips = length(startTimes);
    timeTraces = zeros(duration,numRois,numSnips);
    
    for ss = 1:numSnips
        timeTraces(:,:,ss) = timeByRois(startTimes(ss):endTimes(ss),:);
    end
end