function BarPairCorrelationAnalysis(barPairResponsesMatrix, barPairModelResponseMatrix, params, optimalResponseField, snipShift, duration, barToCenter, numPhases, numROIs, figureNamePrepend)

%% convert from snipMat to matrix wtih averaged flies
timeShift = snipShift/1000;
durationSeconds = duration/1000;
numTimePoints = size(barPairResponsesMatrix, 2);
tVals = linspace(timeShift, timeShift+durationSeconds,numTimePoints);

calciumDelay = 0;
secondBarDelay = params(14).secondBarDelay+calciumDelay;
bothBarsOff = params(14).duration/60; % divide by 60 for 60Hz projector

if bothBarsOff<1
    bothBarsOff=bothBarsOff+calciumDelay;
end

if false
    roiSelectionStart = [1 cumsum(numROIs(1:end-1))+1];
    for respTypes = 1:length(numROIs)
        flyAvg(:, :, respTypes) = mean(barPairResponsesMatrix(:, :, roiSelectionStart(respTypes):roiSelectionStart(respTypes)+numROIs(respTypes)-1), 3);
        flyModelAvg(:, :, respTypes) = mean(barPairModelResponseMatrix(:, :, roiSelectionStart(respTypes):roiSelectionStart(respTypes)+numROIs(respTypes)-1), 3);
    end
    
    barPairModelResponseMatrix = flyModelAvg;
    barPairResponsesMatrix = flyAvg;
    figureNamePrepend = [figureNamePrepend 'By Fly '];
else
    
    figureNamePrepend = [figureNamePrepend 'By ROI '];
end

