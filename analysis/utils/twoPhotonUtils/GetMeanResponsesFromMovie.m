function [averagedEpochs,epochLoc] = GetMeanResponsesFromMovie(movieIn,epochStartTimes,epochDurations,epoch)
    movieSize = size(movieIn);
    
    startTimes = cat(1, epochStartTimes{epoch});
    durations = cat(1,epochDurations{epoch});
    endTimes = startTimes+durations-1;
    
    [startTimes, indSort] = sort(startTimes);
    endTimes = endTimes(indSort);
    
    epochLoc = startTimes+durations/2;
    
    numSnips = length(startTimes);
    averagedEpochs = zeros(movieSize(1),movieSize(2),numSnips);
    warning('off', 'MATLAB:colon:nonIntegerIndex');
    for ss = 1:numSnips
        averagedEpochs(:,:,ss) = mean(movieIn(:,:,startTimes(ss):endTimes(ss)),3);
    end
    warning('on', 'MATLAB:colon:nonIntegerIndex');
end