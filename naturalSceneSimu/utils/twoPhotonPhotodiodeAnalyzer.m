function [trigger_inds] = twoPhotonPhotodiodeAnalyzer(roi_avg_PDintensity, expected_flash_length, imgSizeForAnalysis, Z)

inputsRequired = {'linescan','pdSignalFractionAboveNoise'};
pdSignalFractionAboveNoise = 0.2;
loadFlexibleInputs(Z, inputsRequired)

%First clean up the data to make it much more easily analyzable. We're
%using a TTL 0.5 threshold for changeover to on
min_roi = min(roi_avg_PDintensity);
roi_avg_PDintensity = roi_avg_PDintensity-min_roi;
max_roi = max(roi_avg_PDintensity);
roi_clean_data = zeros(length(roi_avg_PDintensity),1);
% This 0.2 breaks some things if you use the calculated flash_length below
% to determine your epoch_numbers. If, instead, you use
% expected_flash_length (this is as an input to twoPhotonEpochDecoder I'm
% talking about), then everything's dandy. We're gonna go with dandy. It
% used to be 0.5, but that broke another dataset. Hopefully this doesn't
% break anything.
roi_clean_data(roi_avg_PDintensity>pdSignalFractionAboveNoise*max_roi) = 1;
%We'll find the trigger times by means of discovering when the clean
%data changes
PD_diff = diff(roi_clean_data);
%Here we get rid of the falling edge; we add one because we want the start
%to be at the high point of the difference. If our PD data is [0 1 1 1 0]
%then PD_diff will be [1 0 0 -1] and the below find will return index 1,
%but clearly the start should be at index 2!
indexes_beginning = find(PD_diff > 0) + 1;
%Here we get rid of the rising edge. With the example above, we can see
%that we don't need to add one here, because it would return index 4, which
%is in fact the end of the trigger!
indexes_end = find(PD_diff < 0);
%Get rid of the first fall if we start in a bright area or get rid of
%the last rise if we end in a bright area
if indexes_beginning(1) > indexes_end(1)
    indexes_end(1) = [];
elseif indexes_end(end) < indexes_beginning(end)
    indexes_beginning(end) = [];
end
%Every rise will have a fall at this point, unless something's gone
%wrong
if length(indexes_beginning) ~= length(indexes_end)
    error('Rises and falls can''t be matched in the photodiode data; it will need a more thorough lookthrough')
end

% Add one here because if 
flash_lengths = indexes_end-indexes_beginning+1;

%The median should get us the length of the smallest flash (because
%lone flashes occur significantly more often)
unique_flash_lengths = unique(flash_lengths);
%NOTE if something goes wrong here it might be that the
%expected_flash_length and the actual flash_lengths are a couple of pixels
%off.. just... uncomment the following two lines and comment the one after
flash_length = unique_flash_lengths(unique_flash_lengths>=expected_flash_length);
flash_length = flash_length(1);
% flash_length = expected_flash_length;
if round(flash_length/expected_flash_length)> 1
   tempDivisor = round(flash_length/expected_flash_length);
   flash_length = ceil(flash_length/tempDivisor);
end

%Now we're looking at the blank spaces between the triggers
indexes_blank_end = indexes_beginning(2:end);
indexes_blank_begin = indexes_end(1:end-1);
space_lengths = indexes_blank_end-indexes_blank_begin;

%Epochs *always* start with two flashes (because you have one high
%flash, and then it's *always* followed by a one by the binary encoding
%of the epoch number)
epoch_code_starts = indexes_beginning(flash_lengths > 1.5*flash_length);
%If the epoch *is* the stimulus. I don't like this...
if isempty(epoch_code_starts)
    epoch_code_starts = indexes_beginning;
