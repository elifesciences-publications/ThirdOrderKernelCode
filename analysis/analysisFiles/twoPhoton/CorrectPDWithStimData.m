function Z = CorrectPDWithStimData(Z)

allStimulusBehaviorData = Z.stimulus.allStimulusBehaviorData;
recordedFlashStructure = Z.params.trigger_inds;
recordedFlashBounds = [];
% recordedFlashOffsets = [];
epochsRecorded = fieldnames(recordedFlashStructure);
associatedRecordedEpoch = [];
max_index = 1;
 
for ind = 1:length(epochsRecorded)
    epochExpectedBounds = recordedFlashStructure.(epochsRecorded{ind}).bounds;
%     epochTriggerOffsets = recordedFlashStructure.(epochs{ind}).frameTriggerOffset;
    recordedFlashBounds = [recordedFlashBounds epochExpectedBounds];
%     recordedFlashOffsets = [recordedFlashOffsets; epochTriggerOffsets];
    associatedRecordedEpoch = [associatedRecordedEpoch repmat(epochsRecorded(ind), [1 size(epochExpectedBounds, 2)])];
end
[recordedBoundStartsSorted, recordedBoundStartsSortedInds] = sort(recordedFlashBounds(1, :));
associatedRecordedEpochSorted = associatedRecordedEpoch(recordedBoundStartsSortedInds);
recordedFlashBoundsSorted = recordedFlashBounds(:, recordedBoundStartsSortedInds);

% We're gonna trust the timing of the stim data now...
if isfield(Z.params, 'durationOfStimulusRecording')
    durationOfStimulusRecording = Z.params.durationOfStimulusRecording;
else
    if Z.params.linescan
        durationOfStimulusRecording = (length(Z.grab.avg_linear_PDintensity)-recordedFlashBoundsSorted(1,1))/Z.params.fs;
    else
        linesPerFrame = Z.params.imgSize(1);
        durationOfStimulusRecording = (length(Z.grab.avg_linear_PDintensity)-recordedFlashBoundsSorted(1,1)*linesPerFrame)/linesPerFrame/Z.params.fs;
    end
end
firstNonrecordedStimulus = find(Z.stimulus.allStimulusBehaviorData.Time > durationOfStimulusRecording, 1);

expectedFlashStream = allStimulusBehaviorData.Flash;
% If Flash ends up being the last column in stimdata.csv, it picks up an
% extra column of zeros because of the trailing commas that get output in
% WriteStimData.m. We thus get rid of this last column if it's there.
if size(expectedFlashStream, 2) == 2
    expectedFlashStream = expectedFlashStream(:, 1);
end

% Get rid of any stimulus that wasn't recorded; if firstNonrecordedStimulus
% is empty (i.e. all the stimulus was recorded) then this shouldn't do
% anything
expectedFlashStream(firstNonrecordedStimulus:end) = [];

% The expected flash length of the recorded data is 1, because each flash
% is given on a per-frame basis.
streamExpectedFlashLength = 1;
% Image size is a dummy variable here because we're neither grabbing the
% flashs stream from recorded image data, nor do we care about the
% stim_length, which is what the imgSize is used for. Most importantly,
% when decoding this data as a linescan, imgSize isn't even ever used!
expectedFlashStream = [0; expectedFlashStream];
imgSize = [1 1 length(expectedFlashStream)];
% We're decoding this 'recorded' data as a linescan because that'll assume
% each data point is a potential trigger index, as opposed to it thinking
% it's part of an image frame, a frame whose index is then important. Note
% that the [1 1 1] imgSize value would remove that problem anyway
% (probably).
linescanIn = Z.params.linescan;
Z.params.linescan = true;
expectedFlashStructure = twoPhotonPhotodiodeAnalyzer(expectedFlashStream, streamExpectedFlashLength, imgSize, Z);
Z.params.linescan = linescanIn;

expectedFlashBounds = [];
epochsExpected = fieldnames(expectedFlashStructure);
associatedExpectedEpoch = [];
max_index = 1;
for ind = 1:length(epochsExpected)
    epochRecordedBounds = expectedFlashStructure.(epochsExpected{ind}).bounds;
    expectedFlashBounds = [expectedFlashBounds epochRecordedBounds];
    associatedExpectedEpoch = [associatedExpectedEpoch repmat(epochsExpected(ind), [1 size(epochRecordedBounds, 2)])];
    
    % Initialize the new flash structure with the appropriate epochs
    newFlashStructure.(epochsExpected{ind}).bounds = [];
    newFlashStructure.(epochsExpected{ind}).trigger_data = [];
    newFlashStructure.(epochsExpected{ind}).stim_length = [];
    newFlashStructure.(epochsExpected{ind}).frameTriggerOffset = [];

