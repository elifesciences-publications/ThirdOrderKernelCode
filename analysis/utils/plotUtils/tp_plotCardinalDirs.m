function tp_plotCardinalDirs(Z, titleText, epochsOfInterest)

% if nargin<5
%     epochsOfInterestDir2 = epochsOfInterestDir1;
% end

% Grr apparently this wasn't correctly extracted before >.>
% Z.params.trigger_inds = twoPhotonPhotodiodeAnalyzer(Z.grab.avg_linear_PDintensity, Z.params.fps*Z.params.imgSize(1)/60, Z.params.imgSize, Z);

roiIndsOfInterest = logical(ones(size(Z.filtered.roi_avg_intensity_filtered_normalized, 2), 1));
Z.ROI.roiIndsOfInterest = roiIndsOfInterest;
Z = averageEpochResponseAnalysis(Z);


epochNames = {Z.stimulus.params.epochName};
% epochResponseDir1 = epochsForSelectivity(1);
% epochResponseDir2 = epochsForSelectivity(end);


% twoPhotonPlotOverall(Z, [titleText ' ' epochResponseDir1 ' ROIs'], [1 0 0]);
% title([titleText ' ' epochResponseDir1 ' ROIs'])


params = Z.stimulus.params;
roi_image = [];
roi_data = [];
dataToPlotDir = Z.averageEpochResponseAnalysis;
epochsForPlottingDir1 = dataToPlotDir.epochsOfInterest(epochsOfInterest);


figHandle = MakeFigure;
% subplot(2, 2, 1)
if any(roiIndsOfInterest)
    plotAverageEpochResponse(-dataToPlotDir.dFFEpochValues(:,:,epochsOfInterest),params, roi_image, roi_data, epochsForPlottingDir1, [1 0 0]);
    ylabel('DF/F');
    %     dataMeanDir1 = nanmean(dataToPlotDir.dFFEpochValues(:,:,epochsOfInterestDir2), 2);
else
%     dataMeanDir1 = [];
end

 set(gca, 'XTick', 1:length(epochsOfInterest));
    xlabel('Epoch');
    set(gca,'XTickLabel', epochNames(epochsOfInterest));
    set(gca, 'XTickLabelRotation', 45);
    
    axisLims = axis;
    text(axisLims(2), axisLims(4), sprintf('# ROIs = %d', size(dataToPlotDir.dFFEpochValues,1)), 'VerticalAlignment', 'Top', 'HorizontalAlignment', 'Right')
    toc

axHandle = figHandle.Children;
lineHandles = axHandle.Children;
% We don't want patches
patches = lineHandles.findobj('Type', 'Patch');
patches.delete;
intHandles = lineHandles.findobj('Type', 'ErrorBar');
set(intHandles, 'ButtonDownFcn', {@linewidth, intHandles})

end

function linewidth(objH, evtData, intHandles)

