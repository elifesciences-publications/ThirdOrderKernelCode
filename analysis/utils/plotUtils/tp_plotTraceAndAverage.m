function tp_plotTraceAndAverage(epochAvgTriggeredIntensitiesPref, stepsBack, fsAligned, epochsToPlotPref, epochsToPlotNull, colorForPlotPref, colorForPlotNull, shift)
% So sorries shift is just there for bar pairs >.>

if ~exist('colorForPlotPref', 'var')
    colorForPlotPref = [1 0 0];
    colorForPlotNull = [0 0 1];
end

if exist('shift', 'var') && ~isempty(shift)
    barPair = true;
else
    barPair = false;
end


meanIntensities = zeros([size(epochAvgTriggeredIntensitiesPref.(['epoch_' num2str(epochsToPlotPref(1))])),length(epochsToPlotPref)]);
for epochInd = 1:length(epochsToPlotPref)
    meanIntensities(:, 1:size(epochAvgTriggeredIntensitiesPref.(['epoch_' num2str(epochsToPlotPref(epochInd))]), 2), epochInd) = epochAvgTriggeredIntensitiesPref.(['epoch_' num2str(epochsToPlotPref(epochInd))]);
    
end
if barPair
    if length(shift) == 1
        shift = repmat(shift, 1, size(meanIntensities, 1));
    end
    for i = 1:size(meanIntensities, 1)
        meanIntensities(i, :, :) = circshift(meanIntensities(i, :, :), -shift(i), 3);
    end
end
% meanIntensities = mean(responseIntensities, 3);

if ~isempty(epochsToPlotNull)
    meanIntNull = zeros([size(epochAvgTriggeredIntensitiesPref.(['epoch_' num2str(epochsToPlotNull(1))])),length(epochsToPlotNull)]);
    for epochInd = 1:length(epochsToPlotNull)
        meanIntNull(:, 1:size(epochAvgTriggeredIntensitiesPref.(['epoch_' num2str(epochsToPlotNull(epochInd))]), 2), epochInd) = epochAvgTriggeredIntensitiesPref.(['epoch_' num2str(epochsToPlotNull(epochInd))]);
    end
else
    meanIntNull = [];
end
% meanIntNull = mean(respIntNull, 3);


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
% We only draw individual traces like this if we have a single epoch
if size(meanIntensities, 3) == 1
    plot(tVals, meanIntensities, 'Color', color_1);
else
    % Average down the ROIs, though honestly this should only happen when
    % the average is already put in
    stdMeanIntEVals = nanstd(meanIntensities, 0, 1);
    stdMeanIntNullEVals = nanstd(meanIntNull, 0, 1);
    meanIntensities = nanmean(meanIntensities, 1);
    meanIntNull = nanmean(meanIntNull, 1);
    meanIntensitiesImage = permute(meanIntensities, [3 2 1]);
    meanIntNullImage = permute(meanIntNull, [3 2 1]);
    
%     semMeanDiffEVals = (stdMeanIntEVals+stdMeanIntNullEVals)/sqrt(size(meanIntensities, 1)); 
%     semMeanDiffEVals = permute(semMeanDiffEVals, [3 2 1]);
%     meanIntDiffImage((abs(meanIntDiffImage)-semMeanDiffEVals/2)<0) = 0;
    
    semMeanIntEVals =  (stdMeanIntEVals)/sqrt(size(meanIntensities, 1)); 
    semMeanIntEVals = permute(semMeanIntEVals, [3 2 1]);
    if isempty(meanIntNull)
%         meanIntensitiesImage((abs(meanIntensitiesImage)-semMeanIntEVals)<0) = 0;
        imagesc(tVals, [0 length(epochsToPlotPref(end))-1], meanIntensitiesImage);
    else
        meanIntDiffImage = meanIntensitiesImage - meanIntNullImage;
        imagesc(tVals, [0 length(epochsToPlotPref(end))-1], meanIntDiffImage);
    end
    set(gca,'YDir','reverse');
end



% Mean plot pref dir
if size(meanIntensities, 1)>1
    semMeanYVals = nanmean(meanIntensities, 1);
    semMeanXVals = tVals;
    stdMeanEVals = nanstd(meanIntensities);
    semMeanDiffEVals = stdMeanEVals/sqrt(size(meanIntensities, 1));
    plot_err_patch(semMeanXVals, semMeanYVals, semMeanDiffEVals, colorForPlotPref);
end

% Mean plot null dir
if size(meanIntNull, 3) == 1
    if size(meanIntNull, 1) >1
        xVals = -stepsBack:size(meanIntNull, 2)-stepsBack-1;
        tVals = xVals./(fsAligned);
        semMeanYVals = nanmean(meanIntNull, 1);
        semMeanXVals = tVals;
        stdMeanEVals = nanstd(meanIntNull, [], 1);
        semMeanDiffEVals = stdMeanEVals/sqrt(size(meanIntNull, 1));
        plot_err_patch(semMeanXVals, semMeanYVals, semMeanDiffEVals, colorForPlotNull);
    else
        xVals = -stepsBack:size(meanIntNull, 2)-stepsBack-1;
        tVals = xVals./(fsAligned);
        plot(tVals, meanIntNull, 'Color', colorForPlotNull);
    end
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

title(['ROIs 1-' num2str(size(meanIntensities, 1))])
xlabel('Time (s)')
ylabel('DF/F')
axis tight