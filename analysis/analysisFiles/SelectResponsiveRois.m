function [roiResponsesOut,roiMaskOut, roiIndsOfInterest, pValsSum, valueStruct] = SelectResponsiveRois(roiResponses,roiMaskInitial,epochStartTimes,epochDurations, epochsForSelectivity, params, interleaveEpoch, varargin)
% Implement size, brightness


% This should be a 2xM input where the first row epoch must be
% significantly different and significantly greater than the second row
% epoch
pValsSum = [];
epochFractionCompare = 0;
plotDPrimeVsResponse = false;
dsiThresh = 0.4;
pVals = [];
esiThresh = 0.4;
primCorrIndThresh = 0.4;
pValThresh = 0.05;
overallCorrelationThresh = 0.4;
esiDsiMax = false; % Checks whether edge ESI/DSI is calculated by maxing light left/light right, left light/left dark, etc. or by mean-ing them
useNanmean = true;
valueStruct = struct('dirSel', [],'dprimish',[],'meanValsSB',[],'pVals',[],'diffHzPower',[],'meanValsCB',[],'roiSizes',[],'primaryCorrelations',[],'secondaryCorrelations',[],'edgeSelectivityIndex',[], 'edgeDsi', [], 'edgeEsi', [], 'juyueCorr', [], 'maxMeansLoc', [], 'maxPrimEdgeResp', [], 'maxSecEdgeResp', []);


changeableVarargin = {'epochFractionCompare', 'dsiThresh', 'esiThresh', 'primCorrIndThresh', 'pValThresh','overallCorrelationThresh','esiDsiMax', 'useNanmean'};

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

roiIndsOfInterest = false(size(roiResponses, 2),1);

roiIndsOfInterestTemp = zeros(size(epochNumsForSelectivity, 2), size(roiResponses, 2));
% ROImeans = mean(roiAvgIntensityFilteredNormalized);
ROIstds = std(roiResponses);

indInsert = 1;
correlationsDone = struct();
primRespDone = struct();

