function tp_plotBarPairExpandedSummary(Z, phase, barToCenter, pathString, connDb, numROIs)
% plusEpochs and minusEpochs are defined by the first bar being positive or
% negative

epochNames = {Z.stimulus.params.epochName};
epochsOfInterestFirstLeft = find(~cellfun('isempty', strfind(epochNames, 'L++')), 1, 'first');
epochsOfInterestFirstRight = find(~cellfun('isempty', strfind(epochNames, 'R++')), 1, 'first');
if epochsOfInterestFirstLeft < epochsOfInterestFirstRight
    epochsOfInterestFirst = epochsOfInterestFirstLeft;
else
    epochsOfInterestFirst = epochsOfInterestFirstRight;
end
epochPhases = [Z.stimulus.params(epochsOfInterestFirst:end).phase];
phase = sort(unique(epochPhases));

epochsOfInterestNames = epochNames(epochsOfInterestFirst:end);
leftEpochs = epochsOfInterestFirst + find(~cellfun('isempty', strfind(epochsOfInterestNames, 'L')))-1;
rightEpochs = epochsOfInterestFirst + find(~cellfun('isempty', strfind(epochsOfInterestNames, 'R')))-1;
disp(['This analysis depends on whether the mirrors have been rotated or not!\n '...
    'Currently it''s being analyzed as if they have been rotated']);

plotOverall = false;
flyData = fetch(connDb, sprintf('select eye from fly where relativePath = "%s"', pathString));
flyEye = flyData{1};
% stimulusFunction(stimulusFunction=='_') = ' ';
% titleText = [stimulusFunction ' ' flyEye ' eye'];

if strcmpi(flyEye, 'right')
    progEpochs = rightEpochs;
    regEpochs = leftEpochs;
    epochsForSelectivity = {'Square Right'; 'Square Left'};
    rightCheck = false;
else
    progEpochs = leftEpochs;
    regEpochs = rightEpochs;
    epochsForSelectivity = {'Square Left'; 'Square Right'};
    rightCheck = true;
end

if (barToCenter == 2 && strcmpi(flyEye, 'left')) || (barToCenter== 1 && strcmpi(flyEye, 'right'))
    phaseProg = num2str(phase);
    phaseReg = num2str(mod(phase-1, length(phase)));
elseif (barToCenter== 1 && strcmpi(flyEye, 'left')) || (barToCenter== 2 && strcmpi(flyEye, 'right'))
    phaseProg = num2str(phase);
    phaseReg = num2str(mod(phase+1, length(phase)));
else
    phaseProg = num2str(phase);
    phaseReg = num2str(phase);
end

posEpochs = epochsOfInterestFirst + find(~cellfun('isempty', strfind(epochsOfInterestNames, ['++ P'])) | ~cellfun('isempty', strfind(epochsOfInterestNames, ['-- P'])))-1;
negEpochs = epochsOfInterestFirst + find(~cellfun('isempty', strfind(epochsOfInterestNames, ['+- P'])) | ~cellfun('isempty', strfind(epochsOfInterestNames, ['-+ P'])))-1;

plusEpochs = epochsOfInterestFirst:2:length(epochNames);
minusEpochs = (epochsOfInterestFirst+1):2:length(epochNames);

epochOfInterestPhases = regexp(epochsOfInterestNames, '\s*(P\d)\s*', 'tokens');
epochOfInterestPhases = [epochOfInterestPhases{:}];
phaseProgCellStr = cellfun(@(x) num2str(x), num2cell(phaseProg), 'UniformOutput', false);
phaseRegCellStr = cellfun(@(x) num2str(x), num2cell(phaseReg), 'UniformOutput', false);
[a, b] = ismember([epochOfInterestPhases{:}], strcat('P', phaseProgCellStr));
[~, x] = sort(b(b~=0));
l = find(a);
phaseProgEpochs = epochsOfInterestFirst + l(x) -1;
[a, b] = ismember([epochOfInterestPhases{:}], strcat('P', phaseRegCellStr));
[~, x] = sort(b(b~=0));
l = find(a);
phaseRegEpochs = epochsOfInterestFirst + l(x) -1;




