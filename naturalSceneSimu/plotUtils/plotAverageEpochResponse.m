function plotAverageEpochResponse( dFFEpochValues, params, ~, ~, epochsOfInterest, color, barPlot )

if ~exist('color', 'var')
    color = [1 0 0];
end

if ~exist('barPlot', 'var')
    barPlot = 'line';
else
    barPlot = 'bar';
end

display('plotting')
toc
% for ind = 1:size(dFFEpochValues, 1)
% %     figure
% %     subplot(2, 1, 1)
%     
% %     colors = jet(length(roiData.mask));
% %     colormap(gray(256))
% %     imagesc(roiImage);
% %     axis off
% %     hold on
% %     
% %     roiDisplayImage = zeros([size(roiImage), 3]);
% %     alph = zeros(size(roiImage));
% %     for i = 1:length(roiData.mask)
% %         roiMask = logical(roiData.mask{i});
% %         roi_legend_entry{i} = ['ROI ' num2str(i)];
% % %         x = roiData.points{i}(:, 1);
% % %         y = roiData.points{i}(:, 2);
% %         %It's colors(i+2) because of how the plotting works later on;
% %         %this allows the roi colors to match the signal trace colors
% % %         plot(x, y, 'Color', colors(i+2,:));roiMask = logical(roi_data.mask{i});
% %         otherLayerMask = logical(zeros(size(roiMask)));
% %         alph = alph | roiMask;
% %         roiDisplayImage(cat(3, roiMask, otherLayerMask, otherLayerMask)) = colors(i, 1);
% %         roiDisplayImage(cat(3, otherLayerMask, roiMask, otherLayerMask)) = colors(i, 2);
% %         roiDisplayImage(cat(3, otherLayerMask, otherLayerMask, roiMask)) = colors(i, 3);
% %         patch([0 1 1], [ 0 0 1], colors(i, :));
% % %     x = roi_data.points{i}(:, 1);
% % %     y = roi_data.points{i}(:, 2);
% %     %It's colors(i+2) because of how the plotting works later on;
% %     %this allows the roi colors to match the signal trace colors
% % %     plot(x, y, 'Color', colors(i,:));
% %     end
% %     h = imagesc(roiDisplayImage);
% %     set(h, 'AlphaData', .5*alph);
% % %     end
% %     roi_legend_entry{end+1} = 'Background ROI';
% %     legend(roi_legend_entry);
% %     axis equal
%     
% %     subplot(2, 1, 2)
%     if size(dFFEpochValues, 2) > 1
%         currentEpochDffValues = squeeze(dFFEpochValues(ind, :, :));
%         %Get rid of NaNs that may have come in because of one epoch being
%         %presented more than others
% %         currentEpochDffValues(any(isnan(currentEpochDffValues')), :) = []; 
%     else
%         currentEpochDffValues = squeeze(dFFEpochValues(ind, :, :))';
%     end
%     if size(currentEpochDffValues, 2) > 1
% %         bars = bar(mean(currentEpochDffValues));
%         vals = nanmean(currentEpochDffValues, 1);
%     else
% %         bars = bar(currentEpochDffValues);
%         vals = currentEpochDffValues;
%     end
% %     hold on;
% %     plot(currentEpochDffValues', '*');
% %     hold off;
%     
%     std_epochVals = nanstd(currentEpochDffValues(:, :), 0, 1);
%     % Remember there are padded NaN values for a lot of these! So we sum
%     % the logical of values that aren't NaN
%     sem_epochVals = std_epochVals/sqrt(sum(~isnan(currentEpochDffValues(:, 1, 1))));
% %     bars = bar(epochsOfInterest, squeeze(dFFEpochValues(ind, :, :))', 'stacked');
%     sem_plot_x = 1:size(currentEpochDffValues, 2);
%     sem_plot_y = vals;
%     sem_plot_e = sem_epochVals;
%     %Pretty sure this makes color_1 slightly darker than color_2
%     if size(dFFEpochValues, 1)>1
%         color_1  = color;
%         color_1(color_1 == 0) = 0.8;
%     else
%         color_1 = color;
%     end
% %     color_2 = colors(1, :);
% 
%     hold on
%     PlotXvsY(sem_plot_x, sem_plot_y, 'error', sem_plot_e, 'color', color_1, 'graphType', barPlot);
%     toc
% end

if size(dFFEpochValues, 1)>1
    color_1  = color;
    color_1(color_1 == 0) = 0.8;
else
    color_1 = color;
end
std_epochVals_2 = permute(nanstd(dFFEpochValues, 0, 2), [1 3 2]);
sem_epochVals_2 = std_epochVals_2./permute(sqrt(sum(~isnan(dFFEpochValues), 2)), [1 3 2]);
sem_plot_x_2 = meshgrid(1:size(sem_epochVals_2, 2),1:size(sem_epochVals_2, 1));
sem_plot_y_2 = permute(nanmean(dFFEpochValues, 2), [1 3 2]);
sem_plot_e_2 = sem_epochVals_2;
PlotXvsY(sem_plot_x_2', sem_plot_y_2', 'error', sem_plot_e_2', 'color', color_1, 'graphType', barPlot);
hold on
toc

% Mean plot
if size(dFFEpochValues, 1)>1
    meanYVals = squeeze(nanmean(dFFEpochValues, 2));
    semMeanYVals = nanmean(meanYVals);
    semMeanXVals = sem_plot_x_2(1, :);
    stdMeanEVals = nanstd(meanYVals);
    semMeanEVals = stdMeanEVals/sqrt(size(meanYVals, 1));
    PlotXvsY(semMeanXVals, semMeanYVals, 'error', semMeanEVals, 'color', color, 'graphType', 'line');
end

% epochNames = cell(1, length(epochsOfInterest));
% for i = 1:length(epochsOfInterest)
%     %         set(bars(i), 'EdgeColor', colors(i+2, :));
%     if isfield(params, 'epochName') && ~isempty(params(epochsOfInterest(i)).epochName)
%         epochNames{i} = params(epochsOfInterest(i)).epochName;
%     else
%         epochNames{i} = ['Epoch ' num2str(epochsOfInterest(i))];
%     end
% end
% 
% if verLessThan('matlab', '8.4')
%     set(gca, 'XTick', 1:length(epochsOfInterest));
%     set(gca,'XTickLabel',epochNames);
%     rotateticklabel(gca, 45);
% else
%     set(gca, 'XTick', 1:length(epochsOfInterest));
%     set(gca,'XTickLabel',epochNames);
%     set(gca, 'XTickLabelRotation', 45);
% end
% 
% title(['ROIs 1-' num2str(size(dFFEpochValues, 1))])
% xlabel('Epoch')
% ylabel('DF/F')
disp('done plotting')
toc