for i = 1:size(epochNumsForSelectivity, 1)
    
    if ~isempty(esiThreshCell)
        esiThresh = esiThreshCell{i};
    end
    if ~isempty(dsiThreshCell)
        dsiThresh = dsiThreshCell{i};
    end
    
    if epochsForSelectivity{i, 1}(1) ~= '~'
        
        roiIndsOfInterestDoubleTemp = [];
        
        
        selectResponses = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,epochNumsForSelectivity(i, 1));
        compareResponses = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,epochNumsForSelectivity(i, 2));
        
        concatSelectFromBase = cat(1, selectResponses{:});
        concatCompareFromBase = cat(1, compareResponses{:});
        
        selectAvgPerPres = cellfun(@(roiEpochResponses) nanmean(roiEpochResponses), selectResponses, 'UniformOutput', false);
        selectAvgPerPres = cat(1, selectAvgPerPres{:});
        compareAvgPerPres = cellfun(@(roiEpochResponses) nanmean(roiEpochResponses), compareResponses, 'UniformOutput', false);
        compareAvgPerPres = cat(1, compareAvgPerPres{:});
        
        meanValsSB = nanmean(concatSelectFromBase);
        meanValsCB = nanmean(concatCompareFromBase);
        
        dprimish = (meanValsSB-meanValsCB)./sqrt(nanmean((selectAvgPerPres-repmat(meanValsSB, [size(selectAvgPerPres, 1), 1])).^2) + nanmean((compareAvgPerPres-repmat(meanValsCB, [size(compareAvgPerPres, 1), 1])).^2));
        
        if sum(isnan(concatSelectFromBase(:, 1)))>0.2*size(concatSelectFromBase, 1) || sum(isnan(concatCompareFromBase(:, 1)))>0.2*size(concatCompareFromBase, 1)
            roiResponsesOut{i, 1} = [];
            roiMaskOut{i, 1} = [];
            continue;
        elseif any(isnan(concatSelectFromBase(:, 1)))
            tempSB = concatSelectFromBase;
            timeVals = 1:size(concatSelectFromBase, 1);
            timeValsKnown = timeVals(~isnan(tempSB(:, 1)));
            tempSB(isnan(tempSB(:, 1)), :) = [];
            concatSelectFromBase = interp1(timeValsKnown, tempSB, timeVals);
            concatSelectFromBase(isnan(concatSelectFromBase(:, 1)), :) = [];
        end
        
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
        diffHzPower = logical(ones(size(dprimish)));
        %         indsByFFT = diffHzPower>3*std(diffHzPower);
        %
        %         r = (hertzOfIntPowerSFB/max(hertzOfIntPowerSFB)).*(hertzOfIntPowerSFB-hertzOfIntPowerCFB)./(hertzOfIntPowerSFB+hertzOfIntPowerCFB);
        %
        %         indsByFFT = r>0.3;
        
        %         diffSelectFromBase(abs(diffSelectFromBase)<1*stdValsSBrep) = NaN;
        %         diffCompareFromBase(abs(diffCompareFromBase)<1*stdValsCBrep) = NaN;
        
        %         diffCompareFromBase = exp(diffCompareFromBase);
        %         diffSelectFromBase = exp(diffSelectFromBase);
        
        if isinf(pValThresh)
            pValThresh = 0.9999*size(roiResponses, 2);
        end
        %         disp('pvalue threshold');
        %         disp(pValThresh/size(roiResponses, 2));
        %         disp('number ROIs');
        %         disp(size(roiResponses, 2));
        pValThreshCurr = pValThresh/size(roiResponses, 2);
        %         pValThresh = 2e-4;
        [roiIndsOfInterestTemp, pVals] = ttest2(concatSelectFromBase, concatCompareFromBase, 'tail', 'right', 'alpha', pValThreshCurr, 'Vartype', 'unequal');
        %             roiIndsOfInterestDoubleTemp(indInsert, :) = indsByFFT;
        %         [~, pVals] = ttest2(diffSelectFromBase, diffCompareFromBase, 'tail', 'right', 'alpha', alpha);
        %         pVals(isnan(pVals)) = max(pVals);
        %         [sortPVals, sortIndPVals] = sort(pVals);
        %         k = 1:length(sortPVals);
        %         sigTest = sortPVals<=(k*alpha/size(roiAvgIntensityFilteredNormalized, 2));
        %         roiIndsOfInterestTemp(indInsert, sortIndPVals(sigTest)) = true;
        meanValsCB(meanValsCB<0) = 0;
        meanValsSB(meanValsSB<0) = 0;
        minCBResp = min([meanValsCB meanValsSB]);
        dirSel = ((meanValsSB-minCBResp) - (meanValsCB - minCBResp))./(meanValsSB -minCBResp + meanValsCB - minCBResp);
        
        %         roiIndsOfInterestDoubleTemp(indInsert, isnan(roiIndsOfInterestDoubleTemp(indInsert, :))) = 0;
        %         plot(dprime(logical(roiIndsOfInterestDoubleTemp(indInsert, :))));
        %         tempTemp(indInsert, :) = roiIndsOfInterestDoubleTemp(indInsert, :);
        %         tempSB(indInsert, :) = meanValsSB;
        %         tempCB(indInsert, :) = meanValsCB;
        %         dprimeTemp(indInsert, :) = dirSel;
        %         roiIndsOfInterestDoubleTemp(indInsert, :) = roiIndsOfInterestDoubleTemp(indInsert, :) & dirSel > dirSelLevel;
        %         indInsert = indInsert+1;
        %     end
        
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
        %     indInsert = 1;
        %     if ~isempty(roiIndsOfInterestDoubleTemp)
        %         roiIndsOfInterestTemp(i, :) = any(roiIndsOfInterestDoubleTemp, 1);
        %     end
        
        
        
        %     dprimish = corrFirstToSecond(selectResponses);
        %     roiIndsOfInterest = dirSel>dirSelLevel & roiSizes>10;%& dprimish>1 ;
        %      roiIndsOfInterestTemp(isnan(roiIndsOfInterestTemp)) = 0;
        
        %      roiIndsOfInterest(isnan(roiIndsOfInterest)) = 0;
        roiIndsOfInterestTemp(isnan(roiIndsOfInterestTemp)) = 0;
        roiIndsOfInterest = logical(roiIndsOfInterestTemp);% & roiSizes>8 & roiSizes<40;
        
        %     roiIndsOfInterest = dirSel>dirSelLevel;
        %     roiIndsOfInterest(isnan(roiIndsOfInterest)) = 0;
        %     roiIndsOfInterest = logical(roiIndsOfInterest) & roiSizes>10 & roiSizes<40;
        
        if size(epochNumsForSelectivity,2 ) > 2 && (~isnan(epochNumsForSelectivity(i, 3)) || (isnan(epochNumsForSelectivity(i, 3)) && ~isempty(epochsForSelectivity{i, 3}) && epochsForSelectivity{i, 3}(1) == '-'))
            % This happens if we're doing edge distinctions (this will be the
            % assumption in this code)
            if epochsForSelectivity{i, 3}(1) == '-'
                epochNumsForSelectivity(i,3) =  ConvertEpochNameToIndex(params,epochsForSelectivity{i,3}(2:end));
                selectAgainstESI = true;
            else
                selectAgainstESI = false;
            end
            
            
            primaryResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,epochNumsForSelectivity(i, 3));
            secondaryResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,epochNumsForSelectivity(i, 4));
            
            edgeRespEpochs = 1:4;
            nonIncEdges = ~ismember(edgeRespEpochs, epochNumsForSelectivity(i, 3:4));
            otherEdges = edgeRespEpochs(nonIncEdges);
            
            if epochNumsForSelectivity(i, 3)>epochNumsForSelectivity(i, 3)
                otherEdges = otherEdges(end:-1:1);
            end
            
            prim2RespCell =  GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,otherEdges(1));
            sec2RespCell =  GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,otherEdges(2));
            
            % We're going to filter the responses to get rid of high frequency
            % noise
            % We're doing a multiple here because hopefully high frequency
            % noise is just always near the top of the dataRate... (kind of by
            % definition, no?)
            %         dataRate = varargin{[false strcmp(varargin, 'dataRate')]};
            %         highFrequency = 0.5*dataRate/2;
            %         highFreq = 2*highFrequency/dataRate;
            %         [z,p,k] = butter(2, highFreq, 'low');
            %         [sos, g] = zp2sos(z,p,k);
            %         warning('off','signal:filtfilt:ParseSOS')
            %         primaryResponsesCellFilt= cellfun(@(sig) filtfilt(sos,g,sig([end:-1:1 1:end end:-1:1], :)),primaryResponsesCell, 'UniformOutput', false) ;
            %         secondaryResponsesCellFilt= cellfun(@(sig) filtfilt(sos,g,sig([end:-1:1 1:end end:-1:1], :)),secondaryResponsesCell, 'UniformOutput', false) ;
            %         warning('on','signal:filtfilt:ParseSOS') ;
            %
            %         primaryResponsesCell = cellfun(@(sig) sig(end/3+1:2*end/3, :),primaryResponsesCellFilt, 'UniformOutput', false);
            %         secondaryResponsesCell = cellfun(@(sig) sig(end/3+1:2*end/3, :),secondaryResponsesCellFilt, 'UniformOutput', false);
            
            
            %         primaryResponsesCellCell= cellfun(@(sig) mat2cell(sig, size(sig, 1), ones(1, size(sig, 2) )),primaryResponsesCell, 'UniformOutput', false) ;
            %         secondaryResponsesCellCell= cellfun(@(sig) mat2cell(sig, size(sig, 1), ones(1, size(sig, 2) )),secondaryResponsesCell, 'UniformOutput', false) ;
            %
            %         warning('off','signal:filtfilt:ParseSOS')
            %         primaryResponsesCellFilt= cellfun(@(sigs) cellfun(@(sig) filtfilt(sos,g,sig([end:-1:1 1:end end:-1:1])), sigs, 'UniformOutput', false),primaryResponsesCellCell, 'UniformOutput', false) ;
            %         secondaryResponsesCellFilt= cellfun(@(sigs) cellfun(@(sig) filtfilt(sos,g,sig([end:-1:1 1:end end:-1:1])), sigs, 'UniformOutput', false),secondaryResponsesCellCell, 'UniformOutput', false);
            %         warning('on','signal:filtfilt:ParseSOS') ;
            %
            %         primaryResponsesCellMat = cellfun(@(sig) cat(2, sig{:}),primaryResponsesCellFilt, 'UniformOutput', false) ;
            %         secondaryResponsesCellMat = cellfun(@(sig) cat(2, sig{:}),secondaryResponsesCellFilt, 'UniformOutput', false) ;
            %
            %         primaryResponsesCell = cellfun(@(sig) sig(end/3+1:2*end/3, :),primaryResponsesCellMat, 'UniformOutput', false);
            %         secondaryResponsesCell = cellfun(@(sig) sig(end/3+1:2*end/3, :),secondaryResponsesCellMat, 'UniformOutput', false);
            
            
            % This is based on Holly's method for distinguishing T4 from T5
            primaryResponses = AverageResponses(primaryResponsesCell);
            secondaryResponses = AverageResponses(secondaryResponsesCell);
            %          primaryResponses = cat(1 ,primaryResponsesCell{:});
            %         secondaryResponses = cat(1, secondaryResponsesCell{:});
            prim2Resp = cat(1, prim2RespCell{:});
            sec2Resp = cat(1, sec2RespCell{:});
            
            %         primGtPeakCheck = bsxfun(@gt, primaryResponses, 0.2*max(primaryResponses));
            %         primRespGoodPeakiness = any(diff(primGtPeakCheck)==0 & primGtPeakCheck(1:end-1, :)==1);
            %
            %         secGtPeakCheck = bsxfun(@gt, secondaryResponses, 0.2*max(secondaryResponses));
            %         secRespGoodPeakiness = any(diff(secGtPeakCheck)==0 & secGtPeakCheck(1:end-1, :)==1);
            
            primaryResponsesHigh = zeros(1, size(primaryResponses, 2));
            secondaryResponsesHigh = zeros(1, size(secondaryResponses, 2));
            for roiResponse = 1:size(primaryResponses, 2)
                primaryResponsesHigh(roiResponse) = percentileThresh(primaryResponses(:, roiResponse), 0.99);
                secondaryResponsesHigh(roiResponse) = percentileThresh(secondaryResponses(:, roiResponse), 0.99);
                
                prim2RespHigh(roiResponse) = percentileThresh(prim2Resp(:, roiResponse), 0.99);
                sec2RespHigh(roiResponse) = percentileThresh(sec2Resp(:, roiResponse), 0.99);
            end
            edgeSelectivityIndex = (primaryResponsesHigh-secondaryResponsesHigh)./(primaryResponsesHigh+secondaryResponsesHigh);
            %         edgeSelectivityIndex(~primRespGoodPeakiness) = 0; % Set this to 0 so it's not selected
            edgeSelectivityIndexInt = edgeSelectivityIndex>0.5;
            
