function [respData,stimData,stimIndexes] = GetStimResp_OLS(filename,roiUse)
% roiUse = 291;
nBarUse = 20;
load(filename);
% load('I:\kernels\twoPhoton\multiBarFlicker_20_60hz_10dWidth_-64.9down012\22_09_15\flick_18_55.mat' );
%% the response and stimulus should be stored in the flick... load that would be the start of current calculation.
load(filename);
respData = cell(1,1);
respData{1} = OLSMatSave.respData{roiUse};
stimData = OLSMatSave.stimData;
stimIndexes = cell(1,1);
stimIndexes{1} = OLSMatSave.stimIndexed{roiUse};


end