end
%TODO: this is very specific to my current stimuli--we actually need to
%define master_stimulus so that these epoch starts can be easily
%distinguished!
%This is very specific because 4 epochs have a max binary of 100, which
%has two blank frames, or ~30 data points *and* two flashes + 100 (3)
%flashes + 1 end flash gives max 6 flashes (or ~90 data points)
%Also note that to remove repeat frames from dropped ones, there must
%be at least 30 frames between start and end
epoch_code_ends = [];
for i = length(epoch_code_starts):-1:1
    start = epoch_code_starts(i);
    %We've upped the end multiplier to 8*--this means we expect up to a
    %six digit binary to come in here--this means we expect there won't be
    %another flash 8 frames/60 fps = 134 ms after the beginning of the
    %epoch encoding; we dead if there is
    potential_ends = indexes_end(indexes_end>=(start+2*flash_length) & indexes_end<=start+floor(8.2*flash_length));
    %In case there's a binary with a zero, there will be multiple drops
    %within 90 points, but it's only the last one that marks our ending
    if isempty(potential_ends)
        % We check here if we're possibly at the last presentation of 20
        % flashes
        allPotentialEnds = indexes_end(indexes_end>start);
        potential_ends = allPotentialEnds(1);
        if (potential_ends - start) <= 7*flash_length
            epoch_code_starts(i) = [];
            continue
        end
    end
    epoch_code_ends = [epoch_code_ends; potential_ends(end)];
    if length(epoch_code_ends)>1 && epoch_code_ends(end) == epoch_code_ends(end-1)
        epoch_code_ends(end-1) = [];
        %This is i+1 because we're looking at the previous value, which
        %is actually the value one higher because i is going backwards
        %through the indexes
        epoch_code_starts(i+1) = [];
    end
    %Get rid of trigger indexes that fall within the epoch code indexes
    indexes_beginning(indexes_beginning>start & indexes_beginning <= potential_ends(end)) = [];
end

%Gotta align them with epoch_code_starts!
epoch_code_ends = epoch_code_ends(end:-1:1);

[epoch_number, epoch_boundary_inds] = twoPhotonEpochDecoder(roi_clean_data, epoch_code_starts, epoch_code_ends, expected_flash_length);

epoch_data = [epoch_number epoch_boundary_inds];

if length(epoch_data)==length(indexes_beginning)
    if linescan
        stim_length = round(mean(diff(indexes_beginning)));
    else
        stim_length = round(mean(diff(indexes_beginning))/imgSizeForAnalysis(1));
    end
else
    stim_length = [];
end

%Get rid of last one because the full stimulus is unlikely to have been
%presented
all_trigger_indexes = indexes_beginning(1:end-1)-1;
    
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
            alignmentPoints = all_trigger_indexes(all_trigger_indexes>=inds(1) & all_trigger_indexes<inds(2));
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
                end
            else
                stimDiff = [stimDiff diff(alignmentPoints)];
            end
            if length(alignmentPoints)==1
                stimDiff = [stimDiff diff(inds)];
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
             epochAlignmentPoints = [epochAlignmentPoints; all_trigger_indexes(all_trigger_indexes>=inds(1) & all_trigger_indexes<inds(2))];
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
        epoch_trigger_frames = epochAlignmentPoints/imgSizeForAnalysis(1)+1;
        epochFrameTriggerOffsets = imgSizeForAnalysis(1) - mod(epochAlignmentPoints, imgSizeForAnalysis(1));
        
        % Note that this stim_length gets recalculated in
        % CorrectPDWithStimData.m --> Not sure if we should just have that
        % do it all...
        %This happens if the epochs are the only stimulus triggers
        if isequal(epochAlignmentPoints, bounds(1,:)')
            stim_length = median(diff(bounds))/imgSizeForAnalysis(1);
        elseif length(epochAlignmentPoints) == size(bounds, 2)
            stim_length = median(diff(bounds))/imgSizeForAnalysis(1);
        elseif isempty(stim_length)
            %NOTE to self: should this better be a sort and choose the
            %first one instead of a median?
            stim_length = median(diff(epochAlignmentPoints))/imgSizeForAnalysis(1);
        end
        epoch_field = ['epoch_' num2str(unique_epochs(i))];
        trigger_inds.(epoch_field).trigger_data = epoch_trigger_frames;
        trigger_inds.(epoch_field).frameTriggerOffset = epochFrameTriggerOffsets;
        % In case the stim_length jumps over the length of the grabbed
        % data, we can shorten it here.
        if any(stim_length+epoch_trigger_frames>imgSizeForAnalysis(3))
            warning('Had to shorten the data!');
            stim_length = min(imgSizeForAnalysis(3)-epoch_trigger_frames);
        end
        trigger_inds.(epoch_field).stim_length = stim_length;
        % Add one to the bounds for the same reason as described above for
        % the epoch_trigger_frames variable
        trigger_inds.(epoch_field).bounds = bounds/imgSizeForAnalysis(1)+1;
    end
end