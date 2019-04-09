function [SI] = EdgePrediction_RespToSI(value,flyEye)




% first, determine the edgeType
% left light, right light, left dark, right dark.
% [~,predictedEdgeType] = max(value);
% if predictedEdgeType == 1 || predictedEdgeType == 3
%     predictedDirType = 1;
% else
%     predictedDirType = 2;
% end
% lightValue = value([1,2]);
% darkValue =  value([3,4]);
%
% lightCombine = max(lightValue);
% darkCombine = max(darkValue);
%
% lightPrefered =  lightValue(predictedDirType);
% darkPrefered = darkValue(predictedDirType);
%
% LDSI_Combined = (lightCombine - darkCombine)/((lightCombine + darkCombine));
% LDSI_PreferedDir = (lightPrefered - darkPrefered)/((lightPrefered +
% darkPrefered)); 
%
% SI.LDSI_Combined = LDSI_Combined;
% SI.LDSI_PreferedDir = LDSI_PreferedDir;
%
[~,predictedEdgeType] = max(value);
if predictedEdgeType == 1 || predictedEdgeType == 3
    predictedDirType = 1;
else
    predictedDirType = 2;
end
if predictedEdgeType == 1 || predictedEdgeType == 2
    predictedContrastType = 1;
else
    predictedContrastType = 2;
end

% ligth/dark selectivity;
lightValue = value([1,2]);
darkValue =  value([3,4]);

lightCombine = sum(lightValue);
darkCombine = sum(darkValue);
lightPrefered =  lightValue(predictedDirType);
darkPrefered = darkValue(predictedDirType);

LDSI_Combined = (lightCombine - darkCombine)/((lightCombine + darkCombine));
LDSI_PreferedDir = (lightPrefered - darkPrefered)/((lightPrefered + darkPrefered));
contDiff_Combined = (lightCombine - darkCombine);
contDiff_PreferedDir = (lightPrefered - darkPrefered);
% direction selectivity.
% second, compute the direction selectivity. only on the prefered
% Contrast.
% the direction selectivity would be progressive - regressive.
% no way to determine the DSI an
leftValue  = value([1,3]);
rightValue = value([2,4]);

leftCombined = sum(leftValue);
rightCombined = sum(rightValue);
leftPrefered = leftValue(predictedContrastType);
rightPrefered = rightValue(predictedContrastType);

if strcmp(flyEye,'left') || strcmp(flyEye,'Left')
    progCombined = leftCombined;
    progPrefered = leftPrefered;
    regrCombined = rightCombined;
    regrPrefered = rightPrefered;
else
    progCombined = rightCombined;
    progPrefered = rightPrefered;
    regrCombined = leftCombined;
    regrPrefered = leftPrefered;
end

DSI_Combined = (progCombined - regrCombined)/(progCombined + regrCombined);
DSI_PreferedCont = (progPrefered - regrPrefered)/(progPrefered + regrPrefered);
dirDiff_Combined = (progCombined - regrCombined);
dirDiff_PreferedCont = (progPrefered - regrPrefered);

SI.LDSI_Combined = LDSI_Combined;
SI.LDSI_PreferedDir = LDSI_PreferedDir;
SI.DSI_Combined = DSI_Combined;
SI.DSI_PreferedCont = DSI_PreferedCont;
SI.contDiff_Combined  = contDiff_Combined;
SI.contDiff_PreferedDir = contDiff_PreferedDir;
SI.dirDiff_PreferedCont = dirDiff_PreferedCont;
SI.dirDiff_Combined = dirDiff_Combined;