end
[expectedBoundStartsSorted, expectedBoundStartsSortedInds] = sort(expectedFlashBounds(1, :));
associatedExpectedEpochSorted = associatedExpectedEpoch(expectedBoundStartsSortedInds);

if length(expectedBoundStartsSorted) ~= length(recordedBoundStartsSorted)
    firstFrame = Z.stimulus.allStimulusBehaviorData.FrameNumber(1);
    % When we switched to first frame being 1, we also switched the place
    % where the flashes are recorded to be a frame behind
    flashes = Z.stimulus.allStimulusBehaviorData.Flash(:, 1);
    if firstFrame == 1
        flashes = flashes(1:end-1);
        times = Z.stimulus.allStimulusBehaviorData.Time(2:end);
    else
        times = Z.stimulus.allStimulusBehaviorData.Time;
    end
    % Get rid of nonrecorded stuff now, adjust flashes later (since we'll
    % be making the vector bigger potentially)
    flashes(firstNonrecordedStimulus:end) = [];
    % Add on zeros at the beginning and the end to denote beginning and
    % end of first and last codes
    times(firstNonrecordedStimulus:end) = [];
    
    flipTimes = diff(times);
    potentialMissedFlashes = diff(flashes) & (flipTimes<0.012);
    
    projectorFrameRate = 60; % 60 Hz
    frameReps = flipTimes/(1/projectorFrameRate);
    frameReps = floor(frameReps);
    % We've already taken care of frameReps == 0 with
    % potentialMissedFlashes
    frameReps(frameReps==0) = 1;
    frameReps = [frameReps; 1];
    
    
    
    
