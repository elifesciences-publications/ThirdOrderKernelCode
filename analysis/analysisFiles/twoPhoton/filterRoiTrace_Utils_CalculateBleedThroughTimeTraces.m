function bt_subtracted = filterRoiTrace_Utils_CalculateBleedThroughTimeTraces(roiTrace,stimIndexes,stimData,bckgkernel);
[OLSMat] = tp_Compute_OLSMat(roiTrace,stimData,stimIndexes,'order',1, 'maxTau',1);
% you have do
nRoi = length(roiTrace);
bt_subtracted = cell(nRoi,1);
bt_prediction = cell(nRoi,1);

for rr = 1:1:nRoi
    stimMat = cell2mat(OLSMat.stim(:,rr)');
    stimMatMeanSubtracted = stimMat - mean(stimMat(:));
    bt_prediction{rr} = stimMatMeanSubtracted * bckgkernel(1,:)'; % only the first row matters.
    bt_subtracted{rr} = roiTrace{rr} - bt_prediction{rr};
end
end