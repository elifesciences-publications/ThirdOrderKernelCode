function  outHandle = staggerPlotTraces( traceData, inText )
% traceData should be time points on first dimension, different ROIs on
% second dimension. This script (1) figures out the highest peak of any of
% the vectors and then (2) plots the vectors (columns) staggered with a
% separation that is the highest peak value. 

    if nargin < 2
        inText = [];
    end
    
    staggerHeight = percentileThresh( traceData, .999 );
    staggerInd = [1:1:size(traceData,2)]*staggerHeight; 
    staggerInd = repmat(staggerInd,[size(traceData,1) 1]);
    
    plot((traceData + staggerInd));
    if ~isempty(inText)
        for q = 1:size(traceData,2)
            text(5,q*staggerHeight-.75,inText{q});
        end
    end
    
    axis xy
    set(gca,'YTick',[]);
    
    outHandle = gca;

end

