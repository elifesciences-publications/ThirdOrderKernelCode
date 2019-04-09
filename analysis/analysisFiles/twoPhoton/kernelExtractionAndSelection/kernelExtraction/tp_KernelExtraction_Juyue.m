function Z = tp_KernelExtraction_Juyue(Z,varargin)
% takes the output of the pre-analysis of twoPhotonMaster, extracts and
% saves LN model corresponding to usual default parameters.
% tp_KernelExtraction_Juyue(Z,'order',1,'maxTau',30,'roiSelectionFlag',1,'roiUse',[1,2],'doKernel',1,'useBackGroundCheckAlignment',false,'saveKernels',1,'saveOLSMat',1,'force_new_OLSMat',false,'epochForKernel',13,'nMultiBars',20,'doNoise',1,'specialName',[]);
%% changeble variables.
maxTau = 30;
order = 1;
epochForKernel = 13;
nMultiBars = 20;
doKernel = 0;
doNoise = 0;
force_new_OLSMat = false;
% maybe only one roi is used...
roiSelectionFlag = 0;
roiUse = [];
saveKernels = 1;
saveOLSMat = 1;
specialName = [];
useBackGroundCheckAlignment = false;
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
alignRespStim = tp_AlignStimRespforKernelInPhotoDiode(Z,epochForKernel,epochForKernelFlag,nanCullFlag);
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
        end
    end
else
    respData = alignRespStim.resp;
    stimIndexes = alignRespStim.stimIndexes;
end
%% Extract kernels
% if you are forced to select OLS, or you do not have that in Z, or you do
if force_new_OLSMat
    OLSMat = tp_Compute_OLSMat(respData,stimData,stimIndexes,'order',order,'maxTau',maxTau,'nMultiBars', nMultiBars);
    Z.OLSMat = OLSMat;
else
    if(isfield(Z,'OLSMat'))
        OLSMat = Z.OLSMat;
    else
        OLSMat = tp_Compute_OLSMat(respData,stimData,stimIndexes,'order',order,'maxTau',maxTau,'nMultiBars', nMultiBars);
        Z.OLSMat = OLSMat; 
    end
end
% save OLSMat, would save the response, and the corresponding stimulus
% index. still use the old name, it does not matter what name to use...
if saveOLSMat
    OLSMatSave.respData = respData;
    OLSMatSave.stimData = stimData;
    OLSMatSave.stimIndexed = stimIndexes;
    fullOLSMatPathName = tp_saveOLSMat(Z.params.name,OLSMatSave,kernelTypesStr{order},specialName);
    Z.OLSMat.fullOLSMatPathName = fullOLSMatPathName;
end

if doKernel
    kernels = tp_kernels_OLS(OLSMat.resp,OLSMat.stim);
    Z.kernels.kernels = kernels;
    if saveKernels
        fullKernelPathName = tp_saveKernels(Z.params.name,kernels,kernelTypesStr{order},'OLS'); % no special name...
        Z.kernels.fullKernelPathName = fullKernelPathName;
    end
end

% if doNoise
%     % for the noise, the ols would be calcualted again, and the
%     % I do not need the ols again, I just want get the...
%     nosieKernels = tp_kernels_noise(OLSMat.resp,OLSMat.stim);
%     Z.nosieKernels.kernels = nosieKernels;
%     if saveKernels
%         fullKernelPathName = tp_saveKernels(Z.params.name,kernels,kernelTypesStr{order},['noise']); % no special name...
%         Z.nosieKernels.path = fullKernelPathName;
%     end
% end

if useBackGroundCheckAlignment
    % to check alignment, you also have to check before...
    %     OLSMat = tp_Compute_OLSMat(respData,stimData,stimIndexes,'order',order,'maxTau',maxTau,'nMultiBars', nMultiBars);
    reverseMaxTau = 10;
    OLSMatReverse = tp_Compute_OLSMat(respData,stimData,stimIndexes,'order',order,'maxTau',maxTau,'nMultiBars', nMultiBars, 'reverseKernelFlag',true,'reverseMaxTau',reverseMaxTau);
    % put all the stimulus from 20 bars together...
    backgroundStim =OLSMatReverse.stim;
    temp = zeros(size(backgroundStim{1}));
    for qq = 1:1:nMultiBars
        temp = temp + backgroundStim{qq};
    end
    temp = temp / 20;
    stimBackgound = cell(1,1);
    stimBackgound{1,1} = temp;
    resp = OLSMatReverse.resp;
    kernels = tp_kernels_OLS(resp,stimBackgound);
    Z.backgroundKernel.kernels = kernels;
    Z.backgroundKernel.timeLine = [-reverseMaxTau:1:maxTau - 1];
end

%% Extract Noise Kernels
