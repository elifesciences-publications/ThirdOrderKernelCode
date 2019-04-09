function tp_plotBarPairROISummary(Z, epochAvgAnalysisProg, plottingEpochs, barToCenter, regCheck, shift)

PPlusPref = plottingEpochs.PPlusPref;
PPlusNull = plottingEpochs.PPlusNull;
PMinusPref = plottingEpochs.PMinusPref;
PMinusNull = plottingEpochs.PMinusNull;
NPlusPref = plottingEpochs.NPlusPref;
NPlusNull = plottingEpochs.NPlusNull;
NMinusPref = plottingEpochs.NMinusPref;
NMinusNull = plottingEpochs.NMinusNull;


stepsBack = Z.triggeredResponseAnalysis.stepsBack;
fsAligned = Z.params.fs*Z.triggeredResponseAnalysis.fsFactor;
% epochAvgAnalysisProg = Z.triggeredResponseAnalysis.triggeredIntensities;



MakeFigure;
subRows = 4;
if ~isempty(epochAvgAnalysisProg)
    % Plotting the phased responses
    progHandles(1) = subplot(subRows, 10, 1:4);
    tp_plotTraceAndAverage(epochAvgAnalysisProg, stepsBack, fsAligned, PPlusPref, [], [1 0 0], [0 0 1], shift)
    title('Preferred ++')
    
    progHandles(2) = subplot(subRows, 10, 11:14);
    tp_plotTraceAndAverage(epochAvgAnalysisProg, stepsBack, fsAligned, PMinusPref, [], [1 0 0], [0 0 1], shift)
    title('Preferred --')
    
    progHandles(3) = subplot(subRows, 10, 21:24);
    tp_plotTraceAndAverage(epochAvgAnalysisProg, stepsBack, fsAligned, NPlusPref, [], [1 0 0], [0 0 1], shift)
    title('Preferred +-')
    
    progHandles(4) = subplot(subRows, 10, 31:34);
    tp_plotTraceAndAverage(epochAvgAnalysisProg, stepsBack, fsAligned, NMinusPref, [], [1 0 0], [0 0 1], shift)
    title('Preferred -+')
    text(0.75, 0, Z.ROI.typeFlagName(Z.ROI.roiIndsOfInterest));
    
%     subplot(subRows, 10, 41:44)
%     tp_plotTraceAndAverage(Z.triggeredResponseAnalysis.epochAvgTriggeredIntensities, stepsBack, fsAligned, PPlusPref, [], [1 0 0], [ 0 0 1]);
    
    progHandles(5) = subplot(subRows, 10, 7:10);
    tp_plotTraceAndAverage(epochAvgAnalysisProg, stepsBack, fsAligned, PPlusNull, [], [1 0 0], [0 0 1], shift)
    title('Null ++')
    
    progHandles(6) = subplot(subRows, 10, 17:20);
    tp_plotTraceAndAverage(epochAvgAnalysisProg, stepsBack, fsAligned, PMinusNull, [], [1 0 0], [0 0 1], shift)
    title('Null --')
    
    progHandles(7) = subplot(subRows, 10, 27:30);
    tp_plotTraceAndAverage(epochAvgAnalysisProg, stepsBack, fsAligned, NPlusNull, [], [1 0 0], [0 0 1], shift)
    title('Null +-')
    
    progHandles(8) = subplot(subRows, 10, 37:40);
    tp_plotTraceAndAverage(epochAvgAnalysisProg, stepsBack, fsAligned, NMinusNull, [], [1 0 0], [0 0 1], shift)
    title('Null -+')
    text(0.75, 0, Z.ROI.typeFlagName(Z.ROI.roiIndsOfInterest));
    
    
    barColors = [1 1 1; 0 0 0];
    barColorOrderOne = [1 2 1 2];
    barColorOrderTwo = [1 2 2 1];
    % Plotting the actual bar alignment
    if barToCenter == 0
        barShift = 0;
    elseif barToCenter == 1;
        barShift = 1;
    else
        barShift = -1;
    end
    
    ind = 1;
    for i = 5:10:40
        if regCheck
            p1 = i+1;
            p2 = i;
        else
            p1 = i;
            p2 = i+1;
        end
        barsPlot = subplot(4, 10, p1);
        axis([0 0.45 -0.5 3.5])
        patch([0 0 0.45 0.45], [1.5 2.5 2.5 1.5], barColors(barColorOrderOne(ind), :))
        patch([0.15 0.15 0.45 0.45], [0.5 1.5 1.5 0.5], barColors(barColorOrderTwo(ind), :))
        
        barsPlot.Color = get(gcf,'color');
        barsPlot.YColor = get(gcf,'color');
        barsPlot.XTick = [0 0.15 0.45];
        barsPlot.XTickLabel = [0 0.15 0.45];
        xlabel('Time (s)');
        
        barsPlot = subplot(4, 10, p2);
        axis([0 0.45 -0.5 3.5])
        axis([0 0.45 -0.5 3.5])
        patch([0 0 0.45 0.45], [0.5 1.5 1.5 0.5] + barShift, barColors(barColorOrderOne(ind), :))
        patch([0.15 0.15 0.45 0.45], [1.5 2.5 2.5 1.5] + barShift, barColors(barColorOrderTwo(ind), :))
        
        ind = ind + 1;
        barsPlot.Color = get(gcf,'color');
        barsPlot.YColor = get(gcf,'color');
        barsPlot.XTick = [0 0.15 0.45];
        barsPlot.XTickLabel = [0 0.15 0.45];
        xlabel('Time (s)');
    end

    
end

yLims = [];
cLims = [];
if ~isempty(progHandles)
    for i = 1:length(progHandles)
        progHandles(i).YLabel.String = 'Phase';
        yLims = [yLims get(progHandles(i), 'YLim')'];
        potentialImage = findobj(progHandles(i), 'Type', 'Image');
        if ~isempty(potentialImage)% strcmp(class(potentialImage), 'matlab.graphics.primitive.Image')
            cLims = [cLims [min(potentialImage.CData(:)) max(potentialImage.CData(:))]'];
        end
    end
    
    minY = min(yLims(1, :));
    maxY = max(yLims(2, :));
    
    secondBarDelay = Z.stimulus.params(end).secondBarDelay;
    % Duration is in frames; gotta convert to seconds w/ 60 frames/s number
    barsOff = Z.stimulus.params(end).duration/60;
    for i = 1:length(progHandles)
        set(progHandles(i), 'YLim', [minY, maxY]);
        axes(progHandles(i));
        hold on
        potentialImage = findobj(progHandles(i), 'Type', 'Image');
        if ~isempty(potentialImage)%strcmp(class(potentialImage), 'matlab.graphics.primitive.Image')
            minC = min(cLims(1, :));
            maxC = max(cLims(2, :));
            colormap(b2r(minC, maxC));
        end
        plot([barsOff barsOff], [minY maxY], '--k');
        plot([secondBarDelay secondBarDelay], [minY maxY], '--k');
        plot([0 0], [minY maxY], '--k');
        hold off
        
    end
end