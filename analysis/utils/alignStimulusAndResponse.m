function [alignedStimulusData, alignedResponseData, fsFactor, alignedFlashStructure, interpValsConcat] = alignStimulusAndResponse(stimulusData, allStimulusBehaviorData, responseData, recordedFlashStructure, centerOfMassFraction, movieSize, dataRate, varargin)


interpolateInds = 'upsample';
interpolationMethod = 'nearest';
linearizeTriggerInds = false;

changeableVarargin = {'interpolateInds', 'interpolationMethod', 'linearizeTriggerInds'};

for ii = 1:2:length(varargin)
    if any(strcmp(changeableVarargin, varargin{ii}))
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    else
        continue
    end
end



if linearizeTriggerInds
    triggerIndsLinearizationFactor = movieSize(1);
else
    triggerIndsLinearizationFactor = 1;
end

recordedFlashIndexes = [];
% recordedFlashOffsets = [];
max_index = 1;
last_epoch_recorded = 1; 
for ind = 1:length(recordedFlashStructure)
    epoch_triggers = recordedFlashStructure(ind).trigger_data*triggerIndsLinearizationFactor;
%     epochTriggerOffsets = recordedFlashStructure.(epochs{ind}).frameTriggerOffset;
    recordedFlashIndexes = [recordedFlashIndexes; epoch_triggers];
%     recordedFlashOffsets = [recordedFlashOffsets; epochTriggerOffsets];
    if max(epoch_triggers) > max_index
        max_index = max(epoch_triggers);
        last_epoch_recorded = ind;
    end
end
[recordedFlashIndexes] = sort(recordedFlashIndexes);

% Here we're shifting all the recorded flash triggers by the start of the
% stimulus, because if we end up outputting recordedFlashStructure as the
% alignedFlashStructure (see the very bottom), then we need to make sure
% that trigger_data is valid for the aligned data, and this data has been
% cropped to not include the blank period at the start. No, I couldn't
% think of a way to wrap this into the previous for loop, sadly.
for ind = 1:length(recordedFlashStructure)
    stimulusStart = floor(recordedFlashIndexes(1))-1*triggerIndsLinearizationFactor;
    % One way to think about why we're adding one is to think of the case
    % where the stimulusStart is index 1. If we do 1-1=0, we'll get a zero
    % index, which Matlab doesn't like!
    recordedFlashStructure(ind).trigger_data = recordedFlashStructure(ind).trigger_data*triggerIndsLinearizationFactor - stimulusStart + 1;
    recordedFlashStructure(ind).bounds = recordedFlashStructure(ind).bounds*triggerIndsLinearizationFactor - stimulusStart + 1;
    recordedFlashStructure(ind).stim_length = recordedFlashStructure(ind).stim_length*triggerIndsLinearizationFactor;
end
% recordedFlashOffsets = recordedFlashOffsets(sortInds);

% Sadly, the projector's not perfect, and frames get skipped and such.
% Thankfully, there's a good record of when this happens which allows
% reconstruction of the original stimulus! 
t = allStimulusBehaviorData.Time;
flashes = allStimulusBehaviorData.Flash(:, 1);

% The values align appropriately across the rows only if the frames are
% appropriately offset. For a minute there, we'd appropriately offset them
% in the stim file, but then someone came and changed it back. Now we check
% for that changeback noting that if the first frame listed is 1 (instead
% of 2) then we have to shift the flashes appropriately
firstFrame = allStimulusBehaviorData.FrameNumber(1);
if firstFrame == 1
    flashes = flashes(1:end-1);
    t = t(2:end);
    stimulusData = stimulusData(2:end);
end


flipTimes = diff([0;t]);

% Think on this: if a flip delay of one extra frame happens between the first and second frame (i.e.,
% t(2)-t(1)=z(2)~(1/60)*2), then it's actually the *previous* frame that
% got presented twice in a row. What I mean by previous is that even
% thought z(2)~2/60, it's t(1)'s frame that gets those two presentations.
% So we want to align z(2) with t(1), which involves gettign rid of the
% first value. They still have to be the same length however, so add a one
% at the end (of frameReps!!!) (which makes the assumption that the last
% frame gets presented only once; shouldn't matter either way). ("But why
% not just say z=diff(t), then?" you might ask. Well, extra steps
% notwithstanding, it makes more sense to include the first frame's flip
% duration in my mind.) << NOT SURE THIS APPLIES ANYMORE

