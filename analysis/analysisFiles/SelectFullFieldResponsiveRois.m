function [roiResponsesOut,roiMaskOut, roiIndsOfInterest, pValsSum, valueStruct] = SelectFullFieldResponsiveRois(roiResponses,roiMaskInitial,epochStartTimes,epochDurations, epochsForSelectivity, params,interleaveEpoch,varargin)
% Implement size, brightness


% This should be a 2xM input where the first row epoch must be
% significantly different and significantly greater than the second row
% epoch
pValsSum = [];
epochSelIndThresh = 0.4;
overallCorrelationThresh = 0.4;
corrToThirdThresh = 0.4;
roiSizeMin = 5;

valueStruct = struct('dirSel', [],'dprimish',[],'meanValsSB',[],'pVals',[],'diffHzPower',[],'meanValsCB',[],'roiSizes',[],'primaryCorrelations',[],'secondaryCorrelations',[],'edgeSelectivityIndex',[], 'edgeDsi', [], 'edgeEsi', [], 'juyueCorr', [], 'maxMeansLoc', [], 'maxPrimEdgeResp', [], 'maxSecEdgeResp', []);


changeableVarargin = {'epochFractionCompare', 'dsiThresh', 'esiThresh', 'primCorrIndThresh', 'pValThresh','overallCorrelationThresh','esiDsiMax', 'roiSizeMin', 'epochSelIndThresh'};

for ii = 1:2:length(varargin)
    if any(strcmp(changeableVarargin,    varargin{ii}))
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    else
        continue
    end
end

if iscell(roiMaskInitial)
    roiSizes = [];
    for maskNum=1:length(roiMaskInitial)
        roiMaskHere = roiMaskInitial{maskNum};
        roiSizesHere=  zeros(1, max(max(roiMaskHere)));
        for szInd = 1:max(max(roiMaskHere))
            roiSizesHere(szInd) = sum(sum(roiMaskHere == szInd));
        end
        
        roiSizes = [roiSizes roiSizesHere];
    end
    roiMaskInitial = roiMaskInitial{1};
else
    roiSizes = zeros(1, max(max(roiMaskInitial)));
    for szInd = 1:max(max(roiMaskInitial))
        roiSizes(szInd) = sum(sum(roiMaskInitial == szInd));
    end
end

valueStruct.roiSizes = roiSizes;


if any(cat(2, epochsForSelectivity{:, 1}) == '~')
    epochsForCurrSelectivity = cellfun(@(epochName) epochName(epochName~='~'), epochsForSelectivity, 'UniformOutput', false);
    epochNumsForSelectivity = ConvertEpochNameToIndex(params,epochsForCurrSelectivity);
else
    epochNumsForSelectivity = ConvertEpochNameToIndex(params,epochsForSelectivity);
end

if isempty(epochNumsForSelectivity)
    warning('No ROIs extracted by epoch because the epochsForSelectivity couldn''t be found in the epoch names');
    roiMaskOut = {roiMaskInitial};
    roiIndsOfInterest = true(1, size(roiResponses, 2));
    roiResponsesOut{1, 1} = roiResponses(:, roiIndsOfInterest);
    valueStruct = struct();
    pValsSum = zeros(size(roiIndsOfInterest));
    return;
end

% if size(epochsForSelectivity, 1) == 3
%     methodForSelectivity =
% end

roiIndsOfInterest = false(size(roiResponses, 2),1);

roiIndsOfInterestTemp = zeros(size(epochNumsForSelectivity, 2), size(roiResponses, 2));
% ROImeans = mean(roiAvgIntensityFilteredNormalized);
ROIstds = std(roiResponses);

indInsert = 1;
correlationsDone = struct();
primRespDone = struct();

