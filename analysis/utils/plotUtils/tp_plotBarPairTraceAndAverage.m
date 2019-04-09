function tp_plotBarPairTraceAndAverage(epochAvgTriggeredIntensitiesPref, stepsBack, fsAligned, epochsToPlotPref, epochsToPlotNull, colorForPlotPref, colorForPlotNull)

if ~exist('colorForPlotPref', 'var')
    colorForPlotPref = [1 0 0];
    colorForPlotNull = [0 0 1];
end


responseIntensities = zeros([size(epochAvgTriggeredIntensitiesPref.(['epoch_' num2str(epochsToPlotPref(1))])),length(epochsToPlotPref)]);
for epochInd = 1:length(epochsToPlotPref)
    responseIntensities(:, 1:size(epochAvgTriggeredIntensitiesPref.(['epoch_' num2str(epochsToPlotPref(epochInd))]), 2), epochInd) = epochAvgTriggeredIntensitiesPref.(['epoch_' num2str(epochsToPlotPref(epochInd))]);
end

meanIntensities = mean(responseIntensities, 3);

respIntNull = zeros([size(epochAvgTriggeredIntensitiesPref.(['epoch_' num2str(epochsToPlotNull(1))])),length(epochsToPlotNull)]);
for epochInd = 1:length(epochsToPlotNull)
    respIntNull(:, 1:size(epochAvgTriggeredIntensitiesPref.(['epoch_' num2str(epochsToPlotNull(epochInd))]), 2), epochInd) = epochAvgTriggeredIntensitiesPref.(['epoch_' num2str(epochsToPlotNull(epochInd))]);
end
meanIntNull = mean(respIntNull, 3);

%     subplot(2, 1, 2)
% if size(triggeredEpochTraces, 2) > 1
%     currentEpochDffValues = squeeze(triggeredEpochTraces(ind, :, :));
%     %Get rid of NaNs that may have come in because of one epoch being
%     %presented more than others
%     %         currentEpochDffValues(any(isnan(currentEpochDffValues')), :) = [];
% else
%     currentEpochDffValues = squeeze(triggeredEpochTraces(ind, :, :))';
% end
% if size(currentEpochDffValues, 2) > 1
%     %         bars = bar(mean(currentEpochDffValues));
%     vals = nanmean(currentEpochDffValues, 1);
% else
%     %         bars = bar(currentEpochDffValues);
%     vals = currentEpochDffValues;
% end
%     hold on;
%     plot(currentEpochDffValues', '*');
%     hold off;

% std_epochVals = nanstd(currentEpochDffValues(:, :), 0, 1);
% % Remember there are padded NaN values for a lot of these! So we sum
% % the logical of values that aren't NaN
% sem_epochVals = std_epochVals/sqrt(sum(~isnan(currentEpochDffValues(:, 1, 1))));
% %     bars = bar(epochsOfInterest, squeeze(dFFEpochValues(ind, :, :))', 'stacked');
% sem_plot_x = 1:size(currentEpochDffValues, 2);
% sem_plot_y = vals;
% sem_plot_e = sem_epochVals;
%Pretty sure this makes color_1 slightly darker than color_2
if size(meanIntensities, 1)>1
    color_1  = colorForPlotPref;
    color_1(color_1 == 0) = 0.8;
else
    color_1 = colorForPlotPref;
end
%     color_2 = colors(1, :);

xVals = -stepsBack:size(meanIntensities, 2)-stepsBack-1;
tVals = xVals./(fsAligned);

hold on
plot(tVals, meanIntensities, 'Color', color_1);



% Mean plot pref dir
if size(meanIntensities, 1)>1
    semMeanYVals = nanmean(meanIntensities, 1);
    semMeanXVals = tVals;
    stdMeanEVals = nanstd(meanIntensities);
    semMeanEVals = stdMeanEVals/sqrt(size(meanIntensities, 1));
    plot_err_patch(semMeanXVals, semMeanYVals, semMeanEVals, colorForPlotPref);
end

% Mean plot null dir
xVals = -stepsBack:size(meanIntNull, 2)-stepsBack-1;
tVals = xVals./(fsAligned);
semMeanYVals = nanmean(meanIntNull, 1);
semMeanXVals = tVals;
stdMeanEVals = nanstd(meanIntNull);
semMeanEVals = stdMeanEVals/sqrt(size(meanIntNull, 1));
plot_err_patch(semMeanXVals, semMeanYVals, semMeanEVals, colorForPlotNull);

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

title(['ROIs 1-' num2str(size(meanIntensities, 1))])
xlabel('Time (s)')
ylabel('DF/F')
axis tight