function [timeByRois,watershededMean,extraVars] = WatershedRoiExtraction(filteredMovie,deltaFOverF,epochStartTimes,epochDurations,params,varargin)
    meanImage = mean(filteredMovie,3);
    filterWatershed = false;
    extraVars.defaults.filterWatershed = filterWatershed;
    
    if any(strcmp(varargin, 'filterWatershed'))
        filterWatershed = varargin{[false strcmp(varargin, 'filterWatershed')]};
        if filterWatershed
            stDev = 1.5;
            numStd = 2;
            
            x = (-numStd*stDev):(numStd*stDev);
            filtX = normpdf(x,0,stDev);
            spatialFilter = filtX;
            meanImage = imfilter(meanImage, spatialFilter);
        end
        extraVars.filterWatershed = filterWatershed;
    else
        extraVars.filterWatershed = filterWatershed;
    end
    
    watershededMean = WatershedImage(meanImage);
    
    numRois = max(max(watershededMean));
    movieMatrix = reshape(deltaFOverF,[numel(meanImage) size(filteredMovie,3)])';
    
    timeByRois = zeros(size(filteredMovie,3),numRois);
    
    for rr = 1:numRois
        thisRoiMask = watershededMean==rr;
        thisRoiMask = reshape(thisRoiMask,[1 numel(thisRoiMask)]);
        timeByRois(:,rr) = mean(movieMatrix(:,thisRoiMask),2);
    end
    
end