%     if any(potentialMissedFlashes)
        flashes(potentialMissedFlashes)=flashes(find(potentialMissedFlashes)+1);
        flashes = [0; flashes; 0];
        linescanIn = Z.params.linescan;
        Z.params.linescan = true;
        imgSize = [1 1 length(flashes)];
        expectedFlashStructureWithFrameSkips = twoPhotonPhotodiodeAnalyzer(flashes, streamExpectedFlashLength, imgSize, Z);
        Z.params.linescan = linescanIn;
        % We must expand AFTER we take care of the  missed flashes, so they
        % don't get moved around. First get rid of those zeros on the end
        % for now
        flashes([1 end]) = [];
        % We're keeping track of which frames ended up where. That includes
        % erasing skipped frames and expanding repeated frames
        indexesExpansion = 1:length(flashes);
        indexesExpansion(potentialMissedFlashes)=indexesExpansion(find(potentialMissedFlashes)+1);
        together = [indexesExpansion' flashes frameReps];
        combo = mat2cell(together, ones(size(flashes)), size(together, 2));
        expanded = cellfun(@(val) repmat([val(1:end-1)], [val(end), 1]), combo, 'UniformOutput', false);
        expanded = cell2mat(expanded);
        flashes = expanded(:, end);
        expandedIndexes = expanded(:, 1);
        flashes = [0; flashes; 0];
        linescanIn = Z.params.linescan;
        Z.params.linescan = true;
        imgSize = [1 1 length(flashes)];
        expectedFlashStructureWithFrameSkipsAndExpanded = twoPhotonPhotodiodeAnalyzer(flashes, streamExpectedFlashLength, imgSize, Z);
        Z.params.linescan = linescanIn;
%     else
%         error('Nonexistent epoch decoded >.>');
%     end
    
    % We need this set to be calculated so we can match it up to the
    % expectedFlashStructure dataset
    epochsExpectedWithFrameSkips = fieldnames(expectedFlashStructureWithFrameSkips);
    associatedExpectedEpochWithFrameSkips = [];
    expectedFlashBoundsWithFrameSkips = [];
    max_index = 1;
    for ind = 1:length(epochsExpectedWithFrameSkips)
        epochRecordedBoundsWithFrameSkips = expectedFlashStructureWithFrameSkips.(epochsExpectedWithFrameSkips{ind}).bounds;
        expectedFlashBoundsWithFrameSkips = [expectedFlashBoundsWithFrameSkips epochRecordedBoundsWithFrameSkips];
        associatedExpectedEpochWithFrameSkips = [associatedExpectedEpochWithFrameSkips repmat(epochsExpectedWithFrameSkips(ind), [1 size(epochRecordedBoundsWithFrameSkips, 2)])];
        
    end
    [expectedBoundStartsWithFrameSkipsSorted, expectedBoundStartsWithFrameSkipsSortedInds] = sort(expectedFlashBoundsWithFrameSkips(1, :));
    associatedExpectedEpochWithFrameSkipsSorted = associatedExpectedEpochWithFrameSkips(expectedBoundStartsWithFrameSkipsSortedInds);
    
    % We need *this* set to be calculated so we can match it up to the
    % recordedFlashStructure dataset-->the distinction here is that the
    % epoch numbers may be different, but the *number* of epochs should be
    % the same
    epochsExpectedFlashStructureWithFrameSkipsAndExpanded = fieldnames(expectedFlashStructureWithFrameSkipsAndExpanded);
    associatedExpectedEpochWithFrameSkipsAndExpanded = [];
    expectedFlashBoundsWithFrameSkipsAndExpanded = [];
    max_index = 1;
    for ind = 1:length(epochsExpectedFlashStructureWithFrameSkipsAndExpanded)
        epochRecordedBoundsWithFrameSkipsAndExpanded = expectedFlashStructureWithFrameSkipsAndExpanded.(epochsExpectedFlashStructureWithFrameSkipsAndExpanded{ind}).bounds;
        expectedFlashBoundsWithFrameSkipsAndExpanded = [expectedFlashBoundsWithFrameSkipsAndExpanded epochRecordedBoundsWithFrameSkipsAndExpanded];
        associatedExpectedEpochWithFrameSkipsAndExpanded = [associatedExpectedEpochWithFrameSkipsAndExpanded repmat(epochsExpectedFlashStructureWithFrameSkipsAndExpanded(ind), [1 size(epochRecordedBoundsWithFrameSkipsAndExpanded, 2)])];
        
    end
    [expectedBoundStartsWithFrameSkipsAndExpandedSorted, expectedBoundStartsWithFrameSkipsAndExpandedSortedInds] = sort(expectedFlashBoundsWithFrameSkipsAndExpanded(1, :));
    associatedExpectedEpochWithFrameSkipsAndExpandedSorted = associatedExpectedEpochWithFrameSkipsAndExpanded(expectedBoundStartsWithFrameSkipsAndExpandedSortedInds);
    
    if length(expectedBoundStartsWithFrameSkipsSorted) ~= length(recordedBoundStartsSorted)
        error('Nonexistent epoch decoded >.>');
    end
    
    mistakeIndexes = [];
    currentExpectedIndex = 1;
    currentExpectedIndexWithFrameSkips = 1;
    expectedBoundStartsSortedTemp  = expectedBoundStartsSorted;
    expectedBoundStartsWithFrameSkipsSortedTemp = expectedBoundStartsWithFrameSkipsSorted;
    while ~isempty(expectedBoundStartsSortedTemp)
        % If they're not equivalent we've got a problem of trigger_data
        if expectedBoundStartsWithFrameSkipsSortedTemp(1) ~= expectedBoundStartsSortedTemp(1)
            % Unless it's that first frame that happened earlier than
            % expected
            if any(ismember(expectedBoundStartsWithFrameSkipsSortedTemp(1)+[-4:4], find(potentialMissedFlashes))) && abs(expectedBoundStartsSortedTemp(1) - expectedBoundStartsWithFrameSkipsSortedTemp(1)) <= 4
                expectedBoundStartsWithFrameSkipsSortedTemp(1) = [];
                currentExpectedIndexWithFrameSkips = currentExpectedIndexWithFrameSkips + 1;
                expectedBoundStartsSortedTemp(1) = [];
            else
                % Save the indexes of the expected epochs that weren't
                % recorded-->these exist in the trigger_data of the
                % previous epoch, and fixing that's what we're gonna do
                % next
                mistakeIndexes = [mistakeIndexes [currentExpectedIndex;currentExpectedIndexWithFrameSkips]];
                expectedBoundStartsSortedTemp(1) = [];
            end
        else
            expectedBoundStartsWithFrameSkipsSortedTemp(1) = [];
            currentExpectedIndexWithFrameSkips = currentExpectedIndexWithFrameSkips + 1;
            expectedBoundStartsSortedTemp(1) = [];
        end
        currentExpectedIndex = currentExpectedIndex+1;
    end
    
    for i = 1:size(mistakeIndexes, 2)
        missedBoundStart = expectedBoundStartsSorted(mistakeIndexes(1, i));
        presentEpochExpected = associatedExpectedEpochSorted{mistakeIndexes(1, i)};
        boundsForSkippedEpoch = expectedFlashStructure.(presentEpochExpected).bounds;
        triggerDataInSkippedEpoch = expectedFlashStructure.(presentEpochExpected).trigger_data;
        % Bound skipped should be within one of the trigger_data
        boundSkippedIndex = find(boundsForSkippedEpoch(1, :) == missedBoundStart | abs(boundsForSkippedEpoch(1, :)-missedBoundStart)==1);
        boundSkipped = boundsForSkippedEpoch(:, boundSkippedIndex); 
        triggerDataForSkippedEpoch = triggerDataInSkippedEpoch(triggerDataInSkippedEpoch >= boundSkipped(1)  &  triggerDataInSkippedEpoch < boundSkipped(2));
        
        triggerDataForSkippedEpochExpanded = zeros(size(triggerDataForSkippedEpoch));
        for skippedTriggerInd = 1:length(triggerDataForSkippedEpoch)
            triggerDataForSkippedEpochExpanded(skippedTriggerInd) = find(expandedIndexes == triggerDataForSkippedEpoch(skippedTriggerInd), 1);
        end
        
        boundsSkippedExpanded = zeros(size(boundSkipped));
        for skippedBoundInd = 1:size(boundSkipped, 2)
            boundsSkippedExpanded(:, skippedBoundInd) = [find(expandedIndexes == boundSkipped(1, skippedBoundInd), 1); find(expandedIndexes == boundSkipped(2, skippedBoundInd), 1)];
        end
        
        previousEpochExpectedWithFrameSkipsAndExpanded = associatedExpectedEpochWithFrameSkipsAndExpandedSorted{mistakeIndexes(2, i)-1};
        triggerDataWithSkippedEpochAndExpandedStart = expectedFlashStructureWithFrameSkipsAndExpanded.(previousEpochExpectedWithFrameSkipsAndExpanded).trigger_data;
        boundsForSkippedEpochExpanded = expectedFlashStructureWithFrameSkipsAndExpanded.(previousEpochExpectedWithFrameSkipsAndExpanded).bounds;
        
        boundsForSkippedEpochExpandedIndex = find(boundsForSkippedEpochExpanded(2, :) == boundsSkippedExpanded(2) | abs(boundsForSkippedEpochExpanded(2, :)-boundsSkippedExpanded(2))==1);
        
        triggerDataInWrongEpochIndexes = find(triggerDataWithSkippedEpochAndExpandedStart >= boundsSkippedExpanded(1)  &  triggerDataWithSkippedEpochAndExpandedStart < boundsSkippedExpanded(2));
        triggerDataInWrongEpoch = triggerDataWithSkippedEpochAndExpandedStart(triggerDataInWrongEpochIndexes);
        % Now we're finding which of those triggers are actually part of
        % the epoch code; any triggers that are NOT in the expected trigger
        % data (subtract one) are the correct ones to look at
        triggerDataForEpochCode = ~any([ismember(triggerDataInWrongEpoch, triggerDataForSkippedEpochExpanded) ismember(triggerDataInWrongEpoch-1, triggerDataForSkippedEpochExpanded) ismember(triggerDataInWrongEpoch+1, triggerDataForSkippedEpochExpanded)], 2);
        % We get rid of all the epoch code trigger data, but keep the first
        % one (i.e. the start of the epoch!)<--actually this should be
        % autoincluded from the previous line of code
        triggerDataForSkippedEpochIndexes = triggerDataInWrongEpochIndexes(~triggerDataForEpochCode);
        
        % Find the epoch that got skipped using the expanded structure
        % epoch coding (because this will account for misread epochs, for
        % example)
        recordedEpochBeforeSkipped = associatedExpectedEpochWithFrameSkipsAndExpandedSorted{mistakeIndexes(2, i)-1};
        recordedTriggerDataInWrongEpoch = recordedFlashStructure.(recordedEpochBeforeSkipped).trigger_data(triggerDataForSkippedEpochIndexes);
        recordedFlashStructure.(recordedEpochBeforeSkipped).trigger_data(triggerDataInWrongEpochIndexes) = [];
        recordedFrameTriggerOffsetsInWrongEpoch = recordedFlashStructure.(recordedEpochBeforeSkipped).frameTriggerOffset(triggerDataForSkippedEpochIndexes);
        recordedFlashStructure.(recordedEpochBeforeSkipped).frameTriggerOffset(triggerDataInWrongEpochIndexes) = [];
        correctNewBoundsData = [recordedTriggerDataInWrongEpoch(1); recordedFlashStructure.(recordedEpochBeforeSkipped).bounds(2, boundsForSkippedEpochExpandedIndex)];
        recordedFlashStructure.(recordedEpochBeforeSkipped).bounds(2, boundsForSkippedEpochExpandedIndex) = recordedTriggerDataInWrongEpoch(1);
        
        % Add to the new epoch
        incorrectEpochTriggerData = recordedFlashStructure.(presentEpochExpected).trigger_data;
        correctedEpochTriggerData = [incorrectEpochTriggerData(incorrectEpochTriggerData<recordedTriggerDataInWrongEpoch(1)); recordedTriggerDataInWrongEpoch; incorrectEpochTriggerData(incorrectEpochTriggerData>recordedTriggerDataInWrongEpoch(end))];
        recordedFlashStructure.(presentEpochExpected).trigger_data = correctedEpochTriggerData;
        incorrectEpochFrameTriggerOffsetData = recordedFlashStructure.(presentEpochExpected).frameTriggerOffset;
        correctedFrameTriggerOffsetData = [incorrectEpochFrameTriggerOffsetData(incorrectEpochTriggerData<recordedTriggerDataInWrongEpoch(1)); recordedFrameTriggerOffsetsInWrongEpoch; incorrectEpochFrameTriggerOffsetData(incorrectEpochTriggerData>recordedTriggerDataInWrongEpoch(end))];
        recordedFlashStructure.(presentEpochExpected).frameTriggerOffset = correctedFrameTriggerOffsetData;
        incorrectBoundsData = recordedFlashStructure.(presentEpochExpected).bounds;
        correctedBoundsData = [incorrectBoundsData(:, incorrectBoundsData(1, :)<correctNewBoundsData(1, 1)) correctNewBoundsData incorrectBoundsData(:, incorrectBoundsData(1, :)>correctNewBoundsData(2, 1))];
        recordedFlashStructure.(presentEpochExpected).bounds = correctedBoundsData;
        
        % Now we must change the expanded and frame skipped structure the
        % same way so that next time through the loop the indexes still
        % match! Remember that the epoch starts should not be changing in
        % this case (just a few more added) so the mistakeIndexes
        % location should remain the same
        recordedEpochBeforeSkipped = associatedExpectedEpochWithFrameSkipsAndExpandedSorted{mistakeIndexes(2, i)-1};
        recordedTriggerDataInWrongEpoch = expectedFlashStructureWithFrameSkipsAndExpanded.(recordedEpochBeforeSkipped).trigger_data(triggerDataForSkippedEpochIndexes);
        expectedFlashStructureWithFrameSkipsAndExpanded.(recordedEpochBeforeSkipped).trigger_data(triggerDataInWrongEpochIndexes) = [];
        recordedFrameTriggerOffsetsInWrongEpoch = expectedFlashStructureWithFrameSkipsAndExpanded.(recordedEpochBeforeSkipped).frameTriggerOffset(triggerDataForSkippedEpochIndexes);;
        expectedFlashStructureWithFrameSkipsAndExpanded.(recordedEpochBeforeSkipped).frameTriggerOffset(triggerDataInWrongEpochIndexes) = [];
        correctNewBoundsData = [recordedTriggerDataInWrongEpoch(1); expectedFlashStructureWithFrameSkipsAndExpanded.(recordedEpochBeforeSkipped).bounds(2, boundsForSkippedEpochExpandedIndex)];
        expectedFlashStructureWithFrameSkipsAndExpanded.(recordedEpochBeforeSkipped).bounds(2, boundsForSkippedEpochExpandedIndex) = recordedTriggerDataInWrongEpoch(1);
        
        % Add to the new epoch
        incorrectEpochTriggerData = expectedFlashStructureWithFrameSkipsAndExpanded.(presentEpochExpected).trigger_data;
        correctedEpochTriggerData = [incorrectEpochTriggerData(incorrectEpochTriggerData<recordedTriggerDataInWrongEpoch(1)); recordedTriggerDataInWrongEpoch; incorrectEpochTriggerData(incorrectEpochTriggerData>recordedTriggerDataInWrongEpoch(end))];
        expectedFlashStructureWithFrameSkipsAndExpanded.(presentEpochExpected).trigger_data = correctedEpochTriggerData;
        incorrectEpochFrameTriggerOffsetData = expectedFlashStructureWithFrameSkipsAndExpanded.(presentEpochExpected).frameTriggerOffset;
        correctedFrameTriggerOffsetData = [incorrectEpochFrameTriggerOffsetData(incorrectEpochTriggerData<recordedTriggerDataInWrongEpoch(1)); recordedFrameTriggerOffsetsInWrongEpoch; incorrectEpochFrameTriggerOffsetData(incorrectEpochTriggerData>recordedTriggerDataInWrongEpoch(end))];
        expectedFlashStructureWithFrameSkipsAndExpanded.(presentEpochExpected).frameTriggerOffset = correctedFrameTriggerOffsetData;
        incorrectBoundsData = expectedFlashStructureWithFrameSkipsAndExpanded.(presentEpochExpected).bounds;
        correctedBoundsData = [incorrectBoundsData(:, incorrectBoundsData(1, :)<correctNewBoundsData(1, 1)) correctNewBoundsData incorrectBoundsData(:, incorrectBoundsData(1, :)>correctNewBoundsData(2, 1))];
        expectedFlashStructureWithFrameSkipsAndExpanded.(presentEpochExpected).bounds = correctedBoundsData;
    end
    
    Z.params.trigger_inds = recordedFlashStructure;
    Z = CorrectPDWithStimData(Z);
    return
end

% We're rebuilding the flash structure so the epochs are appropriately
% named.
for i = 1:length(expectedBoundStartsSorted)
    % Add the bounds
    newFlashStructure.(associatedExpectedEpochSorted{i}).bounds = [newFlashStructure.(associatedExpectedEpochSorted{i}).bounds recordedFlashBoundsSorted(:, i)];
    
    % Add the trigger data
    recordedEpochData = recordedFlashStructure.(associatedRecordedEpochSorted{i});
    indexesInRecordedEpoch = recordedEpochData.trigger_data >= recordedFlashBoundsSorted(1, i) & recordedEpochData.trigger_data < recordedFlashBoundsSorted(2, i);
    triggerData = recordedEpochData.trigger_data(indexesInRecordedEpoch);
    newFlashStructure.(associatedExpectedEpochSorted{i}).trigger_data = [newFlashStructure.(associatedExpectedEpochSorted{i}).trigger_data; triggerData];
    
    % Add frameTriggerOffset data
    frameTriggerOffset = recordedEpochData.frameTriggerOffset(indexesInRecordedEpoch);
    newFlashStructure.(associatedExpectedEpochSorted{i}).frameTriggerOffset = [newFlashStructure.(associatedExpectedEpochSorted{i}).frameTriggerOffset; frameTriggerOffset];
    
end

% Finally we want to recompute the stim_lengths. We got through
% epochsExpected because that's the only thing the new flash structure will
% have...
for ind = 1:length(epochsExpected)
    %This happens if the epochs are the only stimulus triggers
    epochAlignmentPoints = newFlashStructure.(epochsExpected{ind}).trigger_data;
    bounds = newFlashStructure.(epochsExpected{ind}).bounds;
    if isequal(epochAlignmentPoints, bounds(1,:)')
        stim_length = median(diff(bounds));
    elseif length(epochAlignmentPoints) == size(bounds, 2) % Not really sure why this case is here as I'd've thought it would've been covered by the first one, but shit happens, right?
        stim_length = median(diff(bounds));
    else
        %NOTE to self: should this better be a sort and choose the
        %first one instead of a median?
        stim_length = median(diff(epochAlignmentPoints));
    end
    newFlashStructure.(epochsExpected{ind}).stim_length = stim_length;
end

% And now we replace the old trigger_inds with the new ones...
Z.params.trigger_inds = newFlashStructure;