% First split for progressive/regressive epochs and positive/negative
% correlations
% if length(phase)==1
    % If we have one phase we want to find only those epochs that go in
    % that phase
    progEpochsPhased = intersect(phaseProgEpochs, progEpochs, 'stable');
    regEpochsPhased = intersect(phaseRegEpochs, regEpochs, 'stable');
% else
    % While for the moment, if we have more than one phase, we're honestly
    % just gonna pick out all the phases
%     progEpochsPhased = progEpochs;
%     regEpochsPhased = regEpochs;
% end

progPos = intersect(progEpochsPhased, posEpochs, 'stable');
progNeg = intersect(progEpochsPhased, negEpochs, 'stable');
regPos = intersect(regEpochsPhased, posEpochs, 'stable');
regNeg = intersect(regEpochsPhased, negEpochs, 'stable');

progPPlusNull = intersect(regPos, plusEpochs, 'stable');
progPPlusPref = intersect(progPos, plusEpochs, 'stable');
progPMinusNull = intersect(regPos, minusEpochs, 'stable');
progPMinusPref = intersect(progPos, minusEpochs, 'stable');
% It turns out we're only plotting preferred direction when plotting many
% phases, but experience would suggest that the 'preferred' direction
% switches
if true;%length(phase)==1
    progNPlusNull = intersect(regNeg, plusEpochs, 'stable');
    progNPlusPref = intersect(progNeg, plusEpochs, 'stable');
    progNMinusNull = intersect(regNeg, minusEpochs, 'stable');
    progNMinusPref = intersect(progNeg, minusEpochs, 'stable');
else
    progNPlusNull = intersect(progNeg, plusEpochs, 'stable');
    progNPlusPref = intersect(regNeg, plusEpochs, 'stable');
    progNMinusNull = intersect(progNeg, minusEpochs, 'stable');
    progNMinusPref = intersect(regNeg, minusEpochs, 'stable');
end

plottingEpochs.PPlusPref = progPPlusPref;
plottingEpochs.PMinusPref = progPMinusPref;
plottingEpochs.NPlusPref = progNPlusPref;
plottingEpochs.NMinusPref = progNMinusPref;
plottingEpochs.PPlusNull = progPPlusNull;
plottingEpochs.PMinusNull = progPMinusNull;
plottingEpochs.NPlusNull = progNPlusNull;
plottingEpochs.NMinusNull = progNMinusNull;

epochsOfInterest = sort(unique([rightEpochs, leftEpochs, posEpochs, negEpochs]));
Z.params.epochsOfInterest = epochsOfInterest;
Z.params.epochsForSelectivity = epochsForSelectivity;
[roiIndsOfInterest, pValsSum] = extractROIsBySelectivity(Z);
numROIsOfInterest = sum(roiIndsOfInterest);
if numROIsOfInterest < numROIs
    numROIsProg = numROIsOfInterest;
else
    numROIsProg = numROIs;
end

% Max out all noninteresting ROIs
Z.ROI.roiIndsOfInterest = roiIndsOfInterest;
pValsSum(~Z.ROI.roiIndsOfInterest) = max(pValsSum);
% for i = 1:numROIsProg
%     [~, ind] = min(pValsSum);
%     pValsSum(ind) = max(pValsSum);
%     Z.ROI.roiIndsOfInterest(ind) = true;
%     Z.ROI.roiIndsOfInterest([1:ind-1 ind+1:end]) = false;
%     Z = triggeredResponseAnalysis(Z, 'Bar Pair Plots!');
% 
%     
%     tp_plotBarPairROISummary(Z, Z.triggeredResponseAnalysis.triggeredIntensities, plottingEpochs, barToCenter, rightCheck, []);
%     text(-0.4, 3, flyEye);
% end


responsiveROIs = ~cellfun('isempty', strfind(Z.ROI.typeFlagName, 'Dark')) & roiIndsOfInterest;

% [sortPvals, sortInd] = sort(darkPvalsSum);
responsiveROIs =  responsiveROIs & pValsSum'<0.01;
responsiveROIs = find(responsiveROIs);
pValsSumResponsive = pValsSum(responsiveROIs);
[~, indSort] = sort(pValsSumResponsive);
% Keep only the 10 best ones (if there are 10, it won't error if there are
% fewer)
responsiveROIs(indSort(10:end)) = [];
% progDarkEdge = [ 1 4 6 7 8 9 10 11 12 ];
% responsiveROIs = responsiveROIs(progDarkEdge);

