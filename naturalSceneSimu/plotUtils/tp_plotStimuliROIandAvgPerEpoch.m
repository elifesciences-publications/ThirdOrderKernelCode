function tp_plotStimuliROIandAvgPerEpoch(Z, titleText, epochsForSelectivity, epochsPreferred, epochsNull, prefColorString, labelAxes, xAxisLabels)



if nargin<7
    labelAxes=false;
else
    labelAxes=true;
    xTickLabels = xAxisLabels.xTickLabels;
    xAxisLabel = xAxisLabels.xAxisLabel;
end

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
            warning('No ROIs of interest!');
            return
        end
        disp('averaging');
        Z = averageEpochResponseAnalysis(Z);
        toc
    end
end

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
if iscell(epochsForSelectivity)
    epochResponse = epochsForSelectivity{1};
else
    epochResponse = epochNames{epochsForSelectivity(1)};
end


dataToPlot = Z.averageEpochResponseAnalysis;
dataToPlot.params = Z.stimulus.params;
dataToPlot.roi_image = [];
dataToPlot.roi_data = [];
plotAverageEpochResponse(dataToPlot.dFFEpochValues(:,:,epochsPreferred),dataToPlot.params, dataToPlot.roi_image, dataToPlot.roi_data, epochsPreferred, prefColor);

disp('start rest')
toc
% plotAverageEpochResponse(nanmean(dataToPlot.dFFEpochValues(:,:,epochsNull)),dataToPlot.params, dataToPlot.roi_image, dataToPlot.roi_data, dataToPlot.epochsOfInterest(epochsNull), nullColor);
if labelAxes
    set(gca, 'XTick', 1:length(epochsPreferred));
    toc
    xlabel(xAxisLabel);
    set(gca,'XTickLabel', xTickLabels(epochsPreferred));
    toc
    % set(gca, 'XTickLabelRotation', 45);
    if ~isempty(titleText)
        title([epochResponse ' Responsive ROIs']);
    end
    toc
    axisLims = axis;
    text(axisLims(2), axisLims(4), sprintf('# ROIs = %d', size(dataToPlot.dFFEpochValues,1)), 'VerticalAlignment', 'Top', 'HorizontalAlignment', 'Right')
    toc
else
    set(gca, 'XTick', 1:length(epochsPreferred));
    set(gca, 'XTickLabel', []);
end

disp('done ROIandAvg')
toc