%% Here we check covariances mean of second bar presentation (+0.3s for calcium signal delay)
timeAvgResponses  = squeeze(mean(barPairResponsesMatrix(:, tVals>secondBarDelay & tVals<bothBarsOff, :), 2));
alphaValue = .05;%1-2*normcdf(-1);% alpha of 1 std
[responseCorrelations, pVals, lower95Perc, upper95perc] = corrcoef(timeAvgResponses', 'alpha', alphaValue);
covarFig = BarPairPlotResponseCovariance(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases, optimalResponseField, 2);
title('Covar second bar only response mean all vs all');
covarFig.Name = [figureNamePrepend 'Covar second bar only response mean all vs all'];

covarFig = BarPairPlotResponseCovariance(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases, optimalResponseField, 1);
title('Covar second bar only response mean 4th phase vs all');
covarFig.Name = [figureNamePrepend 'Covar second bar only response mean 4th phase vs all'];

covarFig = BarPairPlotResponseCovariance(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases, optimalResponseField, 0);
title('Covar second bar only response mean 4th phase vs 4th phase');
covarFig.Name = [figureNamePrepend 'Covar second bar only response mean 4th phase vs 4th phase'];

%% Concatenate full time trace responses vertically, then do corrcoef of them
perFlyAvg = permute(barPairResponsesMatrix, [3 2 1]);
allTTDownRows = reshape(perFlyAvg, size(perFlyAvg, 1)*size(perFlyAvg, 2), size(perFlyAvg, 3));
alphaValue = .05;%1-2*normcdf(-1);% alpha of 1 std
[responseCorrelations, pVals, lower95Perc, upper95perc] = corrcoef(allTTDownRows, 'alpha', alphaValue);
covarFig = BarPairPlotResponseCovariance(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases, optimalResponseField, 2);
title('Corrcoef full time trace all vs all');
covarFig.Name = [figureNamePrepend 'Corrcoef full time trace all vs all'];

covarFig = BarPairPlotResponseCovariance(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases, optimalResponseField, 1);
title('Corrcoef full time trace 4th phase vs all');
covarFig.Name = [figureNamePrepend 'Corrcoef full time trace 4th phase vs all'];

covarFig = BarPairPlotResponseCovariance(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases, optimalResponseField, 0);
title('Corrcoef full time trace 4th phase vs 4th phase');
covarFig.Name = [figureNamePrepend 'Corrcoef full time trace 4th phase vs 4th phase'];

%% Do some scaled correlation stuff...
% Not really worth it
% roiSelectionStart = [1 cumsum(numROIs(1:end-1))+1];
% for roiTypes = 1:length(roiSelectionStart)
%     perFlyAvg = permute(barPairResponsesMatrix(:, :, roiSelectionStart(respTypes):roiSelectionStart(respTypes)+numROIs(respTypes)-1), [3 2 1]);
%     allTTDownRows = reshape(perFlyAvg, size(perFlyAvg, 1)*size(perFlyAvg, 2), size(perFlyAvg, 3));
%     alphaValue = 0.00001;%1-2*normcdf(-1);% alpha of 1 std
%     [responseCorrelations(:, :, roiTypes), pVals, lower95Perc, upper95perc] = corrcoef(allTTDownRows, 'alpha', alphaValue);
% end
% responseCorrelations = mean(responseCorrelations, 3);
% BarPairPlotResponseCovariance(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases, optimalResponseField, 2)
% title('Corrcoef full time trace all vs all');
% 
% BarPairPlotResponseCovariance(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases, optimalResponseField, 1)
% title('Corrcoef full time trace 4th phase vs all');
% 
% BarPairPlotResponseCovariance(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases, optimalResponseField, 0)
% title('Corrcoef full time trace 4th phase vs 4th phase');

%% Concatenate full time trace responses vertically, then do corrcoef of them
perFlyAvg = permute(barPairResponsesMatrix(:, tVals>secondBarDelay & tVals<bothBarsOff, :), [3 2 1]);
allTTDownRows = reshape(perFlyAvg, size(perFlyAvg, 1)*size(perFlyAvg, 2), size(perFlyAvg, 3));
alphaValue = 1-2*normcdf(-1);% alpha of 1 std
[responseCorrelations, pVals, lower95Perc, upper95perc] = corrcoef(allTTDownRows, 'alpha', alphaValue);
covarFig = BarPairPlotResponseCovariance(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases, optimalResponseField, 2);
title('Corrcoef second bar time trace all vs all');
covarFig.Name = [figureNamePrepend 'Corrcoef second bar time trace all vs all'];

covarFig = BarPairPlotResponseCovariance(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases, optimalResponseField, 1);
title('Corrcoef second bar time trace 4th phase vs all');
covarFig.Name = [figureNamePrepend 'Corrcoef second bar time trace 4th phase vs all'];

covarFig = BarPairPlotResponseCovariance(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases, optimalResponseField, 0);
title('Corrcoef second bar time trace 4th phase vs 4th phase');
covarFig.Name = [figureNamePrepend 'Corrcoef second bar time trace 4th phase vs 4th phase'];

%% Here we check covariances after subracting response of only the first bar
timeAvgBarOneResponses  = mean(barPairResponsesMatrix(:, tVals>0 & tVals<secondBarDelay, :), 2);
timeTraceBarTwoResponses  = barPairResponsesMatrix(:, tVals>secondBarDelay & tVals<bothBarsOff, :);
timeTraceDiffResponses = squeeze(mean(timeTraceBarTwoResponses - repmat(timeAvgBarOneResponses, [1 size(timeTraceBarTwoResponses, 2) 1]), 2));
%     for diffResp = 1:size(timeTraceDiffResponses, 3)
%         respCorr(:, :, diffResp) = corrcoef(timeTraceDiffResponses(:, :, diffResp)');
%     end
alphaValue = 1-2*normcdf(-1);% alpha of 1 std
[responseCorrelations, pVals, lower95Perc, upper95perc] = corrcoef(timeTraceDiffResponses', 'alpha', alphaValue);
covarFig = BarPairPlotResponseCovariance(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases, optimalResponseField);
title('Covar second bar minus first bar response mean');
covarFig.Name = [figureNamePrepend 'Covar second bar minus first bar response mean'];
covarFig = BarPairPlotResponseCovariance(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases, optimalResponseField, false);
title('Covar second bar minus first bar response mean fourth phase');
covarFig.Name = [figureNamePrepend 'Covar second bar minus first bar response mean fourth phase'];

%% Here we check covariances after subtracting the response to the first bar of the appropriate polarity
% What we do is look only at phase 4 (the purportedly aligned phase)
% Then we subtract the shifted single bar response--shifted so that it
% would appear at the time of the second bar. Then we integrate/mean
% over the second bar region and see what the covariance is
timeAvgOneBarResponses  = mean(barPairResponsesMatrix(:, tVals>calciumDelay & tVals<bothBarsOff-secondBarDelay, :), 2);
optimalPhase = 4;
timeTraceBarTwoResponses  = barPairResponsesMatrix(:, tVals>secondBarDelay & tVals<bothBarsOff, :);
for roi = 1:size(barPairResponsesMatrix, 3)
    % Note that the last 16 rows are the responses to single bars; the
    % way that CalculateBarPairResponseMatrix outputs them is so that
    % the first eight of those rows is the plus response, and the
    % second eight is the minus response
    numSingleBarRows = 16;
    startOfSingleBarRows = size(timeAvgOneBarResponses, 1)-numSingleBarRows+1;
    plusSingleResponseOptimal = startOfSingleBarRows+optimalPhase-1;
    minusSingleResponseOptimal = startOfSingleBarRows+numPhases+optimalPhase-1;
    roiOptimalResponseField = optimalResponseField;
    switch roiOptimalResponseField
        case {'PPlusPref', 'PPlusNull', 'PlusSingle'}
            timeAvgOneBarResponseRoi(roi) = timeAvgOneBarResponses(plusSingleResponseOptimal, :, roi);
        case {'PMinusPref', 'PMinusNull', 'MinusSingle'}
            timeAvgOneBarResponseRoi(roi) = timeAvgOneBarResponses(minusSingleResponseOptimal, :, roi);
    end
end
timeAvgOneBarResponseRoi = permute(timeAvgOneBarResponseRoi, [3 1 2]);
timeTraceDiffResponses = squeeze(mean(bsxfun(@minus, timeTraceBarTwoResponses, timeAvgOneBarResponseRoi), 2));
[responseCorrelations, pVals, lower95Perc, upper95perc] = corrcoef(timeTraceDiffResponses', 'alpha', alphaValue);
covarFig = BarPairPlotResponseCovariance(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases, optimalResponseField, false);
title('Covar second bar minus single bar response mean fourth phase');
covarFig.Name = [figureNamePrepend 'Covar second bar minus single bar response mean fourth phase'];

%% Here we're looking at the actual responses minus the linear model--this will give us a measure of the interation term
%**** NOT SURE THIS WORKS ****%
if ~isempty(barPairModelResponseMatrix)
    realMinusLinearResponse = barPairResponsesMatrix - barPairModelResponseMatrix;
    numTimePoints = size(realMinusLinearResponse, 2);
    modelRealDiffs = squeeze(mean(realMinusLinearResponse(:, tVals>secondBarDelay & tVals<=bothBarsOff, :), 2));
    [responseCorrelations, pVals, lower95Perc, upper95perc] = corrcoef(modelRealDiffs', 'alpha', alphaValue);
    covarFig = BarPairPlotResponseCovariance(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases, optimalResponseField, 2);
    title('Covar actual responses - linear response all vs all');
    covarFig.Name = [figureNamePrepend 'Covar actual responses - linear response all vs all'];
    
    covarFig = BarPairPlotResponseCovariance(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases, optimalResponseField, 1);
    title('Covar actual responses - linear response 4th phase vs all');
    covarFig.Name = [figureNamePrepend 'Covar actual responses - linear response 4th phase vs all'];
    
    covarFig = BarPairPlotResponseCovariance(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases, optimalResponseField, 0);
    title('Covar actual responses - linear response 4th phase vs 4th phase');
    covarFig.Name = [figureNamePrepend 'Covar actual responses - linear response 4th phase vs 4th phase'];
end