% responsiveROIs = responsiveROIs;
if any(responsiveROIs)
    pValsForResponsive = pValsSum(responsiveROIs);
    [~, indsToSortResponse] = sort(pValsForResponsive);
%     darkResponsiveROIs = find(darkResponsiveROIs);
    Z.ROI.roiIndsOfInterest = responsiveROIs;
    Z = triggeredResponseAnalysis(Z, 'Bar Pair Plots!');
    fsAligned = Z.params.fs*Z.triggeredResponseAnalysis.fsFactor;
    stepsBack = Z.triggeredResponseAnalysis.stepsBack;
    
    avgResponses  = [];
    avgResponse = [];
    epochs = [plottingEpochs.PPlusPref' plottingEpochs.PMinusPref' plottingEpochs.PPlusNull' plottingEpochs.PMinusNull'];
    for epochSet = epochs
        avgResponses = [];
        for i = 1:length(epochSet)
            epoch = ['epoch_' num2str(epochSet(i))];
            avgResponses = cat(3, avgResponses, Z.triggeredResponseAnalysis.epochAvgTriggeredIntensities.(epoch));
        end
        avgResponse = cat(4, avgResponse, avgResponses);
    end
    
    
    
    avgResponse = permute(avgResponse, [2 3 1 4]);
    minPRoi = indsToSortResponse(1);
%     avgResponse = avgResponse(:, :, indsToSortResponse, :);
    
    % barsOff =Z.stimulus.params(end).duration/60;
    barsOff = 1;
    xVals = -stepsBack:size(avgResponse, 1)-stepsBack-1;
    tVals = xVals./(fsAligned);
    firstInd = find(tVals>=0, 1, 'first');
    lastInd = find(tVals<=barsOff, 1, 'last');
    barResponse = avgResponse(firstInd:lastInd, :, :, :);
    % meanBarResp = squeeze(nanmean(barResponse, 2));
    avgResponse = barResponse;
    
    
    % meanPhaseResp = nanmean(meanBarResp);
    numberOfRois = length(responsiveROIs);
    numberOfPhases = length(phase);
    %The 2*line_width-1 part has to do with the size xcov outputs
    % crossCovariances = zeros(numberOfRois, 2*numberOfPhases-1);
    
    shift = 0;
    for j = 1:numberOfRois
        % Compute the circular cross correlation (ish)
        timeCorrelations = [];
%         for epochSet = 1:size(avgResponse, 4)
%             timeCorrelations(:,epochSet) = cconv(reshape(avgResponse(:, :, 1, epochSet), 1, []), fliplr(reshape(avgResponse(:, :, j, epochSet), 1, [])), numel(avgResponse(:, :, 1, 1)));
            for phaseNum = 1:numberOfPhases
                covVal(:, :, phaseNum) = cov(reshape(avgResponse(:, :, minPRoi, :), 1, []), reshape(circshift(avgResponse(:, :, j, :), phaseNum, 2), 1, []));
            end
            [~, shift(j)] = max(covVal(1, 2, :)); 
%         end
%         timeCorrelations = cconv(reshape(avgResponse(:, :, 1), 1, []), fliplr(reshape(avgResponse(:, :, j), 1, [])), numel(avgResponse(:, :, 1)));
%         timeCovariances = cov([avgResponse(:, :, 1),avgResponse(:, :, j)]);
%         validCorr = size(avgResponse, 1):size(avgResponse, 1):length(timeCorrelations);
%         [~, maxCorr] = max(timeCorrelations(validCorr));
%         timeCovariancesOfInterest = timeCovariances(1:end/2, end/2+1:end);
%         [~, indMaxAlign] = max(timeCovariancesOfInterest(:));
%         [phaseBest, phaseNew] = ind2sub(size(timeCovariancesOfInterest), indMaxAlign);
%         shift(j) = phaseBest - phaseNew;
%         shift(j) = validCorr(maxCorr)/size(avgResponse, 1);
    end
    
    phaseByEpoch = squeeze(mean(avgResponse(:, :, minPRoi, :), 1));
    [~, maxInd] = max(phaseByEpoch(:));
    [phaseMax, ~] = ind2sub(size(phaseByEpoch), maxInd);
    
    phaseDesired = round(numberOfPhases/2)-phaseMax;
    shift = phaseDesired-shift;
    
    tp_plotBarPairROISummary(Z, Z.triggeredResponseAnalysis.epochAvgTriggeredIntensities, plottingEpochs, barToCenter, rightCheck, shift);
