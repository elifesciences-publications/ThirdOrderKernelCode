function Z = ExtractTriggersFromPhotodiode(Z)
% Z = ExtractTriggersFromPhotoDiode(Z)
%
% This function will use the stimulus parameters in
% Z.stimulus.allStimulusBehaviorData to determine what each of the triggers
% is triggering. I.e. whether or not it's triggering a new epoch or just a
% mid-epoch alignment point. I have never seen a lonely flash get
% disappeared from a dataset, but I have seen triple flashes become one
% flash, or single flashes become triples, which has always gotten in the
% way of good determination of the epochs being encoded. However, since
% flashes have always been there, and nonflashes have never been introduced
% between flashes, keeping track of the rises and aligning them to the
% expected rises should work out find :) I think. [fingers crossed]
extractTriggerStyle = 'fromRecording';
inputsRequired = {'linescan','fps','imgSize','extractTriggerStyle'};
loadFlexibleInputs(Z, inputsRequired)

avg_linear_PDintensity = Z.grab.avg_linear_PDintensity;

% We add 1 to the line length because scanimage discard the flyback line,
% but it should still count when determining how the rate at which each
% line is acquired (i.e. it takes the same amount of time for the mirrors
% to go from the bottom right corner to the top left corner of a frame as
% it takes them to traverse a single line, so this should count as the
% 128th line)
fs_pd = (imgSize(1)+1)*fps;
% The 60 is for 60Hz; fs samples/sec over 60 frames/sec should give
% samples/frame
expected_flash_length = fs_pd/60;

epochCodeLength = 10;
triggerBeginningIndexes = GrabTriggerBeginnings(avg_linear_PDintensity, expected_flash_length, epochCodeLength, Z);

% We're gonna trust the timing of the stim data now...
if isfield(Z.params, 'durationOfStimulusRecording')
    durationOfStimulusRecording = Z.params.durationOfStimulusRecording;
else
    durationOfStimulusRecording = (length(Z.grab.avg_linear_PDintensity)-triggerBeginningIndexes(1,1))/fs_pd;
end


firstFrame = Z.stimulus.allStimulusBehaviorData.FrameNumber(1);
expectedFlashes = [Z.stimulus.allStimulusBehaviorData.Flash(:, 1)];
expectedEpochs = Z.stimulus.allStimulusBehaviorData.Epoch(:, 1);
if firstFrame == 1
    expectedFlashes = expectedFlashes(1:end-1);
    expectedEpochs = expectedEpochs(1:end-1);
    times = Z.stimulus.allStimulusBehaviorData.Time(2:end);
else
    times = Z.stimulus.allStimulusBehaviorData.Time;
    expectedEpochs = [expectedEpochs(1); expectedEpochs];
end
firstNonrecordedStimulus = find(times > durationOfStimulusRecording, 1);
if strcmp(extractTriggerStyle, 'fromRecording')
    expectedFlashes(firstNonrecordedStimulus:end) = [];
    expectedEpochs(firstNonrecordedStimulus:end) = [];
end
expectedFlashes = [0; expectedFlashes; 0];
expectedEpochs = [0; expectedEpochs; 0];
stimulusDataFlashLength = 1; %Because each frame is one data point

expectedTriggerBeginningIndexes = GrabTriggerBeginnings(expectedFlashes, stimulusDataFlashLength, epochCodeLength, Z);

