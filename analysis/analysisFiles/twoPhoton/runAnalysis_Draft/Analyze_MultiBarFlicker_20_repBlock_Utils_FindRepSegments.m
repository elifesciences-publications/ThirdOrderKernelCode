function analysis = Analyze_MultiBarFlicker_20_repBlock_Utils_FindRepSegments(~,~,~,stimAnalysis,~,~,~,varargin)
% this is a hard coded function..
%  analysis = EdgeSelectivityAnalysis(flyResp,epochs,params,~ ,dataRate,dataType,~,varargin)
epoch_info_at_which_column = 3;
epochForKernel = 13;
stimulust_epoch = stimAnalysis{1}(:,epoch_info_at_which_column); % hard coded

startFramesKernelEpoch = find(stimulust_epoch == epochForKernel,1);
indForKernelEpoch = stimulust_epoch == epochForKernel;

% to find the endFramesKernelEpoch, you need to find the last probe.
endFramesProbEpoch =  find(stimulust_epoch == epochForKernel - 1,1,'last');
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

analysis.repFrameInds = repFrameInds;
end