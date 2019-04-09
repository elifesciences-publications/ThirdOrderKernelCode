function [snippedTimeTraces] = GetRoiResponsesFromEpoch(roiTraces,epochStartTimes,epochDurations,epoch)
    numRois = size(roiTraces, 2);
    
    startTimes = epochStartTimes{epoch};
    durations = epochDurations{epoch};
    
    numSnips = length(startTimes);
    
    warning('off', 'MATLAB:colon:nonIntegerIndex');
    for ss = 1:numSnips
        snippedTimeTraces{ss} = roiTraces(startTimes(ss):startTimes(ss)+durations(ss)-1,:);
    end
    warning('on', 'MATLAB:colon:nonIntegerIndex');
end