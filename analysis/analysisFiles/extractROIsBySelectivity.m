function [roiIndsOfInterest, pValsSum, valueMatrix] = extractROIsBySelectivity(Z)
% Implement size, brightness


% This should be a 2xM input where the first row epoch must be
% significantly different and significantly greater than the second row
% epoch
pValsSum = [];
combinationMethod = 'any';
epochFractionCompare = 0;
plotDPrimeVsResponse = false;
dirSelLevel = 0.5;
pVals = [];

roiAvgIntensityFilteredNormalized = Z.filtered.roi_avg_intensity_filtered_normalized;
if ~isfield(Z.params, 'epochsForSelectivity')
    warning('No epochsForSelectivity varargin, so all ROIs are being kept');
    roiIndsOfInterest = 1:size(roiAvgIntensityFilteredNormalized, 2);
    pValsSum = [];
    return
end

inputsRequired = {'combinationMethod', 'epochsForSelectivity','epochFractionCompare','fs'};
loadFlexibleInputs(Z, inputsRequired);


triggerInds = Z.params.trigger_inds;
roiAvgIntensityFilteredNormalized = Z.filtered.roi_avg_intensity_filtered_normalized;

% % Receive input variables
% for ii = 1:2:length(varargin)
%     %Remember to append all new varargins so old ones don't overwrite
%     %them!
%     eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
% end

if ~isnumeric(epochsForSelectivity)
    if iscell(epochsForSelectivity)
        epochNum = [];
        for i = 1:size(epochsForSelectivity, 1)% We should only compare two at a time!
            for j = 1:size(epochsForSelectivity, 2) 
                epochIndex = find(strcmp({Z.stimulus.params.epochName}, epochsForSelectivity{i, j}));
                if ~isempty(epochIndex)
                    epochNum(i, j) = epochIndex(1);
                end
            end
        end
        epochsForSelectivity = epochNum;
    elseif ischar(epochsForSelectivity)
        epochsForSelectivity = find(strcmp(Z.stimulus.params.epochName, epochsForSelectivity));
    end
end

if isempty(epochsForSelectivity)
    warning('No ROIs extracted by epoch because the epochsForSelectivity couldn''t be found in the epoch names');
    roiIndsOfInterest = logical(ones(1, size(Z.filtered.roi_avg_intensity_filtered_normalized, 2)));
    pValsSum = zeros(size(roiIndsOfInterest));
    return;
end

% if size(epochsForSelectivity, 1) == 3
%     methodForSelectivity = 
% end
    
roiIndsOfInterestTemp = zeros(size(epochsForSelectivity, 2), size(roiAvgIntensityFilteredNormalized, 2));
% ROImeans = mean(roiAvgIntensityFilteredNormalized);
ROIstds = std(roiAvgIntensityFilteredNormalized);

indInsert = 1;

for i = 1:size(epochsForSelectivity, 2)
    selectDataBounds = triggerInds.(['epoch_' num2str(epochsForSelectivity(1, i))]).bounds;
    compareDataBounds = triggerInds.(['epoch_' num2str(epochsForSelectivity(2, i))]).bounds;
    
    % Here we assume that selectDataBounds and compareDataBounds have
    % equivalent gray interleaves right before their presentation that we
    % can compare against
%     subplotsNeeded = min([size(selectDataBounds, 2), size(compareDataBounds, 2)]);
    if plotDPrimeVsResponse
        if ~isempty(findobj('type','figure'))
            currFigure = gcf;
        else
            currFigure = [];
        end
        MakeFigure;
        hold on
    end
    roiIndsOfInterestDoubleTemp = [];
    for ind = 1:min([size(selectDataBounds, 2), size(compareDataBounds, 2)]);
        
        
        diffSelectFromBase = findDiffFromBase(roiAvgIntensityFilteredNormalized, selectDataBounds(:, ind), triggerInds, epochFractionCompare);
        diffCompareFromBase = findDiffFromBase(roiAvgIntensityFilteredNormalized, compareDataBounds(:,ind), triggerInds, epochFractionCompare);
        
%         if sum(isnan(diffSelectFromBase(:, 1)))>0.2*size(diffSelectFromBase, 1)
%             continue;
%         elseif any(isnan(diffSelectFromBase(:, 1)))
%             tempSB = diffSelectFromBase;
%             timeVals = 1:size(diffSelectFromBase, 2);
%             timeValsKnown = timeVals(~isnan(tempSB(:, 1)));
%             tempSB(isnan(tempSB(:, 1)), :) = [];
%             diffSelectFromBase = interp1(timeValsKnown, tempSB, timeVals);
%             diffSelectFromBase(isnan(diffSelectFromBase(:, 1)), :) = [];
%         end

        meanValsSB = nanmean(diffSelectFromBase);
        meanValsCB = nanmean(diffCompareFromBase);
        