for i = 1:size(epochNumsForSelectivity, 1)
        
        
    % Grab the responses from the two epochs being compared
    selectResponses = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,epochNumsForSelectivity(i, 1));
    compareResponses = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,epochNumsForSelectivity(i, 2));
    
    % Concatenate the two response traces together for finding the mean
    % response
    concatSelectFromBase =  cat(1, selectResponses{:});
    concatCompareFromBase = cat(1, compareResponses{:});

    % Find the mean response to these epochs
    highSelectFromBase = percentileThresh(concatSelectFromBase, 0.99);
    lowSelectFromBase = percentileThresh(concatSelectFromBase, 0.5);
    highCompareFromBase = percentileThresh(concatCompareFromBase, 0.99);
    lowCompareFromBase = percentileThresh(concatCompareFromBase, 0.5);
    diffValsSB = highSelectFromBase - lowSelectFromBase;
    diffValsCB = highCompareFromBase - lowCompareFromBase;
    
    % Much like the ESI and DSI of before, this is just a selection index
    % for whatever epochs are being compared, and it has an associated
    % threshold
    epochSelInd = (diffValsSB-diffValsCB)./(diffValsSB+diffValsCB);
    
    roiIndsOfInterest = epochSelInd > epochSelIndThresh;
    
    
    % Doing the correlation threshold here; we're using the entire
    % probe stimulus, which is everything that occurs before the
    % interleave epoch the way that ReadImagingData is set up
    if interleaveEpoch~=1
        probeResponse = cell(1, interleaveEpoch-1);
        for probeEpoch = 1:interleaveEpoch-1
            probeResponse{probeEpoch} = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,probeEpoch);
        end
        
        concatProbeResps = cat(1, probeResponse{:});
        % This code assumes there are three presentations of the probe!
        firstPres = cat(1, concatProbeResps{:, 1});
        secondPres = cat(1, concatProbeResps{:, 1});
        thirdPres = cat(1, concatProbeResps{:, 1});
        [overallCorrelations, meanFirstTwo] = corrFirstToSecond({firstPres secondPres});
        
        % We check that the third probe presentation, at the end, agrees
        % with the first ones; this is a way of checking that too much
        % motion didn't occur across the presentation
        corrToThird = corrFirstToSecond({meanFirstTwo thirdPres});
        
        roiIndsOfInterest = roiIndsOfInterest & overallCorrelations>overallCorrelationThresh & corrToThird > corrToThirdThresh;
    elseif length(selectResponses)>2
        firstPres = cat(1, selectResponses{1}, compareResponses{1});
        secondPres = cat(1, selectResponses{2}, compareResponses{2});
        [overallCorrelations] = corrFirstToSecond({firstPres secondPres});
        roiIndsOfInterest = roiIndsOfInterest & overallCorrelations>overallCorrelationThresh;
    else
        warning('No correlation threshold is being calculated because there was both no probe stimulus and no repeats of the epochs being used for selection');
    end
    
    roiIndsOfInterest = roiIndsOfInterest & roiSizes>roiSizeMin;
    
    
    
    
    
    roiIndsOfInterest = roiIndsOfInterest(:);
    roiResponsesOut{i, 1} = roiResponses(:, roiIndsOfInterest);
    
    
    roiMask = zeros(size(roiMaskInitial));
    indsOfInt = find(roiIndsOfInterest);
    % Not really sure that this would work if you have two presentations on
    % the same fly, because roiMaskInitial has been changed to just the
    % first mask (this is if you call this function outside
    % ReadImagingData, where the roiMasks have been concatenated.
    for j = 1:length(indsOfInt)
        roiMask(roiMaskInitial==indsOfInt(j)) = j;
    end
    
    
    roiMaskOut{i, 1} = {roiMask};
end





end

function alignedResponses = AverageResponses(responsesCell)


if size(responsesCell{1}, 1) < size(responsesCell{2}, 1)
    sizeDiff = size(responsesCell{2}, 1)-size(responsesCell{1}, 1);
    averagingCell{2} = responsesCell{2}(1:end-sizeDiff, :);
    averagingCell{3} = responsesCell{2}(1+sizeDiff:end, :);
    averagingCell{1} = responsesCell{1};
elseif size(responsesCell{1}, 1) > size(responsesCell{2}, 1)
    sizeDiff = size(responsesCell{1}, 1)-size(responsesCell{2}, 1);
    averagingCell{2} = responsesCell{1}(1:end-sizeDiff, :);
    averagingCell{3} = responsesCell{1}(1+sizeDiff:end, :);
    averagingCell{1} = responsesCell{2};
else
    averagingCell{2} = responsesCell{2};
    averagingCell{3} = responsesCell{2};
    averagingCell{1} = responsesCell{1};
end

avgCells = mean(cat(3, averagingCell{[1 2]}), 3);
avgCells(:, :, 2) = mean(cat(3, averagingCell{[1 3]}), 3);
maximalResponses = max(avgCells,[],1);
[~, bestAlignmentInd ]=max(maximalResponses, [], 3);
alignedResponses = zeros(size(avgCells(:, :, 1)));
for i = 1:length(bestAlignmentInd)
    alignedResponses(:, i) = avgCells(:,i, bestAlignmentInd(i));
end

end

function [valsFirstToSecondPres, meanRespsOut]= corrFirstToSecond(responsesCell)

if size(responsesCell{1}, 1) < size(responsesCell{2}, 1)
    sizeDiff = size(responsesCell{2}, 1)-size(responsesCell{1}, 1);
    correlationCell{2} = responsesCell{2}(1:end-sizeDiff, :);
    correlationCell{3} = responsesCell{2}(1+sizeDiff:end, :);
    correlationCell{1} = responsesCell{1};
elseif size(responsesCell{1}, 1) > size(responsesCell{2}, 1)
    sizeDiff = size(responsesCell{1}, 1)-size(responsesCell{2}, 1);
    correlationCell{2} = responsesCell{1}(1:end-sizeDiff, :);
    correlationCell{3} = responsesCell{1}(1+sizeDiff:end, :);
    correlationCell{1} = responsesCell{2};
else
    correlationCell{2} = responsesCell{2};
    correlationCell{3} = responsesCell{2};
    correlationCell{1} = responsesCell{1};
end

respsIn3D = cat(3, correlationCell{:});
respsInLayers = permute(respsIn3D, [1 3 2]);
resps2DSetsOfThree = reshape(respsInLayers, size(respsInLayers, 1), []);

% Get rid of NaN vals that would ruin the cross correlation
nanVals = any(isnan(resps2DSetsOfThree), 2);
resps2DSetsOfThree(nanVals, :) = [];

ccVals = corrcoef(resps2DSetsOfThree);
% Neighbor's gonna be the second presentation
comparisonWithNeighbor1 = diag([ccVals ccVals], 1);
comparisonWithNeighbor2 = diag([ccVals ccVals], 2);
% But two of every three will be to different ROI
valsFirstToSecondPres1 = comparisonWithNeighbor1(1:3:end);
valsFirstToSecondPres2 = comparisonWithNeighbor2(1:3:end);

[valsFirstToSecondPres, indMaxVal] = max([valsFirstToSecondPres1'; valsFirstToSecondPres2']);

% Add 1 to get it into the index of correlationCell which is changing size
indMaxVal = indMaxVal+1;
tempOut = zeros(size(correlationCell{1}));
tempOut(:, indMaxVal==2) = correlationCell{2}(:, indMaxVal==2);
tempOut(:, indMaxVal==3) = correlationCell{3}(:, indMaxVal==3);
meanRespsOut = mean(cat(3, tempOut, correlationCell{1}), 3);

end