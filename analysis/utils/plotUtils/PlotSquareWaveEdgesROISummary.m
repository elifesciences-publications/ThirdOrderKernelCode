function [figureHandles, axesHandles] = PlotSquareWaveEdgesROISummary(roiSummaryMatrix, ~, barToCenter, allParamsPlot, ~, timeShift, duration, regCheck, numPhases, varargin)



paramsPlot = allParamsPlot(1);

% MakeFigure;
subRows = 4;
colsPerRow = 10;

numTimePoints = size(roiSummaryMatrix, 2);
tVals = linspace(timeShift, timeShift+duration,numTimePoints);
if ~isempty(roiSummaryMatrix)
    
    % For xtPlotNeeded, S is single, E is edges, D is double
    stillFigHandle = MakeFigure;
    stillFigHandle.Name = 'Edges ';
    numStillEpochs = numPhases;
    stillEpochsBlockStart = 1:numPhases:size(roiSummaryMatrix, 1);
    if length(stillEpochsBlockStart) == 2
        blockTitles = {'Still +', 'Still -'};
        subCols = {1:4 7:10};
        subRows = 1;
        xtPlotsNeeded = 'S';
    elseif length(stillEpochsBlockStart) == 4
        switch paramsPlot.optimalBar
            case 'PlusSingle'
                blockTitles = {'Still -+', 'Still +-', 'Still +', 'Still -'};
                stillEpochsBlockStart(1:2) = stillEpochsBlockStart(2:-1:1);
            case 'MinusSingle'
                blockTitles = {'Still +-', 'Still -+', 'Still +', 'Still -'};
        end
        subCols = {2:10 11:14 17:20};
        subRows = 2;
        % We're naming ON for optimal-nonoptimal based on response expectationg here...
        phasesPerBar = paramsPlot.barWd/paramsPlot.phaseShift;
        
        
        if regCheck
            edgeONResp = roiSummaryMatrix(stillEpochsBlockStart(1):stillEpochsBlockStart(1)+numPhases-1, :, :);
            edgeNOResp = roiSummaryMatrix(stillEpochsBlockStart(2):stillEpochsBlockStart(2)+numPhases-1, :, :);
            edgeNOResp = circshift(edgeNOResp, [-(phasesPerBar-1) 0]); % This three is because there were 4 phasesPerBar for the edge responses...
            edgesResp = mean(cat(4, edgeONResp, edgeNOResp), 4);
        else
            edgeONResp = roiSummaryMatrix(stillEpochsBlockStart(2):stillEpochsBlockStart(2)+numPhases-1, :, :);
            edgeNOResp = roiSummaryMatrix(stillEpochsBlockStart(1):stillEpochsBlockStart(1)+numPhases-1, :, :);
            edgeNOResp = circshift(edgeNOResp, [(phasesPerBar-1) 0]); % This three is because there were 4 phasesPerBar for the edge responses...
            edgesResp = mean(cat(4, edgeONResp, edgeNOResp), 4);
        end
        
        roiSummaryMatrix(stillEpochsBlockStart(2):stillEpochsBlockStart(2)+numPhases-1, :, :) = edgesResp;
        % We won't plot the other, unaveraged, edges
        stillEpochsBlockStart(1) = [];
        blockTitles(1) = [];
        xtPlotsNeeded = 'ES';
    elseif length(stillEpochsBlockStart) == 10
        % NOT CURRENTLY USED
        switch paramsPlot.optimalBar
            case 'PlusSingle'
                blockTitles = {'Still ++', 'Still --', 'Still +-', 'Still -+', 'Still N ++', 'Still N --', 'Still N -+', 'Still N +-', 'Still +', 'Still -'};
                stillEpochsBlockStart(7:8) = stillEpochsBlockStart(8:-1:7);
            case 'MinusSingle'
                blockTitles = {'Still ++', 'Still --', 'Still +-', 'Still -+', 'Still N --', 'Still N ++', 'Still N +-', 'Still N -+', 'Still +', 'Still -'};
                stillEpochsBlockStart(5:6) = stillEpochsBlockStart(6:-1:5);
        end
        subCols = {1:4 7:10 11:14 17:20 21:24 27:30 31:34 37:40 41:44 47:50};
        subRows = 5;
        xtPlotsNeeded = 'ED';
    elseif isempty(stillEpochsBlockStart)
        subRows = 0;
    end
    % We know the input roiSummaryMatrix is rotated so the two edges are
    % displaced--here we rotate on of them back for the average (we can do
    % a simple average because the flies see the same amount of each
    % stimulus)
    
    for i = 1:length(stillEpochsBlockStart-1)
        stillHandles(i) = subplot(subRows, colsPerRow, subCols{i});
        imagesc(tVals, 0:numPhases-1, nanmean(roiSummaryMatrix(stillEpochsBlockStart(i):stillEpochsBlockStart(i)+numPhases-1, :, :), 3));
        title(blockTitles{i});
    end
    
    if subRows
        
        startingCol = colsPerRow/2; % Everything up to that halfway column is the heatmap of responses
        for i = 1:length(xtPlotsNeeded)
            
            switch xtPlotsNeeded(i)
                case 'S'
                    numPlots = 2;
                    startingColsEachRow = startingCol:colsPerRow:(startingCol+(numPlots/2)*colsPerRow-1);
                    % One light bar, one dark bar
                    barsOff = paramsPlot(1).duration/60;
                    barColors = [1 1 1; 0 0 0];
                    barColorOrderOne = [1 2];
                    barDelay = 0;
                    ind = 1;
                    for strtCols = startingColsEachRow
                        p1 = strtCols;
                        p2 = strtCols+1;
                        barsPlot = subplot(subRows, 10, p1);
                        BarPairPlotSingleBarsXT(barsPlot, barsOff, barDelay, barColors(barColorOrderOne(ind), :))
                        hold on
                        if barToCenter == 2
                            plot([0,0], [0.5 1.5], 'r', 'LineWidth', 5);
                        elseif barToCenter == 1
                            plot([0,0], [1.5 2.5], 'r', 'LineWidth', 5);
                        end
                        ind = ind + 1;
                        
                        barsPlot = subplot(subRows, 10, p2);
                        BarPairPlotSingleBarsXT(barsPlot, barsOff, barDelay, barColors(barColorOrderOne(ind), :))
                        hold on
                        if barToCenter == 2
                            plot([0,0], [0.5 1.5], 'r', 'LineWidth', 5);
                        elseif barToCenter == 1
                            plot([0,0], [1.5 2.5], 'r', 'LineWidth', 5);
                        end
                        ind = ind + 1;
                    end
                case 'E'
                    numPlots = 2; % One +- edge, one -+ edge
                    startingColHere = floor(startingCol/colsPerRow)+1; % The starting col will always be the first for edges
                    startingColsEachRow = startingCol:colsPerRow:(startingCol+(numPlots/2)*colsPerRow-1); %Keeping this for how we progress startingCol at the end of the for loop
                    
                    barsOff = paramsPlot.duration/60;
                    barColors = [1 1 1; 0 0 0];
                    switch paramsPlot.optimalBar
                        case 'PlusSingle'
                            barColorOrderOne = [2 2];
                            barColorOrderTwo = [1 1];
                        case 'MinusSingle'
                            barColorOrderOne = [1 1];
                            barColorOrderTwo = [2 2];
                    end
                    ind = 1;
                    for strtCol = startingColHere
                        p1 = strtCol;
                        %NOTE: the combination of regCheck and progMot don't necessarily make much sense here--try to assume they're legacy                    
                        if regCheck
                            barsPlot = subplot(subRows, colsPerRow, p1);
                            progMot = true;
                            BarPairPlotEdgesXT(barsPlot, barsOff, barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :), barToCenter, progMot)
                            ind = ind+1;
                        else
                            barsPlot = subplot(subRows, colsPerRow, p1);
                            progMot = false;
                            BarPairPlotEdgesXT(barsPlot, barsOff,  barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :), barToCenter, progMot)
                            ind = ind+1;
                        end
                        hold on
                        if barToCenter == 2
                            plot([0,0], [0.5 1.5], 'r', 'LineWidth', 5);
                        elseif barToCenter == 1
                            plot([0,0], [1.5 2.5], 'r', 'LineWidth', 5);
                        end
                    end
                case 'D'
                    % TODO: CORRECT
                    secondBarDelay = 0;
                    BarPairPlotOneApartBarsXT(barsPlot, bothBarsOff, secondBarDelay, barColorOne, barColorTwo)
            end
            startingCol = startingColsEachRow(end) + colsPerRow;
        end
        
       
    end
    
