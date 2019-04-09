function Z = tp_extractKernels( Z )
% Emilio's linear kernel extraction script

% select only kernelEpoch

%     keyboard
    path = [];
    
    loadFlexibleInputs(Z)
    grabStimPath = fullfile(Z.params.pathName,Z.params.fn);
%     grabStimPath = sprintf('%s/%s',path,fn);
    [allStimulusBehaviorData] = Z.stimulus.allStimulusBehaviorData;% grabStimulusData(Z);
    
    if ~isempty(stimulusDataCols)
        stimulusData = allStimulusBehaviorData.StimulusData(:,stimulusDataCols);
    else
        stimulusData = allStimulusBehaviorData.StimulusData;
    end

    filteredTraces = Z.filtered.roi_avg_intensity_filtered_normalized;
    roiCenterOfMass = Z.ROI.roiCenterOfMass;
    if ~linescan
%         [alignedStimulusData(:,1), responseData(:, 1), fsFactor, expectedFlashIndices] = alignStimulusAndResponse(stimulusData, allStimulusBehaviorData.Flash, filteredTraces(:, 1), trigger_inds, Z);
        % Skip the background!
        for roi = 1:size(roiCenterOfMass,1)-1
            [alignedStimulusData(:, roi), responseData(:, roi), fsFactor, expectedFlashIndices] = alignStimulusAndResponse(stimulusData, allStimulusBehaviorData, filteredTraces(:, roi), trigger_inds, Z, roiCenterOfMass(roi)/imgSize(1));
        end
    else
        [alignedStimulusData, responseData, fsFactor, expectedFlashIndices] = alignStimulusAndResponse(stimulusData, allStimulusBehaviorData, filteredTraces, trigger_inds, Z);
    end
    
    epochBoundForKernel = expectedFlashIndices.(['epoch_' num2str(epochForKernel)]).bounds;
    kernelInds = epochBoundForKernel(1, 1):epochBoundForKernel(end, end);
   
    Z.extractKernels.kernels = extractKernels(alignedStimulusData(kernelInds', :), responseData(kernelInds', :), fs*fsFactor, fn, Z);
    Z.extractKernels.stimulusData = alignedStimulusData;
    Z.extractKernels.responseData = responseData;
    Z.extractKernels.expectedFlashIndices = expectedFlashIndices;

end

