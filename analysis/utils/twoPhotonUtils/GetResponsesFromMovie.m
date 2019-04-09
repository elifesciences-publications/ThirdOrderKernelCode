function [averagedEpochs,epochLoc] = GetResponsesFromMovie(movieIn,epochStartTimes,epochDurations,epoch)

% movieSize = size(movieIn);
    
    startTimes = epochStartTimes{epoch};
    durations = epochDurations{epoch};
    endTimes = startTimes+durations-1;
    
    epochLoc = startTimes+durations/2;
    
    numSnips = length(startTimes);
    %     averagedEpochs = zeros(movieSize(1),movieSize(2),numSnips);
    averagedEpochs = [];
    for ss = 1:numSnips
        %     averagedEpochs(:,:,ss) = mean(movieIn(:,:,startTimes(ss):endTimes(ss)),3);
        averagedEpochs = cat(3, averagedEpochs,movieIn(:,:,startTimes(ss):endTimes(ss)));
        %         averagedEpochs(:,:,ss) = median(movieIn(:,:,startTimes(ss):endTimes(ss)),3);
    end
end