%             edgeDsi = max([(primaryResponsesHigh-prim2RespHigh)./(primaryResponsesHigh+prim2RespHigh); (secondaryResponsesHigh-sec2RespHigh)./(secondaryResponsesHigh+sec2RespHigh)]);
            
            %         juyueEdgeDsi =
            %         juyueESI
            
            % This one's based on Juyue's method
            primaryCorrelations = corrFirstToSecond(primaryResponsesCell);
            secondaryCorrelations = corrFirstToSecond(secondaryResponsesCell);
            % Assuming that all negative ones are crap...
            correlationCheck = primaryCorrelations>0.6 & secondaryCorrelations<0.3;
            
            if selectAgainstESI
                edgeCheck = abs(edgeSelectivityIndex)<esiThresh/2 & primaryCorrelations>primCorrIndThresh;
            else
                edgeCheck = edgeSelectivityIndex>esiThresh & primaryCorrelations>primCorrIndThresh;
            end
            % Get the interesting ROIs
            roiIndsOfInterest = roiIndsOfInterest & edgeCheck;
            %         roiIndsOfInt = roiIndsOfInt & edgeSelectivityIndexInt;
            valueStruct.primaryCorrelations = primaryCorrelations;
            valueStruct.secondaryCorrelations = secondaryCorrelations;
            valueStruct.edgeSelectivityIndex = edgeSelectivityIndex;