else
    fprintf('No dark edge responsive regressive ROIs found!\n' )
end

% for i = 1:length(responsiveROIs)
%     ind = responsiveROIs(i);
%     Z.ROI.roiIndsOfInterest=ind;
% %     Z.ROI.roiIndsOfInterest([1:ind-1 ind+1:end]) = false;
%     Z = triggeredResponseAnalysis(Z, 'Bar Pair Plots!');
%     
%     tp_plotBarPairROISummary(Z, Z.triggeredResponseAnalysis.triggeredIntensities, plottingEpochs, barToCenter, rightCheck, shift(i));
%     text(-0.4, 3, flyEye);
% end


%% Light Progressive!
responsiveROIs = ~cellfun('isempty', strfind(Z.ROI.typeFlagName, 'Light')) & roiIndsOfInterest;
% [sortPvals, sortInd] = sort(darkPvalsSum);
responsiveROIs =  responsiveROIs & pValsSum'<0.01;

responsiveROIs =  responsiveROIs & pValsSum'<0.01;
responsiveROIs = find(responsiveROIs);
pValsSumResponsive = pValsSum(responsiveROIs);
[~, indSort] = sort(pValsSumResponsive);
% Keep only the 10 best ones (if there are 10, it won't error if there are
% fewer)
responsiveROIs(indSort(10:end)) = [];



if any(responsiveROIs)
    pValsForResponsive = pValsSum(responsiveROIs);
    [~, indsToSortResponse] = sort(pValsForResponsive);
%     darkResponsiveROIs = find(darkResponsiveROIs);
    Z.ROI.roiIndsOfInterest = responsiveROIs;
    Z = triggeredResponseAnalysis(Z, 'Bar Pair Plots!');
    fsAligned = Z.params.fs*Z.triggeredResponseAnalysis.fsFactor;
    stepsBack = Z.triggeredResponseAnalysis.stepsBack;
    
    avgResponses  = [];
    avgResponse = [];
    epochs = [plottingEpochs.PPlusPref' plottingEpochs.PMinusPref' plottingEpochs.PPlusNull' plottingEpochs.PMinusNull'];
    for epochSet = epochs
        avgResponses = [];
        for i = 1:length(epochSet)
            epoch = ['epoch_' num2str(epochSet(i))];
            avgResponses = cat(3, avgResponses, Z.triggeredResponseAnalysis.epochAvgTriggeredIntensities.(epoch));
        end
        avgResponse = cat(4, avgResponse, avgResponses);
    end
    
    
    
    avgResponse = permute(avgResponse, [2 3 1 4]);
    minPRoi = indsToSortResponse(1);
%     avgResponse = avgResponse(:, :, indsToSortResponse, :);
    
    % barsOff =Z.stimulus.params(end).duration/60;
    barsOff = 1;
    xVals = -stepsBack:size(avgResponse, 1)-stepsBack-1;
    tVals = xVals./(fsAligned);
    firstInd = find(tVals>=0, 1, 'first');
    lastInd = find(tVals<=barsOff, 1, 'last');
    barResponse = avgResponse(firstInd:lastInd, :, :, :);
    % meanBarResp = squeeze(nanmean(barResponse, 2));
    avgResponse = barResponse;
    
    
    % meanPhaseResp = nanmean(meanBarResp);
    numberOfRois = length(responsiveROIs);
    numberOfPhases = length(phase);
    %The 2*line_width-1 part has to do with the size xcov outputs
    % crossCovariances = zeros(numberOfRois, 2*numberOfPhases-1);
    
    shift = 0;
    for j = 1:numberOfRois
        % Compute the circular cross correlation (ish)
        timeCorrelations = [];
