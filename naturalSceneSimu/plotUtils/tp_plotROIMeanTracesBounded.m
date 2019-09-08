function tp_plotROIMeanTracesBounded( Z, traceBounds, color )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


loadFlexibleInputs(Z)

if nargin<2 || isempty(traceBounds)
    traceBounds = [1, size(Z.filtered.roi_avg_intensity_filtered_normalized, 1)];
elseif ischar(traceBounds)
    epochNum = find(strcmp({Z.stimulus.params.epochName}, traceBounds));
    if isempty(epochNum)
        error(['Epoch ' traceBounds ' not found']);
    end
    epochInfo = Z.params.trigger_inds.(['epoch_' num2str(epochNum)]);
    traceBounds = round(epochInfo.bounds(:, 1)+[-epochInfo.stim_length; epochInfo.stim_length]./2);
end
if nargin<3
    color = [0 0 1];
end

roiAvgIntensityFilteredNormalized = Z.filtered.roi_avg_intensity_filtered_normalized;
if isfield(Z.ROI, 'roiIndsOfInterest')
    indsToPlot = Z.ROI.roiIndsOfInterest;%subtract one to get rid of average ind
    if ~any(indsToPlot)
        warning('No roiIndsOfInterest were extracted! Plotting all ROI values');
    else
        roiAvgIntensityFilteredNormalized = roiAvgIntensityFilteredNormalized(:, indsToPlot);
    end
end

params = Z.stimulus.params;
roiAvgTrace = mean(roiAvgIntensityFilteredNormalized, 2);

if ~ishold
    MakeFigure
colors = jet( size(roiAvgIntensityFilteredNormalized, 2));
plotBounds = traceBounds(1):traceBounds(2);
timeVals = linspace(0, imgSize(3)/fps, length(roiAvgIntensityFilteredNormalized));
plot(timeVals(plotBounds), roiAvgTrace(plotBounds), 'Color', color);



epochs = fields(trigger_inds);
ylim = get(gca, 'ylim');
traceBoundTimes = traceBounds/fs;
for epoch = 1:length(epochs)
    epoch_bounds = trigger_inds.(epochs{epoch}).bounds;
    %     legend_patch_entries(epoch) = {epochs{epoch}};
    for j = 1:size(epoch_bounds,2)
        x = [epoch_bounds(:, j)', epoch_bounds(end:-1:1, j)']/fs;
        if x(1)>traceBoundTimes(1) && x(2)<traceBoundTimes(2)
            y = [ylim(1)-1 ylim(1)-1 diff(ylim) diff(ylim)];
            legend_patch(epoch) = patch(x, y, [1 1 1], 'FaceColor', 'none');
            xText(epoch, j) = mean(x);
            %         yText = max(y) - .1*(max(diff(y)));
            if epoch<=length(params) && isfield(params(epoch), 'epochName') && ~isempty(params(epoch).epochName)
                %             hText = text(xText, yText, params(epoch).epochName, 'FontUnits', 'normalized', 'Rotation', 90, 'HorizontalAlignment', 'left');
                hText{epoch, j} = params(epoch).epochName;
            else
                %             hText = text(xText, yText, sprintf('%d', epoch), 'FontUnits', 'normalized', 'Rotation', 0, 'HorizontalAlignment', 'center');
                hText{epoch, j} = sprintf('Epoch %d', epoch);
            end
            %         set(hText, 'FontSize', .02);
        elseif traceBoundTimes(1)>x(1) && traceBoundTimes(2) < x(2)
            y = [ylim(1)-1 ylim(1)-1 diff(ylim) diff(ylim)];
            legend_patch(epoch) = patch(x, y, [1 1 1], 'FaceColor', 'none');
            xText(epoch, j) = mean(traceBoundTimes);
            %         yText = max(y) - .1*(max(diff(y)));
            if epoch<=length(params) && isfield(params(epoch), 'epochName') && ~isempty(params(epoch).epochName)
                %             hText = text(xText, yText, params(epoch).epochName, 'FontUnits', 'normalized', 'Rotation', 90, 'HorizontalAlignment', 'left');
                hText{epoch, j} = params(epoch).epochName;
            else
                %             hText = text(xText, yText, sprintf('%d', epoch), 'FontUnits', 'normalized', 'Rotation', 0, 'HorizontalAlignment', 'center');
                hText{epoch, j} = sprintf('Epoch %d', epoch);
            end
        end
    end
end

xTextLin = xText(xText~=0);
hTextLin = hText(xText~=0);
[xTextSort, sortInd] = sort(xTextLin);
hTextSort = hTextLin(sortInd);

currentAx = gca;
if verLessThan('matlab', '8.4')
    %         position = get(currentAx, 'position');
    xlim = get(currentAx, 'xlim');
    ylim = get(currentAx, 'ylim');
    epochAx =axes('units','normalized','xlim',xlim,'ylim', ylim, 'xtick', xTextSort, 'xticklabel', hTextSort, 'color', 'none', 'ycolor', [0 0 0], 'XAxisLocation', 'top', 'TickLength', [0 0]);
    rotateticklabel(epochAx, 90);
else
    epochAx =axes('units','normalized','position',currentAx.Position,'xlim',currentAx.XLim,'ylim', currentAx.YLim, 'xtick', xTextSort, 'xticklabel', hTextSort, 'color', 'none', 'ycolor', 'none', 'XAxisLocation', 'top', 'TickLength', [0 0], 'XTickLabelRotation', 90);
end

linkaxesProperties([currentAx, epochAx], 'xy', 'Position');

hold off;
else
    
plotBounds = traceBounds(1):traceBounds(2);
timeVals = linspace(-epochInfo.stim_length, epochInfo.stim_length, length(plotBounds))/fs;
plot(timeVals, roiAvgTrace(plotBounds), 'Color', color);
end


end


