function [roiResponsesOut,roiMaskOut, roiIndsOfInterest, pValsSum, valueStruct] = SelectEdgeResponsiveRois(roiResponses,roiMaskInitial,epochStartTimes,epochDurations, epochsForSelectivity, params,interleaveEpoch,varargin)
% Implement size, brightness


% This should be a 2xM input where the first row epoch must be
% significantly different and significantly greater than the second row
% epoch
pValsSum = [];
dsiThresh = 0.4;
esiThresh = 0.4;
overallCorrelationThresh = 0.4;
corrToThirdThresh = 0.4;
roiSizeMin = 5; %pixel-- ~1 micron at our zoom levels
esiDsiMax = false; % Checks whether edge ESI/DSI is calculated by maxing light left/light right, left light/left dark, etc. or by mean-ing them
valueStruct = struct('dirSel', [],'dprimish',[],'meanValsSB',[],'diffHzPower',[],'meanValsCB',[],'roiSizes',[],'primaryCorrelations',[],'secondaryCorrelations',[],'edgeSelectivityIndex',[], 'edgeDsi', [], 'edgeEsi', [], 'juyueCorr', [], 'maxMeansLoc', [], 'maxPrimEdgeResp', [], 'maxSecEdgeResp', [], 'corrToThirdThresh', []);


changeableVarargin = {'epochFractionCompare', 'dsiThresh', 'esiThresh', 'primCorrIndThresh', 'pValThresh','overallCorrelationThresh','esiDsiMax','corrToThirdThresh', 'roiSizeMin'};

for ii = 1:2:length(varargin)
    if any(strcmp(changeableVarargin,    varargin{ii}))
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    else
        continue
    end
end

if iscell(esiThresh)
    esiThreshCell = esiThresh;
else
    esiThreshCell = {};
end

if iscell(dsiThresh)
    dsiThreshCell = dsiThresh;
else
    dsiThreshCell = {};
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
else
    roiSizes = zeros(1, max(max(roiMaskInitial)));
    for szInd = 1:max(max(roiMaskInitial))
        roiSizes(szInd) = sum(sum(roiMaskInitial == szInd));
    end
end

valueStruct.roiSizes = roiSizes;

if iscell(roiMaskInitial)
    roiMaskInitial = roiMaskInitial{1};
end

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


roiIndsOfInterestTemp = zeros(size(epochNumsForSelectivity, 2), size(roiResponses, 2));
% ROImeans = mean(roiAvgIntensityFilteredNormalized);
ROIstds = std(roiResponses);

indInsert = 1;

for i = 1:size(epochNumsForSelectivity, 1)
    
    if ~isempty(esiThreshCell)
        esiThresh = esiThreshCell{i};
    end
    if ~isempty(dsiThreshCell)
        dsiThresh = dsiThreshCell{i};
    end
    
    % reset roiIndsOfInterest every time....
    roiIndsOfInterest = false(1,size(roiResponses, 2));

    if true
        primaryResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,epochNumsForSelectivity(i, 1));
        secondaryResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,epochNumsForSelectivity(i, 2));
        tertiaryResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,epochNumsForSelectivity(i, 3));
        quaternaryResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,epochNumsForSelectivity(i, 4));
        
        squareWaveEpochs = {'Square Right', 'Square Left', 'Square Down', 'Square Up'};
        squareEpochNumsForSelectivity = ConvertEpochNameToIndex(params,squareWaveEpochs);
        
        rightResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,squareEpochNumsForSelectivity(1));
        leftResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,squareEpochNumsForSelectivity(2));
        downResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,squareEpochNumsForSelectivity(3));
        upResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,squareEpochNumsForSelectivity(4));
        
        
        leftResponses = cat(1, leftResponsesCell{:});
        rightResponses = cat(1, rightResponsesCell{:});
        upResponses = cat(1, upResponsesCell{:});
        downResponses = cat(1, downResponsesCell{:});
        
        
        stillPreRightResponsesCell  = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,squareEpochNumsForSelectivity(1)-1);
        stillPreLeftResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,squareEpochNumsForSelectivity(2)-1);
        stillPreDownResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,squareEpochNumsForSelectivity(3)-1);
        stillPreUpResponsesCell= GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,squareEpochNumsForSelectivity(4)-1);
        
%         leftMean = mean(leftResponses);
%         rightMean = mean(rightResponses);
%         upMean = mean(upResponses);
%         downMean = mean(downResponses);
        leftMean = nanmean(leftResponses);
        rightMean = nanmean(rightResponses);
        upMean = nanmean(upResponses);
        downMean = nanmean(downResponses);
        
        meanMatrix = [leftMean;rightMean;upMean;downMean];
        
        [~, maxMeansLoc] = max(meanMatrix);
        
        maxMeanEpochCutoff = (maxMeansLoc==1 | maxMeansLoc==2);
        
        % Doing the correlation threshold here; we're using the entire
        % probe stimulus, which is everything that occurs before the
        % interleave epoch the way that ReadImagingData is set up
        if interleaveEpoch~=1
            probeResponse = cell(interleaveEpoch-1);
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
%         elseif length(selectResponses)>2
%             firstPres = cat(1, selectResponses{1}, compareResponses{1});
%             secondPres = cat(1, selectResponses{2}, compareResponses{2});
%             [overallCorrelations] = corrFirstToSecond({firstPres secondPres});
%             roiIndsOfInterest = roiIndsOfInterest & overallCorrelations>overallCorrelationThresh;
        else
            warning('No correlation threshold is being calculated because there was both no probe stimulus and no repeats of the epochs being used for selection');
        end
        
