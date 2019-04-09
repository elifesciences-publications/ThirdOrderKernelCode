function Z = tp_kernelExtraction_Juyue_ReverseCorr(Z,varargin)

% takes the output of the pre-analysis of twoPhotonMaster, extracts and
% saves LN model corresponding to usual default parameters.
% tp_KernelExtraction_Juyue(Z,'order',1,'maxTau',30,'roiSelectionFlag',1,'roiUse',[1,2],'doKernel',1,'useBackGroundCheckAlignment',false,'saveKernels',1,'saveOLSMat',1,'force_new_OLSMat',false,'epochForKernel',13,'nMultiBars',20,'doNoise',1,'specialName',[]);
%% changeble variables.
maxTau = 30;
order = 1;
epochForKernel = 13;
nMultiBars = 20;
doKernel = 0;
repCVFlag = false;
doNoise = 0;
force_new_OLSMat = false;
% maybe only one roi is used...
roiSelectionFlag = 0;
roiUse = [];
saveKernels = 1;
saveFlick = 0;
% saveOLSMat = 1;
specialName = [];
useBackGroundCheckAlignment = false;
kernelTypeStr = {'first','second'};
dx = 1;
interpolateRespFlag = false;
%% varargin
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% constant variables.
kernelTypesStr = {'first','second'};
%% Get stimulus data
if ~isfield(Z,'stimulus')
    Z.stimulus = loadStimulusData(Z);
end
stimData =  Z.stimulus.allStimulusBehaviorData.StimulusData;
%% Run and save alignment, Because the alignment now is very fast. no need to save it.
nanCullFlag = true;
epochForKernelFlag = true;
% decide whether to do interpolation at this point... good idea? change the
% stimIndexes as well...
alignRespStim = tp_AlignStimRespforKernelInPhotoDiode(Z,epochForKernel,epochForKernelFlag,nanCullFlag,interpolateRespFlag);
% this is an extra variable...
if repCVFlag
    repStimIndInFrame = tp_FindRepSegments(Z,epochForKernel);
else
    repStimIndInFrame = []; % not avaible? or empty...
end
if roiSelectionFlag
    if isempty(roiUse)
        error('no roi is selected!!!');
        
    else
        nRoi = length(roiUse); % normally, there should be only one..
        respData = cell(nRoi,1);
        stimIndexes = cell(nRoi,1);
        
        for ii = 1:1:nRoi
            rr = roiUse(ii);
            respData{ii} = alignRespStim.resp{rr};
            stimIndexes{ii} = alignRespStim.stimIndexes{rr};
            %             varianceReshaped(ii) =  repmat(reshape(variance{bar},1,1,[]),maxTau,1);
        end
    end
else
    respData = alignRespStim.resp;
    stimIndexes = alignRespStim.stimIndexes;
end

if saveFlick
    flickSave.respData = respData;
    flickSave.stimData = stimData;
    flickSave.stimIndexed = stimIndexes;
    flickSave.repCVFlag = repCVFlag;
    flickSave.repStimIndInFrame = repStimIndInFrame;
    flickSave.interpolateRespFlag = interpolateRespFlag;
    % it is so wired to have this....
    fullFlickPathName = tp_saveFlick(Z.params.name,flickSave,kernelTypesStr{order},specialName);
    Z.flick.fullFlickPathName = fullFlickPathName;
end

if doKernel
    % there is another label, to decide whether to use the repBlock.
    tic
    kernels = tp_kernels_ReverseCorrGPU(respData,stimIndexes,stimData,'order',order,'maxTau',maxTau,'dx',dx,'repCVFlag',repCVFlag,'repStimIndInFrame',repStimIndInFrame);
    toc
    disp([kernelTypeStr{order},'order kernel is extracted']);
    Z.kernels.kernels = kernels;
    if saveKernels
        fullKernelPathName = tp_saveKernels(Z.params.name,kernels,kernelTypesStr{order},['_ReverseCorr','_dx',num2str(dx)]); % no special name...
        Z.kernels.fullKernelPathName = fullKernelPathName;
    end
end

if doNoiseKernel
    tic 
    % same here for noise...
    noiseKernels = tp_kernels_Noise_ReverseCorr(respData,stimIndexes,stimData,'order',order,'maxTau',maxTau,'repCVFlag',repCVFlag,'repStimIndInFrame',repStimIndInFrame); 
    toc
    disp([kernelTypeStr{order},'order noise kernel is extracted']);
    Z.noiseKernels.kernels = noiseKernels;
    if saveKernels
        fullKernelPathName = tp_saveKernels(Z.params.name,noiseKernels,kernelTypesStr{order},['_ReverseCorrNoise']); % no special name...
        Z.noiseKernels. fullKernelPathName = fullKernelPathName;
    end
end




