function Z = triggeredResponseAnalysis(Z, plot_title)
% This is one of the potential two photon analysis methods. It displays the
% triggered responses averaged over all the trials and all the ROIs in an
% epoch with SEM. It also displays the responses of each ROI averaged over
% the trials. No output because none is necessary.

plot_figs = false;
epochsOfInterest = [];
steps_back = [];
steps_ahead = [];
timeBeforeTrigger = 0; % Should be in seconds
timeAfterTrigger = 0; % Should also be in seconds


% Receive input variables
% for ii = 1:2:length(varargin)
%     %Remember to append all new varargins so old ones don't overwrite
%     %them!
%     eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
% end
loadFlexibleInputs(Z)


triggerInds = trigger_inds;
roiAvgIntensityFilteredNormalized = Z.filtered.roi_avg_intensity_filtered_normalized;
fs = Z.params.fs;

if ~isempty(timeBeforeTrigger)
    steps_back = fs*timeBeforeTrigger;
end
if ~isempty(timeAfterTrigger)
    steps_ahead = fs*timeAfterTrigger;
end

if isfield(Z.ROI, 'roiIndsOfInterest')
    roiIndsOfInterest = Z.ROI.roiIndsOfInterest;
else
    roiIndsOfInterest = logical(ones(1, size(roiAvgIntensityFilteredNormalized, 2)));
end
roiAvgIntensityFilteredNormalized = roiAvgIntensityFilteredNormalized(:, roiIndsOfInterest);
if any(size(roiAvgIntensityFilteredNormalized)==0)
    warning('No ROIs of interest!');
    % Set these to empty to indicate what's happened later in the code
    Z.triggeredResponseAnalysis.epochAvgTriggeredIntensities = [];
    Z.triggeredResponseAnalysis.triggeredIntensities = [];
    Z.triggeredResponseAnalysis.stepsBack = [];
    Z.triggeredResponseAnalysis.fsFactor = [];
    return;
end

potentialEpochs = fields(triggerInds);
alignmentAdjust = false;
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
    alignmentAdjust = true;
end

if iscell(triggerInds)
    cell_trigger_inds = triggerInds;
    epochs = {};
    for i = 1:length(cell_trigger_inds)
        epochs = [epochs; fields(cell_trigger_inds{i})];
    end
    epochs = unique(epochs);
    
    if plot_figs
        epoch_figures = zeros(size(epochs));
        for i = 1:length(epochs)
            epoch_figures(i) = makeFigure;
        end
    end
    
    for epoch_ind = 1:length(epochs)
        epoch = epochs{epoch_ind};
        steps_back = length(roiAvgIntensityFilteredNormalized{1}); %dummy clearly larger than necessary value
        stim_length = steps_back; %also a dummy value clearly larger than actual value
        num_triggers = zeros(1, length(cell_trigger_inds));%Going to find the num_traces to preallocated triggered_intensities
        for cell_ind=1:length(cell_trigger_inds)
            triggerInds = cell_trigger_inds{cell_ind};
            trigger_data = triggerInds.(epoch).trigger_data;
            stim_length_temp = triggerInds.(epoch).stim_length;
            %There may be some fuzziness, so we're going to the smallest
            %stim_length so we don't accidentally broach other trigger's
            %data
            num_triggers(cell_ind) = length(trigger_data);
            if stim_length_temp < stim_length
                stim_length= stim_length_temp;
            end
            if trigger_data(1)<ceil(0.1*stim_length)
                steps_back_temp = trigger_data(1)-1;
            else
                steps_back_temp = ceil(0.1*stim_length);
            end
            %Grabbing the smallest of all the potential steps_back (in case
            %one of the data sets has the beginning of its triggers right at
            %the start, for example)
            if steps_back_temp < steps_back
                steps_back = steps_back_temp;
            end
        end
        
        
        for cell_ind = 1:length(cell_trigger_inds)
            cell_triggered_intensities{cell_ind} = zeros(size(roiAvgIntensityFilteredNormalized{cell_ind},2),length(-steps_back:stim_length),num_triggers(cell_ind));
        end
        
        
        
        for cell_ind=1:length(cell_trigger_inds)
            triggered_intensities = cell_triggered_intensities{cell_ind};
            triggerInds = cell_trigger_inds{cell_ind};
            trigger_data = triggerInds.(epoch).trigger_data;
            stim_length = triggerInds.(epoch).stim_length;
            if trigger_data(1)<ceil(0.1*stim_length)
                steps_back = trigger_data(1)-1;
            else
                steps_back = ceil(0.1*stim_length);
            end
            %     PDavg = zeros(length(trigger_data),length(-steps_back:stim_length));
            
            for i = 1:length(trigger_data)
                trigger_ind = trigger_data(i);
                finalInd = trigger_ind + stim_length;
                triggered_intensities(:, :, i) = roiAvgIntensityFilteredNormalized{cell_ind}(trigger_ind-steps_back:finalInd, :)';
                %         triggered_intensities(:, :, i) = roi_avg_intensity_filtered(trigger_ind-steps_back:final_ind, :)'./repmat(roi_avg_intensity_filtered(trigger_ind, :)', 1, length(roi_avg_intensity_filtered(trigger_ind-steps_back:final_ind, :)));
                %         PDavg(i, :) = avg_PDintensity(trigger_ind-steps_back:final_ind)';
            end
            
            
            cell_avg_triggered_intensities{cell_ind} = nanmean(triggered_intensities, 3)';
            %     avg_PDavg = nanmean(PDavg);
            triggerInds.(epoch).avg_triggered_intensities = cell_avg_triggered_intensities{cell_ind};
            %     trigger_inds.(epoch).avg_PDavg = avg_PDavg;
            
            
        end
        
        avg_triggered_intensities = cell2mat(cell_avg_triggered_intensities);%should work....
        
        epochAvgTriggeredIntensities.(epoch) = avg_triggered_intensities;
        
        %We're going to be plotting the SEMs using Matt's plot_err_patch
        %function
        std_triggered_intensities = std(avg_triggered_intensities, 0, 2);
        sem_triggered_intensities = std_triggered_intensities/sqrt(size(triggered_intensities, 1));
        
        %Include the mean of the all the values; confusing terms: avg_ is
        %the average over the triggers; mean_ is the mean over the neurons
        %(averaged over the triggers)
        mean_triggered_intensities = nanmean(avg_triggered_intensities, 2);
        avg_triggered_intensities = [mean_triggered_intensities, avg_triggered_intensities]'; %transpose for twoPhotonPlotter
        
        
        
        if plot_figs
            epoch_fig_handle = epoch_figures(epoch_ind);
            
            twoPhotonPlotter(plot_title, avg_triggered_intensities, sem_triggered_intensities, steps_back, fs, epoch, epoch_fig_handle, varargin{:})
        end
    end
    
    
    
    
