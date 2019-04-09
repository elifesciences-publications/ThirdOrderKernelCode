function [respFull,respRepByTrial,respRepByTrialTimeLag,respRepByTrialNew,respRepByTrialTimeLagNew,respRepByTrialNewNoiseless,respRepByTrialTimeLagNewNoiseless,respRepNoiselessUpSample]= roiAnalysis_OneRoi_getResponseRepSeg(roi,varargin)
order = 1;
controlRespFlag = false;
% repCVFlag = false; % if it is true...
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

S = GetSystemConfiguration;
kernelPath = S.kernelSavePath;
flickpath = [kernelPath,roi.stimInfo.flickPath];
roiNum = roi.stimInfo.roiNum;
k = roi.filterInfo.firstKernel.Original;

% you would have a small flag here to decide whether it is simulation
% data.
if isfield(roi,'simuInfo')
    [respData,stimData,stimIndexes,repCVFlag,repStimuIndInFrame,respNoiseless,respNoiselessUpSample] = GetStimResp_ReverseCorr(flickpath, roiNum);
else
    [respData,stimData,stimIndexes,repCVFlag,repStimuIndInFrame] = GetStimResp_ReverseCorr(flickpath, roiNum);
    
end
nMultiBars = size(k,2);
maxTau = size(k,1);
% first, get the repeated segments.
if repCVFlag
    repSegFlag = true;
    
    % whether it is control, if it is.
    if controlRespFlag
        % 15 + 45 % control response: 15 seconds after the 15 seconds of repeated stimulus.
        % you tp_Compute_OLSMat_NonRepOrRep would take care of taking
        stimuIndInFrameUsed = repStimuIndInFrame + size(repStimuIndInFrame,1);
    else
        stimuIndInFrameUsed = repStimuIndInFrame;
    end
    
    OLSMat = tp_Compute_OLSMat_NonRepOrRep(respData,stimData,stimIndexes,stimuIndInFrameUsed,repSegFlag,'order',order,'maxTau',maxTau,'nMultiBars', nMultiBars);
    respRepByTrial = OLSMat.respByTrial{1};
    respRepByTrialTimeLag = OLSMat.relativeTimePointsEachTrial{1}; % is there are problem with your alignment code?
    [respFull,indSetToZeros] =  MultibarFlicker_alignResponseInRepSeg(respRepByTrial,respRepByTrialTimeLag);
    [respRepByTrialNew,respRepByTrialTimeLagNew] = MultibarFlicker_alignResponseInRepSeg_ShiftBack(respFull,indSetToZeros,respRepByTrialTimeLag);
    
    % decide whether it is a simulation data.
    if isfield(roi,'simuInfo')
        OLSMatNoiseless = tp_Compute_OLSMat_NonRepOrRep({respNoiseless},stimData,stimIndexes,stimuIndInFrameUsed,repSegFlag,'order',order,'maxTau',maxTau,'nMultiBars', nMultiBars);
        respRepByTrialNoiseless = OLSMatNoiseless .respByTrial{1};
        respRepByTrialTimeLagNoiseless = OLSMatNoiseless .relativeTimePointsEachTrial{1};
        [respFullNoiseless,indSetToZerosNoiseless] =  MultibarFlicker_alignResponseInRepSeg(respRepByTrialNoiseless,respRepByTrialTimeLagNoiseless);
        [respRepByTrialNewNoiseless,respRepByTrialTimeLagNewNoiseless] = MultibarFlicker_alignResponseInRepSeg_ShiftBack(respFullNoiseless,indSetToZerosNoiseless,respRepByTrialTimeLagNoiseless);
        
        respRepNoiselessUpSample = respNoiselessUpSample(repStimuIndInFrame(maxTau + 1:end,1));
    else
        respRepByTrialNewNoiseless = [];
        respRepByTrialTimeLagNewNoiseless = [];
        respRepNoiselessUpSample = [];
    end
else
    error('this fly does not have repeated segments');
end
end