%         for epochSet = 1:size(avgResponse, 4)
%             timeCorrelations(:,epochSet) = cconv(reshape(avgResponse(:, :, 1, epochSet), 1, []), fliplr(reshape(avgResponse(:, :, j, epochSet), 1, [])), numel(avgResponse(:, :, 1, 1)));
            for phaseNum = 1:numberOfPhases
                covVal(:, :, phaseNum) = cov(reshape(avgResponse(:, :, minPRoi, :), 1, []), reshape(circshift(avgResponse(:, :, j, :), phaseNum, 2), 1, []));
            end
            [~, shift(j)] = max(covVal(1, 2, :)); 
%         end
%         timeCorrelations = cconv(reshape(avgResponse(:, :, 1), 1, []), fliplr(reshape(avgResponse(:, :, j), 1, [])), numel(avgResponse(:, :, 1)));
%         timeCovariances = cov([avgResponse(:, :, 1),avgResponse(:, :, j)]);
%         validCorr = size(avgResponse, 1):size(avgResponse, 1):length(timeCorrelations);
%         [~, maxCorr] = max(timeCorrelations(validCorr));
%         timeCovariancesOfInterest = timeCovariances(1:end/2, end/2+1:end);
%         [~, indMaxAlign] = max(timeCovariancesOfInterest(:));
%         [phaseBest, phaseNew] = ind2sub(size(timeCovariancesOfInterest), indMaxAlign);
%         shift(j) = phaseBest - phaseNew;
%         shift(j) = validCorr(maxCorr)/size(avgResponse, 1);
    end
    
    phaseByEpoch = squeeze(mean(avgResponse(:, :, minPRoi, :), 1));
    [~, maxInd] = max(phaseByEpoch(:));
    [phaseMax, ~] = ind2sub(size(phaseByEpoch), maxInd);
    
    phaseDesired = round(numberOfPhases/2)-phaseMax;
    shift = phaseDesired-shift;
    
    tp_plotBarPairROISummary(Z, Z.triggeredResponseAnalysis.epochAvgTriggeredIntensities, plottingEpochs, barToCenter, rightCheck, shift);
else
    fprintf('No light edge responsive regressive ROIs found!\n');
end

% for i = 1:length(responsiveROIs)
%     ind = responsiveROIs(i);
%     Z.ROI.roiIndsOfInterest(ind) = true;
%     Z.ROI.roiIndsOfInterest([1:ind-1 ind+1:end]) = false;
%     Z = triggeredResponseAnalysis(Z, 'Bar Pair Plots!');
%     
%     tp_plotBarPairROISummary(Z, Z.triggeredResponseAnalysis.triggeredIntensities, plottingEpochs, barToCenter, rightCheck, []);
%     text(-0.4, 3, flyEye);
% end

%% Regressive side
Z.params.epochsForSelectivity = epochsForSelectivity(end:-1:1);
Z.params.combinationMethod = 'any';
[Z.ROI.roiIndsOfInterest, pValsSum] = extractROIsBySelectivity(Z);

pValsSum(~Z.ROI.roiIndsOfInterest) = max(pValsSum);
[~, ind] = min(pValsSum);
Z.ROI.roiIndsOfInterest([1:ind-1 ind+1:end]) = false;
Z = triggeredResponseAnalysis(Z, 'Bar Pair Plots!');


regPPlusPref = intersect(regPos, plusEpochs, 'stable');
regPPlusNull = intersect(progPos, plusEpochs, 'stable');
regPMinusPref = intersect(regPos, minusEpochs, 'stable');
regPMinusNull = intersect(progPos, minusEpochs, 'stable');
% It turns out we're only plotting preferred direction when plotting many
% phases, but experience would suggest that the 'preferred' direction
% switches
if true;%length(phase)==1
    regNPlusPref = intersect(regNeg, plusEpochs, 'stable');
    regNPlusNull = intersect(progNeg, plusEpochs, 'stable');
    regNMinusPref = intersect(regNeg, minusEpochs, 'stable');
    regNMinusNull = intersect(progNeg, minusEpochs, 'stable');
else
    regNPlusPref = intersect(progNeg, plusEpochs, 'stable');
    regNPlusNull = intersect(regNeg, plusEpochs, 'stable');
    regNMinusPref = intersect(progNeg, minusEpochs, 'stable');
    regNMinusNull = intersect(regNeg, minusEpochs, 'stable');
