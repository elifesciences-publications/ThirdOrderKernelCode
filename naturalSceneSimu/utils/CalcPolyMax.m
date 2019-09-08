function out = CalcPolyMax(dataIn,turn,polyOrder,dataXFit,fitLength,logScale,numAroundFit)
    dataIn = dataIn';
    dataXFit = dataXFit';
    dataX = dataXFit(:,1);
    
    if turn
        [~,maxLoc] = max(mean(dataIn,2));
    else
        [~,maxLoc] = min(mean(dataIn,2));
    end
    
    maxStart = max([maxLoc-numAroundFit,1]);
    maxEnd = min([maxLoc+numAroundFit+(maxStart-(maxLoc-numAroundFit)),size(dataIn,1)]);
    maxStart = max([maxLoc-numAroundFit+(maxEnd-(maxLoc+numAroundFit)),1]);
        
    pointsToFit = maxStart:maxEnd;
    
    dataX = dataX(pointsToFit,:);
    fitX = linspace(dataX(1),dataX(end),fitLength)';
    
    cfRange = linspace(dataX(1),dataX(end),fitLength)';
    if logScale
        cfRange = exp(cfRange);
    end

    coefFit = polyfit(dataXFit,dataIn,polyOrder);

    traceFit = polyval(coefFit,fitX);
    
    if turn
        [maxVal,maxInd] = max(traceFit);
    else
        [maxVal,maxInd] = min(traceFit);
    end
    
    polyMax = cfRange(maxInd);
    out = [polyMax,maxVal];
end