%             valueStruct.edgeDsi = edgeDsi;
        end
        
        % Some good stuff to have
        leftResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,6);
        rightResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,8);
        upResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,10);
        downResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,12);
        
        leftResponses = cat(1, leftResponsesCell{:});
        rightResponses = cat(1, rightResponsesCell{:});
        upResponses = cat(1, upResponsesCell{:});
        downResponses = cat(1, downResponsesCell{:});
        
        stillPreRightResponsesCell  = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,5);
        stillPreLeftResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,7);
        stillPreDownResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,9);
        stillPreUpResponsesCell= GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,11);
        
        primaryResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,1);
        secondaryResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,2);
        tertiaryResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,3);
        quaternaryResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,4);
        
        if useNanmean
            leftMean = nanmean(leftResponses);
            rightMean = nanmean(rightResponses);
            upMean = nanmean(upResponses);
            downMean = nanmean(downResponses);
        else
            leftMean = mean(leftResponses);
            rightMean = mean(rightResponses);
            upMean = mean(upResponses);
            downMean = mean(downResponses);
        end
        
        
        meanMatrix = [leftMean;rightMean;upMean;downMean];
        
        [~, maxMeansLoc] = max(meanMatrix);
        
        
        firstPres = cat(1, primaryResponsesCell{1}, secondaryResponsesCell{1}, tertiaryResponsesCell{1}, quaternaryResponsesCell{1},stillPreRightResponsesCell{1},rightResponsesCell{1}, stillPreLeftResponsesCell{1}, leftResponsesCell{1},stillPreDownResponsesCell{1}, downResponsesCell{1}, stillPreUpResponsesCell{1},upResponsesCell{1});
        secondPres = cat(1, primaryResponsesCell{2}, secondaryResponsesCell{2}, tertiaryResponsesCell{2}, quaternaryResponsesCell{2},stillPreRightResponsesCell{2},rightResponsesCell{2}, stillPreLeftResponsesCell{2}, leftResponsesCell{2},stillPreDownResponsesCell{2}, downResponsesCell{2}, stillPreUpResponsesCell{2},upResponsesCell{2});
        overallCorrelations = corrFirstToSecond({firstPres secondPres});
        
        
        maxMeanEpochCutoff = (maxMeansLoc==1 | maxMeansLoc==2);
        roiIndsOfInterest = roiIndsOfInterest & maxMeanEpochCutoff & overallCorrelations>overallCorrelationThresh;
        
        valueStruct.dirSel = dirSel;
        valueStruct.dprimish = dprimish;
        valueStruct.meanValsSB = meanValsSB;
        valueStruct.pVals = pVals;
        valueStruct.diffHzPower = diffHzPower;
        valueStruct.meanValsCB = meanValsCB;
        valueStruct.roiSizes = roiSizes;
        
    else
        primaryResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,epochNumsForSelectivity(i, 1));
        secondaryResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,epochNumsForSelectivity(i, 2));
        tertiaryResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,epochNumsForSelectivity(i, 3));
        quaternaryResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,epochNumsForSelectivity(i, 4));
        
        rightResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,6);
        leftResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,8);
        downResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,10);
        upResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,12);
        
        
        leftResponses = cat(1, leftResponsesCell{:});
        rightResponses = cat(1, rightResponsesCell{:});
        upResponses = cat(1, upResponsesCell{:});
        downResponses = cat(1, downResponsesCell{:});
        
        
        stillPreRightResponsesCell  = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,5);
        stillPreLeftResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,7);
        stillPreDownResponsesCell = GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,9);
        stillPreUpResponsesCell= GetRoiResponsesFromEpoch(roiResponses,epochStartTimes,epochDurations,11);

        if useNanmean
            leftMean = nanmean(leftResponses);
            rightMean = nanmean(rightResponses);
            upMean = nanmean(upResponses);
            downMean = nanmean(downResponses);
        else
            leftMean = mean(leftResponses);
            rightMean = mean(rightResponses);
            upMean = mean(upResponses);
            downMean = mean(downResponses);
        end
        
        meanMatrix = [leftMean;rightMean;upMean;downMean];
        
        [~, maxMeansLoc] = max(meanMatrix);
        
        maxMeanEpochCutoff = (maxMeansLoc==1 | maxMeansLoc==2);
        
        epochCode = num2str(epochNumsForSelectivity(i, :));
        epochCode(epochCode==' ') = '_';
        epochCode = ['code' epochCode];
        
        if isfield(correlationsDone, epochCode)
            overallCorrelations = correlationsDone.(epochCode);
        else
            firstPres = cat(1, primaryResponsesCell{1}, secondaryResponsesCell{1}, tertiaryResponsesCell{1}, quaternaryResponsesCell{1},stillPreRightResponsesCell{1},rightResponsesCell{1}, stillPreLeftResponsesCell{1}, leftResponsesCell{1},stillPreDownResponsesCell{1}, downResponsesCell{1}, stillPreUpResponsesCell{1},upResponsesCell{1});
            secondPres = cat(1, primaryResponsesCell{2}, secondaryResponsesCell{2}, tertiaryResponsesCell{2}, quaternaryResponsesCell{2},stillPreRightResponsesCell{2},rightResponsesCell{2}, stillPreLeftResponsesCell{2}, leftResponsesCell{2},stillPreDownResponsesCell{2}, downResponsesCell{2}, stillPreUpResponsesCell{2},upResponsesCell{2});
            overallCorrelations = corrFirstToSecond({firstPres secondPres});
            correlationsDone.(epochCode) = overallCorrelations;
        end
        
        primaryResponses = AverageResponses(primaryResponsesCell);
        secondaryResponses = AverageResponses(secondaryResponsesCell);
        tertiaryResponses = AverageResponses(tertiaryResponsesCell);
        quaternaryResponses = AverageResponses(quaternaryResponsesCell);
        
        if ~isfield(primRespDone, epochCode)
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
            primRespDone.(epochCode).primRespDiff = primRespHigh - primRespLow;
            primRespDone.(epochCode).secRespDiff = secRespHigh - secRespLow;
            primRespDone.(epochCode).tertRespDiff = tertRespHigh - tertRespLow;
            primRespDone.(epochCode).quatRespDiff = quatRespHigh - quatRespLow;
        end
        
        primRespDiff =primRespDone.(epochCode).primRespDiff;
        secRespDiff = primRespDone.(epochCode).secRespDiff;
        tertRespDiff =  primRespDone.(epochCode).tertRespDiff;
        quatRespDiff = primRespDone.(epochCode).quatRespDiff;
        
        if esiDsiMax
            edgeEsi = (max([primRespDiff; tertRespDiff])- max([secRespDiff; quatRespDiff]))./(max([primRespDiff; tertRespDiff]) + max([secRespDiff; quatRespDiff]));
            edgeDsi = (max([primRespDiff; secRespDiff])- max([tertRespDiff; quatRespDiff]))./(max([primRespDiff; secRespDiff])+ max([tertRespDiff; quatRespDiff]));
        else
            edgeEsi = (mean([primRespDiff; tertRespDiff])- mean([secRespDiff; quatRespDiff]))./(mean([primRespDiff; tertRespDiff]) + mean([secRespDiff; quatRespDiff]));
            edgeDsi = (mean([primRespDiff; secRespDiff])- mean([tertRespDiff; quatRespDiff]))./(mean([primRespDiff; secRespDiff])+ mean([tertRespDiff; quatRespDiff]));
            
            if length(primaryResponsesCell)==3
                primaryResponses = AverageResponses({primaryResponses primaryResponsesCell{3}});
                secondaryResponses = AverageResponses({secondaryResponses secondaryResponsesCell{3}});
                tertiaryResponses = AverageResponses({tertiaryResponses tertiaryResponsesCell{3}});
                quaternaryResponses = AverageResponses({quaternaryResponses quaternaryResponsesCell{3}});
            end
            primRespMax = max(primaryResponses);
            secRespMax = max(secondaryResponses);
            tertRespMax = max(tertiaryResponses);
            quatRespMax = max(quaternaryResponses);
            respsCat = [primRespMax; secRespMax; tertRespMax; quatRespMax];
            [mxResp, mxInd] = max(respsCat);
            mxNullInd = zeros(size(mxInd));
            mxNullInd(mxInd==1) = 2;
            mxNullInd(mxInd==2) = 1;
            mxNullInd(mxInd==3) = 4;
            mxNullInd(mxInd==4) = 3;
            mxNull = zeros(size(mxResp));
            for mxIter = 1:length(mxNull)
                mxNull(mxIter) = respsCat(mxNullInd(mxIter), mxIter);
            end
            
            edgeEsiLeong = (mxResp - mxNull)./(mxResp + mxNull);
        end
        
        if epochsForSelectivity{i, 1}(2) == '~' %hacky method of doing no edge selection
            roiIndsOfInterest = edgeDsi > dsiThresh & overallCorrelations > overallCorrelationThresh & maxMeanEpochCutoff;
        else
            roiIndsOfInterest = edgeEsi >= esiThresh(1) & edgeDsi >= dsiThresh(1) & overallCorrelations > overallCorrelationThresh & maxMeanEpochCutoff;
            if length(esiThresh)>1
                roiIndsOfInterest = roiIndsOfInterest & edgeEsi < esiThresh(2);
            end
            if length(dsiThresh)>1
                roiIndsOfInterest = roiIndsOfInterest & edgeDsi < dsiThresh(2);
            end
        end
        roiIndsOfInterest = roiIndsOfInterest & roiSizes>5;
        
%         if any(edgeDsi>1) || any(edgeEsi>1)
%             keyboard
%         end
        valueStruct.edgeEsi = edgeEsi;
        valueStruct.edgeDsi = edgeDsi;
        valueStruct.edgeEsiLeong = edgeEsiLeong;
        valueStruct.overallCorrelations = overallCorrelations;
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

function valsFirstToSecondPres = corrFirstToSecond(responsesCell)

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

valsFirstToSecondPres = max([valsFirstToSecondPres1'; valsFirstToSecondPres2']);

end