function [indexes_beginning, flash_length] = GrabTriggerBeginnings(roiAvgPDintensity, expectedFlashLength, epochCodeLength, varargin)

pdSignalFractionAboveNoise = 0.01;
changeableVarargin = {'pdSignalFractionAboveNoise'};

for ii = 1:2:length(varargin)
    if any(strcmp(changeableVarargin, varargin{ii}))
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    else
        continue
    end
end


%First clean up the data to make it much more easily analyzable. We're
%using a TTL 0.5 threshold for changeover to on
min_roi = min(roiAvgPDintensity);
roiAvgPDintensity = roiAvgPDintensity-min_roi;
max_roi = max(roiAvgPDintensity);
roi_clean_data = zeros(length(roiAvgPDintensity),1);
% This 0.2 breaks some things if you use the calculated flash_length below
% to determine your epoch_numbers. If, instead, you use
% expected_flash_length (this is as an input to twoPhotonEpochDecoder I'm
% talking about), then everything's dandy. We're gonna go with dandy. It
% used to be 0.5, but that broke another dataset. Hopefully this doesn't
% break anything.
roi_clean_data(roiAvgPDintensity>pdSignalFractionAboveNoise*max_roi) = 1;
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
temp_end = [];
if indexes_beginning(1) > indexes_end(1)
    % We're gonna save this so we can put it back in with the appropriate
    % beginning flash--importantly, we should *never* be starting with the
    % flash on, unless something's gone weird. So we'll be replacing the
    % flash on with the flash code for epoch 1 (where we should *always* be
    % starting)
    temp_end = indexes_end(1);
    % We still have to remove this, however, to make sure that the
    % flash_lengths are correctly calculated
    indexes_end(1) = [];
elseif indexes_end(end) < indexes_beginning(end)
    indexes_beginning(end) = [];
end
%Every rise will have a fall at this point, unless something's gone
%wrong
if length(indexes_beginning) ~= length(indexes_end)
    error('Rises and falls can''t be matched in the photodiode data; it will need a more thorough lookthrough')
end


% Add one here because if [oh, my I never finished this comment... that's
% unfortunate]
flash_lengths = indexes_end-indexes_beginning+1;

%The median should get us the length of the smallest flash (because
%lone flashes occur significantly more often)
unique_flash_lengths = unique(flash_lengths);
%NOTE if something goes wrong here it might be that the
%expected_flash_length and the actual flash_lengths are a couple of pixels
%off.. just... uncomment the following two lines and comment the one after
flash_length = unique_flash_lengths(unique_flash_lengths>=expectedFlashLength);

if ~isempty(temp_end)
    indexes_beginning = [temp_end-3*flash_length; indexes_beginning];
    indexes_end = [temp_end; indexes_end];
    warning(['It seems as if the acquisition started with the photodiode reading an '...
        'on flash (i.e. the screen was already on, probably). '...
        'This has been fixed by putting in a faux epoch_1 code.'])
end


pointsPerEpochCode = epochCodeLength*expectedFlashLength;
nonEpochCodeFlashes = [true; diff(indexes_beginning)>pointsPerEpochCode];
indexes_beginning = indexes_beginning(nonEpochCodeFlashes);
