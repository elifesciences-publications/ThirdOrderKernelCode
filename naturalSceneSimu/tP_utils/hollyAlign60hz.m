function [alignedStimulusData, alignedResponseData] = hollyAlign60hz(stimulusData, expectedFlashStream, responseData, recordedFlashStructure, fs)

recordedFlashIndexes = [];
epochs = fieldnames(recordedFlashStructure);
max_index = 1;
last_epoch_recorded = epochs{1};
for ind = 1:length(epochs)
    epoch_triggers = recordedFlashStructure.(epochs{ind}).trigger_data;
    recordedFlashIndexes = [recordedFlashIndexes; epoch_triggers];
    if max(epoch_triggers) > max_index
        max_index = max(epoch_triggers);
        last_epoch_recorded = epochs{ind};
    end
end
recordedFlashIndexes = sort(recordedFlashIndexes);

% The expected flash length of the recorded data is 1, because each flash
% is given on a per-frame basis.
streamExpectedFlashLength = 1;
% Image size is a dummy variable here because we're neither grabbing the
% flashs stream from recorded image data, nor do we care about the
% stim_length, which is what the imgSize is used for. Most importantly,
% when decoding this data as a linescan, imgSize isn't even ever used!
imgSize = [1 1 1];
% We're decoding this 'recorded' data as a linescan because that'll assume
% each data point is a potential trigger index, as opposed to it thinking
% it's part of an image frame, a frame whose index is then important. Note
% that the [1 1 1] imgSize value would remove that problem anyway
% (probably).
expectedFlashStructure = twoPhotonPhotodiodeAnalyzer([0; expectedFlashStream], streamExpectedFlashLength, imgSize, 'linescan', true);

expectedFlashIndexes = [];
epochs = fieldnames(expectedFlashStructure);
max_index = 1;
last_epoch_expected = epochs{1};
for ind = 1:length(epochs)
    epoch_triggers = expectedFlashStructure.(epochs{ind}).trigger_data;
    expectedFlashIndexes = [expectedFlashIndexes; epoch_triggers];
    if max(epoch_triggers) > max_index
        max_index = max(epoch_triggers);
        last_epoch_expected = epochs{ind};
    end
end
expectedFlashIndexes = sort(expectedFlashIndexes);

% First, we need to remove everything from the recorded data that comes
% before the first photodiode flash--that is to say, before the beginning
% of the stimulus
stimulusStart = recordedFlashIndexes(1);
responseDataCropped = responseData(stimulusStart:end,:);
recordedFlashIndexes = recordedFlashIndexes - stimulusStart + 1;

% Next, we need to remove all the stimulus data that occurred after
% recording stopped. This one's gonna assume perfect recording (which
% experience suggests is true) and assume the number of triggers recorded
% equals the number of triggers expected before recording stopped. I.e.
% we're going to delete all the expected triggers past that number. 
if length(expectedFlashIndexes) > length(recordedFlashIndexes)
    expectedFlashIndexes(length(recordedFlashIndexes)+1:end) = [];
end
% We're then going to do a first pass assumption that epoch decoding worked
% and use the stim_length in the expectedFlashStructure of the last epoch
% from recordedFlashStructure to figure out how far past the last trigger
% we have stimulus data that matters

stim_length_expected = expectedFlashStructure.(last_epoch_recorded).stim_length;
lastExpectedTrigger = expectedFlashIndexes(end);
lastDataPointExpected = lastExpectedTrigger + stim_length_expected;
stimulusDataCropped = stimulusData(1:lastDataPointExpected,:);

% Finally, we need to make sure and do this for the recorded data as well.
% This is because twoPhotonPhotodiodeAnalyzer's last returned trigger is
% the last *full* trigger. So it erases the actual last recorded trigger as
% there's but an infintesimal chance that it actually got the full
% presentation. This also ensures that the lastDataPoint will never
% overflow the matrix (though the :end avoids errors resulting from that)
stim_length_recorded = recordedFlashStructure.(last_epoch_recorded).stim_length;
lastRecordedTrigger = recordedFlashIndexes(end);
lastDataPointRecorded = lastRecordedTrigger + stim_length_recorded;
responseDataCropped(lastDataPointRecorded+1:end, :) = [];

% interpInd = linspace(1,length(responseDataCropped),floor(length(responseDataCropped)*60/fs));
interpInd = linspace(1,length(responseDataCropped),length(stimulusDataCropped));

alignedResponseData = interp1([1:length(responseDataCropped)],responseDataCropped,interpInd);

% alignedStimulusData = stimulusData(1:floor(length(responseDataCropped)*60/fs));
alignedStimulusData = stimulusDataCropped;

end
