function covarFig = BarPairPlotResponseCorrelation(responseCorrelations, pVals, lower95Perc, upper95Perc, barToCenter, numPhases, optimalResponseField, plotAllCovariances)
% The plotAllCovariances inputs tells us:
% 0) plot just the covariance betwen optimalPhase and optimalPhase,
% 1) plot the covariance between optimalPhase and all phases, or
% 2) plot the covariance between all phases and all phases
if nargin < 8
    plotAllCovariances = 1;
end

covarFig = MakeFigure;
optimalPhases = [4, 4+numPhases, 4+2*numPhases, 4+3*numPhases];
numSbpltRows = length(optimalPhases)+1;
minY = [];
maxY = [];
pValThresh = 0.01;

if plotAllCovariances == 2
    phasesOfInterest = 1:size(responseCorrelations, 1);
    numCols = length(phasesOfInterest)/numPhases + 1;
    numSbpltRows = length(phasesOfInterest)/numPhases + 1;
elseif plotAllCovariances == 1
    phasesOfInterest = 1:size(responseCorrelations, 1); 
    numCols = length(phasesOfInterest)/numPhases;
else
    phasesOfInterest = optimalPhases(1):numPhases:size(responseCorrelations, 1); 
    numCols = length(phasesOfInterest);
end

if plotAllCovariances < 2
    subplotXTIndexes = reshape(1:numSbpltRows*numCols, numCols, [])';
    subplotXTIndexes = subplotXTIndexes(1, :);
    for i = 1:length(optimalPhases)
        
        sbpltHandles(i) = subplot(numSbpltRows, 1, i+1);
        
        corrOfInt = responseCorrelations(optimalPhases(i), phasesOfInterest);
        lowerVals = lower95Perc(optimalPhases(i), phasesOfInterest);
        upperVals = upper95Perc(optimalPhases(i), phasesOfInterest);
        pValsInt = pVals(optimalPhases(i), phasesOfInterest);
        lowerError = corrOfInt - lowerVals;
        upperError = upperVals - corrOfInt;
        errorVals = cat(3, lowerError', upperError');
        
        dataX = (1:length(corrOfInt))';
        PlotXvsY(dataX, corrOfInt', 'error', errorVals, 'graphType', 'bar' )
        pValStat = pValThresh/numel(pValsInt); % Correcting for multiple comparisons
        sigVals = pValsInt<pValStat;
%         sigVals = sign(upper95Perc(optimalPhases(i), phasesOfInterest)) == sign(lower95Perc(optimalPhases(i), phasesOfInterest));
        plotY = max(upperError+corrOfInt)+0.25;
        text(dataX(sigVals), plotY*ones(sum(sigVals), 1), '*', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [1 0 0]);
        hold on
        plot(dataX(sigVals), plotY*ones(sum(sigVals), 1)+0.25, '*', 'MarkerSize', 0.5);
        axVals = axis;
        minY = [minY axVals(3)];
        maxY = [maxY plotY+0.25];
        if length(optimalPhases)/2>=i && length(optimalPhases)/2<(i+1)
            ylabel('Normalized Correlation');
        end
        axis tight
        set(gca,'box','off');
    end
else
    subplotIndexes = reshape(1:numSbpltRows*numCols, numSbpltRows, [])';
    subplotXTIndexes = [subplotIndexes(1, 2:end)' subplotIndexes(2:end, 1)];
    sbpltHandles = subplot(numSbpltRows, numCols, reshape(subplotIndexes(2:end, 2:end)', 1, []));
    imagesc(responseCorrelations)
    minY = sbpltHandles.YLim(1);
    maxY = sbpltHandles.YLim(2);
    colormap(b2r(min(responseCorrelations(:)),max(responseCorrelations(:))))
    
    % Plotting the significant points here
    pValStat = pValThresh/numel(pVals);
    sigVals = pVals<pValStat;
%     sigVals = sign(upper95Perc) == sign(lower95Perc);
    [sigRow, sigCol] = find(sigVals);
    hold on; plot(sigRow, sigCol, 'k*', 'MarkerSize', 1)
end

[sbpltHandles.YLim] = deal([min(minY) max(maxY)]);

if plotAllCovariances == 2
    axes(sbpltHandles)
    xValsSeparation = (numPhases+0.5):numPhases:size(responseCorrelations, 1);
    hold on
    plot([xValsSeparation; xValsSeparation], bsxfun(@plus, zeros(2, length(xValsSeparation)), [min(minY); max(maxY)]), 'k--');
    plot(bsxfun(@plus, zeros(2, length(xValsSeparation)), [min(minY); max(maxY)]), [xValsSeparation; xValsSeparation], 'k--');
    axis off
elseif plotAllCovariances == 1
    for sbplt = 1:length(sbpltHandles)
        axes(sbpltHandles(sbplt))
        xValsSeparation = (numPhases+0.5):numPhases:size(responseCorrelations, 1);
        plot([xValsSeparation; xValsSeparation], bsxfun(@plus, zeros(2, length(xValsSeparation)), [min(minY); max(maxY)]), 'k--');
    end
end

%% Plot directional bar pairs
barColors = [1 1 1; 0 0 0];
barColorOrderOne = [1 2 1 2];
barColorOrderTwo = [1 2 2 1];
% Plotting the actual bar alignment

secondBarDelay = 0.15;
bothBarsOff = 1;
ind = 1;

for i = 1:4
    barsPlot = subplot(numSbpltRows, numCols, subplotXTIndexes(i*2-1));
    progMot = true;
    BarPairPlotSideBySideBarsXT(barsPlot, bothBarsOff, secondBarDelay, barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :), barToCenter, progMot);
    
    barsPlot = subplot(numSbpltRows, numCols, subplotXTIndexes(i*2));
    progMot = false;
    BarPairPlotSideBySideBarsXT(barsPlot, bothBarsOff, secondBarDelay, barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :), barToCenter, progMot);
    
    if plotAllCovariances == 2
        barsPlot = subplot(numSbpltRows, numCols, subplotXTIndexes(i*2-1, 2));
        progMot = true;
        BarPairPlotSideBySideBarsXT(barsPlot, bothBarsOff, secondBarDelay, barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :), barToCenter, progMot);
        barsPlot = subplot(numSbpltRows, numCols, subplotXTIndexes(i*2, 2));
        progMot = false;
        BarPairPlotSideBySideBarsXT(barsPlot, bothBarsOff, secondBarDelay, barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :), barToCenter, progMot);
    end
    ind = ind+1;
