function repFrameInds  = tp_FindRepSegments(Z,epochForKernel)
loadFlexibleInputs(Z)
%% Interpolate and align stimulus and response

if ~isfield(Z,'stimulus')
    [allStimulusBehaviorData] = grabStimulusData(Z);
else
    allStimulusBehaviorData = Z.stimulus.allStimulusBehaviorData;
end

% this has nothing to do with the aligneResp
startFramesKernelEpoch = find(allStimulusBehaviorData.Epoch == epochForKernel,1);

% how could you do thise?
indForKernelEpoch = allStimulusBehaviorData.Epoch == epochForKernel;
endFramesProbEpoch = find(allStimulusBehaviorData.Epoch == epochForKernel - 1,1,'last');
if endFramesProbEpoch > startFramesKernelEpoch
    indBeforeLastEpoch = (1:length(indForKernelEpoch))' < endFramesProbEpoch;
    endFramesKernelEpoch = find(indBeforeLastEpoch & indForKernelEpoch,1,'last');
else
    endFramesKernelEpoch = find(indForKernelEpoch,1,'last');
end
nTNonRep = 45 * 60; % 60 seconds * 60 frames
nTRep = 15 * 60; % 15 seconds * 60 frames.
nTSeg = nTRep + nTNonRep;
nTKernelEpoch = endFramesKernelEpoch - startFramesKernelEpoch + 1;
nSeg = ceil(nTKernelEpoch/nTSeg);

repFrameIndsSingle = (0:1:nTRep - 1)';
repFrameIndsStartPoint = startFramesKernelEpoch + (0:1:nSeg - 1) * (nTSeg);
repFrameInds = bsxfun(@plus,repmat(repFrameIndsSingle,1,nSeg),repFrameIndsStartPoint);

% epochLongderThanStim = repFrameInds(end,:) > endFramesKernelEpoch;
% repFrameInds(:,epochLongderThanStim) = [];

% the last frames here is not finished... check whether it is a full epoch.
% doublee check wether the last one the the correct.
%
% now you get your response and stimulus indexes....
% remember which frame is the repeated segments, hopefully, they are all
% there... no lost frames. this would be the same for all rois.


% get the stimulus and see whether they are the same thing.
% nSeg = size(repFrameInds,2);
% repStim = zeros(size(repFrameInds));
% for ii = 1:1:nSeg
%     repStim(:,ii) = allStimulusBehaviorData.StimulusData(repFrameInds(:,ii),1);
% end
% %
% isequal(repStim(:,1),repStim(:,2),repStim(:,3),repStim(:,19))
end