%         firstPres = cat(1, primaryResponsesCell{1}, secondaryResponsesCell{1}, tertiaryResponsesCell{1}, quaternaryResponsesCell{1},stillPreRightResponsesCell{1},rightResponsesCell{1}, stillPreLeftResponsesCell{1}, leftResponsesCell{1},stillPreDownResponsesCell{1}, downResponsesCell{1}, stillPreUpResponsesCell{1},upResponsesCell{1});
%         secondPres = cat(1, primaryResponsesCell{2}, secondaryResponsesCell{2}, tertiaryResponsesCell{2}, quaternaryResponsesCell{2},stillPreRightResponsesCell{2},rightResponsesCell{2}, stillPreLeftResponsesCell{2}, leftResponsesCell{2},stillPreDownResponsesCell{2}, downResponsesCell{2}, stillPreUpResponsesCell{2},upResponsesCell{2});
%         thirdPres = cat(1, primaryResponsesCell{3}, secondaryResponsesCell{3}, tertiaryResponsesCell{3}, quaternaryResponsesCell{3},stillPreRightResponsesCell{3},rightResponsesCell{3}, stillPreLeftResponsesCell{3}, leftResponsesCell{3},stillPreDownResponsesCell{3}, downResponsesCell{3}, stillPreUpResponsesCell{3},upResponsesCell{3});
        [overallCorrelations, meanFirstTwo] = corrFirstToSecond({firstPres secondPres});
        
        corrToThird = corrFirstToSecond({meanFirstTwo thirdPres});
        
        primaryResponses = AverageResponses(primaryResponsesCell);
        secondaryResponses = AverageResponses(secondaryResponsesCell);
        tertiaryResponses = AverageResponses(tertiaryResponsesCell);
        quaternaryResponses = AverageResponses(quaternaryResponsesCell);
        
        for roiResponse = 1:size(primaryResponses, 2)
            primRespHigh(roiResponse) = percentileThresh(primaryResponses(:, roiResponse), 0.99);
            secRespHigh(roiResponse) = percentileThresh(secondaryResponses(:, roiResponse), 0.99);
            tertRespHigh(roiResponse) = percentileThresh(tertiaryResponses(:, roiResponse), 0.99);
            quatRespHigh(roiResponse) = percentileThresh(quaternaryResponses(:, roiResponse), 0.99);
            
            primRespLow(roiResponse) = percentileThresh(primaryResponses(:, roiResponse), 0.5);
            secRespLow(roiResponse) = percentileThresh(secondaryResponses(:, roiResponse), 0.5);
            tertRespLow(roiResponse) = percentileThresh(tertiaryResponses(:, roiResponse), 0.5);
            quatRespLow(roiResponse) = percentileThresh(quaternaryResponses(:, roiResponse), 0.5);      
        end
        
        primRespDiff = primRespHigh - primRespLow;
        secRespDiff = secRespHigh - secRespLow; 
        tertRespDiff = tertRespHigh - tertRespLow;
        quatRespDiff = quatRespHigh - quatRespLow;
        
        if esiDsiMax
            edgeEsi = (max([primRespDiff; tertRespDiff])- max([secRespDiff; quatRespDiff]))./(max([primRespDiff; tertRespDiff]) + max([secRespDiff; quatRespDiff]));
            edgeDsi = (max([primRespDiff; secRespDiff])- max([tertRespDiff; quatRespDiff]))./(max([primRespDiff; secRespDiff])+ max([tertRespDiff; quatRespDiff]));
        else
            edgeEsi = (mean([primRespDiff; tertRespDiff])- mean([secRespDiff; quatRespDiff]))./(mean([primRespDiff; tertRespDiff]) + mean([secRespDiff; quatRespDiff]));
            edgeDsi = (mean([primRespDiff; secRespDiff])- mean([tertRespDiff; quatRespDiff]))./(mean([primRespDiff; secRespDiff])+ mean([tertRespDiff; quatRespDiff]));
        end
        
        if epochsForSelectivity{i, 1}(1) == '~' %hacky method of doing no edge selection
            roiIndsOfInterest = edgeDsi > dsiThresh & overallCorrelations > overallCorrelationThresh & maxMeanEpochCutoff & corrToThird > corrToThirdThresh;
            disp('No edge selection being performed--only direction selectivity');
        else
            roiIndsOfInterest = edgeEsi > esiThresh(1) & edgeDsi > dsiThresh & overallCorrelations > overallCorrelationThresh & maxMeanEpochCutoff & corrToThird > corrToThirdThresh;
            if length(esiThresh)>1
                roiIndsOfInterest = roiIndsOfInterest & edgeEsi < esiThresh(2);
            end
        end
        roiIndsOfInterest = roiIndsOfInterest & roiSizes>roiSizeMin;
        
%         if any(edgeDsi>1) || any(edgeEsi>1)
%             keyboard
%         end
        valueStruct.edgeEsi = edgeEsi;
        valueStruct.edgeDsi = edgeDsi;
        valueStruct.overallCorrelations = overallCorrelations;
        valueStruct.corrToThird = corrToThird;
        valueStruct.maxPrimEdgeResp = mean([primRespDiff; tertRespDiff]);
        valueStruct.maxSecEdgeResp = mean([secRespDiff; quatRespDiff]);
    end
    
    roiIndsOfInterest = roiIndsOfInterest(:);
    roiResponsesOut{i, 1} = roiResponses(:, roiIndsOfInterest);
    
    valueStruct.meanMatrix = meanMatrix;
    valueStruct.maxMeansLoc = maxMeansLoc;
    
    roiMask = zeros(size(roiMaskInitial));
    indsOfInt = find(roiIndsOfInterest);
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