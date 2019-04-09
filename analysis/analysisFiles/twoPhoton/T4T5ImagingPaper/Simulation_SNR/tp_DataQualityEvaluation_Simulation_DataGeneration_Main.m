function roiSimuData = tp_DataQualityEvaluation_Simulation_DataGeneration_Main(roi,varargin)
% you can add all kinds of things in it.
nSample = 1000;
LNType = 'none';
simuType = 'firstOnly';
dataName = ''; % should it be random?  you will also have to remember that and store the data you created in to sql
reciprocalSNRMax = 1000; % will be uniformly sampled on a log scale...
reciprocalSNRMin = 0.1;
interpolationRespFlag = false; % do not have need to use it.
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% get the original response ans stimulus out of the file.
% you should have a function here to compute, instead of storing
% everything...
S = GetSystemConfiguration;
kernelPath = S.kernelSavePath;
flickpath = [kernelPath,roi.stimInfo.flickPath];
[respData,stimData,stimIndexes,repCVFlag,repStimIndInFrame] = GetStimResp_ReverseCorr(flickpath, roi.stimInfo.roiNum);
% also, you have to get the kernel.
% first, prepare for the non noisy response.
epochKernelStart = repStimIndInFrame(1);
stimData(1:epochKernelStart - 1,:) = 0; % but
stimIndStart = int32(epochKernelStart :1:size(stimData,1))'; % is the stimulus 60Hz or 13Hz?
reverseKernelFlag = false;reverseMaxTau = 0;

%% calculate the response of the first order kernel.
order = 1;dx = 1;
kernelFirst = roi.LM.firstOrder.kernel;
%%===============================================
%% always smooth the real kernel/
% kernelFirst = MySmooth_1DKernel(kernelFirst,'smoothLevel',3,'method','decaying');
% first order kernel, is not that terrible...
[maxTau,nMultiBars] = size(kernelFirst);
stimMatrix = tp_Compute_OLSMat_FromStimIndStartToStimSS(stimData,stimIndStart,maxTau,reverseKernelFlag,reverseMaxTau,nMultiBars,order,dx);
predRespFirstEachBar = zeros(length(stimIndStart),nMultiBars);
for qq = 1:1:nMultiBars                                          % you should use the original kernel, or extract kernel yourself. interesting!
    SS = stimMatrix{qq}; % only get those used predictors.
    predRespFirstEachBar(:,qq) = SS * kernelFirst(:,qq);
end
predRespFirstSum = sum(predRespFirstEachBar,2);

%% calculate the response of the second order kernel.
order = 2;dx = 1;
kernelSecond = roi.LM.secondOrder.kernel; % only one kernel is making a difference.
%%===============================================
%% always smooth the real kernel/
% [maxTau,nMultiBars] = size(kernelSecond);
% maxTau = round(sqrt(maxTau));
% for qq = 1:1:size(kernelSecond,2)
%     kernelSecond(:,qq) = MySmooth_2DKernel(kernelSecond(:,qq));
% end

[maxTauSquared,~] = size(kernelSecond); maxTauSecond = round(sqrt(maxTauSquared)); % make sure the first and second
barUse = find(sum(kernelSecond) ~= 0); nMultiBarsUse = length(barUse);
kernelSecond = kernelSecond(:,barUse);
% to make things easier, let the maxTau of first order kernel and second
% order kernel be the same.
kernelSecondUse = zeros(maxTau^2,nMultiBarsUse);
for qq = 1:1:nMultiBarsUse
    kernelTemp = reshape(kernelSecond(:,qq),[maxTauSecond,maxTauSecond]);kernelTemp = kernelTemp(1:maxTau,1:maxTau);kernelTemp = kernelTemp(:);
    kernelSecondUse(:,qq) = kernelTemp;
end
% it might be extremely s
stimMatrix = tp_Compute_OLSMat_FromStimIndStartToStimSS(stimData,stimIndStart,maxTau,reverseKernelFlag,reverseMaxTau,nMultiBars,order,dx,'setBarUseFlag',true,'barUse',barUse);
predRespSecondEachBar = zeros(length(stimIndStart),nMultiBarsUse);
for qq = 1:1:nMultiBarsUse                                          % you should use the original kernel, or extract kernel yourself. interesting!
    SS = stimMatrix{qq}; % only get those used predictors.
    predRespSecondEachBar(:,qq) = SS * kernelSecondUse(:,qq);
end
predRespSecondSum = sum(predRespSecondEachBar,2);


