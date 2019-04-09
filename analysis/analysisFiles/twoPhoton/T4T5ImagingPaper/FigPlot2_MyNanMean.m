function [predMean,respMean] = FigPlot2_MyNanMean(predResp,resp)
    % key, respMean has elements which non nan number is larger than 2.
    % find how many nan's in one
    nonNanNumber = sum(~ isnan(resp),2);
    
    plotInd = nonNanNumber > 1;
    
    
    predMean = nanmean(predResp,2);
    respMean = nanmean(resp,2);
    
    predMean(~plotInd) = NaN;
    respMean(~plotInd) = NaN;
end