set(objH, 'LineWidth', 4)
set(intHandles(intHandles~=objH), 'LineWidth', 1)
end
% Z.params.epochsForSelectivity = epochsForSelectivity(end:-1:1);
% [roiIndsOfInterestDir2, pValsSumDir2] = extractROIsBySelectivity(Z);
% 
% Z.ROI.roiIndsOfInterest = roiIndsOfInterestDir2;
% Z = averageEpochResponseAnalysis(Z);
% 
% % makeFigure
% dataToPlotDir2 = Z.averageEpochResponseAnalysis;
% epochsForPlottingDir2 = dataToPlotDir2.epochsOfInterest(epochsOfInterestDir2);
% dataMeanDir2 = nanmean(dataToPlotDir2.dFFEpochValues(:,:,epochsOfInterestDir1), 2);
% if any(roiIndsOfInterestDir2)
%     plotAverageEpochResponse(reshape(dataMeanDir2, [1, size(dataMeanDir2, 1), size(dataMeanDir2, 3)]),params, roi_image, roi_data, epochsForPlottingDir1, [0 0 1]);
%     title([titleText ' ' epochResponseDir1 ' ROIs'])
% else
%     dataMeanDir2 = [];
% end
% 
% 
% % plotAverageEpochResponse(mean(dataToPlot.dFFEpochValues(:,:,epochsOfInterest), 2),dataToPlot.params, dataToPlot.roi_image, dataToPlot.roi_data, dataToPlot.epochsOfInterest(epochsOfInterest));
% subplot(2, 2, 2)
% if any(roiIndsOfInterestDir2)
%     plotAverageEpochResponse(dataToPlotDir2.dFFEpochValues(:,:,epochsOfInterestDir2),params, roi_image, roi_data, epochsForPlottingDir2, [0 0 1]);
% end
% if any(roiIndsOfInterestDir1)
%     plotAverageEpochResponse(reshape(dataMeanDir1, [1, size(dataMeanDir1, 1), size(dataMeanDir1, 3)]),params, roi_image, roi_data, epochsForPlottingDir2, [1 0 0]);
% end
% title([titleText ' ' epochResponseDir2 ' ROIs'])
% 
% if nargin < 5
%     subplot(2, 1, 2)
%     legendEntries = {};
%     if ~isempty(dataMeanDir1)
%         plotAverageEpochResponse(reshape(dataMeanDir1, [1, size(dataMeanDir1, 1), size(dataMeanDir1, 3)]),params, roi_image, roi_data, epochsForPlottingDir1, [1 0 0]);
%         legendEntries = [legendEntries [epochResponseDir1 ' Responsive ROIs']];
%     end
%     if ~isempty(dataMeanDir2)
%         plotAverageEpochResponse(reshape(dataMeanDir2, [1, size(dataMeanDir2, 1), size(dataMeanDir2, 3)]),params, roi_image, roi_data, epochsForPlottingDir2, [0 0 1]);
%         legendEntries = [legendEntries [epochResponseDir2 ' Responsive ROIs']];
%     end
%     title('Compiled responses');
%     legend(legendEntries);
% else
%     subplot(2, 2, 3)
%     params = struct('epochName', {'Null Positive Correlation', 'Preferred Negative Correlation', 'Null Negative Correlation', 'Preferred Positive Correlation'});
%     epochsForPlotNames = 1:4;
%     if ~isempty(dataMeanDir1)
%         if ~isempty(dataMeanDir2)
%             dataToPlotOverall = [dataToPlotDir.dFFEpochValues(:,:,epochsOfInterestDir1); dataToPlotDir2.dFFEpochValues(:,:,epochsOfInterestDir2)];
%         else
%             dataToPlotOverall = [dataToPlotDir.dFFEpochValues(:,:,epochsOfInterestDir1)];
%         end
%     elseif ~isempty(dataMeanDir2)
%         dataToPlotOverall = [dataToPlotDir.dFFEpochValues(:,:,epochsOfInterestDir2)];
%     else
%         warning('No data to plot!')
%         return;
%     end
%     plotAverageEpochResponse(dataToPlotOverall,params, roi_image, roi_data, epochsForPlotNames, [1 0 0]);
%     title('Responses Folded Over Preferred/Null Direction');
%     subplot(2, 2, 4)
%     dataToPlotOverallMean = nanmean(dataToPlotOverall, 2);
%     plotAverageEpochResponse(reshape(dataToPlotOverallMean, [1, size(dataToPlotOverallMean, 1), size(dataToPlotOverallMean, 3)]),params, roi_image, roi_data, epochsForPlotNames, [1 0 0], true);
%     title('Average Response Folded Over Preferred/Null Direction');
%     Z.ROI.roiIndsOfInterest = roiIndsOfInterestDir2 | roiIndsOfInterestDir1;
% %     twoPhotonPlotOverall(Z, [titleText ' ' epochResponseDir1 ' and ' epochResponseDir2 ' ROIs']);
% end

% Z.ROI.roiIndsOfInterest = roiIndsOfInterestDir2;
% twoPhotonPlotOverall(Z, [titleText ' ' epochResponseDir2 ' ROIs'], [0 0 1]);
% title([titleText ' ' epochResponseDir2 ' ROIs'])


% [~, bestDir1RoiSort] = sort(pValsSumDir1);
% bestROIIndDir1 = logical(zeros(size(roiIndsOfInterestDir1)));
% bestROIIndDir1(bestDir1RoiSort(1)) = true;
% Z.ROI.roiIndsOfInterest = roiIndsOfInterestDir1;
% triggerInds = Z.params.trigger_inds;
% % We want to 
% tp_plotROIMeanTracesBounded( Z, [floor(triggerInds.epoch_1.bounds(1, 1)),ceil(triggerInds.epoch_5.bounds(2, 1))], [1 0 0] )
% title([titleText ' ' epochResponseDir1 ' Direction Probe']);
% tp_plotROIMeanTracesBounded( Z, [floor(triggerInds.epoch_9.bounds(1, 1)),ceil(triggerInds.epoch_16.bounds(2, 1))], [1 0 0] )
% title([titleText ' ' epochResponseDir1 ' Glider Responses']);
% 
% % [~, bestDir2RoiSort] = sort(pValsSumDir2);
% % bestROIIndDir2 = logical(zeros(size(roiIndsOfInterestDir2)));
% % bestROIIndDir2(bestDir2RoiSort(1)) = true;
% Z.ROI.roiIndsOfInterest = roiIndsOfInterestDir2;
% tp_plotROIMeanTracesBounded( Z, [floor(triggerInds.epoch_1.bounds(1, 1)),ceil(triggerInds.epoch_5.bounds(2, 1))], [0 0 1] )
% title([titleText ' ' epochResponseDir2 ' Direction Probe']);
% tp_plotROIMeanTracesBounded( Z, [floor(triggerInds.epoch_9.bounds(1, 1)),ceil(triggerInds.epoch_16.bounds(2, 1))], [0 0 1] )
% title([titleText ' ' epochResponseDir2 ' Glider Responses']);