% Each frame repeats the number of multiples of the 60Hz presentation time
% the flip takes--so 
projectorFrameRate = 60; % 60 Hz
frameReps = flipTimes/(1/projectorFrameRate);
frameReps = floor(frameReps);
% On occasion it's even faster, so set that equal to one
frameReps(frameReps==0) = 1;
if firstFrame ~= 1
    frameReps = [frameReps; 1];
end

% Let's put everything together so we manipulate it together
together = [stimulusData flashes t];
indexes = 1:length(frameReps);
repeatNumMax = max(frameReps);
currRepeat = 2;
while currRepeat<=repeatNumMax
    indexes(currRepeat, frameReps>=currRepeat) = indexes(1, frameReps>=currRepeat);
    currRepeat = currRepeat+1;
end
indexes = indexes(:);
indexes(indexes==0) = [];
expanded =  together(indexes, :);
% together = [stimulusData flashes t frameReps];
% combo = mat2cell(together, ones(size(flashes)), size(together, 2));
% expanded = cellfun(@(val) repmat([val(1:end-1)], [val(end), 1]), combo, 'UniformOutput', false);
% expanded = cell2mat(expanded);
expectedFlashStream = expanded(:, end-1);
%expectedFlashStream = expanded(1:25195, end-1);
stimulusData = expanded(:, 1:end-2); %For the times stimulusData is multiple columns
expandedT = expanded(:, end);

% The expected flash length of the recorded data is 1, because each flash
% is given on a per-frame basis.
streamExpectedFlashLength = 1;
% Image size is a dummy variable here because we're neither grabbing the
% flashs stream from recorded image data, nor do we care about the
% stim_length, which is what the imgSize is used for. Most importantly,
% when decoding this data as a linescan, imgSize isn't even ever used!
expectedFlashStream = [0; expectedFlashStream; 0];
% We're decoding this 'recorded' data as a linescan because that'll assume
% each data point is a potential trigger index, as opposed to it thinking
% it's part of an image frame, a frame whose index is then important. Note
% that the [1 1 1] imgSize value would remove that problem anyway
% (probably).
linescanPhotodiode = true;
sizePhotodiode = [1 1 1];
photoDiodeFps = 60;
extractTriggerStyle = 'fromStimData';
expectedFlashStructure = ExtractTriggersFromPhotodiode(expectedFlashStream, allStimulusBehaviorData, linescanPhotodiode, photoDiodeFps,sizePhotodiode, 'extractTriggerStyle', extractTriggerStyle);

expectedFlashIndexes = [];
max_index = 1;
last_epoch_expected = 1;
for ind = 1:length(expectedFlashStructure)
    epoch_triggers = expectedFlashStructure(ind).trigger_data;
    expectedFlashIndexes = [expectedFlashIndexes; epoch_triggers];
    if max(epoch_triggers) > max_index
        max_index = max(epoch_triggers);
        last_epoch_expected = ind;
    end
end
expectedFlashIndexes = sort(expectedFlashIndexes);

% First, we need to remove everything from the recorded data that comes
% before the first photodiode flash--that is to say, before the beginning
% of the stimulus
stimulusStart = floor(recordedFlashIndexes(1))-1*triggerIndsLinearizationFactor;
% stimulusStart = recordedFlashIndexes(1);
responseDataCropped = responseData(floor(stimulusStart):end,:);
recordedFlashIndexes = recordedFlashIndexes - floor(stimulusStart) + 1 -1*triggerIndsLinearizationFactor;

% Next, we need to remove all the stimulus data that occurred after
% recording stopped. This one's gonna assume perfect recording (which
% experience suggests is true) and assume the number of triggers recorded
% equals the number of triggers expected before recording stopped. I.e.
% we're going to delete all the expected triggers past that number. 
if length(expectedFlashIndexes) > length(recordedFlashIndexes)
    expectedFlashIndexes(length(recordedFlashIndexes)+1:end) = [];
    for ind = 1:length(expectedFlashStructure)
        expectedFlashStructure(ind).trigger_data(expectedFlashStructure(ind).trigger_data>expectedFlashIndexes(end))=[];
        expectedFlashStructure(ind).bounds(:, expectedFlashStructure(ind).bounds(1, :) >expectedFlashIndexes(end))=[];
    end
