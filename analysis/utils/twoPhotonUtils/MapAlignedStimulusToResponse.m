function [timeByRoisInitial, roiRecordingCorrespondingStimulus, epochList, useFly] = MapAlignedStimulusToResponse(timeByRoisInitial, stimData, dataPath, roiCenterOfMass, movieSizeFull, dataRate, linescan, photodiodeData, highResLinesPerFrame)

allStimulusBehaviorData = GrabStimulusDataStructure(dataPath);
photoDiodeFps = dataRate*highResLinesPerFrame;
useFly = true;
try
    triggerInds = ExtractTriggersFromPhotodiode(photodiodeData, allStimulusBehaviorData, linescan,photoDiodeFps,movieSizeFull);
    contAlign = true;
catch err
    if strcmp(err.identifier, 'ExtractTriggersFromPhotodiode:SizeMismatch')
        timeByRoisInitial = [];
        epochList = [];
        stimRoi = [];
        useFly = false;
        contAlign = false;
    else
        rethrow(err)
    end
end
if contAlign
    [epochBegin, epochEnd, endFlash, flashBeginInd] = GetStimulusBounds(photodiodeData, highResLinesPerFrame, dataRate, linescan);

    
    epochsListInit = allStimulusBehaviorData.Epoch;
    stimulusInds = (1:length(allStimulusBehaviorData.Epoch))';
    roiCenterOfMassFraction = (roiCenterOfMass(:, 1)./movieSizeFull(1))';
    [stimulusDataIndsRaw, rDatRaw, ~, ~] = alignStimulusAndResponse(stimulusInds, allStimulusBehaviorData, photodiodeData, triggerInds, 0, movieSizeFull, dataRate, 'linearizeTriggerInds', true);
    
    % Subtract one because you want a fraction through the
    % first frame to be less than one (when you bsxfun on the
    % next line)
    recordingFrames = (1:movieSizeFull(3))-1;
    roiAllRecordingFractionFrame = bsxfun(@plus, recordingFrames', roiCenterOfMassFraction);
    % The output  stimulusDataIndsRaw cuts off at the end
    % of the last trigger, so we get rid of that portion
    % (epochEnd*highResLinesPerFrame).
    % The output also starts at the first trigger, so you
    % must subtract away that first trigger here
    % (epochBegin*highResLinesPerFrame).
    % Since epochEnd is in the frame of the non-cut
    % stimulus, it must be removed first.
    roiAllRecordingLine = roiAllRecordingFractionFrame*highResLinesPerFrame;
    roiAllRecordingLine(roiAllRecordingLine>=epochEnd*highResLinesPerFrame) = NaN;
    roiAllRecordingLine = roiAllRecordingLine - epochBegin*highResLinesPerFrame; % (consider (epochBegin-1) here...)
    roiAllRecordingLine(roiAllRecordingLine<=0) = NaN;
    roiAllRecordingLine(all(isnan(roiAllRecordingLine), 2), :) = [];
    roiAllRecordingLine = round(roiAllRecordingLine);
    roiAllRecordingLine(roiAllRecordingLine<=0) = NaN; % Sometimes a few things might round to zero
    
    
    % We need to find the appropriate frame of data to gather
    % from the response that corresponds to the above stimuli.
    % This means we have to add back the
    % epochBegin*highResLinesPerFrame that we'd deleted, change
    % it to movie frame space and then subtract
    % round(epochBegin) to put it into the space of
    % filteredMovie, whence we can grab the data points
    roiRespFrame = floor((roiAllRecordingLine+epochBegin*highResLinesPerFrame)/127)+1;
    roiRespFrame = roiRespFrame-round(epochBegin);
    % On occasion we'll find that roiRespFrame becomes
    % zero--this happens if epochBegin rounds down (i.e.
    % mod(epochBegin, 1) < 0.5. At that point we just ignore
    % the first frame of aligned stimulus recording and the
    % first frame of aligned stimulus. Since this is usually
    % the probe/only one frame, we don't care about it!
    if any(roiRespFrame(1, :)==0)
        roiRespFrame = roiRespFrame(2:end,:);
        roiAllRecordingLine = roiAllRecordingLine(2:end, :);
    end
    % timeByRoisInitial{ff} might become larger if
    % mod(epochEnd, 1)>0.5, i.e. epochEnd rounds up. This
    % should only ever make it one index larger, so we delete
    % that index
    if size(roiRespFrame, 1)<size(timeByRoisInitial, 1)
        roiAllRecordingLine(end+1, :) =  roiAllRecordingLine(end, :);
        %                         timeByRoisInitial{ff}(end, :) = [];
    end
    
    roiRecordingCorrespondingStimulus = roiAllRecordingLine;
    roiRecordingCorrespondingStimulus(~isnan(roiRecordingCorrespondingStimulus)) = stimulusDataIndsRaw(roiAllRecordingLine(~isnan(roiAllRecordingLine)));
    roiRecordingCorrespondingStimulus(all(isnan(roiRecordingCorrespondingStimulus), 2), :) = [];
    
    timeByRoisInitial(isnan(roiRespFrame)) = NaN;
    roiRecordingCorrespondingStimulusPerFly = roiRecordingCorrespondingStimulus;
    epochList = roiRecordingCorrespondingStimulus;
    epochList(~isnan(roiRecordingCorrespondingStimulus)) = epochsListInit(roiRecordingCorrespondingStimulus(~isnan(roiRecordingCorrespondingStimulus)));
    
    % Actually align the stimulus
    stimRoi = nan([size(roiRecordingCorrespondingStimulus, 1) size(stimData, 2) size(timeByRoisInitial, 2)]);
    for roiInd = 1:size(timeByRoisInitial, 2)
        stimRoi(~isnan(roiRecordingCorrespondingStimulus(:, roiInd)), :, roiInd) = stimData(roiRecordingCorrespondingStimulus(~isnan(roiRecordingCorrespondingStimulus(:, roiInd)), roiInd), :);
    end
end