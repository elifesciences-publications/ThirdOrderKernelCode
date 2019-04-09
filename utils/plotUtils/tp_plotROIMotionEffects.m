function tp_plotROIMotionEffects( Z, indsToPlot )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


loadFlexibleInputs(Z)

roiAvgIntensityFilteredNormalized = Z.filtered.roi_avg_intensity_filtered_normalized;
if nargin > 1 && ~isfield(Z.ROI, 'roiIndsOfInterest')
    roiAvgIntensityFilteredNormalized = roiAvgIntensityFilteredNormalized(:, indsToPlot);
elseif isfield(Z.ROI, 'roiIndsOfInterest')
    if nargin > 1
        indsToPlot = Z.ROI.roiIndsOfInterest(indsToPlot);
    else
        indsToPlot = Z.ROI.roiIndsOfInterest;
    end
    if ~any(indsToPlot)
        warning('No roiIndsOfInterest were extracted! Plotting all ROI values');
%         roiAvgIntensityFilteredNormalized = roiAvgIntensityFilteredNormalized;
    else
        roiAvgIntensityFilteredNormalized = roiAvgIntensityFilteredNormalized(:, indsToPlot);
    end
else
%     roiAvgIntensityFilteredNormalized = roiAvgIntensityFilteredNormalized;
end

params = Z.stimulus.params;

% roiAvgIntensityFilteredNormalized = [roiAvgIntensityFilteredNormalized];


alignmentShift = sqrt(sum(Z.grab.alignmentData.^2, 2));



MakeFigure
time_vals = linspace(0, imgSize(3)/fps, size(roiAvgIntensityFilteredNormalized, 1));

averagedROIIntensities = mean(roiAvgIntensityFilteredNormalized, 2);

if ischar (Z.params.channelDesired)
    imgFramesChannelName = sprintf('imgFrames_ch%s', Z.params.channelDesired);
else
    imgFramesChannelName = sprintf('imgFrames_ch%d', Z.params.channelDesired);
end
imgFramesStruc = load(fullfile(Z.params.pathName, [Z.params.name '.mat']), imgFramesChannelName);
imgFrames = imgFramesStruc.(imgFramesChannelName);


imgFrames = log(imgFrames + 1);
movieMean = mean(imgFrames(:, :, :), 3);

windMask = logical(Z.grab.windowMask);
covImg = zeros(size(imgFrames, 3),1);
for i= 1:size(imgFrames, 3)
    imgFrame = imgFrames(:, :, i);
    covImg(i) = sum(imgFrame(windMask).*movieMean(windMask))./sum(imgFrame(windMask))/sum(movieMean(windMask));
end;
covVector = covImg;%(1, 2, :);
% size(covVector)
% covVector = squeeze(covVector);

vectorsToPlot = [averagedROIIntensities, alignmentShift, covVector];

maxVals = max(vectorsToPlot);
minVals = min(vectorsToPlot);

diffVals = maxVals - minVals;
scalingFactorsLog = round(log10(diffVals(1)./diffVals));

scalingFactors = 10.^scalingFactorsLog;
scalingFactorsMat = repmat(scalingFactors, [size(vectorsToPlot, 1), 1]);

vectorsToPlotScaled = scalingFactorsMat.*vectorsToPlot;

trace_dists = diff(vectorsToPlotScaled'-repmat(min(vectorsToPlotScaled), [size(vectorsToPlotScaled, 1), 1])');
plot_sep = 2*min(max(trace_dists)-min(trace_dists));

hold on
plot(time_vals, vectorsToPlotScaled(:, 1));
plot(time_vals, vectorsToPlotScaled(:, 2));%+plot_sep);
plot(time_vals, vectorsToPlotScaled(:, 3));%+plot_sep*2);

legend({['Averaged Fluorescence Traces (' num2str(scalingFactors(1)) 'x)'], 
        ['Alignment Shift (' num2str(scalingFactors(2)) 'x)'],
        ['Covariance Change (' num2str(scalingFactors(3)) 'x)']});



xlabel('Time (s)');
ylabel('Total F');



epochs = fields(trigger_inds);
colors = bone(length(epochs));
ylim = get(gca, 'ylim');
for epochInd = 1:length(epochs)
    epoch_bounds = trigger_inds.(epochs{epochInd}).bounds;
    %     legend_patch_entries(epoch) = {epochs{epoch}};
    for j = 1:size(epoch_bounds,2)
        x = [epoch_bounds(:, j)', epoch_bounds(end:-1:1, j)']/fs;
        y = [ylim(1)-1 ylim(1)-1 ylim(2)+1 ylim(2)+1];
        legend_patch(epochInd) = patch(x, y, [1 1 1], 'FaceColor', 'none');
        xText(epochInd, j) = mean(x);
        %         yText = max(y) - .1*(max(diff(y)));
        epochActual = str2num(epochs{epochInd}((find(epochs{epochInd}=='_')+1:end)));
        if epochActual<=length(params) && isfield(params(epochActual), 'epochName') && ~isempty(params(epochActual).epochName)
            %             hText = text(xText, yText, params(epoch).epochName, 'FontUnits', 'normalized', 'Rotation', 90, 'HorizontalAlignment', 'left');
            hText{epochInd, j} = params(epochActual).epochName;
        else
            %             hText = text(xText, yText, sprintf('%d', epoch), 'FontUnits', 'normalized', 'Rotation', 0, 'HorizontalAlignment', 'center');
            hText{epochInd, j} = sprintf('Epoch %d', epochInd);
        end
        %         set(hText, 'FontSize', .02);
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









