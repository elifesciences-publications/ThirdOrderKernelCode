function [figureHandles, axesHandles, barPairComboRespOut] = PlotBarPairROISummaryPoint(roiSummaryMatrix, respSemOrCompMat, barToCenter, allParamsPlot, dataRate, timeShift, duration, regCheck, numPhases, varargin)

paramsPlot = allParamsPlot(1);


plotType = varargin([false strcmp(varargin(1:end-1), 'PlotType')]);

traceColor = varargin([false strcmp(varargin(1:end-1), 'traceColor')]);
if isempty(traceColor)
    traceColor = [ 1 0 0 ];
else
    traceColor = traceColor{1};
end

figurePlotName = varargin([false strcmp(varargin(1:end-1), 'figurePlotName')]);
if isempty(figurePlotName)
    figureHandles = MakeFigure;
else
    figurePlotName = figurePlotName{1};
    figureHandles = findobj('Type', 'Figure', 'Name', figurePlotName);
    if isempty(figureHandles)
        figureHandles = MakeFigure;
        figureHandles.Name = figurePlotName;
    end
    figure(figureHandles);
end

prefDirFields = varargin([false strcmp(varargin(1:end-1), 'preferredDirectionFields')]);
if isempty(prefDirFields)
    prefDirFields = {'PPlusPref', 'PMinusPref'};
else
    prefDirFields = prefDirFields{1};
end

% MakeFigure;
subRows = 4;

if ~isfield(paramsPlot, 'firstBarDelay')
    firstBarDelay = 0;
else
    firstBarDelay = paramsPlot.firstBarDelay;
end
secondBarDelay = paramsPlot.secondBarDelay;
calciumResponseTime = 0;%seconds
presRate = 60; % Hz
integralEndTime = paramsPlot.duration/presRate+calciumResponseTime;
numTimePoints = size(roiSummaryMatrix, 2);
tVals = linspace(timeShift, timeShift+duration,numTimePoints);
pointsOfInterestForAveraging = find(tVals>secondBarDelay & tVals<integralEndTime);

polDirBlockStart = 1:numPhases:numPhases*8;%size(roiSummaryMatrix, 1);
barPairComboRespOut = zeros(2, length(polDirBlockStart)/2); %Pref vs Null by polarities, so 2x4
barPairComboRespOutSem = zeros(2, length(polDirBlockStart)/2); %Pref vs Null by polarities, so 2x4
meanIndResps = zeros(size(roiSummaryMatrix, 3), length(polDirBlockStart)/2);
for i = 1:length(polDirBlockStart)
    phaseCenter = 4;
    respsOfInt = roiSummaryMatrix(phaseCenter+(i-1)*numPhases, pointsOfInterestForAveraging, :);
    % Plotting the phased responses
%     progHandles(1) = subplot(subRows, 10, 1:4);
    meanIndResps(:, i) = reshape(mean(respsOfInt, 2), [], 1); % individual ROI or fly means--i.e. individual data points
    barPairComboRespOut(i) = mean(meanIndResps(:, i)); %  Overall mean
    barPairComboRespOutSem(i) = NanSem(meanIndResps(:, i), 1); % Overall Sem
    sigs(i) = signtest(meanIndResps(:, i));
%     tp_plotTraceAndAverage(epochAvgAnalysisProg, stepsBack, fsAligned, PPlusPref, [], [1 0 0], [0 0 1], shift)
    if strcmp(plotType, 'SubOpp') && i>=length(polDirBlockStart)/2% Only half the plots if you're subtracting half from the other half!
            break
    end
    
end
    
    
    
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
    
    axesHandles = subplot(2, 1, 2); hold on;
    barPairComboRespOut = barPairComboRespOut(:);
    barPairComboRespOutSem = barPairComboRespOutSem(:)';
    if ~isempty(axesHandles.Children.findobj('Type', 'Bar'))
        barGraphs = axesHandles.Children.findobj('Type', 'Bar');
        currCols = colormap;
        currDat = cat(1, barGraphs.YData);
        cla;
        newCols = [currCols; traceColor];
        newDat = [currDat(end:-1:1, :)' barPairComboRespOut];
%         colormap(newCols);
%         bar(1:length(barPairComboRespOut), newDat);
        PlotXvsY(1:length(barPairComboRespOut), newDat, 'graphType', 'bar', 'color', newCols);
        PlotConstLine(0, 1);
    else
%         PlotXvsY((1:length(barPairComboRespOut))', barPairComboRespOut, 'error', barPairComboRespOutSem, 'significance', sigs, 'graphType', 'bar', 'color', traceColor);
        PlotXvsY(repmat((1:size(meanIndResps, 2)), size(meanIndResps, 1), 1), meanIndResps, 'error', barPairComboRespOutSem(1:size(meanIndResps, 2)), 'significance', sigs, 'graphType', 'spread', 'color', traceColor, 'connect', true);
        PlotConstLine(0, 1);
        ConfAxis
    end
%     legend({'T4 Prog',  'T4 Reg', 'T5 Prog', 'T5 Reg'});
    ylabel('Average \Delta F/F');
    title(sprintf('Average \Delta F/F from %ss to %ss', secondBarDelay, duration));
%     axis tight;
    
    ind = 1;
    for i = 1:4
%         if regCheck
%             p1 = i+1;
%             p2 = i;
%         else
%             p1 = i;
%             p2 = i+1;
%         end
        barsPlot = subplot(2, 8, i*2-1); cla

        progMot = true;
        barsOff = paramsPlot.duration/60;
        BarPairPlotSideBySideBarsXT(barsPlot, barsOff, secondBarDelay, barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :), barToCenter, progMot)

        barsPlot = subplot(2, 8, i*2); cla   
        
        progMot = false;
        BarPairPlotSideBySideBarsXT(barsPlot, barsOff, secondBarDelay, barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :), barToCenter, progMot)
        ind = ind+1;
        
    end


% yLims = [];
% cLims = [];
% if ~isempty(progHandles)
%     for i = 1:length(progHandles)
%         progHandles(i).YLabel.String = 'Phase';
%         yLims = [yLims get(progHandles(i), 'YLim')'];
%         potentialImage = findobj(progHandles(i), 'Type', 'Image');
%         if ~isempty(potentialImage)% strcmp(class(potentialImage), 'matlab.graphics.primitive.Image')
%             cLims = [cLims [min(potentialImage.CData(:)) max(potentialImage.CData(:))]'];
%         end
%     end
%     
%     minY = min(yLims(1, :));
%     maxY = max(yLims(2, :));
%     
%     secondBarDelay = params(end).secondBarDelay;
%     % Duration is in frames; gotta convert to seconds w/ 60 frames/s number
%     barsOff = params(end).duration/60;
%     for i = 1:length(progHandles)
%         set(progHandles(i), 'YLim', [minY, maxY]);
%         axes(progHandles(i));
%         hold on
%         potentialImage = findobj(progHandles(i), 'Type', 'Image');
%         if ~isempty(potentialImage)%strcmp(class(potentialImage), 'matlab.graphics.primitive.Image')
%             minC = min(cLims(1, :));
%             maxC = max(cLims(2, :));
%             colormap(b2r(minC, maxC));
%         end
%         plot([barsOff barsOff], [minY maxY], '--k');
%         plot([secondBarDelay secondBarDelay], [minY maxY], '--k');
%         plot([0 0], [minY maxY], '--k');
%         hold off
%         
%     end
% end