%         hertzOfInt = 0;
%         lengthTime = size(diffSelectFromBase, 1);
%         f = fs*(0:(lengthTime/2))/lengthTime;
%         [~, ind] = min(abs(f-hertzOfInt));
%         
%         fftDiffSelectFromBase = fft(diffSelectFromBase);
%         p2 = abs(fftDiffSelectFromBase/lengthTime);
%         p1 = p2(1:round(lengthTime/2)+1, :);
%         p1(2:end-1, :) = 2*p1(2:end-1, :);
%         hertzOfIntPowerSFB = p1(ind, :);
%         
%         
%         
%         lengthTime = size(diffSelectFromBase, 1);
%         f = fs*(0:(lengthTime/2))/lengthTime;
%         [~, ind] = min(abs(f-hertzOfInt));
%         
%         fftDiffCompareFromBase = fft(diffCompareFromBase);
%         p2 = abs(fftDiffCompareFromBase/lengthTime);
%         p1 = p2(1:round(lengthTime/2)+1, :);
%         p1(2:end-1, :) = 2*p1(2:end-1, :);
%         hertzOfIntPowerCFB = p1(ind, :);
%         
%         diffHzPower = hertzOfIntPowerSFB-hertzOfIntPowerCFB;
%         indsByFFT = diffHzPower>3*std(diffHzPower);
%         
%         r = (hertzOfIntPowerSFB/max(hertzOfIntPowerSFB)).*(hertzOfIntPowerSFB-hertzOfIntPowerCFB)./(hertzOfIntPowerSFB+hertzOfIntPowerCFB);
%         
%         indsByFFT = r>0.3;
        
%         diffSelectFromBase(abs(diffSelectFromBase)<1*stdValsSBrep) = NaN;
%         diffCompareFromBase(abs(diffCompareFromBase)<1*stdValsCBrep) = NaN;
        
%         diffCompareFromBase = exp(diffCompareFromBase);
%         diffSelectFromBase = exp(diffSelectFromBase);
        
        alpha = .01;
        [roiIndsOfInterestDoubleTemp(indInsert, :), pVals(indInsert, :)] = ttest2(diffSelectFromBase, diffCompareFromBase, 'tail', 'right', 'alpha', alpha/size(roiAvgIntensityFilteredNormalized, 2), 'Vartype', 'unequal');
%             roiIndsOfInterestDoubleTemp(indInsert, :) = indsByFFT;
%         [~, pVals] = ttest2(diffSelectFromBase, diffCompareFromBase, 'tail', 'right', 'alpha', alpha);
%         pVals(isnan(pVals)) = max(pVals);
%         [sortPVals, sortIndPVals] = sort(pVals);
%         k = 1:length(sortPVals);
%         sigTest = sortPVals<=(k*alpha/size(roiAvgIntensityFilteredNormalized, 2));
%         roiIndsOfInterestTemp(indInsert, sortIndPVals(sigTest)) = true;
        minCBResp = min([meanValsCB meanValsSB]);
        dirSel = ((meanValsSB-minCBResp) - (meanValsCB - minCBResp))./(meanValsSB -minCBResp + meanValsCB - minCBResp);
        roiIndsOfInterestDoubleTemp(indInsert, isnan(roiIndsOfInterestDoubleTemp(indInsert, :))) = 0;
