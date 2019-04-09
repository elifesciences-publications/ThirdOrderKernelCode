function out = PlotBarPairROISummaryTrace(roiAveragedResponses, roiAveragedResponsesSEM, plottingEpochs, barToCenter, params, dataRate, timeShift, duration, regCheck)

out = [];
PPlusPref = plottingEpochs.PPlusPref;
PPlusNull = plottingEpochs.PPlusNull;
PMinusPref = plottingEpochs.PMinusPref;
PMinusNull = plottingEpochs.PMinusNull;
NPlusPref = plottingEpochs.NPlusPref;
NPlusNull = plottingEpochs.NPlusNull;
NMinusPref = plottingEpochs.NMinusPref;
NMinusNull = plottingEpochs.NMinusNull;



% We try to align them all to the 3rd bar, assuming that the preferred
% direction positive correlations will have the maximum responses
meanPPlusPref = mean(cat(2, roiAveragedResponses{PPlusPref, 1}));
meanPMinusPref = mean(cat(2, roiAveragedResponses{PMinusPref, 1}));
[maxPP, locMPP] = max(meanPPlusPref);
[maxPM, locMPM] = max(meanPMinusPref);

numPhases = length(PPlusPref);
halfPoint = round(numPhases/2);
if maxPP>=maxPM
    shift = halfPoint - locMPP;
else
    shift = halfPoint - locMPM;
end

MakeFigure;
subRows = 8;

