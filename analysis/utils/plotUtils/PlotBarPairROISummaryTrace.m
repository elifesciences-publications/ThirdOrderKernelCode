function [figureHandles, axesHandles] = PlotBarPairROISummaryTrace(roiSummaryMatrix, respSemOrCompMat, barToCenter, allParamsPlot, dataRate, timeShift, duration, regCheck, numPhases, varargin)

paramsPlot = allParamsPlot(1);
epochNames = {allParamsPlot.epochName};

iteration = varargin{[false strcmp(varargin(1:end-1), 'iteration')]};

plotType = varargin{[false strcmp(varargin(1:end-1), 'PlotType')]};


traceColor = varargin([false strcmp(varargin(1:end-1), 'traceColor')]);
if isempty(traceColor)
    traceColor = [ 1 0 0 ];
else
    traceColor = traceColor{1}{iteration};
end

figurePlotName = varargin([false strcmp(varargin(1:end-1), 'figurePlotName')]);
if isempty(figurePlotName)
    figureHandles = MakeFigure;
else
    figurePlotName = figurePlotName{1};
    if strcmp(plotType, 'Real')
        figurePlot = findobj('Type', 'Figure', 'UserData', figurePlotName);
        if isempty(figurePlot)
            figurePlot = MakeFigure;
            figurePlot.UserData = figurePlotName;
        end
    else
        figurePlot = MakeFigure;
    end
    figureHandles = figure(figurePlot);
end

plotType = varargin([false strcmp(varargin(1:end-1), 'PlotType')]);



subRows = 8;

numTimePoints = size(roiSummaryMatrix, 2);
tVals = linspace(timeShift, timeShift+duration,numTimePoints);
if ~isempty(roiSummaryMatrix)
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
        
        secondBarDelay = paramsPlot.secondBarDelay;
        % Duration is in frames; gotta convert to seconds w/ 60 frames/s number
        barsOff = paramsPlot.duration/60;
%         warning('This might shouldn''t be commented out...');
%         if regCheck
%             p1 = i+1;
%             p2 = i;
%         else
            p1 = i;
            p2 = i+1;
%         end
        barsPlot = subplot(subRows, 2, p1); cla
        progMot = true;
        BarPairPlotSideBySideBarsXT(barsPlot, barsOff, secondBarDelay, barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :), barToCenter, progMot)
%         hold on
%         axis([tVals(1) tVals(end) -0.5 2.5])
%         patch([0 0 barsOff barsOff], [1.5 2.5 2.5 1.5], barColors(barColorOrderOne(ind), :))
%         patch([secondBarDelay secondBarDelay barsOff barsOff], [0.5 1.5 1.5 0.5], barColors(barColorOrderTwo(ind), :))
%         
%         barsPlot.Color = get(gcf,'color');
%         barsPlot.YColor = get(gcf,'color');
%         barsPlot.XTick = [0 secondBarDelay barsOff];
%         barsPlot.XTickLabel = [0 secondBarDelay barsOff];
%         xlabel('Time (s)');
        
        barsPlot = subplot(subRows, 2, p2); cla
        progMot = false;
        BarPairPlotSideBySideBarsXT(barsPlot, barsOff, secondBarDelay, barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :), barToCenter, progMot)
        ind = ind+1;
%         hold on
%         axis([tVals(1) tVals(end) -0.5 2.5])
%         patch([0 0 barsOff barsOff], [0.5 1.5 1.5 0.5] + barShift, barColors(barColorOrderOne(ind), :))
%         patch([secondBarDelay secondBarDelay barsOff barsOff], [1.5 2.5 2.5 1.5] + barShift, barColors(barColorOrderTwo(ind), :))
%         
%         ind = ind + 1;
%         barsPlot.Color = get(gcf,'color');
%         barsPlot.YColor = get(gcf,'color');
%         barsPlot.XTick = [0 secondBarDelay barsOff];
%         barsPlot.XTickLabel = [0 secondBarDelay barsOff];
%         xlabel('Time (s)');
    end
    
    phaseCenter = 4;
    subSpots = {3 4 7 8 11 12 15 16};
    if false;%isempty(figurePlotName)
        blockTitles = {'Preferred ++', 'Null ++', 'Preferred --', 'Null --', 'Preferred +-', 'Null +-', 'Preferred -+', 'Null -+'};
    else
        blockTitles = {'Progressive ++', 'Regressive ++', 'Progressive --', 'Regressive --', 'Progressive +-', 'Regressive +-', 'Progressive -+', 'Regressive -+'};
    end
    polDirBlockStart = 1:numPhases:numPhases*8;%size(roiSummaryMatrix, 1);
    for i = 1:length(polDirBlockStart)
        progHandles(i) = subplot(subRows, 2, subSpots{i});
