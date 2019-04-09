function Z = averageEpochResponseAnalysis(Z)

epochsOfInterest = [];

% Receive input variables
% for ii = 1:2:length(varargin)
%     %Remember to append all new varargins so old ones don't overwrite
%     %them!
%     eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
% end

if nargin>2
    loadFlexibleInputs
end

roi_avg_intensity_filtered_normalized = Z.filtered.roi_avg_intensity_filtered_normalized;
triggerInds = Z.params.trigger_inds;

roiIndsOfInterest = Z.ROI.roiIndsOfInterest;
% roiIndsOfInterest(1) = true; %Because the first column is the average >.>

% We don't really care about the roiAvg, so we take 2:end of the columns
% roiAvg = roi_avg_intensity_filtered_normalized(:, 1);
roiData = roi_avg_intensity_filtered_normalized(:, roiIndsOfInterest);

potentialEpochs = fields(triggerInds);
if ~isempty(epochsOfInterest)
    for i = length(epochsOfInterest):-1:1
        epochs{i} = ['epoch_' num2str(epochsOfInterest(i))];
        % Check to make sure the epoch actually exists, delete it if it
        % doesn't
        if ~any(strcmp(potentialEpochs, epochs{i}))
            disp(['There is no epoch ' num2str(epochsOfInterest(i)) ' in the dataset so it is being ignored.']);
            epochs(i) = [];
            epochsOfInterest(i) = [];
        end
    end
else
    epochs = potentialEpochs;
    epochsOfInterest = cellfun(@(epochTag) str2double(epochTag(find(epochTag=='_')+1:end)), potentialEpochs);
end

dFFEpochValues = [];
for epoch_ind = 1:length(epochs)
    epoch = epochs{epoch_ind};
    boundsData = triggerInds.(epoch).bounds;
    stim_length = ceil(triggerInds.(epoch).stim_length);
    
   
    % frameBaseline is the number of frames before the epoch to use as a
    % reference F for DF/F
    frameBaselineFraction = 0.5;
    baseline = [];
    
    
    triggered_intensities = zeros(size(roiData,2),length(1:stim_length),size(boundsData, 2));
    epochFields = fields(triggerInds);
    %     PDavg = zeros(length(trigger_data),length(-steps_back:stim_length));
    
    for i = size(boundsData, 2):-1:1
        firstInd = ceil(boundsData(1, i));
        indBefore = firstInd - 1;
%         final_ind = floor(boundsData(2, i)); <- I apparently didn't like
%         this method...
        triggered_intensities(:, :, i) = roiData(firstInd:firstInd+stim_length-1, :)';
        
        % Get baseline information from directly previous epoch
        epochFieldIndBefore = cellfun(@(epochField) any(triggerInds.(epochField).bounds(1, :)<=indBefore & triggerInds.(epochField).bounds(2, :)>=indBefore), epochFields);
        epochFieldBefore = epochFields(epochFieldIndBefore);
        % epochFieldBefore should only be empty when we're at the very
        % first epoch presented. Honestly, a correct stimulus will only
        % show an interleave as the first stimulus, so we don't want this
        % anyway
        if isempty(epochFieldBefore)
            triggered_intensities(:, :, i) = [];
            if ~isempty(baseline)
                baseline(:, :, i) = [];
            end
            continue;
        else
            epochBeforeLength = ceil(triggerInds.(epochFieldBefore{1}).stim_length*frameBaselineFraction);
            if epochBeforeLength < size(baseline, 2)
                baseline = baseline(:, 1:epochBeforeLength, :);
            elseif ~isempty(baseline)
                epochBeforeLength = size(baseline, 2);
            end
        end
        if isempty(baseline)
            baseline = zeros(size(roiData,2),ceil(epochBeforeLength),size(triggered_intensities, 3));
        end
        baseline(:, :, i) = roiData(firstInd-ceil(epochBeforeLength):firstInd-1, :)';

    end
    
    if isempty(triggered_intensities)
%         dFFEpochValues = [];
        warning('For some reason you have no triggered_intensities!!');
        continue
    end
    
    % get the baseline median
    if size(triggered_intensities, 1) > 1
        reference = squeeze(mean(baseline, 2));
    else
        reference = squeeze(mean(baseline, 2))';
    end
%     reference = triggered_intensities(:, 1, :);
    
    % avg_epoch_values will be a #roi x 1 x #epochPresentations matrix; we
    % just have to quash the 1D columns and plot with bar graphs, which is
    % what squeeze does!
    if size(triggered_intensities, 1) > 1
        avgEpochValues = squeeze(mean(triggered_intensities, 2));
    else
        avgEpochValues = squeeze(mean(triggered_intensities, 2))';
    end
    
    % Find the second pass DF/F--subtract the epoch presentation averages
    % from the baseline values (which are the average of a few frames
    % directly before the presentation)
    actualEpochInd = sscanf(epoch, 'epoch_%d');
    dFFEpochValues(1:size(avgEpochValues, 1), 1:size(avgEpochValues, 2), actualEpochInd) = (avgEpochValues-reference);
    
    
end

% We're making these NaN because this only occurs when one of the epochs
% is presented more times than the others (for example, a gray epoch
% between other epochs gets presented once for each epoch presentation)
dFFEpochValues(:,sum(dFFEpochValues)==0) = NaN;

Z.averageEpochResponseAnalysis.dFFEpochValues = dFFEpochValues;
Z.averageEpochResponseAnalysis.epochsOfInterest = epochsOfInterest;
Z.ROI.roiIndsOfInterest = roiIndsOfInterest;