if length(triggerBeginningIndexes) ~= length(expectedTriggerBeginningIndexes)
    % We're going to try and see if there were any skipped frames and fill
    % them in here!
    firstFrame = Z.stimulus.allStimulusBehaviorData.FrameNumber(1);
    % When we switched to first frame being 1, we also switched the place
    % where the flashes are recorded to be a frame behind
    flashes = Z.stimulus.allStimulusBehaviorData.Flash(:, 1);
    expectedEpochs = Z.stimulus.allStimulusBehaviorData.Epoch(:, 1);
    if firstFrame == 1
        flashes = flashes(1:end-1);
        expectedEpochs = expectedEpochs(1:end-1);
        times = Z.stimulus.allStimulusBehaviorData.Time(2:end);
    else
        times = Z.stimulus.allStimulusBehaviorData.Time;
    end
    % Get rid of nonrecorded stuff now, adjust flashes later (since we'll
    % be making the vector bigger potentially)
    expectedEpochs(firstNonrecordedStimulus:end) = [];
    flashes(firstNonrecordedStimulus:end) = [];
    times(firstNonrecordedStimulus:end) = [];
    
    projectorFrameRate = 60; % 60 Hz
    timePerFlip = 1/projectorFrameRate;
    flipTimes = diff(times);
    flipTimes = [flipTimes; timePerFlip]; % Assume the last frame lasts the appropriate 16ms; this is to make sizes correct, shouldn't matter
    flipTimesCell = num2cell(flipTimes);
    frameInds = (1:length(flipTimes))';
    frameIndsCell = num2cell(frameInds);
    frameIndsExpansion = cellfun(@(x, y) repmat(x, round(y/timePerFlip), 1), frameIndsCell, flipTimesCell, 'UniformOutput', false);
    newFrameInds = cat(1, frameIndsExpansion{:});
    flashes = flashes(newFrameInds);
    times = times(newFrameInds);
    expectedEpochs = expectedEpochs(newFrameInds);
    
    flipTimes = diff(times);
    % This number is magical. Appreciate its enchanted properties.
    smallestValidFlipTime = 0.0135;
    potentialMissedFlashes = diff(flashes) & (flipTimes<smallestValidFlipTime);
    
    
    
    
    
    
    expectedEpochs(potentialMissedFlashes) = expectedEpochs(find(potentialMissedFlashes)+1);
    flashes(potentialMissedFlashes)=flashes(find(potentialMissedFlashes)+1);
    % Add on zeros at the beginning and the end to denote beginning and
    % end of first and last codes
    flashes = [0; flashes; 0];
    expectedEpochs = [0; expectedEpochs; 0];
    expectedTriggerBeginningIndexes = GrabTriggerBeginnings(flashes, stimulusDataFlashLength, epochCodeLength, Z);
    if length(triggerBeginningIndexes) ~= length(expectedTriggerBeginningIndexes)
        error('Amgad we can''t match indexes again >.>')
    end
end

[epoch_number, epoch_boundary_inds] = DecodeEpochsAndBoundaries(triggerBeginningIndexes, expectedTriggerBeginningIndexes, expectedEpochs);

epoch_data = [epoch_number epoch_boundary_inds];

%This is very specific because we assume that the epoch code will be max 6
%binary digits (or max 63). Add these six digits to the beginning and end
%flash and we get max digits of 8. There will likely be more, but hopefully
%no beginning index after eight digits.
maxBinaryDigits = 8;
maxNumberOfLines = (maxBinaryDigits+0.5)*expected_flash_length;
stim_length = [];
    
if linescan
    unique_epochs = unique(epoch_data(:, 1));
    for i = 1:length(unique_epochs)
        bounds = epoch_data(epoch_data(:, 1) == unique_epochs(i), 2:3)';
        epochAlignmentPoints = [];
        stimDiff = [];
        % This bit of code exists for the occasion when you have one epoch,
        % but within that epoch you have multiple aligning flashes (say
        % you're trying to extract a kernel and you're showing one epoch
        % for Gaussian flashing, but this epoch's stimfunction has a flash
        % ever second for alignment). The all_trigger_indexes variable
        % contains those flashes, even though they have been erased from
        % epoch_trigger_inds (because one flash is never an epoch code) and
        % you can capture the flashes that occur within one epoch
        for boundInd = 1:size(bounds, 2)
            inds = bounds(:, boundInd);
            alignmentPoints = [inds(1); triggerBeginningIndexes(triggerBeginningIndexes>=(inds(1)+maxNumberOfLines) & triggerBeginningIndexes<inds(2))];
            epochAlignmentPoints = [epochAlignmentPoints; alignmentPoints];
            if ~isempty(stimDiff)
                % This code runs for the case where one of the epochs has
                % fewer alignment points than the other ones, so the diff
                % is shorter and the concatenation wouldn't work. By
                % putting an NaN for the remaining slots, we can then do an
                % nanmedian below to find the stim_length. BOOYAH!
                if ~isempty(diff(alignmentPoints))
                    stimDiff(1:length(diff(alignmentPoints)), end+1) = diff(alignmentPoints);
                    % Remember that end+1 was created in the previous line, so
                    % this column should be end!
                    stimDiff(length(diff(alignmentPoints))+1:end, end) = NaN;
                else
                    stimDiff(1:length(diff(inds)), end+1) = diff(inds);
                    % Remember that end+1 was created in the previous line, so
                    % this column should be end!
                    stimDiff(length(diff(inds))+1:end, end) = NaN;
                end
            elseif length(alignmentPoints) == 1
                stimDiff = [stimDiff diff(inds)];
            else
                stimDiff = [stimDiff diff(alignmentPoints)];
            end
        end
        
        epoch_field = ['epoch_' num2str(unique_epochs(i))];
        trigger_inds.(epoch_field).trigger_data = epochAlignmentPoints;
        trigger_inds.(epoch_field).frameTriggerOffset = zeros(size(epochAlignmentPoints));
        %Uncomment if you ever run into a stim_length going over the length
        %of the image
