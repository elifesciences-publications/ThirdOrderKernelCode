function alignRespStim = tp_AlignStimRespforKernelInPhotoDiode(Z,epochForKernel,epochForKernelFlag,nanCullFlag)
% what is the name for this function?
%
loadFlexibleInputs(Z)
%% Interpolate and align stimulus and response

grabStimPath = fullfile(pathName, fn);
if ~isfield(Z,'stimulus')
    [allStimulusBehaviorData] = grabStimulusData(Z);
else
    allStimulusBehaviorData = Z.stimulus.allStimulusBehaviorData;
end

% it is easier to set a flag here.
%%%%%%%%%%%%%%%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% potential timing error sources...
Z.params.linearizeTriggerInds = true;
Z.params.interpolationMethod = 'previous';
% the size of the rDat and stimulusDataInds does not match!!, which one is
% longer?
[stimulusDataIndsRaw, rDatRaw, ~, ~] = alignStimulusAndResponse([1:length(allStimulusBehaviorData.Epoch)]', allStimulusBehaviorData, Z.grab.avg_linear_PDintensity, trigger_inds, Z);

% clean the data a little bit... first, find the part of nan
% first of all, make sure the length of the two are the same. reason is
% still unclear, the rDatRaw normally has more elements.
nRDat = length(rDatRaw);
nStim = length(stimulusDataIndsRaw);
if nStim ~= nRDat
    warning('stimulusDataInds is not the same length as rDat,nRData is %d, nRStim is %d', nRDat,nStim);
    % you have to check that whether it is only in the middle, or
    % otherwise, it is very dangerou to just ignor them.
end
nT = min([nStim,nRDat]);
stimulusDataIndsRaw = stimulusDataIndsRaw(1:nT);
rDatRaw = rDatRaw(1:nT);

nanStimulus = isnan(stimulusDataIndsRaw);
if  ~isempty(find(nanStimulus,1))
    warning('stimulusDataInds has nan,nan value might appear in the middle of the array');
    % you have to check that whether it is only in the middle, or
    % otherwise, it is very dangerou to just ignor them.
end
stimulusDataInds = stimulusDataIndsRaw(~nanStimulus);

% Start of stimulus in lines based on the photodiode (hence the
% multiplication by Z.params.imgSize(1). Subtract by one because
% trigger_data is 1-indexed

% If center of mass is [row col];
% for each line..
roiCenterOfMass = Z.ROI.roiCenterOfMass; % the background might still be there...
filteredTrace = Z.filtered.roi_avg_intensity_filtered_normalized;

nRoi = size(filteredTrace,2);
%
% nRoi = size(roiCenterOfMass,1);
% This is the offset from top of frame for each frame (i.e. if ROI 1 is 0.9
% down the way of a frame, then on frame 2 it is at 2.9, on frame 3 it is
% at 3.9, on frame 100 it is at 100.9, etc); subtract one to start at 0.9
% so conversion to lines isn't off by one frame
% for different roi, the lenghth of the stimulus are the same.

% why the response is much longer than the stimulus.?
% roiLinesInFrames is longer than filteredTraces.
% you have to calculate the roiLinesInFrames at first.
% first, makeSure that the length are the same....
roiLinesInFramesAll = cell(nRoi,1);
stimulusIndexesForRoi =  cell(nRoi,1);

% you might want to change the way you do it.... even though it is working
% now....
respCutOffIndStart = cell(nRoi,1);
respCutOffIndEnd = cell(nRoi,1);

firstPhotodiodeLine = trigger_inds.epoch_1.trigger_data(1) * Z.params.imgSize(1)-Z.params.imgSize(1);
for rr = 1:1:nRoi
    % imgSize(3) is the same as the time in filteredTrace
    roiCenterOfMassInFrames = [1:Z.params.imgSize(3)] + roiCenterOfMass(rr,1)/Z.params.imgSize(1) - 1;
    % Convert the offset to lines
    roiLinesInFrames = round(roiCenterOfMassInFrames*Z.params.imgSize(1));
    % Offset them based on the first photodiode flash
    roiLinesInFrames = roiLinesInFrames - firstPhotodiodeLine;
    % why there are less than zeros? where does it come from?
    % you have to remember which part of the response is cuttoff...
    % why there are more than rDat? where does it come from?
    % you have to remeber which part of the response if cuttoff..
    respCutOffIndStart{rr}= (roiLinesInFrames <= 0);
    respCutOffIndEnd{rr} = roiLinesInFrames > size(stimulusDataInds,1);
    % Is that a good practice? yes, because it is abosulte value...
    roiLinesInFrames(roiLinesInFrames <= 0) = [];
    roiLinesInFrames(roiLinesInFrames > size(stimulusDataInds,1)) = [];
    % the response of each roi is cut differently, why is that?? what
    % results in this differences.
    %     a(rr) = length(roiLinesInFrames);
    % Use the lines to get the index of the stimulus the ROI sees at that frame
    roiLinesInFramesAll{rr} =  roiLinesInFrames; % why do you care about roiLinesInFrames??? It is not important at all....nooo.... you need that....
    % it does not work here... ask for Help from Emilio....
    stimulusIndexesForRoi{rr} = uint32(stimulusDataInds(roiLinesInFrames)); % index in frame number...
end

% create corresponding response from that.
responseData = cell(nRoi,1);
for rr = 1:1:nRoi
    indResp = ~(respCutOffIndStart{rr} | respCutOffIndEnd{rr});
    responseData{rr} = filteredTrace(indResp,rr);
end

%% get rid of the NAN in the response.
% you will put all the nan data to be zero, because it is reverse
% correlation.
% so painful...
if nanCullFlag
    for rr = 1:1:nRoi
        nanResp = isnan(responseData{rr});
        responseData{rr}(nanResp) = [];
        stimulusIndexesForRoi{rr}(nanResp) = [];
    end
end
% now, you have got the response
% how could you find the proper time for your response and stimulus and
% Frames?
% for each Roi, find the part of the stimulus whose epoch is 13.
if epochForKernelFlag
    responseDataKernel = cell(nRoi,1);
    stimulusIndexesForRoiKernel = cell(nRoi,1);
    for rr = 1:1:nRoi
        epochOfStimulusRoi = allStimulusBehaviorData.Epoch(stimulusIndexesForRoi{rr});
        kernelInd = epochOfStimulusRoi == epochForKernel;
        responseDataKernel{rr} = responseData{rr}(kernelInd);
        stimulusIndexesForRoiKernel{rr} =  stimulusIndexesForRoi{rr}(kernelInd);
    end
end

% now you get your response and stimulus indexes....

alignRespStim.resp = responseDataKernel;
alignRespStim.stimIndexes =stimulusIndexesForRoiKernel;
end
%% from now on... you could construc filter and response.