end

%% Plot still double bars
if numCols>8
    barColors = [1 1 1; 0 0 0];
    barColorOrderOne = [1 2 1 2];
    barColorOrderTwo = [1 2 2 1];
    ind = 1;
    for i = 5:6
        secondBarDelay = 0;
        
        barsPlot = subplot(numSbpltRows, numCols, subplotXTIndexes(i*2-1));
        BarPairPlotOneApartBarsXT(barsPlot, bothBarsOff, secondBarDelay, barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :))
        
        ind = ind + 1;
        
        barsPlot = subplot(numSbpltRows, numCols, subplotXTIndexes(i*2));
        BarPairPlotOneApartBarsXT(barsPlot, bothBarsOff, secondBarDelay, barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :))
        if plotAllCovariances == 2
            ind = ind -1;
            barsPlot = subplot(numSbpltRows, numCols, subplotXTIndexes(i*2-1, 2));
            BarPairPlotOneApartBarsXT(barsPlot, bothBarsOff, secondBarDelay, barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :))
            ind = ind + 1;
            barsPlot = subplot(numSbpltRows, numCols, subplotXTIndexes(i*2, 2));
            BarPairPlotOneApartBarsXT(barsPlot, bothBarsOff, secondBarDelay, barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :))
        end
        ind = ind + 1;
    end
end