%         if any(stim_length+epoch_trigger_inds>length(roi_avg_PDintensity))
%             stim_length = min(length(roi_avg_PDintensity)-epoch_trigger_inds)
%         end
        if isempty(stim_length)
            stim_length = round(nanmedian(stimDiff));
            trigger_inds.(epoch_field).stim_length = stim_length;
            % Make it empty again so the next epoch gets into here and
            % calculates a new stim_length for its epoch!
            stim_length = [];
        else
            trigger_inds.(epoch_field).stim_length = stim_length;
        end
        trigger_inds.(epoch_field).bounds = bounds;
    end
else
    unique_epochs = unique(epoch_data(:, 1));
    for i = 1:length(unique_epochs)
        bounds = epoch_data(epoch_data(:, 1) == unique_epochs(i), 2:3)';
        epochAlignmentPoints = [];
        for inds = bounds
             epochAlignmentPoints = [epochAlignmentPoints; inds(1); triggerBeginningIndexes(triggerBeginningIndexes>=(inds(1)+maxNumberOfLines) & triggerBeginningIndexes<inds(2))];
        end
        %This could happen if there are no triggers in the epoch. 'But how
        %did the epoch get found?' you might ask. Well, the epoch finding
        %is distinct from the calculation of whether a full stimulus has
        %been shown. So the epoch may have been found, but then it could be
        %discovered that the epoch code may have also been the last trigger
        %of the stimulus, which means the full stimulus wasn't shown. If
        %there happens to be only one epoch of that kind, we'd then find
        %that it has no triggers associated with it and it will be empty!
        if isempty(epochAlignmentPoints)
            continue;
        end
        %The epoch_trigger_inds occur sometime in the middle of a frame,
        %and we have to get them back into frame space so we divide by the
        %number of rows per frame. We then need to store what fraction of
        %the frame through the flash occurred. Think if it's the first
        %frame and the flash occurs at line 26 of, say, 128. 26/128<1, so
        %but you want to show what fraction through frame 1 it went! So you
        %add one. HOWEVER! For more refined tweaks, an offset is saved to
        %note how many lines before that frame's end the flash actually
        %occurred.
        epoch_trigger_frames = epochAlignmentPoints/imgSize(1)+1;
        epochFrameTriggerOffsets = imgSize(1) - mod(epochAlignmentPoints, imgSize(1));
        
        % Note that this stim_length gets recalculated in
        % CorrectPDWithStimData.m --> Not sure if we should just have that
        % do it all...
        %This happens if the epochs are the only stimulus triggers
        if isequal(epochAlignmentPoints, bounds(1,:)')
            stim_length = median(diff(bounds))/imgSize(1);
        elseif length(epochAlignmentPoints) == size(bounds, 2)
            stim_length = median(diff(bounds))/imgSize(1);
        elseif isempty(stim_length)
            %NOTE to self: should this better be a sort and choose the
            %first one instead of a median?
            stim_length = median(diff(epochAlignmentPoints))/imgSize(1);
        end
        epoch_field = ['epoch_' num2str(unique_epochs(i))];
        trigger_inds.(epoch_field).trigger_data = epoch_trigger_frames;
        trigger_inds.(epoch_field).frameTriggerOffset = epochFrameTriggerOffsets;
        % In case the stim_length jumps over the length of the grabbed
        % data, we can shorten it here.
        if any(stim_length+epoch_trigger_frames>imgSize(3))
            warning('Had to shorten the data!');
            stim_length = min(imgSize(3)-epoch_trigger_frames);
        end
        trigger_inds.(epoch_field).stim_length = stim_length;
        % Add one to the bounds for the same reason as described above for
        % the epoch_trigger_frames variable
        trigger_inds.(epoch_field).bounds = bounds/imgSize(1)+1;
    end
end

Z.params.trigger_inds = trigger_inds;