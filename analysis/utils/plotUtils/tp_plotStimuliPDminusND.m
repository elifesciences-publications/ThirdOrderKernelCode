function tp_plotStimuliPDminusND(Z, titleText, epochsForSelectivity, epochsPreferred, epochsNull, epochsUncorrelated, prefColorString, xAxisLabels)

xTickLabels = xAxisLabels.xTickLabels;
xAxisLabel = xAxisLabels.xAxisLabel;

if iscell(Z)
    flyAveragedResponseValues = [];
    for i = 1:length(Z)
        tempZ = Z{i};
        tempZ.params.epochsForSelectivity = epochsForSelectivity;
        tempZ.ROI.roiIndsOfInterest = extractROIsBySelectivity(tempZ);
        tempZ = averageEpochResponseAnalysis(tempZ);
        flyAveragedResponseValues = [flyAveragedResponseValues; nanmean(tempZ.averageEpochResponseAnalysis.dFFEpochValues)];
    end
    Z = tempZ; % We're setting it to the last Z, but we're only gonna use those default values that come with that...
    Z.averageEpochResponseAnalysis.dFFEpochValues = flyAveragedResponseValues;
else
    if ~isfield(Z, 'averageEpochResponseAnalysis')
        Z.params.epochsForSelectivity = epochsForSelectivity;
        Z.ROI.roiIndsOfInterest = extractROIsBySelectivity(Z);
        
        if ~any(Z.ROI.roiIndsOfInterest)
            warning('No ROIs of interest!')
            return
        end
        Z = averageEpochResponseAnalysis(Z);
    end
end

uncorrColor = [0 0 0];
if isequal(prefColorString, 'red')
    prefColor = [1 0 0];
    nullColor = [0 0 1];
elseif isequal(prefColorString, 'blue');
    prefColor = [0 0 1];
    nullColor = [1 0 0];
else
    warning('Color input should only be ''red'' or ''blue''. Preferred color automatically set to red.');
    prefColor = [1 0 0];
    nullColor = [0 0 1];
end

epochNames = {Z.stimulus.params.epochName};
% epochResponse = epochNames{epochsForSelectivity(1)};

lambda = [Z.stimulus.params(epochsPreferred).numDegX];

dataToPlot = Z.averageEpochResponseAnalysis;
dataToPlot.params = Z.stimulus.params;
dataToPlot.roi_image = [];
dataToPlot.roi_data = [];


% preferredDtSweepName = epochNames{epochsPreferred(1)};
% if ~isempty(strfind(preferredDtSweepName(1), 'R'))
%     preferredDtSweepName = 'Right Dt Sweep';
% elseif lower(preferredDtSweepName(1)) == 'l'
%     preferredDtSweepName = 'Left Dt Sweep';
% end
% nullDtSweepName = epochNames{epochsNull(1)};
% if ~isempty(strfind(nullDtSweepName(1), 'L'))
%     nullDtSweepName = 'Left Dt Sweep';
% elseif lower(nullDtSweepName(1)) == 'r'
%     nullDtSweepName = 'Right Dt Sweep';
% end

dataMeanPrefROIPref = nanmean(dataToPlot.dFFEpochValues(:,:,epochsPreferred), 2);
dataMeanPrefROINull = nanmean(dataToPlot.dFFEpochValues(:,:,epochsNull), 2);
dataMeanPrefROIUncorr = nanmean(dataToPlot.dFFEpochValues(:, :, epochsUncorrelated), 2);
plotAverageEpochResponse(reshape(dataMeanPrefROIPref, [1, size(dataMeanPrefROIPref, 1), size(dataMeanPrefROIPref, 3)]),dataToPlot.params, dataToPlot.roi_image, dataToPlot.roi_data, epochsPreferred, prefColor);
plotAverageEpochResponse(reshape(dataMeanPrefROINull, [1, size(dataMeanPrefROINull, 1), size(dataMeanPrefROINull, 3)]),dataToPlot.params, dataToPlot.roi_image, dataToPlot.roi_data, epochsNull, nullColor);
if ~isempty(epochsUncorrelated)
    if length(epochsUncorrelated) ~= 1
        plotAverageEpochResponse(reshape(dataMeanPrefROIUncorr, [1, size(dataMeanPrefROIUncorr, 1), size(dataMeanPrefROIUncorr, 3)]),dataToPlot.params, dataToPlot.roi_image, dataToPlot.roi_data, epochsUncorrelated, uncorrColor);
    else
        plotAverageEpochResponse(repmat(reshape(dataMeanPrefROIUncorr, [1, size(dataMeanPrefROIUncorr, 1), size(dataMeanPrefROIUncorr, 3)]), [1 1 size(dataMeanPrefROIPref, 3)]),dataToPlot.params, dataToPlot.roi_image, dataToPlot.roi_data, repmat(epochsUncorrelated, [length(epochsPreferred), 1]), uncorrColor);
    end
end
% legend({preferredDtSweepName, nullDtSweepName});
% set(gca, 'XTick', 1:length(epochsPreferred));
% xlabel(xAxisLabel);
% set(gca,'XTickLabel',xTickLabels(epochsPreferred));
% set(gca, 'XTickLabelRotation', 45);
% title(titleText)

% plotAverageEpochResponse(reshape(dataMeanPrefROIPref-dataMeanPrefROINull, [1, size(dataMeanPrefROIPref, 1), size(dataMeanPrefROIPref, 3)]),dataToPlot.params, dataToPlot.roi_image, dataToPlot.roi_data, epochsPreferred, [0 0 0]);
% legend({preferredDtSweepName});
set(gca, 'XTick', 1:length(epochsPreferred));
xlabel(xAxisLabel);
set(gca,'XTickLabel', xTickLabels(epochsPreferred));
set(gca, 'XTickLabelRotation', 45);
title(titleText)
disp('done PDminusND')
toc