end
% We're then going to do a first pass assumption that epoch decoding worked
% and use the stim_length in the expectedFlashStructure of the last epoch
% from recordedFlashStructure to figure out how far past the last trigger
% we have stimulus data that matters
% stim_length_expected = expectedFlashStructure.(last_epoch_expected).stim_length;
% lastExpectedTrigger = expectedFlashIndexes(end);
% lastDataPointExpected = lastExpectedTrigger + stim_length_expected;
lastDataPointExpected =  expectedFlashStructure(last_epoch_expected).bounds(end, end);% lastExpectedTrigger + stim_length_expected;
stimulusDataCropped = stimulusData([1 1:lastDataPointExpected],:);

% Finally, we need to make sure and do this for the recorded data as well.
% This is because twoPhotonPhotodiodeAnalyzer's last returned trigger is
% the last *full* trigger. So it erases the actual last recorded trigger as
% there's but an infintesimal chance that it actually got the full
% presentation. This also ensures that the lastDataPoint will never
% overflow the matrix (though the :end avoids errors resulting from that)
stim_length_recorded = recordedFlashStructure(last_epoch_recorded).stim_length;
lastRecordedTrigger = recordedFlashIndexes(end);
lastDataPointRecorded = lastRecordedTrigger + stim_length_recorded;
lastDataPointRecorded = recordedFlashStructure(last_epoch_recorded).bounds(end, end);
% lastDataPointRecorded = recordedFlashStructure.(last_epoch_recorded).bounds(end, end);%lastRecordedTrigger + stim_length_recorded;
responseDataCropped(floor(lastDataPointRecorded)+1:end, :) = [];

% Next step is to take into account the possibility that the stimulus data
% was changing at 180Hz, while each row is recorded at 60Hz. Put simply, we
% need to linearize the stimulus data.
stimulusDataTransposed = stimulusDataCropped';
stimulusDataLinearized = stimulusDataTransposed(:);
% As we're expanding the stimulus set, we have to shift the trigger
% indexes accordingly. So if there are three values per frame and the
% original trigger were at frame 2, the new one should be at index 4, as
% that's where frame 2 starts in the expanded indexes. The equation can
% easily be worked out to be (frame-1)*expansion + 1;
factorIndExpansion = size(stimulusDataCropped,2);
expectedFlashIndexes = (expectedFlashIndexes-1)*factorIndExpansion+1;

for ind = 1:length(expectedFlashStructure)
    currTrigData = expectedFlashStructure(ind).trigger_data;
    expectedFlashStructure(ind).trigger_data = (currTrigData-1)*factorIndExpansion+1;
    currBoundsData = expectedFlashStructure(ind).bounds;
    expectedFlashStructure(ind).bounds = (currBoundsData-1)*factorIndExpansion+1;
end

% Now we're going to interpolate the smaller data set to the bigger one by
% the linspace technique of just stretching the same values across (we'll
% usually be interpolating the stimulusData to the recorded data, something
% that should work fine since it's not making up data to say that a given
% frame presented continues to be that frame until the next one appears)
% TODO: consider always only changing the stimulus data by upsampling or
% downsampling, under the assumption that those will be the only
% quantifiable changes anyway
if length(stimulusDataLinearized) < length(responseDataCropped) && strcmp(interpolateInds,'upsample')
    dataForInterpolation = stimulusDataLinearized;
    postInterpolationInds = recordedFlashIndexes;
    preInterpolationInds = expectedFlashIndexes;
    interpolatedData = zeros(size(responseDataCropped, 1), size(dataForInterpolation, 2));
elseif length(stimulusDataLinearized) < length(responseDataCropped) && strcmp(interpolateInds,'downsample')
    warning('This might not work. Check it.');
    % Low passing the response data here...
    highFrequency = 60/dataRate; % Using the typical projector frame rate
    [z,p,k] = butter(2, highFrequency, 'low');
    [sos, g] = zp2sos(z,p,k);
    dataForInterpolation=filtfilt(sos,g,responseDataCropped);
    postInterpolationInds = expectedFlashIndexes;
    preInterpolationInds = recordedFlashIndexes;
    interpolatedData = zeros(length(stimulusDataLinearized), size(dataForInterpolation, 2));
else
    dataForInterpolation = responseDataCropped;
    postInterpolationInds = expectedFlashIndexes;
    preInterpolationInds = recordedFlashIndexes;
    interpolatedData = zeros(length(stimulusDataLinearized), size(dataForInterpolation, 2));
end

data_insert_ind = uint32(1);
interpValsConcat = [];
sumLength =0;
diffVal = 1;
for ind = 1:length(preInterpolationInds) 
     
    startInd = preInterpolationInds(ind);
