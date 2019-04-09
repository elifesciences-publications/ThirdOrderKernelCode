function plotVect = plotDifferentialEpochTraces( upperInds,lowerInds,differentialEpochs )
% Plots the time traces of an array of indices (inds)

    frameRange = [ min(upperInds{1}):max(lowerInds{size(differentialEpochs,2)}) ];        
    
    plotVect = zeros(max(frameRange)-(min(frameRange)-1), ...
        size(differentialEpochs,2));
    for q = 1:size(differentialEpochs,2);     
        for r = 1:length(lowerInds{q})
            plotVect(lowerInds{q}-(min(frameRange)-1),q) = 1;
        end 
    end
    figure; plot(plotVect);
            
end

