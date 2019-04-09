function [respData,stimData,stimIndexes,repCVFlag,repStimuIndInFrame,respNoiseless,respNoiselessUpSampled] = GetStimResp_ReverseCorr(filename,roiUse)
% roiUse = 291;
nBarUse = 20;
load(filename);
% load('I:\kernels\twoPhoton\multiBarFlicker_20_60hz_10dWidth_-64.9down012\22_09_15\flick_18_55.mat' );
%% the response and stimulus should be stored in the flick... load that would be the start of current calculation.
load(filename);
respData = cell(1,1);
respData{1} = flickSave.respData{roiUse};
stimData = flickSave.stimData;
stimIndexes = cell(1,1);
stimIndexes{1} = flickSave.stimIndexed{roiUse};

if isfield(flickSave,'repCVFlag')
    repCVFlag = flickSave.repCVFlag;
else
    repCVFlag = false;
end

if isfield(flickSave,'repStimIndInFrame')
    repStimuIndInFrame = flickSave.repStimIndInFrame;
else
    repStimuIndInFrame = [];
end

if isfield(flickSave,'repCVFlag')
    repCVFlag = flickSave.repCVFlag;
else
    repCVFlag = false;
end

if isfield(flickSave,'simuFlag');
    % this would be the upsampled version.
    respNoiselessUpSampled = flickSave.respNoiselessUpSampled;
    respNoiseless = flickSave.respNoiseless;
else
    respNoiselessUpSampled = [];
    respNoiseless = [];
end
% check whether to load rep...

end