%     offsetStart = recordedFlashOffsets(ind);
    if ind == length(preInterpolationInds)
        endInd = length(dataForInterpolation);
%         offsetEnd = frameSize;
        newLength = uint32(length(interpolatedData) - postInterpolationInds(ind));
    else
        endInd = preInterpolationInds(ind+1);
%         offsetEnd = recordedFlashOffsets(ind+1);
        newLength = uint32(postInterpolationInds(ind+1) - postInterpolationInds(ind));
    end
    sumLength = sumLength+newLength;
    if centerOfMassFraction > mod(startInd, 1)
        startIndData = floor(startInd);
    else
        startIndData = ceil(startInd);
    end
    startIndInterp = startIndData+centerOfMassFraction;
    
    if centerOfMassFraction > mod(endInd, 1)
        endIndData = floor(endInd)-1;
    else
        endIndData = floor(endInd);
    end
    endIndInterp = endIndData + centerOfMassFraction;
        
%     oldLength = endIndData-startIndData+1;
    

    if strcmp(interpolateInds, 'upsample') || strcmp(interpolateInds, 'downsample')
        if ind > 1 || startIndData > 1
            startIndInterp = startIndInterp-1;
%             oldLength = oldLength+1;
%             startIndData = startIndData-1;
%         elseif startIndData > 1
%             if startInd > endIndPrev
% %                 oldLength = oldLength+1;
%             end
%             startInd = endIndInterpPrev;
%             startIndData = endIndDataPrev;
%             interp_vals = linspace(endIndPrev, endInd, newLength);
        end
%         if endIndData<length(dataForInterpolation)
%             endIndInterp = endIndInterp + 1;
%             endIndData = endIndData+1;
%         end
        
            % interp_vals only does 2:end because you don't want to repeat
            % the startInd, which should be identical to the endInd of the
            % previous round!
        interp_vals = linspace(startInd, endInd, newLength+1);
        
        if ind>1
            interp_vals = interp_vals(2:end);
        else
            newLength = newLength + 1; % account for the fact that we include the extra index at the end here
        end
%         oldLength = endIndData-startIndData+1;
%         interp_vals = linspace(startInd, endInd, newLength);
%         interpolatedData(data_insert_ind:data_insert_ind+newLength-1, :) = interp1(linspace(startIndInterp, endIndInterp, oldLength), dataForInterpolation(startIndData:endIndData, :), interp_vals); 
%         endIndPrev = endInd;
%         endIndInterpPrev = endIndInterp;
%         endIndDataPrev = endIndData;
        interpValsConcat = [interpValsConcat, interp_vals];
    else
        interp_inds = floor(linspace(startInd, endInd, newLength));
        interpolatedData(data_insert_ind:data_insert_ind+newLength-1, :) = dataForInterpolation(interp_inds, :);
    end
    data_insert_ind = data_insert_ind+newLength;
end

interpValsPerROI = repmat(interpValsConcat', 1, size(dataForInterpolation, 2));
%interpDataBig = interp1(1:length(dataForInterpolation), dataForInterpolation, bsxfun(@minus, interpValsConcat', centerOfMassFraction), 'previous');

interpDataBig = interp1(1:length(dataForInterpolation), dataForInterpolation, bsxfun(@minus, interpValsPerROI, centerOfMassFraction), interpolationMethod);

interpolatedData = zeros(size(interpDataBig, 1), size(interpDataBig, 2));
for ROI = 1:size(dataForInterpolation, 2)
    interpolatedData(:, ROI) = interpDataBig(:, ROI, ROI);
end


if length(stimulusDataLinearized) < length(responseDataCropped) && strcmp(interpolateInds,'upsample')
    alignedStimulusData = interpolatedData;
    alignedResponseData = responseDataCropped;
    % TODO This structure needs to be appropriately shifted (i.e. the
    % indexes in bounds and trigger_inds change as a result of the current
    % function, so they need to be changed in here as well
    alignedFlashStructure = recordedFlashStructure;
elseif length(stimulusDataLinearized) < length(responseDataCropped) && strcmp(interpolateInds,'downsample')
    alignedResponseData = interpolatedData;
    alignedStimulusData = stimulusDataLinearized;
    
    alignedFlashStructure = expectedFlashStructure;
else
    alignedResponseData = interpolatedData;
    alignedStimulusData = stimulusDataLinearized;
    
    alignedFlashStructure = expectedFlashStructure;
    
end

fsFactor = length(alignedResponseData)/length(responseDataCropped);