end

plottingEpochs.PPlusPref = regPPlusPref;
plottingEpochs.PMinusPref = regPMinusPref;
plottingEpochs.NPlusPref = regNPlusPref;
plottingEpochs.NMinusPref = regNMinusPref;
plottingEpochs.PPlusNull = regPPlusNull;
plottingEpochs.PMinusNull = regPMinusNull;
plottingEpochs.NPlusNull = regNPlusNull;
plottingEpochs.NMinusNull = regNMinusNull;

Z.params.epochsForSelectivity = epochsForSelectivity(end:-1:1);
Z.params.combinationMethod = 'any';
[roiIndsOfInterest, pValsSum] = extractROIsBySelectivity(Z);
numROIsOfInterest = sum(roiIndsOfInterest);
if numROIsOfInterest < numROIs
    numROIsReg = numROIsOfInterest;
else
    numROIsReg = numROIs;
end

% Max out all noninteresting ROIs
Z.ROI.roiIndsOfInterest = roiIndsOfInterest;
pValsSum(~roiIndsOfInterest) = max(pValsSum);
rightCheck = ~rightCheck;



responsiveROIs = ~cellfun('isempty', strfind(Z.ROI.typeFlagName, 'Dark')) & roiIndsOfInterest;

% [sortPvals, sortInd] = sort(darkPvalsSum);
responsiveROIs =  responsiveROIs & pValsSum'<0.01;
responsiveROIs = find(responsiveROIs);
pValsSumResponsive = pValsSum(responsiveROIs);
[~, indSort] = sort(pValsSumResponsive);
% Keep only the 10 best ones (if there are 10, it won't error if there are
% fewer)
responsiveROIs(indSort(10:end)) = [];

% responsiveROIs = responsiveROIs;
if any(responsiveROIs)
    pValsForResponsive = pValsSum(responsiveROIs);
    [~, indsToSortResponse] = sort(pValsForResponsive);
%     darkResponsiveROIs = find(darkResponsiveROIs);
    Z.ROI.roiIndsOfInterest = responsiveROIs;
    Z = triggeredResponseAnalysis(Z, 'Bar Pair Plots!');
    fsAligned = Z.params.fs*Z.triggeredResponseAnalysis.fsFactor;
    stepsBack = Z.triggeredResponseAnalysis.stepsBack;
    
    avgResponses  = [];
    avgResponse = [];
    epochs = [plottingEpochs.PPlusPref' plottingEpochs.PMinusPref' plottingEpochs.PPlusNull' plottingEpochs.PMinusNull'];
    for epochSet = epochs
        avgResponses = [];
        for i = 1:length(epochSet)
            epoch = ['epoch_' num2str(epochSet(i))];
            avgResponses = cat(3, avgResponses, Z.triggeredResponseAnalysis.epochAvgTriggeredIntensities.(epoch));
        end
        avgResponse = cat(4, avgResponse, avgResponses);
    end
    
    
    
    avgResponse = permute(avgResponse, [2 3 1 4]);
    minPRoi = indsToSortResponse(1);
%     avgResponse = avgResponse(:, :, indsToSortResponse, :);
    
    % barsOff =Z.stimulus.params(end).duration/60;
    barsOff = 1;
    xVals = -stepsBack:size(avgResponse, 1)-stepsBack-1;
    tVals = xVals./(fsAligned);
    firstInd = find(tVals>=0, 1, 'first');
    lastInd = find(tVals<=barsOff, 1, 'last');
    barResponse = avgResponse(firstInd:lastInd, :, :, :);
    % meanBarResp = squeeze(nanmean(barResponse, 2));
    avgResponse = barResponse;
    
    
    % meanPhaseResp = nanmean(meanBarResp);
    numberOfRois = length(responsiveROIs);
    numberOfPhases = length(phase);
    %The 2*line_width-1 part has to do with the size xcov outputs
    % crossCovariances = zeros(numberOfRois, 2*numberOfPhases-1);
    
    shift = 0;
    for j = 1:numberOfRois
        % Compute the circular cross correlation (ish)
        timeCorrelations = [];