%         plot(dprime(logical(roiIndsOfInterestDoubleTemp(indInsert, :))));
        tempTemp(indInsert, :) = roiIndsOfInterestDoubleTemp(indInsert, :);
        tempSB(indInsert, :) = meanValsSB;
        tempCB(indInsert, :) = meanValsCB;
        dprimeTemp(indInsert, :) = dirSel;
        roiIndsOfInterestDoubleTemp(indInsert, :) = roiIndsOfInterestDoubleTemp(indInsert, :) & dirSel > dirSelLevel;
        indInsert = indInsert+1;
    end
    
    if plotDPrimeVsResponse
        sigROIsBothTimes = find(all(tempTemp));
        sigROIsFirstTime = find(xor(tempTemp(1, :), all(tempTemp)));
        sigROIsSecondTime = find(xor(tempTemp(2, :), all(tempTemp)));
        plot(dprimeTemp(:, sigROIsBothTimes), tempSB(:, sigROIsBothTimes), 'Color', [0 0 0]);
        plot(dprimeTemp([1 1], sigROIsBothTimes), [tempSB(1, sigROIsBothTimes); tempCB(1, sigROIsBothTimes)], '--b');
        scatter(dprimeTemp(1, sigROIsBothTimes), tempSB(1, sigROIsBothTimes), 100, 'MarkerFaceColor', [0 0 0]);
        scatter(dprimeTemp(1, sigROIsFirstTime), tempSB(1, sigROIsFirstTime), 80, 'MarkerFaceColor', [1 0 0]);
        scatter(dprimeTemp(2, sigROIsSecondTime), tempSB(2, sigROIsSecondTime), 80, 'MarkerFaceColor', [0 0 1]);
        
        scatter(dprimeTemp(:), tempSB(:),20, 'MarkerFaceColor', [1 1 1]);
        
        
        title(sprintf('%s vs. %s, Both Presentations - Df/f from previous %d%% of still epoch', Z.params.epochsForSelectivity{1}, Z.params.epochsForSelectivity{2},epochFractionCompare*100));
        xlabel('dprime');
        ylabel('mean motion response from still');
        %     end
        hold off
        if ~isempty(currFigure)
            figure(currFigure);
        end
    end
    indInsert = 1;
    if ~isempty(roiIndsOfInterestDoubleTemp)
        roiIndsOfInterestTemp(i, :) = any(roiIndsOfInterestDoubleTemp, 1);
    end
end

switch combinationMethod
    case 'any'
        roiIndsOfInterest = any(roiIndsOfInterestTemp, 1);
    case 'all'
        roiIndsOfInterest = all(roiIndsOfInterestTemp, 1);
    otherwise
        roiIndsOfInterest = any(roiIndsOfInterestTemp, 1);
end
% This is a hacky way of finding the best ROI by looking at the minimum of
% these sums...
pValsSum = sum(pVals, 1);

% if isfield(Z.params, 'roiType') && isfield(Z.ROI, 'typeFlag')
%     epochNames = {Z.stimulus.params.epochName};
%     epochNamesForSelectivity = epochNames(epochsForSelectivity(1, :));
%     epochNamesCompare = epochNames(epochsForSelectivity(2, :));
%     splitNames = cellfun(@(epochN) strsplit(epochN), epochNamesForSelectivity, 'UniformOutput', false);
%     splitNamesCompare = cellfun(@(epochN) strsplit(epochN), epochNamesCompare, 'UniformOutput', false);
%     for j = 1:length(splitNames)
%         splitNamesActual{j} = splitNames{j}(~ismember(splitNames{j}, splitNamesCompare{j}));
%     end
%     splitNames = [splitNamesActual{:}];
%     splitFlagNames = cellfun(@(epochN) strsplit(epochN), Z.ROI.typeFlagName, 'UniformOutput', false);
%     roiIndsOfInterest = cellfun(@(splitName) any(ismember(splitNames, splitName)), splitFlagNames);
% %     edgeTypeSelection = ~cellfun('isempty', strfind(Z.ROI.typeFlagName, Z.params.roiType));
% %     roiIndsOfInterest = edgeTypeSelection;% roiIndsOfInterest & edgeTypeSelection';
% end

roiIndsOfInterest = roiIndsOfInterest(:);

end

function diffPointsFromBase = findDiffFromBase(data, dataBounds, triggerInds, epochFractionCompare)


firstInd = ceil(dataBounds(1, end));
indBefore = firstInd - 1;
epochFields = fields(triggerInds);
epochFieldIndBefore = cellfun(@(epochField) any(triggerInds.(epochField).bounds(1, :)<indBefore & triggerInds.(epochField).bounds(2, :)>indBefore), epochFields);
epochFieldBefore = epochFields(epochFieldIndBefore);
if isempty(epochFieldBefore) || length(epochFieldBefore)>1
    error('Something''s gone wrong with finding the bounds of the epochs!')
else
    epochFieldBefore = epochFieldBefore{1};
end

 % This is the fractional portion of the epoch closest to the current epoch whose average value we'll compare to
epochCompareBeforeLength = triggerInds.(epochFieldBefore).stim_length*epochFractionCompare;

dataPointsBeforePresentation = data(floor(firstInd-epochCompareBeforeLength):floor(firstInd-1), :);



dataPoints = data(ceil(dataBounds(1, end)):floor(dataBounds(2, end)), :);
if ~isempty(dataPointsBeforePresentation)
    averageBeforePresentation = nanmean(dataPointsBeforePresentation);
else
    averageBeforePresentation = zeros(1, size(dataPoints, 2));
end

diffPointsFromBase = dataPoints - repmat(averageBeforePresentation, [size(dataPoints, 1), 1]);

end