numTimePoints = length(roiAveragedResponses{PPlusPref(1), 1});
tVals = linspace(timeShift, timeShift+duration,numTimePoints);
if ~isempty(roiAveragedResponses)
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
    for i = 1:4:subRows*2
        if regCheck
            p1 = i+1;
            p2 = i;
        else
            p1 = i;
            p2 = i+1;
        end
        barsPlot = subplot(subRows, 2, p1);
        hold on
        axis([tVals(1) tVals(end) -0.5 2.5])
        patch([0 0 0.45 0.45], [1.5 2.5 2.5 1.5], barColors(barColorOrderOne(ind), :))
        patch([0.15 0.15 0.45 0.45], [0.5 1.5 1.5 0.5], barColors(barColorOrderTwo(ind), :))
        
        barsPlot.Color = get(gcf,'color');
        barsPlot.YColor = get(gcf,'color');
        barsPlot.XTick = [0 0.15 0.45];
        barsPlot.XTickLabel = [0 0.15 0.45];
        xlabel('Time (s)');
        
        barsPlot = subplot(subRows, 2, p2);
        hold on
        axis([tVals(1) tVals(end) -0.5 2.5])
        patch([0 0 0.45 0.45], [0.5 1.5 1.5 0.5] + barShift, barColors(barColorOrderOne(ind), :))
        patch([0.15 0.15 0.45 0.45], [1.5 2.5 2.5 1.5] + barShift, barColors(barColorOrderTwo(ind), :))
        
        ind = ind + 1;
        barsPlot.Color = get(gcf,'color');
        barsPlot.YColor = get(gcf,'color');
        barsPlot.XTick = [0 0.15 0.45];
        barsPlot.XTickLabel = [0 0.15 0.45];
        xlabel('Time (s)');
    end
    
    phaseCenter = 4;
    % Plotting the phased responses
    barPairCombo = PPlusPref;
    progHandles(1) = subplot(subRows, 2, 3);
    barPairComboResp = cat(2, roiAveragedResponses{barPairCombo, 1})';
    barPairComboResp = circshift(barPairComboResp, shift);
    barPairComboRespSEM = cat(2, roiAveragedResponsesSEM{barPairCombo, 1})';
    barPairComboRespSEM = circshift(barPairComboRespSEM, shift);
    PlotXvsY(tVals', barPairComboResp(phaseCenter, :)', 'error', barPairComboRespSEM(phaseCenter, :)');
%     plot(tVals, pplusPrefResp(phaseCenter, :));
%     imagesc(tVals, 0:numPhases-1, pplusPrefResp);
%     tp_plotTraceAndAverage(epochAvgAnalysisProg, stepsBack, fsAligned, PPlusPref, [], [1 0 0], [0 0 1], shift)
    title('Preferred ++')
    
    barPairCombo = PMinusPref;
    progHandles(2) = subplot(subRows, 2, 7);
    barPairComboResp = cat(2, roiAveragedResponses{barPairCombo, 1})';
    barPairComboResp = circshift(barPairComboResp, shift);
    barPairComboRespSEM = cat(2, roiAveragedResponsesSEM{barPairCombo, 1})';
    barPairComboRespSEM = circshift(barPairComboRespSEM, shift);
    PlotXvsY(tVals', barPairComboResp(phaseCenter, :)', 'error', barPairComboRespSEM(phaseCenter, :)');
%     plot(tVals, pminusPrefResp(phaseCenter, :));
%     imagesc(tVals, 0:numPhases-1, pminusPrefResp);
%     tp_plotTraceAndAverage(epochAvgAnalysisProg, stepsBack, fsAligned, PMinusPref, [], [1 0 0], [0 0 1], shift)
    title('Preferred --')
    
    barPairCombo = NPlusPref;
    progHandles(3) = subplot(subRows, 2, 11);
    barPairComboResp = cat(2, roiAveragedResponses{barPairCombo, 1})';
    barPairComboResp = circshift(barPairComboResp, shift);
    barPairComboRespSEM = cat(2, roiAveragedResponsesSEM{barPairCombo, 1})';
    barPairComboRespSEM = circshift(barPairComboRespSEM, shift);
    PlotXvsY(tVals', barPairComboResp(phaseCenter, :)', 'error', barPairComboRespSEM(phaseCenter, :)');
%     imagesc(tVals, 0:numPhases-1, nplusPrefResp);
%     tp_plotTraceAndAverage(epochAvgAnalysisProg, stepsBack, fsAligned, NPlusPref, [], [1 0 0], [0 0 1], shift)
    title('Preferred +-')
    
    barPairCombo = NMinusPref;
    progHandles(4) = subplot(subRows, 2, 15);
    barPairComboResp = cat(2, roiAveragedResponses{barPairCombo, 1})';
    barPairComboResp = circshift(barPairComboResp, shift);
    barPairComboRespSEM = cat(2, roiAveragedResponsesSEM{barPairCombo, 1})';
    barPairComboRespSEM = circshift(barPairComboRespSEM, shift);
    PlotXvsY(tVals', barPairComboResp(phaseCenter, :)', 'error', barPairComboRespSEM(phaseCenter, :)');
%     nminusPrefResp = circshift(nminusPrefResp, shift);
%     plot(tVals, nminusPrefResp(phaseCenter, :));
%     imagesc(tVals, 0:numPhases-1, nminusPrefResp);
%     tp_plotTraceAndAverage(epochAvgAnalysisProg, stepsBack, fsAligned, NMinusPref, [], [1 0 0], [0 0 1], shift)
    title('Preferred -+')
%     text(0.75, 0, Z.ROI.typeFlagName(Z.ROI.roiIndsOfInterest));
    
%     subplot(subRows, 10, 41:44)
%     tp_plotTraceAndAverage(Z.triggeredResponseAnalysis.epochAvgTriggeredIntensities, stepsBack, fsAligned, PPlusPref, [], [1 0 0], [ 0 0 1]);
    
    barPairCombo = PPlusNull;
    progHandles(5) = subplot(subRows, 2, 4);
    barPairComboResp = cat(2, roiAveragedResponses{barPairCombo, 1})';
    barPairComboResp = circshift(barPairComboResp, shift);
    barPairComboRespSEM = cat(2, roiAveragedResponsesSEM{barPairCombo, 1})';
    barPairComboRespSEM = circshift(barPairComboRespSEM, shift);
    PlotXvsY(tVals', barPairComboResp(phaseCenter, :)', 'error', barPairComboRespSEM(phaseCenter, :)');
%     imagesc(tVals, 0:numPhases-1, pplusNullResp);
%     tp_plotTraceAndAverage(epochAvgAnalysisProg, stepsBack, fsAligned, PPlusNull, [], [1 0 0], [0 0 1], shift)
    title('Null ++')
    
    barPairCombo = PMinusNull;
    progHandles(6) = subplot(subRows, 2, 8);
    barPairComboResp = cat(2, roiAveragedResponses{barPairCombo, 1})';
    barPairComboResp = circshift(barPairComboResp, shift);
    barPairComboRespSEM = cat(2, roiAveragedResponsesSEM{barPairCombo, 1})';
    barPairComboRespSEM = circshift(barPairComboRespSEM, shift);
    PlotXvsY(tVals', barPairComboResp(phaseCenter, :)', 'error', barPairComboRespSEM(phaseCenter, :)');
%     imagesc(tVals, 0:numPhases-1, pminusNullResp);
%     tp_plotTraceAndAverage(epochAvgAnalysisProg, stepsBack, fsAligned, PMinusNull, [], [1 0 0], [0 0 1], shift)
    title('Null --')
    
    barPairCombo = NPlusNull;
    progHandles(7) = subplot(subRows, 2, 12);
    barPairComboResp = cat(2, roiAveragedResponses{barPairCombo, 1})';
    barPairComboResp = circshift(barPairComboResp, shift);
    barPairComboRespSEM = cat(2, roiAveragedResponsesSEM{barPairCombo, 1})';
    barPairComboRespSEM = circshift(barPairComboRespSEM, shift);
    PlotXvsY(tVals', barPairComboResp(phaseCenter, :)', 'error', barPairComboRespSEM(phaseCenter, :)');
%     imagesc(tVals, 0:numPhases-1, nplusNullResp);
%     tp_plotTraceAndAverage(epochAvgAnalysisProg, stepsBack, fsAligned, NPlusNull, [], [1 0 0], [0 0 1], shift)
    title('Null +-')
    
    barPairCombo = NMinusNull;
    progHandles(8) = subplot(subRows, 2, 16);
    barPairComboResp = cat(2, roiAveragedResponses{barPairCombo, 1})';
    barPairComboResp = circshift(barPairComboResp, shift);
    barPairComboRespSEM = cat(2, roiAveragedResponsesSEM{barPairCombo, 1})';
    barPairComboRespSEM = circshift(barPairComboRespSEM, shift);
    PlotXvsY(tVals', barPairComboResp(phaseCenter, :)', 'error', barPairComboRespSEM(phaseCenter, :)');
%     imagesc(tVals, 0:numPhases-1, nminusNullResp);
%     tp_plotTraceAndAverage(epochAvgAnalysisProg, stepsBack, fsAligned, NMinusNull, [], [1 0 0], [0 0 1], shift)
    title('Null -+')
%     text(0.75, 0, Z.ROI.typeFlagName(Z.ROI.roiIndsOfInterest));
    
    
    
    
    

    
end

yLims = [];
cLims = [];
if ~isempty(progHandles)
    for i = 1:length(progHandles)
        progHandles(i).YLabel.String = '\Delta F/F';
        yLims = [yLims [min(progHandles(i).Children.findobj('Type', 'ErrorBar').YData); max(progHandles(i).Children.findobj('Type', 'ErrorBar').YData)]];
        potentialImage = findobj(progHandles(i), 'Type', 'Image');
        if ~isempty(potentialImage)% strcmp(class(potentialImage), 'matlab.graphics.primitive.Image')
            cLims = [cLims [min(potentialImage.CData(:)) max(potentialImage.CData(:))]'];
        end
    end
    
    minY = min(yLims(1, :));
    maxY = max(yLims(2, :));
    
    secondBarDelay = params(PPlusPref(1)).secondBarDelay;
    % Duration is in frames; gotta convert to seconds w/ 60 frames/s number
    barsOff = params(end).duration/60;
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