function  [fullResp, fullStimIndex] = tp_AlignStimRespforKernelInPhotoDiode_Utils_Interpolation(resp,stimIndex)
repeatedStimFramesInd = find(diff(stimIndex) == 0) + 1;
errorStimFramesInd = find(diff(stimIndex) < 0) + 1;

respAtRepeatedStimFrames = resp(repeatedStimFramesInd);
stimIndexAtRepeatedStimFrames = stimIndex(repeatedStimFramesInd);

% get rid of those from resp and stimIndex.
resp([repeatedStimFramesInd;errorStimFramesInd]) = [];
stimIndex([repeatedStimFramesInd;errorStimFramesInd]) = [];

fullStimIndex = (stimIndex(1):1:stimIndex(end))';
fullResp = interp1(double(stimIndex),resp,double(fullStimIndex),'previous');

% put the original response and stimindex where the frames are repeated back.
[fullStimIndex,fullResp] = tp_AlignStimRespforKernelInPhotoDiode_Utils_MyInsert(fullStimIndex,stimIndexAtRepeatedStimFrames,fullResp,respAtRepeatedStimFrames);
end