%         for epochSet = 1:size(avgResponse, 4)
%             timeCorrelations(:,epochSet) = cconv(reshape(avgResponse(:, :, 1, epochSet), 1, []), fliplr(reshape(avgResponse(:, :, j, epochSet), 1, [])), numel(avgResponse(:, :, 1, 1)));
            for phaseNum = 1:numberOfPhases
                covVal(:, :, phaseNum) = cov(reshape(avgResponse(:, :, minPRoi, :), 1, []), reshape(circshift(avgResponse(:, :, j, :), phaseNum, 2), 1, []));
            end
            [~, shift(j)] = max(covVal(1, 2, :)); 
%         end
%         timeCorrelations = cconv(reshape(avgResponse(:, :, 1), 1, []), fliplr(reshape(avgResponse(:, :, j), 1, [])), numel(avgResponse(:, :, 1)));
%         timeCovariances = cov([avgResponse(:, :, 1),avgResponse(:, :, j)]);
%         validCorr = size(avgResponse, 1):size(avgResponse, 1):length(timeCorrelations);
%         [~, maxCorr] = max(timeCorrelations(validCorr));
%         timeCovariancesOfInterest = timeCovariances(1:end/2, end/2+1:end);
%         [~, indMaxAlign] = max(timeCovariancesOfInterest(:));
%         [phaseBest, phaseNew] = ind2sub(size(timeCovariancesOfInterest), indMaxAlign);
%         shift(j) = phaseBest - phaseNew;
%         shift(j) = validCorr(maxCorr)/size(avgResponse, 1);
    end
    
    phaseByEpoch = squeeze(mean(avgResponse(:, :, minPRoi, :), 1));
    [~, maxInd] = max(phaseByEpoch(:));
    [phaseMax, ~] = ind2sub(size(phaseByEpoch), maxInd);
    
    phaseDesired = round(numberOfPhases/2)-phaseMax;
    shift = phaseDesired-shift;
    
    tp_plotBarPairROISummary(Z, Z.triggeredResponseAnalysis.epochAvgTriggeredIntensities, plottingEpochs, barToCenter, rightCheck, shift);
else
    fprintf('No dark edge responsive regressive ROIs found!\n' )
end

for i = 1:length(responsiveROIs)
    ind = responsiveROIs(i);
    Z.ROI.roiIndsOfInterest=ind;
%     Z.ROI.roiIndsOfInterest([1:ind-1 ind+1:end]) = false;
    Z = triggeredResponseAnalysis(Z, 'Bar Pair Plots!');
    
    tp_plotBarPairROISummary(Z, Z.triggeredResponseAnalysis.triggeredIntensities, plottingEpochs, barToCenter, rightCheck, []);
    text(-0.4, 3, flyEye);
end


%% Light Regressive!
responsiveROIs = ~cellfun('isempty', strfind(Z.ROI.typeFlagName, 'Light')) & roiIndsOfInterest;
% [sortPvals, sortInd] = sort(darkPvalsSum);
responsiveROIs =  responsiveROIs & pValsSum'<0.01;
responsiveROIs = find(responsiveROIs);
pValsSumResponsive = pValsSum(responsiveROIs);
[~, indSort] = sort(pValsSumResponsive);
% Keep only the 10 best ones (if there are 10, it won't error if there are
% fewer)
responsiveROIs(indSort(10:end)) = [];



% responsiveROIs = responsiveROIs;
if any(responsiveROIs)
    pValsForResponsive = pValsSum(responsiveROIs);
    [~, indsToSortResponse] = sort(pValsForResponsive);
%     darkResponsiveROIs = find(darkResponsiveROIs);
    Z.ROI.roiIndsOfInterest = responsiveROIs;
    Z = triggeredResponseAnalysis(Z, 'Bar Pair Plots!');
    fsAligned = Z.params.fs*Z.triggeredResponseAnalysis.fsFactor;
    stepsBack = Z.triggeredResponseAnalysis.stepsBack;
    
    avgResponses  = [];
    avgResponse = [];
    epochs = [plottingEpochs.PPlusPref' plottingEpochs.PMinusPref' plottingEpochs.PPlusNull' plottingEpochs.PMinusNull'];
    for epochSet = epochs
        avgResponses = [];
        for i = 1:length(epochSet)
            epoch = ['epoch_' num2str(epochSet(i))];
            avgResponses = cat(3, avgResponses, Z.triggeredResponseAnalysis.epochAvgTriggeredIntensities.(epoch));
        end
        avgResponse = cat(4, avgResponse, avgResponses);
    end
    
    
    
    avgResponse = permute(avgResponse, [2 3 1 4]);
    minPRoi = indsToSortResponse(1);
