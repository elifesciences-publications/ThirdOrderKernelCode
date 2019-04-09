function PlotROITraces( roiTimeTraces, params, epochs, epochToPlot, axesToPlotIn, fps, alignmentData )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% 
% if nargin > 2
%     
%     epochNum = EpochNumsFromName(epochToPlot, {Z.stimulus.params.epochName});
%     boundsForPlot = Z.params.trigger_inds.(['epoch_' num2str(epochNum)]).bounds;
%     indsToPlot = IndexesFromBounds(boundsForPlot);
%     roiTimeTraces = roiTimeTraces(indsToPlot, :);
% else
%     indsToPlot = 1:size(roiTimeTraces, 1);
% end

if ~isempty(epochToPlot)
    epochNum = ConvertEpochNameToIndex(params,epochToPlot);
    indsToPlot = epochs==epochNum;
    roiTimeTraces = roiTimeTraces(indsToPlot, :);
else
    indsToPlot = (1:size(roiTimeTraces, 1))';
end

trace_dists = diff(roiTimeTraces');
plot_sep = 2*nanmean(max(trace_dists)-min(trace_dists));

if nargin > 6
    alignmentShift = sqrt(sum(alignmentData(indsToPlot, 1:2).^2, 2));
else
    alignmentShift = zeros(size(roiTimeTraces, 1), 1);
end
% alignmentShift = alignmentShift/Z.params.imgSize(1);



if isempty(axesToPlotIn)
    MakeFigure;
else
    axes(axesToPlotIn);
end

colors = jet( size(roiTimeTraces, 2)+1);
time_vals = linspace(0, size(roiTimeTraces, 1)/fps, size(roiTimeTraces, 1));
% Average ROI plot
% legend_plots(1) = plot(time_vals, bkgd_intensity(:, 1), 'Color', colors(1, :));

currentAx = gca;
if size(roiTimeTraces, 2) < 50
    hold on;
    % Individual ROI intensities
    legend_entries = cell(1, size(roiTimeTraces, 2));
    for i = 1:size(roiTimeTraces, 2)
        legend_plots(i) = plot(time_vals, roiTimeTraces(:, i)+(i)*plot_sep, 'Color', colors(i, :));
        plot(time_vals, (i)*plot_sep*ones(size(time_vals)), '--', 'Color', colors(i, :));
        legend_entries(i) = {['ROI ' num2str(i)]};
    end
    legend_plots(i+1) = plot(time_vals, alignmentShift, 'Color', colors(end, :));
    legend_entries(i+1) = {'Alignment Percent'};
    %Normalize and shift up the PD signal
    max_signal = max(max([roiTimeTraces]));
    min_signal = min(min([roiTimeTraces]));
    % max_diff = max_signal - min_signal;
    max_diff = max_signal+i*plot_sep-min_signal;
%     time_vals_PD = linspace(0, imgSize(3)/fps, length(avg_linear_PDintensity));
%     legend_plots(end+1) = plot(time_vals_PD,avg_linear_PDintensity/max(avg_linear_PDintensity)*max_diff+min_signal, 'Color', colors(2, :));
    
%     title(sprintf('%s\n%s', fn));
    % legend_entries(1) = {'Background ROI'};
%     for i = 1:size(roiAvgIntensityFilteredNormalized, 2)
%     end
%     legend_entries(end+1) = {'PD Data'};
%     legend_entries(1)=[];
%     legend_plots(1) = [];
    legend(legend_plots, legend_entries);
else
    [ttime, rrois] = meshgrid(time_vals, 0:size(roiTimeTraces, 2)+1);
    
    %         surf(ttime, rrois, roi_avg_intensity_filtered_normalized(:, 2:end)', 'EdgeColor', 'none');
    % Normalize to the max of each trace here
    roiValsForPlotting = roiTimeTraces./(repmat(max(abs(roiTimeTraces)), [size(roiTimeTraces, 1), 1]));
    roiValsForPlotting = [alignmentShift roiValsForPlotting zeros(size(roiValsForPlotting, 1), 1)]'; %We add an extra column to make sure the last ROI gets plotted
    % Set NaNs to zero, so that the colormap sems to ignore them
    roiValsForPlotting(isnan(roiValsForPlotting)) = 0;
    
    %     surf(ttime, rrois, roiValsForPlotting, 'EdgeColor', 'none');
    imagesc([ttime(1) ttime(end)], [rrois(1) rrois(end)], roiValsForPlotting);
    set(currentAx,'YDir','normal');
    colormap(b2r(min(roiValsForPlotting(:)), max(roiValsForPlotting(:))))
    colorbar
    hold on

%     for i = 2:length(Z.grab.alignmentData)
%         xDisp = Z.grab.alignmentData(i,1)-Z.grab.alignmentData(1,1);
%         yDisp = Z.grab.alignmentData(i,2)-Z.grab.alignmentData(1,2);
%         sqdisplacements(i-1) = (xDisp)^2+(yDisp)^2;
%     end
%     sqdisplacements = [0; sqdisplacements];
%     for i = 1:length(Z.grab.alignmentData)
%         xDisp = Z.grab.alignmentData(indsToPlot,1);
%         yDisp = Z.grab.alignmentData(indsToPlot,2);
%         sqdisplacements = (xDisp).^2+(yDisp).^2;
% %     end
%     %sqdisplacements = [0 sqdisplacements];
%      plot(time_vals, sqdisplacements/50);
%      Z.sqDispTimes = time_vals;
%      Z.sqDisps = sqdisplacements;

end


xlabel('Time (s)');
ylabel('\Delta F/F');

if isempty(epochToPlot)
    epochsPlot = unique(epochs);
    epochsPlot(epochsPlot==0)= [];
    ylim = get(currentAx, 'ylim');
    for epochInd = 1:length(epochsPlot)
        epochStarts = find(diff([-1;epochs;-1]==epochInd)==1)';
        epochEnds = find(diff([-1;epochs;-1]==epochInd)==-1)';
        % I think these were here for the version where we didn't delete
        % the beginning and end where there's laser but no stimulus...
%         if any(epochStarts==1)
%             epochEnds(epochStarts==1) = [];
%             epochStarts(epochStarts==1) = [];
%         end
%         if any(epochEnds>=length(epochs))
%             epochStarts(epochEnds>=length(epochs)) = [];
%             epochEnds(epochEnds>=length(epochs)) = [];
%         end
        epochBounds = [epochStarts; epochEnds];
        %     legend_patch_entries(epoch) = {epochs{epoch}};
        for j = 1:size(epochBounds,2)
            x = [epochBounds(:, j)', epochBounds(end:-1:1, j)']/fps;
            y = [ylim(1)-1 ylim(1)-1 ylim(2)+1 ylim(2)+1];
            legend_patch(epochInd) = patch(x, y, [1 1 1], 'FaceColor', 'none');
            xText(epochInd, j) = mean(x);
            %         yText = max(y) - .1*(max(diff(y)));
            epochActual = epochsPlot(epochInd);
            if epochActual ~=0
                if epochActual<=length(params) && isfield(params(epochActual), 'epochName') && ~isempty(params(epochActual).epochName)
                    %             hText = text(xText, yText, params(epoch).epochName, 'FontUnits', 'normalized', 'Rotation', 90, 'HorizontalAlignment', 'left');
                    hText{epochInd, j} = params(epochActual).epochName;
                else
                    %             hText = text(xText, yText, sprintf('%d', epoch), 'FontUnits', 'normalized', 'Rotation', 0, 'HorizontalAlignment', 'center');
                    hText{epochInd, j} = sprintf('Epoch %d', epochInd);
                end
            end
            %         set(hText, 'FontSize', .02);
        end
    end
else
    diffInds = [2; diff(indsToPlot)];
    ylim = get(currentAx, 'ylim');
    linesToPlot = [time_vals(diffInds>1) time_vals(end)];
    
    for i = 1:length(linesToPlot)-1
        x = [linesToPlot([i i+1 i+1 i])];
        y = [ylim(1)-1 ylim(1)-1 ylim(2)+1 ylim(2)+1];
        patch(x, y, [1 1 1], 'FaceColor', 'none');
        xText(i) = mean(x);
        hText{i} = params(epochNum).epochName;
    end
end

xTextLin = xText(xText~=0);
hTextLin = hText(xText~=0);
[xTextSort, sortInd] = sort(xTextLin);
hTextSort = hTextLin(sortInd);

if verLessThan('matlab', '8.4')
    %         position = get(currentAx, 'position');
    xlim = get(currentAx, 'xlim');
    ylim = get(currentAx, 'ylim');
    epochAx =axes('units','normalized','xlim',xlim,'ylim', ylim, 'xtick', xTextSort, 'xticklabel', hTextSort, 'color', 'none', 'ycolor', [0 0 0], 'XAxisLocation', 'top', 'TickLength', [0 0]);
    if isempty(epochToPlot)
        rotateticklabel(epochAx, 90);
    end
else
    epochAx =axes('units','normalized','position',currentAx.Position,'xlim',currentAx.XLim,'ylim', currentAx.YLim, 'xtick', xTextSort, 'xticklabel', hTextSort, 'color', 'none', 'ycolor', 'none', 'XAxisLocation', 'top', 'TickLength', [0 0], 'XTickLabelRotation', 90);
    if ~isempty(epochToPlot)
        epochAx.XTickLabelRotation = 0;
    end
end

uistack(epochAx, 'bottom');
linkaxesProperties([currentAx, epochAx], 'xy', 'Position');
%saveas(gcf, ['plots', filesep, strcat('ROIs False Color', ' ', Z.params.epochsForSelectivity{1})], 'fig');
hold off;


end

