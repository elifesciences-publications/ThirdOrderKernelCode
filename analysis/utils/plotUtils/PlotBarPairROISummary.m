function [figureHandles, axesHandles] = PlotBarPairROISummary(roiSummaryMatrix, ~, barToCenter, allParamsPlot, dataRate, timeShift, duration, regCheck, numPhases, varargin)


paramsPlot = allParamsPlot(1);
epochNames = {allParamsPlot.epochName};


mainFigure = MakeFigure;
mainFigure.Name = 'App mot ';
subRows = 4;
plotType = varargin([false strcmp(varargin(1:end-1), 'PlotType')]);

numTimePoints = size(roiSummaryMatrix, 2);
tVals = linspace(timeShift, timeShift+duration,numTimePoints);
if ~isempty(roiSummaryMatrix)
    subCols = {1:4 7:10 11:14 17:20 21:24 27:30 31:34 37:40};
    blockTitles = {'Preferred ++', 'Null ++', 'Preferred --', 'Null --', 'Preferred +-', 'Null +-', 'Preferred -+', 'Null -+'};
    polDirBlockStart = 1:numPhases:numPhases*8;%size(roiSummaryMatrix, 1);
    
    
    for i = 1:length(polDirBlockStart)
        progHandles(i) = subplot(subRows, 10, subCols{i});
        imagesc(tVals, 0:numPhases-1, nanmean(roiSummaryMatrix(polDirBlockStart(i):polDirBlockStart(i)+numPhases-1, :, :), 3));
        title(blockTitles{i});
        if strcmp(plotType, 'SubOpp') && i>=length(polDirBlockStart)/2%
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
    
    ind = 1;
    for i = 5:10:40
        secondBarDelay = paramsPlot.secondBarDelay;
        % Duration is in frames; gotta convert to seconds w/ 60 frames/s number
        barsOff = paramsPlot.duration/60;
%         if regCheck
%             p1 = i+1;
%             p2 = i;
%         else
            p1 = i;
            p2 = i+1;
%         end
        barsPlot = subplot(4, 10, p1);
        axis([0 barsOff -3.5 4.5])
        patch([0 0 barsOff barsOff], [1.5 2.5 2.5 1.5], barColors(barColorOrderOne(ind), :))
        patch([secondBarDelay secondBarDelay barsOff barsOff], [0.5 1.5 1.5 0.5], barColors(barColorOrderTwo(ind), :))
        
        hold on
        if barToCenter == 2
            plot([0,0], [0.5 1.5], 'r', 'LineWidth', 5);
        elseif barToCenter == 1
            plot([0,0], [1.5 2.5], 'r', 'LineWidth', 5);
        end
        
        barsPlot.Color = get(gcf,'color');
        barsPlot.YColor = get(gcf,'color');
        barsPlot.XTick = [0 secondBarDelay barsOff];
        barsPlot.XTickLabel = [0 secondBarDelay barsOff];
%         xlabel('Time (s)');
        
        barsPlot = subplot(4, 10, p2);
        axis([0 barsOff -3.5 4.5])
        patch([0 0 barsOff barsOff], [0.5 1.5 1.5 0.5] + barShift, barColors(barColorOrderOne(ind), :))
        patch([secondBarDelay secondBarDelay barsOff barsOff], [1.5 2.5 2.5 1.5] + barShift, barColors(barColorOrderTwo(ind), :))
        
        hold on
        if barToCenter == 2
            plot([0,0], [0.5 1.5], 'r', 'LineWidth', 5);
        elseif barToCenter == 1
            plot([0,0], [1.5 2.5], 'r', 'LineWidth', 5);
        end
        
        ind = ind + 1;
        barsPlot.Color = get(gcf,'color');
        barsPlot.YColor = get(gcf,'color');
        barsPlot.XTick = [0 secondBarDelay barsOff];
        barsPlot.XTickLabel = [0 secondBarDelay barsOff];
%         xlabel('Time (s)');
    end
    
    stillFigure = MakeFigure;
    stillFigure.Name = 'Still ';
    numStillEpochs = numPhases;
    stillEpochsBlockStart = numPhases*8+1:numPhases:size(roiSummaryMatrix, 1);
    if length(stillEpochsBlockStart) == 6
        blockTitles = {'Still ++', 'Still --', 'Still +-', 'Still -+', 'Still +', 'Still -'};
        subCols = {1:4 7:10 11:14 17:20 21:24 27:30};
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
        subCols = {1:4 7:10 11:14 17:20 21:24 27:30 31:34 37:40 41:44 47:50};
        subRows = 5;
    elseif isempty(stillEpochsBlockStart)
        subRows = 0;
    end
    for i = 1:length(stillEpochsBlockStart)
        stillHandles(i) = subplot(subRows, 10, subCols{i});
        imagesc(tVals, 0:numPhases-1, nanmean(roiSummaryMatrix(stillEpochsBlockStart(i):stillEpochsBlockStart(i)+numPhases-1, :, :), 3));
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