end



%% Prettify still axes
yLims = [];
cLims = [];
% Using an exist instead of presetting stillHandles to an empty vector
% because that latter one breaks the contents of the graphics object vector
% and instead makes it a vector of handles grrr
if exist('stillHandles', 'var') && ~isempty(stillHandles)
    for i = 1:length(stillHandles)
        stillHandles(i).YLabel.String = 'Phase';
        yLims = [yLims get(stillHandles(i), 'YLim')'];
        potentialImage = findobj(stillHandles(i), 'Type', 'Image');
        if ~isempty(potentialImage)% strcmp(class(potentialImage), 'matlab.graphics.primitive.Image')
            cLims = [cLims [min(potentialImage.CData(:)) max(potentialImage.CData(:))]'];
        end
    end
    
    minY = min(yLims(1, :));
    maxY = max(yLims(2, :));
    
    secondBarDelay = paramsPlot.secondBarDelay;
    % Duration is in frames; gotta convert to seconds w/ 60 frames/s number
    barsOff = paramsPlot(1).duration/60;
    for i = 1:length(stillHandles)
        set(stillHandles(i), 'YLim', [minY, maxY]);
        axes(stillHandles(i));
        hold on
        potentialImage = findobj(stillHandles(i), 'Type', 'Image');
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
else
    close(stillFigure)
end

axesHandles = [stillHandles];
figureHandles = [stillFigHandle];