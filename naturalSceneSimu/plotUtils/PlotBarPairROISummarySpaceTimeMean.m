function [figureHandles, axesHandles] = PlotBarPairROISummarySpaceTimeMean(roiSummaryMatrix, respSemOrCompMat, barToCenter, allParamsPlot, dataRate, timeShift, duration, regCheck, numPhases, varargin)

traceColor = varargin([false strcmp(varargin(1:end-1), 'traceColor')]);
if isempty(traceColor)
    traceColor = [ 1 0 0 ];
else
    traceColor = traceColor{1};
end

paramsPlot = allParamsPlot(1);
epochNames = {allParamsPlot.epochName};

plotType = varargin([false strcmp(varargin(1:end-1), 'PlotType')]);

mainFigure = MakeFigure;
mainFigure.Name = 'App mot ';
subRows = 4;

delay = paramsPlot.secondBarDelay;
calciumResponseTime = 0;%seconds
presRate = 60; % Hz
integralEndTime = paramsPlot.duration/presRate+calciumResponseTime;
numTimePoints = size(roiSummaryMatrix, 2);
tVals = linspace(timeShift, timeShift+duration,numTimePoints);
pointsOfInterestForIntegration = tVals>delay & tVals<integralEndTime;

numTimePoints = size(roiSummaryMatrix, 2);
tVals = linspace(timeShift, timeShift+duration,numTimePoints);
if ~isempty(roiSummaryMatrix)
    subFigs = 1:8;
    blockTitles = {'Preferred ++', 'Null ++', 'Preferred --', 'Null --', 'Preferred +-', 'Null +-', 'Preferred -+', 'Null -+'};
    polDirBlockStart = 1:numPhases:numPhases*8;%size(roiSummaryMatrix, 1);
    
    
    barColors = [1 1 1; 0 0 0];
    barColorOrderOne = [1 2 1 2];
    barColorOrderTwo = [1 2 2 1];
    
    secondBarDelay = paramsPlot.secondBarDelay;
    % Duration is in frames; gotta convert to seconds w/ 60 frames/s number
    barsOff = paramsPlot.duration/60;
    
    ind = 0;
    
    for i = 1:length(polDirBlockStart)
        progHandles(i) = FilledSubplot(subRows, 2, subFigs(i));
        tempFig = MakeFigure;
        htMap = subplot(5, 5, [1:3 6:8 11:13 16:18]);
        imagesc(tVals, 0:numPhases-1, roiSummaryMatrix(polDirBlockStart(i):polDirBlockStart(i)+numPhases-1, :));
        title(blockTitles{i});
        timeMean = subplot(5, 5, [4 9 14 19]);
        PlotXvsY(mean(roiSummaryMatrix(polDirBlockStart(i):polDirBlockStart(i)+numPhases-1, pointsOfInterestForIntegration), 2), 0:numPhases-1, 'color', traceColor);
        timeMean.YDir = 'reverse';
        spaceMean = subplot(5, 5, 21:23);
        PlotXvsY(tVals', mean(roiSummaryMatrix(polDirBlockStart(i):polDirBlockStart(i)+numPhases-1, :), 1)');
        axis tight
        subplot(5, 5, 24);
        respsOfInt = roiSummaryMatrix(polDirBlockStart(i):polDirBlockStart(i)+numPhases-1, pointsOfInterestForIntegration)';
        % Plotting the phased responses
        %     progHandles(1) = subplot(subRows, 10, 1:4);
        barPairComboRespOut = mean(respsOfInt(:));
        barPairComboRespOutSem = NanSem(respsOfInt(:), 1);
        PlotXvsY(1, barPairComboRespOut, 'graphType', 'bar', 'error', barPairComboRespOutSem);
        
        barsPlot = subplot(5, 5, [5 10 15 20]);
        progMot = mod(i, 2); % Fast way to alternate true/false starting with false
        ind = ind + mod(i, 2); % We want to add 1 every 2 times
        BarPairPlotSideBySideBarsXT(barsPlot, barsOff, secondBarDelay, barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :), barToCenter, progMot)

        
        % Remember which axes are which
        htMpChldLoc = tempFig.Children == htMap;
        tmLoc = tempFig.Children == timeMean;
        spcLoc = tempFig.Children == spaceMean;
        
        % Move the plot over
        nwAx = MoveFigureToSubplot(tempFig, progHandles(i));
        progHandles(i) = nwAx(htMpChldLoc);
        tmLocHandles(i) = nwAx(tmLoc);
        spcLocHandles(i) = nwAx(spcLoc);
        delete(tempFig);
        if strcmp(plotType, 'SubOpp') && i>=length(polDirBlockStart)/2% Only half the plots if you're subtracting half from the other half!
            break
        end
    end
    
    % Plotting the actual bar alignment
    