else
    %There will be one figure per epoch, and two subfigures: the individual
    %traces per ROI and the averaged trace per ROI with error bars
    if plot_figs
        epoch_figures = zeros(size(epochs));
        for i = 1:length(epochs)
            epoch_figures(i) = MakeFigure;
        end
    end
%     for roiInd = 1:size(roiAvgIntensityFilteredNormalized, 2)
stimulusData = Z.stimulus.allStimulusBehaviorData.StimulusData;
allStimulusBehaviorData= Z.stimulus.allStimulusBehaviorData;
centerOfMassFraction = Z.ROI.roiCenterOfMass/Z.params.imgSize(1);
spacing = 5;
        alignedResponseData = [];
        numIndsOfInt = size(roiAvgIntensityFilteredNormalized, 2);
        for indsToInterp = 1:spacing:numIndsOfInt
            if (indsToInterp+spacing)>numIndsOfInt
                spacing = numIndsOfInt-indsToInterp+1;
            else
                spacing = 5;
            end
            [~, roiAvgIntensityFilteredNormalizedAligned(:, indsToInterp:indsToInterp+spacing-1), fsFactor, triggerIndsAligned] = alignStimulusAndResponse(stimulusData(:, 1), allStimulusBehaviorData, roiAvgIntensityFilteredNormalized(:,indsToInterp:indsToInterp+spacing-1), triggerInds, Z, centerOfMassFraction(indsToInterp:indsToInterp+spacing-1, 1)');
        end
%         [~, , , ] = alignStimulusAndResponse(Z.stimulus.allStimulusBehaviorData.StimulusData(:, 1), Z.stimulus.allStimulusBehaviorData, roiAvgIntensityFilteredNormalized, triggerInds, Z, Z.ROI.roiCenterOfMass(Z.ROI.roiIndsOfInterest, 1)'/Z.params.imgSize(1));
%     end
%     for roiInd = 1:size(roiAvgIntensityFilteredNormalized, 2)
%         [~, roiAvgIntensityFilteredNormalizedAligned(:, roiInd), fsFactor, triggerIndsAligned, ~] = alignStimulusAndResponse(Z.stimulus.allStimulusBehaviorData.StimulusData(:, 1), Z.stimulus.allStimulusBehaviorData, roiAvgIntensityFilteredNormalized(:, roiInd), triggerInds, Z, Z.ROI.roiCenterOfMass(roiInd)/Z.params.imgSize(1));
%     end
    if alignmentAdjust
        potentialEpochs = fields(triggerIndsAligned);
        epochs = potentialEpochs;
        epochsOfInterest = cellfun(@(epochTag) str2double(epochTag(find(epochTag=='_')+1:end)), potentialEpochs);
    end
    
    if ~isempty(timeBeforeTrigger)
        steps_back = fs*fsFactor*timeBeforeTrigger;
    end
    if ~isempty(timeAfterTrigger)
        steps_ahead = fs*fsFactor*timeAfterTrigger;
    end
    
    for epoch_ind = 1:length(epochs)
        epoch = epochs{epoch_ind};
        trigger_data = triggerIndsAligned.(epoch).trigger_data;
        stim_length = nanmedian(triggerIndsAligned.(epoch).stim_length);
        if isempty(steps_back)
            if trigger_data(1)<ceil(0.1*stim_length)
                steps_back = trigger_data(1)-1;
            else
                steps_back = ceil(0.1*stim_length);
            end
        end
        
        if isempty(steps_ahead)
            if (length(roiAvgIntensityFilteredNormalizedAligned)-trigger_data(end)-stim_length)<floor(0.1*stim_length)
                steps_ahead = floor(length(roiAvgIntensityFilteredNormalizedAligned)-trigger_data(end)-stim_length);
            else
                steps_ahead = floor(0.1*stim_length);
                %Corner case for non-linescans where the frame arrangement
                %might be such that no frame is averaged after the end of the
                %stimulus <.<
                if steps_ahead == 0
                    steps_ahead = 1;
                end
            end
        end
        steps_back = floor(steps_back);
        steps_ahead = ceil(steps_ahead);
        stim_length = floor(stim_length);
        
        % Note that we're subtracting one when creating the size of the
        % second index. To see why this works, consider an epoch with a
        % stim_length of 5 where we don't want any data before or after the
        % trigger plotted. This means steps_back=0, but length(0:5) is
        % actually 6, though we clearly want this to be the size of
        % stim_length, or 5. Putting length(0:5-1) gets the desired result.
        triggered_intensities = zeros(size(roiAvgIntensityFilteredNormalizedAligned,2),length(-steps_back:stim_length+steps_ahead-1),length(trigger_data));
        %     PDavg = zeros(length(trigger_data),length(-steps_back:stim_length));
        
        for i = 1:length(trigger_data)
            trigger_ind = floor(trigger_data(i));
            firstInd = trigger_ind-steps_back;
            if firstInd<1
                insertInd = trigger_ind-firstInd;
                firstInd = 1;
            else
                insertInd = 1;
            end
            finalInd = firstInd + size(triggered_intensities, 2)-insertInd;% stim_length+steps_ahead+1;
            if finalInd > size(roiAvgIntensityFilteredNormalizedAligned, 1)
                finalInd = size(roiAvgIntensityFilteredNormalizedAligned, 1);
                lastInsertInd = length(firstInd:finalInd)+insertInd-1;
%             elseif length(firstInd:finalInd)>length(insertInd:lastInsertInd)
            else
                lastInsertInd = size(triggered_intensities, 2);
            end
            %Note that we're normalizing to the trigger point here, and
            %everything will equal 1 at that point
            triggered_intensities(:, insertInd:lastInsertInd, i) = roiAvgIntensityFilteredNormalizedAligned(firstInd:finalInd, :)';
            %         triggered_intensities(:, :, i) = roi_avg_intensity_filtered(trigger_ind-steps_back:final_ind, :)'./repmat(roi_avg_intensity_filtered(trigger_ind, :)', 1, length(roi_avg_intensity_filtered(trigger_ind-steps_back:final_ind, :)));
            %         PDavg(i, :) = avg_PDintensity(trigger_ind-steps_back:final_ind)';
        end
        
        avg_triggered_intensities = nanmean(triggered_intensities, 3);
        %     avg_PDavg = nanmean(PDavg);
        
        % We're only going 2:end because row 1 is the average over the
        % ROIs, which we don't want
        triggeredIntensities.(epoch) = permute(triggered_intensities, [3 2 1]);
        epochAvgTriggeredIntensities.(epoch) = avg_triggered_intensities(1:end, :);
        %     trigger_inds.(epoch).avg_PDavg = avg_PDavg;
        
        %TODO fix this SEM for the averaged data--it should be OVER NEURONS
        %not over triggers -.-
        %We're going to be plotting the SEMs using Matt's plot_err_patch
        %function
        std_triggered_intensities = std(triggered_intensities, 0, 3);
        sem_triggered_intensities = std_triggered_intensities/sqrt(size(triggered_intensities, 3));
        
        
        
        if plot_figs
            epoch_fig_handle = epoch_figures(epoch_ind);
            
            twoPhotonPlotter(plot_title, permute(triggered_intensities, [3 2 1]), steps_back, fs, epoch, epoch_fig_handle, Z, 'plot_rois', false)
        end
        
    end
end

Z.triggeredResponseAnalysis.epochAvgTriggeredIntensities = epochAvgTriggeredIntensities;
Z.triggeredResponseAnalysis.triggeredIntensities = triggeredIntensities;
Z.triggeredResponseAnalysis.stepsBack = steps_back;
Z.triggeredResponseAnalysis.fsFactor = fsFactor;