%         if size(roiSummaryMatrix, 3) == 1
            respsOfInt = mean(roiSummaryMatrix(phaseCenter+(i-1)*numPhases, :, :), 3)';
            if strcmp(plotType, 'Real')
                errsOfInt = NanSem(roiSummaryMatrix(phaseCenter+(i-1)*numPhases, :, :), 3)';
                PlotXvsY(tVals', respsOfInt, 'error', errsOfInt, 'color', traceColor);
                zVals = respsOfInt./errsOfInt;
                
                % MULTIPLE COMPARISONS
                pVal = 0.01;
                multipleComps = 4; % The four cell types in this phase combo
                pValCorr = pVal/multipleComps;
                zValSig = norminv(1-pValCorr);
                
                %             responseLines = progHandles(i).Children.findobj('Type', 'Line');
                %             lineColors = cat(1, responseLines.Color);
                %             avgLines = any(lineColors==0, 2) & ~all(lineColors==0, 2);
                %             numLines = sum(avgLines);
                
                hold on
                plot(tVals(zVals>zValSig), respsOfInt(zVals>zValSig), '*', 'MarkerSize', 10);
                hold off
            elseif strcmp(plotType, 'SubOpp')
                semMat = NanSem(respSemOrCompMat, 3);
                progHandles(i) = subplot(subRows, 2, subSpots{2*i-1}); % This lets us go down the rows in this case
                errsOfInt = semMat(phaseCenter+(i-1)*numPhases, :)';
                PlotXvsY(tVals', respsOfInt, 'error', errsOfInt, 'color', traceColor);
                zVals = respsOfInt./errsOfInt;
                
                phaseVals = squeeze(respSemOrCompMat(phaseCenter+(i-1)*numPhases, :, :));
                % Run through each time point and see that it's
                % significant--they're down the rows b/c of squeeze
                for tPt = 1:size(phaseVals, 1)
                    compMedian = mean(phaseVals(tVals<0, :), 1);
                    pValsST(tPt) = signrank(phaseVals(tPt, :)', compMedian);
                end
               
                % MULTIPLE COMPARISONS
                pVal = 0.01;
                multipleComps = 4; % The four cell types in this phase combo
                pValCorr = pVal/multipleComps;
                
                %             responseLines = progHandles(i).Children.findobj('Type', 'Line');
                %             lineColors = cat(1, responseLines.Color);
                %             avgLines = any(lineColors==0, 2) & ~all(lineColors==0, 2);
                %             numLines = sum(avgLines);
%                 
                hold on
                plot(tVals(pValsST<pValCorr), respsOfInt(pValsST<pValCorr), '*', 'MarkerSize', 10);
                hold off
                
            elseif any(strcmp(plotType, {'LinModel', 'NeighModel'}))
                realData = respSemOrCompMat(phaseCenter+(i-1)*numPhases, :)';
                PlotXvsY(tVals', respsOfInt, 'color', traceColor, 'lineStyle', '--');
                hold on
                PlotXvsY(tVals', realData, 'color', traceColor, 'lineStyle', '-');
            else
                PlotXvsY(tVals', respsOfInt, 'color', traceColor);
            end
%             PlotXvsY(tVals', respsOfInt,'color', traceColor);

            
           
            
            
            
%             PlotXvsY(tVals', roiSummaryMatrix(phaseCenter+(i-1)*numPhases, :)', 'color', traceColor);
%         else
%             PlotXvsY(tVals', permute(roiSummaryMatrix(phaseCenter+(i-1)*numPhases, :, :), [2 3 1]), 'color', traceColor);
%         end
        title(blockTitles{i});
        
        responseLines = progHandles(i).Children.findobj('Type', 'Line');
        lineColors = cat(1, responseLines.Color);
        avgLines = any(lineColors==0, 2) & ~all(lineColors==0, 2);
        uistack(responseLines(avgLines), 'top')
        if any(avgLines)
            [responseLines(avgLines).LineWidth] = deal(2);
        end
        
        lineMarkers = {responseLines.Marker};
        legendLines = avgLines & strcmp(lineMarkers, 'none')';
        
        if strcmp(plotType, 'SubOpp') && i>=length(polDirBlockStart)/2% Only half the plots if you're subtracting half from the other half!
            break
        end
    end
    
    
    legend(responseLines(legendLines), { 'T5 Reg','T5 Prog', 'T4 Reg','T4 Prog'  });
    
    
    

    
end

yLims = [];
cLims = [];
if ~isempty(progHandles)
    for i = 1:length(progHandles)
        progHandles(i).YLabel.String = '\Delta F/F';
        errBarsOrLines = progHandles(i).Children.findobj('Type', 'ErrorBar');
        errBarsOrLines = [errBarsOrLines; progHandles(i).Children.findobj('Type', 'Line')];
        for errBarInd = 1:length(errBarsOrLines)
            yLims = [yLims [min(errBarsOrLines(errBarInd).YData); max(errBarsOrLines(errBarInd).YData)]];
        end
        potentialImage = findobj(progHandles(i), 'Type', 'Image');
        if ~isempty(potentialImage)% strcmp(class(potentialImage), 'matlab.graphics.primitive.Image')
            cLims = [cLims [min(potentialImage.CData(:)) max(potentialImage.CData(:))]'];
        end
        
    end
    
    minY = min(yLims(1, :));
    maxY = max(yLims(2, :));
    
    secondBarDelay = paramsPlot.secondBarDelay;
    % Duration is in frames; gotta convert to seconds w/ 60 frames/s number
    barsOff = paramsPlot.duration/60;
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

axesHandles = progHandles;