%     ind = 1;
%     for i = 5:10:40
% %         if regCheck
% %             p1 = i+1;
% %             p2 = i;
% %         else
%             p1 = i;
%             p2 = i+1;
% %         end
%         barsPlot = subplot(4, 10, p1);
%         progMot = true;
%         BarPairPlotSideBySideBarsXT(barsPlot, barsOff, secondBarDelay, barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :), barToCenter, progMot)
%                 
%         barsPlot = subplot(4, 10, p2);
%         progMot = false;
%         BarPairPlotSideBySideBarsXT(barsPlot, barsOff, secondBarDelay, barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :), barToCenter, progMot)
%         ind = ind+1;
% %         xlabel('Time (s)');
%     end
    
    stillFigure = MakeFigure;
    stillFigure.Name = 'Still ';
    numStillEpochs = numPhases;
    stillEpochsBlockStart = numPhases*8+1:numPhases:size(roiSummaryMatrix, 1);
    if length(stillEpochsBlockStart) == 6
        blockTitles = {'Still ++', 'Still --', 'Still +-', 'Still -+', 'Still +', 'Still -'};
        subFigs = {1:4 7:10 11:14 17:20 21:24 27:30};
        subRows = 3;
    elseif length(stillEpochsBlockStart) == 10
        
        switch paramsPlot.optimalBar
            case 'PlusSingle'
                blockTitles = {'Still ++', 'Still --', 'Still +-', 'Still -+', 'Still N ++', 'Still N --', 'Still N -+', 'Still N +-', 'Still +', 'Still -'};
                stillEpochsBlockStart(7:8) = stillEpochsBlockStart(8:-1:7);
            case 'MinusSingle'
                blockTitles = {'Still ++', 'Still --', 'Still +-', 'Still -+', 'Still N --', 'Still N ++', 'Still N +-', 'Still N -+', 'Still +', 'Still -'};
                stillEpochsBlockStart(5:6) = stillEpochsBlockStart(6:-1:5);
        end
        subFigs = {1:4 7:10 11:14 17:20 21:24 27:30 31:34 37:40 41:44 47:50};
        subRows = 5;
    elseif isempty(stillEpochsBlockStart)
        subRows = 0;
    end
    for i = 1:length(stillEpochsBlockStart)
        stillHandles(i) = subplot(subRows, 10, subFigs{i});
        imagesc(tVals, 0:numPhases-1, roiSummaryMatrix(stillEpochsBlockStart(i):stillEpochsBlockStart(i)+numPhases-1, :));
        title(blockTitles{i});
    end
    
    if subRows
        colStart = 5;
        if any(cellfun(@(nm) ~isempty(nm), strfind(epochNames, 'S++')))
            barColors = [1 1 1; 0 0 0];
            barColorOrderOne = [1 2 1 2];
            barColorOrderTwo = [1 2 2 1];
            ind = 1;
            % Two apart bars
            
            for i = colStart:10:colStart+20-1;
                secondBarDelay = 0;
                %         if regCheck
                %             p1 = i+1;
                %             p2 = i;
                %         else
                p1 = i;
                p2 = i+1;
                %         end
                barsPlot = subplot(subRows, 10, p1);
                axis([0 barsOff -3.5 4.5])
                patch([0 0 barsOff barsOff], [1.5 2.5 2.5 1.5], barColors(barColorOrderOne(ind), :))
                patch([secondBarDelay secondBarDelay barsOff barsOff], [-0.5 0.5 0.5 -0.5], barColors(barColorOrderTwo(ind), :))
                
                hold on
                if barToCenter == 2
                    plot([0,0], [0.5 1.5], 'r', 'LineWidth', 5);
                elseif barToCenter == 1
                    plot([0,0], [1.5 2.5], 'r', 'LineWidth', 5);
                end
                
                ind = ind + 1;
                barsPlot.Color = get(gcf,'color');
                barsPlot.YColor = get(gcf,'color');
                barsPlot.XTick = [0 barsOff];
                barsPlot.XTickLabel = [0 barsOff];
                %             xlabel('Time (s)');
                
                barsPlot = subplot(subRows, 10, p2);
                axis([0 barsOff -3.5 4.5])
                patch([0 0 barsOff barsOff], [1.5 2.5 2.5 1.5], barColors(barColorOrderOne(ind), :))
                patch([secondBarDelay secondBarDelay barsOff barsOff], [-0.5 0.5 0.5 -0.5], barColors(barColorOrderTwo(ind), :))
                
                hold on
                if barToCenter == 2
                    plot([0,0], [0.5 1.5], 'r', 'LineWidth', 5);
                elseif barToCenter == 1
                    plot([0,0], [1.5 2.5], 'r', 'LineWidth', 5);
                end
                
                ind = ind + 1;
                barsPlot.Color = get(gcf,'color');
                barsPlot.YColor = get(gcf,'color');
                barsPlot.XTick = [0 barsOff];
                barsPlot.XTickLabel = [0 barsOff];
                %             xlabel('Time (s)');
            end
            colStart = i+10;
        end
        
        if any(cellfun(@(nm) ~isempty(nm), strfind(epochNames, 'Sn++')))
            % Neighboring bars
            barColors = [1 1 1; 0 0 0];
            switch paramsPlot.optimalBar
                case 'PlusSingle'
                    barColorOrderOne = [1 2 2 1];
                    barColorOrderTwo = [1 2 1 2];
                case 'MinusSingle'
                    barColorOrderOne = [2 1 1 2];
                    barColorOrderTwo = [2 1 2 1];
            end
            ind = 1;
            for i = colStart:10:colStart+20-1
                secondBarDelay = 0;
                %         if regCheck
                %             p1 = i+1;
                %             p2 = i;
                %         else
                p1 = i;
                p2 = i+1;
                %         end
                barsPlot = subplot(subRows, 10, p1);
                axis([0 barsOff -3.5 4.5])
                patch([0 0 barsOff barsOff], [1.5 2.5 2.5 1.5], barColors(barColorOrderOne(ind), :))
                patch([secondBarDelay secondBarDelay barsOff barsOff], [0.5 1.5 1.5 0.5], barColors(barColorOrderTwo(ind), :))
                
                hold on
                if barToCenter == 2
                    plot([0,0], [0.5 1.5], 'r', 'LineWidth', 5);
                elseif barToCenter == 1
                    plot([0,0], [1.5 2.5], 'r', 'LineWidth', 5);
                end
                
                ind = ind + 1;
                barsPlot.Color = get(gcf,'color');
                barsPlot.YColor = get(gcf,'color');
                barsPlot.XTick = [0 barsOff];
                barsPlot.XTickLabel = [0 barsOff];
                %             xlabel('Time (s)');
                
                barsPlot = subplot(subRows, 10, p2);
                axis([0 barsOff -3.5 4.5])
                patch([0 0 barsOff barsOff], [0.5 1.5 1.5 0.5], barColors(barColorOrderOne(ind), :))
                patch([secondBarDelay secondBarDelay barsOff barsOff], [-0.5 0.5 0.5 -0.5], barColors(barColorOrderTwo(ind), :))
                
                hold on
                if barToCenter == 2
                    plot([0,0], [0.5 1.5], 'r', 'LineWidth', 5);
                elseif barToCenter == 1
                    plot([0,0], [1.5 2.5], 'r', 'LineWidth', 5);
                end
                
                ind = ind + 1;
                barsPlot.Color = get(gcf,'color');
                barsPlot.YColor = get(gcf,'color');
                barsPlot.XTick = [0 barsOff];
                barsPlot.XTickLabel = [0 barsOff];
                %             xlabel('Time (s)');
            end
            colStart = i+10;
        end
        
        if any(cellfun(@(nm) ~isempty(nm), strfind(epochNames, 'Sh+')))
            barDelay = 0;
            
            % Half bars
            barColors = [1 1 1; 0 0 0];
            barColorOrderOne = [1 2];
            ind = 1;
            for i = colStart:10:colStart+10-1
                secondBarDelay = 0;
                %         if regCheck
                %             p1 = i+1;
                %             p2 = i;
                %         else
                p1 = i;
                p2 = i+1;
                %         end
                barsPlot = subplot(subRows, 10, p1);
                BarPairPlotSingleBarsXT(barsPlot, barsOff/2, barDelay, barColors(barColorOrderOne(ind), :), barsOff);
                
                
                ind = ind + 1;
                barsPlot = subplot(subRows, 10, p2);
                BarPairPlotSingleBarsXT(barsPlot, barsOff/2, barDelay, barColors(barColorOrderOne(ind), :), barsOff);

            end
            colStart = i+10;
        end
        
        if any(cellfun(@(nm) ~isempty(nm), strfind(epochNames, 'Ss+')))
            barDelay = 0;
            barsOffShort = 0.15;
            
            % Half bars
            barColors = [1 1 1; 0 0 0];
            barColorOrderOne = [1 2];
            ind = 1;
            for i = colStart:10:colStart+10-1
                secondBarDelay = 0;
                %         if regCheck
                %             p1 = i+1;
                %             p2 = i;
                %         else
                p1 = i;
                p2 = i+1;
                %         end
                barsPlot = subplot(subRows, 10, p1);
                BarPairPlotSingleBarsXT(barsPlot, barsOffShort, barDelay, barColors(barColorOrderOne(ind), :), barsOff);
                
                
                ind = ind + 1;
                barsPlot = subplot(subRows, 10, p2);
                BarPairPlotSingleBarsXT(barsPlot, barsOffShort, barDelay, barColors(barColorOrderOne(ind), :), barsOff);

            end
            colStart = i+10;
        end
        
        if any(cellfun(@(nm) ~isempty(nm), strfind(epochNames, 'S+')))
            % Single bars
            barColors = [1 1 1; 0 0 0];
            barColorOrderOne = [1 2];
            ind = 1;
            for i = colStart:10:colStart+10-1
                secondBarDelay = 0;
                %         if regCheck
                %             p1 = i+1;
                %             p2 = i;
                %         else
                p1 = i;
                p2 = i+1;
                %         end
                barsPlot = subplot(subRows, 10, p1);
                axis([0 barsOff -3.5 4.5])
                patch([secondBarDelay secondBarDelay barsOff barsOff], [0.5 1.5 1.5 0.5], barColors(barColorOrderOne(ind), :))
                
                hold on
                if barToCenter == 2
                    plot([0,0], [0.5 1.5], 'r', 'LineWidth', 5);
                elseif barToCenter == 1
                    plot([0,0], [1.5 2.5], 'r', 'LineWidth', 5);
                end
                
                ind = ind + 1;
                barsPlot.Color = get(gcf,'color');
                barsPlot.YColor = get(gcf,'color');
                barsPlot.XTick = [0 barsOff];
                barsPlot.XTickLabel = [0 barsOff];
                %             xlabel('Time (s)');
                
                barsPlot = subplot(subRows, 10, p2);
                axis([0 barsOff -3.5 4.5])
                patch([secondBarDelay secondBarDelay barsOff barsOff], [0.5 1.5 1.5 0.5], barColors(barColorOrderOne(ind), :))
                
                hold on
                if barToCenter == 2
                    plot([0,0], [0.5 1.5], 'r', 'LineWidth', 5);
                elseif barToCenter == 1
                    plot([0,0], [1.5 2.5], 'r', 'LineWidth', 5);
                end
                
                ind = ind + 1;
                barsPlot.Color = get(gcf,'color');
                barsPlot.YColor = get(gcf,'color');
                barsPlot.XTick = [0 barsOff];
                barsPlot.XTickLabel = [0 barsOff];
                %             xlabel('Time (s)');
                
                if barToCenter == 2
                    plot([0,0], [0.5 1.5], 'r', 'LineWidth', 5);
                elseif barToCenter == 1
                    plot([0,0], [1.5 2.5], 'r', 'LineWidth', 5);
                end
            end
        end
    end
    
