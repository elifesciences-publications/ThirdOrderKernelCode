function out = Behavior_KernelExtraction_Juyue_ReverseCorr(flyResp,epochs,params,stim,dataRate,dataType,interleaveEpoch,varargin)
% you should treat different fly as different roi...

nfly = size(flyResp,2);


% prepare the respData, stimData and stimIndexes for my kernel....
% here, not all the rois share the same stim, so your method only works for
% 5 fly a time. 
resp = cell(nfly,1);
for ff = 1:1:nfly
resp{ff} = squeeze(flyResp{ff}(1:end-1,1,1));
end
respData = resp;
% second, organize the stimulus.
% they should be the same, check it.
stimDataTemp = stim{1};
% you will organize your data by time

nFrames = size(stimDataTemp,1);
nStimPerFrame = 3;
nT = nFrames * nStimPerFrame; % that is 180 hz.
nMultiBars = 2;
stimDataL = stimDataTemp(:,[11,15,19]);
stimDataR = stimDataTemp(:,[12,16,20]);
stimDataL = stimDataL'; stimDataL = stimDataL(:);
stimDataR = stimDataR'; stimDataR = stimDataR(:);
% stimDataL = mean(stimDataL,2);
% stimDataR = mean(stimDataR,2);
stimData = [stimDataL,stimDataR];

% create stimDataIndexes
% 
stimIndexesSingle = uint32(1:nStimPerFrame:nT)';
% stimIndexesSingle = uint32(1:1:size(respData{1},1))';
stimIndexes = cell(nfly,1);
for ff = 1:1:nfly
    stimIndexes{ff} = stimIndexesSingle;
end

tic
firstkernels = tp_kernels_ReverseCorrGPU(respData,stimIndexes,stimData,'order',1,'maxTau',180,'dx',1,'order',1);
toc

% it 
maxTauUnit = 64; % for second order kernel, the maxTau for GPU is fixed. Rearrange your kernel, so that is could 
maxTauN = 3; % legnth is 1 seconds.
tic
secondkernels = tp_kernels_ReverseCorrGPU(respData,stimIndexes,stimData,'order',1,'maxTau',64,'dx',1,'order',2);

tp_kernels_ReverseCorrGPU_LongerSecondOrderKernel(respData,stimIndexes,stimData,maxTauN)
% % what would be the glider response?

% dt = [-20:1:20]';
% nT = length(dt);
% gliderResp = zeros(nT,1);
% maxTauShow = 64;
% [gliderResp,~] = roiAnalysis_OneKernel_dtSweep_SecondOrderKernel(secondkernels(:,1,2),'dt' ,dt,'maxTauUse',maxTauShow);
% timeUnit = 1/180;
% dtPlot = dt * timeUnit;
% MakeFigure;
% plot(dtPlot,gliderResp);


MakeFigure;
quickViewKernels(secondkernels,2);
toc
disp('behavior kernel for five flies is extracted')
end