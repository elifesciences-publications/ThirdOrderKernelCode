function [timeTraces,epochLoc] = GetTimeTracesFromMovie(movieIn,epochStartTimes,epochDurations,epoch)
    startTimes = epochStartTimes{epoch};
    duration = round(mean(epochDurations{epoch}));
    endTimes = startTimes+duration-1;
    
    epochLoc = startTimes+duration/2;
    
    movieSize = size(movieIn);
    
    numSnips = length(startTimes);
    timeTraces = zeros(duration,movieSize(1)*movieSize(2),numSnips);
    
    for ss = 1:numSnips
        trial = movieIn(:,:,startTimes(ss):endTimes(ss));
        
        % filter trial
        stdFiltT = 1;
        stdFiltXY = 1;
        numStd = 2;
        t = (-stdFiltT*numStd):(stdFiltT*numStd);
        xy = (-stdFiltXY*numStd):(stdFiltXY*numStd);
        spatialFilter = normpdf(xy',0,stdFiltXY)*normpdf(xy,0,stdFiltXY);
        temporalFilter = permute(normpdf(t,0,stdFiltT),[1 3 2]);
        repTemporalFilter = repmat(temporalFilter,[size(xy,1) size(xy,2) 1]);
        spatioTemporalFilter = bsxfun(@times,spatialFilter,repTemporalFilter);
        
        trial = imfilter(trial,spatioTemporalFilter,'symmetric');
        
        timeTraces(:,:,ss) = reshape(trial,[movieSize(1)*movieSize(2) duration])';
    end
end