end


%% Prettify motion axes
yLims = [];
cLims = [];
tmXLims = [];
spcYLims = [];
if ~isempty(progHandles)
    for i = 1:length(progHandles)
        progHandles(i).YLabel.String = 'Phase';
        yLims = [yLims get(progHandles(i), 'YLim')'];
        potentialImage = findobj(progHandles(i), 'Type', 'Image');
        if ~isempty(potentialImage)% strcmp(class(potentialImage), 'matlab.graphics.primitive.Image')
            cLims = [cLims [min(potentialImage.CData(:)) max(potentialImage.CData(:))]'];
        end
        tmXLims = [tmXLims tmLocHandles(i).XLim'];
        spcYLims = [spcYLims spcLocHandles(i).YLim'];
    end
    
    minY = min(yLims(1, :));
    maxY = max(yLims(2, :));
    
    minTmX = min(tmXLims(1, :));
    maxTmX = max(tmXLims(2, :));
    
    minSpcY = min(spcYLims(1, :));
    maxSpcY = max(spcYLims(2, :));
    
    [tmLocHandles.XLim] = deal([minTmX maxTmX]);
    [spcLocHandles.YLim] = deal([minSpcY maxSpcY]);
    
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
    
    [progHandles.XTickLabel] = deal([]);
    [tmLocHandles.YTickLabel] = deal([]);
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
    barsOff = paramsPlot.duration/60;
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
    stillHandles = [];
    close(stillFigure)
end

axesHandles = [progHandles stillHandles];
figureHandles = [mainFigure(isvalid(mainFigure)) stillFigure(isvalid(stillFigure))];