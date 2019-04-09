function roiDataSimu_ReExtraKernel = Simulation_ReExtractKernels_AllRoi(roiData)
nRoi = length(roiData);
respData = cell(nRoi,1);
stimIndexes = cell(nRoi,1);

for rr = 1:1:nRoi
    roi = roiData{rr};
    S = GetSystemConfiguration;
    kernelPath = S.kernelSavePath;
    flickpath = [kernelPath,roi.stimInfo.flickPath];
    [respDataThisRoi,stimData,stimIndexesThisRoi,repCVFlag,repStimIndInFrame] = GetStimResp_ReverseCorr(flickpath, roi.stimInfo.roiNum);
    % stimData should be the whole dataset.
    respData{rr} = respDataThisRoi{1};
    stimIndexes{rr} = stimIndexesThisRoi{1};
end

% it takes some time, why is that slowly?
% the respData, stimIndexes, stimData,respCVFlag, respStimIndInFram should
% all be very very easy to get from the flick.
% once you get the kernel, you can 
kernelTypeStr = {'first','second'};
order = 1; maxTau = 60; dx = 1; 
kernels_first = tp_kernels_ReverseCorrGPU(respData,stimIndexes,stimData,'order',order,'maxTau',maxTau,'dx',dx,'repCVFlag',repCVFlag,'repStimIndInFrame',repStimIndInFrame);
disp([kernelTypeStr{order},'order kernel is extracted']);

order = 2; maxTau = 64; dx = 1; 
kernels_second_dx1 = tp_kernels_ReverseCorrGPU(respData,stimIndexes,stimData,'order',order,'maxTau',maxTau,'dx',dx,'repCVFlag',repCVFlag,'repStimIndInFrame',repStimIndInFrame);
disp([kernelTypeStr{order},'order kernel is extracted']);

order = 2; maxTau = 64; dx = 2; 
kernels_second_dx2 = tp_kernels_ReverseCorrGPU(respData,stimIndexes,stimData,'order',order,'maxTau',maxTau,'dx',dx,'repCVFlag',repCVFlag,'repStimIndInFrame',repStimIndInFrame);
disp([kernelTypeStr{order},'order kernel is extracted']);

% once you get the kernel, put them into the roi.
% look at the difference between real one?
roiDataSimu_ReExtraKernel = roiData;
for rr = 1:1:nRoi
    roi = roiData{rr};
    roi.filterInfo.firstKernel.Original = kernels_first(:,:,rr);
    roi.filterInfo.secondKernel.dx1.Original = kernels_second_dx1(:,:,rr);
    roi.filterInfo.secondKernel.dx2.Original = kernels_second_dx2(:,:,rr);
    roiDataSimu_ReExtraKernel{rr} = roi; 
end
end