%% Plot neighboring still bars
if numCols>12 && numCols>16 % The latter will obviously negate the former; but it's there to indicate two different situations of parameter files
    switch optimalResponseField
        case {'PPlusPref', 'PPlusNull', 'PlusSingle'}
            plotLightCenter = true;
        case {'PMinusPref', 'PMinusNull', 'MinusSingle'}
            plotLightCenter = false;
        otherwise
            error('Don''t know how to align the single bars!');
    end
    
    colsPlotted = 12;
    barColors = [1 1 1; 0 0 0];
    if plotLightCenter
        barColorOrderOne = [1 2 2 2];
        barColorOrderTwo = [1 2 1 1];
    else
        barColorOrderOne = [1 2 1 1];
        barColorOrderTwo = [1 2 2 2];
    end
    % Plotting the actual bar alignment
    if barToCenter == 0
        barShift = 0;
    elseif barToCenter == 1;
        barShift = 1;
    else
        barShift = -1;
    end
    
    
    
    secondBarDelay = 0;
    bothBarsOff = 1;
    
    for i = [1 4]
        if plotLightCenter
            barsPlot = subplot(numSbpltRows, numCols, subplotXTIndexes(colsPlotted+i));
            progMot = true;
            BarPairPlotSideBySideBarsXT(barsPlot, bothBarsOff, secondBarDelay, barColors(barColorOrderOne(i), :), barColors(barColorOrderTwo(i), :), barToCenter, progMot);
            
            
        else
            barsPlot = subplot(numSbpltRows, numCols, subplotXTIndexes(colsPlotted+i));
            progMot = false;
            BarPairPlotSideBySideBarsXT(barsPlot, bothBarsOff, secondBarDelay, barColors(barColorOrderOne(i), :), barColors(barColorOrderTwo(i), :), barToCenter, progMot);
            
        end
    end
    
    for i = [2 3]
        if ~plotLightCenter
            barsPlot = subplot(numSbpltRows, numCols, subplotXTIndexes(colsPlotted+i));
            progMot = true;
            BarPairPlotSideBySideBarsXT(barsPlot, bothBarsOff, secondBarDelay, barColors(barColorOrderOne(i), :), barColors(barColorOrderTwo(i), :), barToCenter, progMot);
        else
            barsPlot = subplot(numSbpltRows, numCols, subplotXTIndexes(colsPlotted+i));
            progMot = false;
            BarPairPlotSideBySideBarsXT(barsPlot, bothBarsOff, secondBarDelay, barColors(barColorOrderOne(i), :), barColors(barColorOrderTwo(i), :), barToCenter, progMot);
        end
    end
    
    if plotAllCovariances == 2
        for i = [1 4]
            if plotLightCenter
                barsPlot = subplot(numSbpltRows, numCols, subplotXTIndexes(colsPlotted+i, 2));
                progMot = true;
                BarPairPlotSideBySideBarsXT(barsPlot, bothBarsOff, secondBarDelay, barColors(barColorOrderOne(i), :), barColors(barColorOrderTwo(i), :), barToCenter, progMot);
                
                
            else
                barsPlot = subplot(numSbpltRows, numCols, subplotXTIndexes(colsPlotted+i, 2));
                progMot = false;
                BarPairPlotSideBySideBarsXT(barsPlot, bothBarsOff, secondBarDelay, barColors(barColorOrderOne(i), :), barColors(barColorOrderTwo(i), :), barToCenter, progMot);
                
            end
        end
        
        for i = [2 3]
            if ~plotLightCenter
                barsPlot = subplot(numSbpltRows, numCols, subplotXTIndexes(colsPlotted+i, 2));
                progMot = true;
                BarPairPlotSideBySideBarsXT(barsPlot, bothBarsOff, secondBarDelay, barColors(barColorOrderOne(i), :), barColors(barColorOrderTwo(i), :), barToCenter, progMot);
            else
                barsPlot = subplot(numSbpltRows, numCols, subplotXTIndexes(colsPlotted+i, 2));
                progMot = false;
                BarPairPlotSideBySideBarsXT(barsPlot, bothBarsOff, secondBarDelay, barColors(barColorOrderOne(i), :), barColors(barColorOrderTwo(i), :), barToCenter, progMot);
            end
        end
    end
end

%% Plot single bars
if numCols>16
    startCol = 16;
    barColors = [1 1 1; 0 0 0];
    barColorOrderOne = [1 2];
    ind = 1;
    for i = startCol/2
        barDelay = 0;
        barsPlot = subplot(numSbpltRows, numCols, subplotXTIndexes(i*2+1));
        BarPairPlotSingleBarsXT(barsPlot, bothBarsOff, barDelay, barColors(barColorOrderOne(ind), :))
        
        if plotAllCovariances == 2
            barsPlot = subplot(numSbpltRows, numCols, subplotXTIndexes(i*2+1, 2));
            BarPairPlotSingleBarsXT(barsPlot, bothBarsOff, barDelay, barColors(barColorOrderOne(ind), :))
        end
        
        ind = ind + 1;
        
        barsPlot = subplot(numSbpltRows, numCols, subplotXTIndexes(i*2+2));
        BarPairPlotSingleBarsXT(barsPlot, bothBarsOff, barDelay, barColors(barColorOrderOne(ind), :))
        
        if plotAllCovariances == 2
            barsPlot = subplot(numSbpltRows, numCols, subplotXTIndexes(i*2+2, 2));
            BarPairPlotSingleBarsXT(barsPlot, bothBarsOff, barDelay, barColors(barColorOrderOne(ind), :))
        end
        
        ind = ind + 1;
        
    end
    
end

%% Turn off axes if you're plotting the entire covariance matrix
if plotAllCovariances == 2
    allAxes = covarFig.findobj('Type', 'Axes');
    
    for indAx = 1:length(allAxes)
        % Slower, but not sure how to deal all the axis off without messing
        % up how they're displayed
        axes(allAxes(indAx))
        axis off
    end
end

end