%%
% determine what is your response
switch simuType
    case 'firstOnly'
        predResp = predRespFirstSum;
    case 'secondOnly'
        predResp = predRespSecondSum;
    case 'LN'
        nonLinearity = roi.LM.nonLinearity;
        switch LNType
            case 'softRec'
                predResp = MyLN_SoftRectification(predRespFirstSum,nonLinearity.fit_SoftRectification);
            case 'poly2'
                predResp= MyLN_Poly(predRespFirstSum,nonLinearity.fit_Poly2,nonLinearity.lookUpTable);
        end
    case 'firstAndSecond'
        predResp = predRespSecondSum + predRespFirstSum;
end

%% add noise to your response.
varResp = var(predResp,1); nT = length(predResp);% after you have calcualte the variance, you can set the first part to be zeros.
% reciprocalSNR = randi(reciprocalSNRMax,nSample);
% maybe the random sample is better?
% do not use random sample anymore. select some points to draw a line....
% reciprocalSNR = MyRand_UniformOnLogScale(nSample,reciprocalSNRMin,reciprocalSNRMax);
reciprocalSNR = MyRand_UniformOnLogScale(nSample,reciprocalSNRMin,reciprocalSNRMax,'method','discrete');
predRespZeros = zeros(epochKernelStart-1,1);
respDataSimu = cell(nSample,1);
stimIndexesSimu = cell(nSample,1);
for ii = 1:1:nSample
    % add noise to the response
    predRespNoisy = predResp + randn(nT,1) * reciprocalSNR(ii) * sqrt(varResp);
    % pad zeros just to make the format the same to real experiments.
    predRespUse = [predRespZeros;predRespNoisy]; % predRespUse is the Upsampled Version
    
    % oragnize the data.
    % you are
    respDataSimu{ii} = predRespUse(stimIndexes{1}); % down sample the predicted response and store it...
    stimIndexesSimu{ii} = stimIndexes{1};
end

kernelTypesStr = {'first','second'};
flickSave.respData = respDataSimu;
flickSave.stimData = stimData;
flickSave.stimIndexed = stimIndexesSimu;
flickSave.repCVFlag = repCVFlag;
flickSave.repStimIndInFrame = repStimIndInFrame;
flickSave.simuFlag = true;
% this would be the upsampled version.
flickSave.respNoiselessUpSampled = [predRespZeros;predResp];
flickSave.respNoiseless = flickSave.respNoiselessUpSampled(stimIndexes{1});
% it should be good this time, change a name and redo everything?
fullFlickPathName = tp_saveFlick(dataName,flickSave,kernelTypesStr{order},'simualtion_Debug');
flickPathName = KernelPathManage_DeleteAbsolutePath(fullFlickPathName,kernelPath);

% store the data in roi stucture and save it in the future.
roiWithoutAnalysis = roi;
roiWithoutAnalysis = rmfield(roiWithoutAnalysis,'LM'); roiWithoutAnalysis = rmfield(roiWithoutAnalysis,'repSegInfo');
roiWithoutAnalysis.stimInfo.flickPath = flickPathName;
roiSimuData = cell(nSample,1);
% type.
% full kernel format.
simuKernel.firstOrder = kernelFirst;
for qq = 1:1:nMultiBarsUse % you
    kernelTemp = reshape(kernelSecondUse(:,qq),[maxTau,maxTau]);
    kernelTempLarge = zeros(maxTauSecond,maxTauSecond);kernelTempLarge(1:maxTau,1:maxTau) = kernelTemp; kernelTempLarge = kernelTempLarge(:);
end
kernelSecondUseStore = zeros(maxTauSecond^2,nMultiBars);
kernelSecondUseStore(:,barUse) =  kernelTempLarge;
simuKernel.secondOrder.dx1 = kernelSecondUseStore;
simuKernel.secondOrder.dx2 = zeros(maxTauSecond^2,nMultiBars);
simuInfo.simuKernel = simuKernel;
simuInfo.simuType = simuType;
for ii = 1:1:nSample
    roiSimuDataThis = roiWithoutAnalysis;
    simuInfo.reciprocalSNR = reciprocalSNR(ii); % you might want other data.
    
    roiSimuDataThis.simuInfo = simuInfo;
    roiSimuDataThis.stimInfo.roiNum = ii;
    roiSimuData{ii} = roiSimuDataThis;
end

% append the original to back.
roiSimuData = [roiSimuData;roi];
end