%     avgResponse = avgResponse(:, :, indsToSortResponse, :);
    
    % barsOff =Z.stimulus.params(end).duration/60;
    barsOff = 1;
    xVals = -stepsBack:size(avgResponse, 1)-stepsBack-1;
    tVals = xVals./(fsAligned);
    firstInd = find(tVals>=0, 1, 'first');
    lastInd = find(tVals<=barsOff, 1, 'last');
    barResponse = avgResponse(firstInd:lastInd, :, :, :);
    % meanBarResp = squeeze(nanmean(barResponse, 2));
    avgResponse = barResponse;
    
    
    % meanPhaseResp = nanmean(meanBarResp);
    numberOfRois = length(responsiveROIs);
    numberOfPhases = length(phase);
    %The 2*line_width-1 part has to do with the size xcov outputs
    % crossCovariances = zeros(numberOfRois, 2*numberOfPhases-1);
    
    shift = 0;
    for j = 1:numberOfRois
        % Compute the circular cross correlation (ish)
        timeCorrelations = [];
%         for epochSet = 1:size(avgResponse, 4)
%             timeCorrelations(:,epochSet) = cconv(reshape(avgResponse(:, :, 1, epochSet), 1, []), fliplr(reshape(avgResponse(:, :, j, epochSet), 1, [])), numel(avgResponse(:, :, 1, 1)));
            for phaseNum = 1:numberOfPhases
                covVal(:, :, phaseNum) = cov(reshape(avgResponse(:, :, minPRoi, :), 1, []), reshape(circshift(avgResponse(:, :, j, :), phaseNum, 2), 1, []));
            end
            [~, shift(j)] = max(covVal(1, 2, :)); 
%         end
%         timeCorrelations = cconv(reshape(avgResponse(:, :, 1), 1, []), fliplr(reshape(avgResponse(:, :, j), 1, [])), numel(avgResponse(:, :, 1)));
%         timeCovariances = cov([avgResponse(:, :, 1),avgResponse(:, :, j)]);
%         validCorr = size(avgResponse, 1):size(avgResponse, 1):length(timeCorrelations);
%         [~, maxCorr] = max(timeCorrelations(validCorr));
%         timeCovariancesOfInterest = timeCovariances(1:end/2, end/2+1:end);
%         [~, indMaxAlign] = max(timeCovariancesOfInterest(:));
%         [phaseBest, phaseNew] = ind2sub(size(timeCovariancesOfInterest), indMaxAlign);
%         shift(j) = phaseBest - phaseNew;
%         shift(j) = validCorr(maxCorr)/size(avgResponse, 1);
    end
    
    phaseByEpoch = squeeze(mean(avgResponse(:, :, minPRoi, :), 1));
    [~, maxInd] = max(phaseByEpoch(:));
    [phaseMax, ~] = ind2sub(size(phaseByEpoch), maxInd);
    
    phaseDesired = round(numberOfPhases/2)-phaseMax;
    shift = phaseDesired-shift;
    
    tp_plotBarPairROISummary(Z, Z.triggeredResponseAnalysis.epochAvgTriggeredIntensities, plottingEpochs, barToCenter, rightCheck, shift);
else
    fprintf('No light edge responsive regressive ROIs found!\n');
end

% for i = 1:length(responsiveROIs)
%     ind = responsiveROIs(i);
%     Z.ROI.roiIndsOfInterest(ind) = true;
%     Z.ROI.roiIndsOfInterest([1:ind-1 ind+1:end]) = false;
%     Z = triggeredResponseAnalysis(Z, 'Bar Pair Plots!');
%     
%     tp_plotBarPairROISummary(Z, Z.triggeredResponseAnalysis.triggeredIntensities, plottingEpochs, barToCenter, rightCheck, []);
%     text(-0.4, 3, flyEye);
% end