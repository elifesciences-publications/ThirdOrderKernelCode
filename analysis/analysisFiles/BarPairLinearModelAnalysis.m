function analysis = BarPairLinearModelAnalysis(flyResp,epochs,params,~ ,dataRate,dataType,interleaveEpoch,varargin)
% Call this with an empty roiSelectionFunction--all ROI selection will
% occur in here so we can compile all the ROIs together!

combOpp = 1; % logical for combining symmetic epochs such as left and right
numIgnore = 0; % number of epochs to ignore
numSep = 1; % number of different traces in the paramter file
dataX = [];
labelX = '';
fTitle = '';
flyEyes = [];
dataPathsOut = [];
epochsForSelectivity = {'' ''};
timeShift = 0;
duration = 2000;
fps = 1;
barToCenter = 2;
plottingFunction = 'PlotBarPairROISummaryTrace';
calculateModelMatrix = true;
% Can't instantiate this as empty because plenty of figures will have
% empty names as the default
figureName = 'omgIHopeNoFigureIsEverNamedThis';
figurePlotName = 'COMPILED!';
simulation = false;
plotIndividualROIs = false;
plotIndividualFlies = false;
plotFlyAverage = true;
plotResponsesOnly = false;
ignoreNeighboringBars = false;
% This is used to determine how to check for the optimal alignment to a
% single bar--the first column of the epochsForSelectivity is being checked
% against having this term somewhere as an indication that this ROI should
% respond more to a positive contrast bar
polarityPosCheck = 'Light'; 

allAxesHandles = [];
figureHandles = [];

fprintf('Two plots this time\n');
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

BarPairPlotFunction = str2func(plottingFunction);
% Gotta unwrap these because of how they're put in here
flyEyes = [flyEyes{:}];
dataPathsOut = [dataPathsOut{:}];
%     params = cellfun(@(prm) prm{1}, params, 'UniformOutput', false);

% If figureName is a cell, we need to change it depending on the
% iteration (i.e. depending on the ROIs we've selected)
if iscell(figureName) && length(figureName)>1
    figureName = figureName{iteration};
end

if any(cellfun('isempty', flyResp))
    nonResponsiveFlies = cellfun('isempty', flyResp);
    fprintf('The following flies did not respond: %s\n', num2str(find(nonResponsiveFlies)));
    flyResp(nonResponsiveFlies) = [];
    epochs(nonResponsiveFlies) = [];
    if ~isempty(flyEyes)
        flyEyes(nonResponsiveFlies)=[];
    end
    params(nonResponsiveFlies) = [];
    epochsForSelection(nonResponsiveFlies) = [];
else
    nonResponsiveFlies = [];
end

numFlies = length(flyResp);
averagedROIs = cell(1,numFlies);

if numFlies==0
    analysis = [];
    return
end



numROIs = zeros(1, numFlies);
% run the algorithm for each fly
roiResps = [];
realMinusLinearFullResponse = [];
realMinusLinearHalfResponse = [];
realMinusLinearShortNeighResponse = [];
apparentMinusSingleResponse = [];
realMinusDoubleResponse = [];

modelMatrixPerRoi = [];
modelSingleMatrixPerRoi = [];
optimalResponseFieldPerRoi = [];
% for selEpochs = 1:size(epochsForSelectivity, 1)
    flyResponseMatrix = [];
    for ff = 1:numFlies

        if ~simulation
            epochNames = {params{ff}.epochName};

% %             numEpochs = length(params{ff});
% %             epochList = epochs{ff}(:, 1);
% %             epochStartTimes = cell(numEpochs,1);
% %             epochDurations = cell(numEpochs,1);
% %             
% %             for ee = 1:length(epochStartTimes)
% %                 chosenEpochs = [0; epochList==ee; 0];
% %                 startTimes = find(diff(chosenEpochs)==1);
% %                 endTimes = find(diff(chosenEpochs)==-1)-1;
% %                 
% %                 epochStartTimes{ee} = startTimes;
% %                 epochDurations{ee} = endTimes-startTimes+1;
% %             end
            roiResponsesOut = flyResp{ff};
            epochsForRois = epochs{ff};
%             if progRegSplit
%                 [epochsForSelectionForFly, ~, ~] = AdjustEpochsForEye(dataPathsOut{ff}, [], [], varargin{:});
%             else
                epochsForSelectionForFly = epochsForSelectivity;
%             end
% %             [roiResponsesOut,roiMaskOut, roiIndsOfInterest, pValsSum, valueStruct] = SelectionFunctionBarPair(flyResp{ff},roiMask{ff},epochStartTimes,epochDurations, epochsForSelectionForFly(selEpochs, :), params{ff},interleaveEpoch, varargin{:}, 'dataRate', dataRate);
% %             
% %             roiResponsesOut = roiResponsesOut{1};
% %             epochsForRois= epochs{ff}(:, 1:size(roiResponsesOut, 2));
% %             if isempty(roiResponsesOut)
% %                 continue
% %             end
%             
            if any(strfind(epochsForSelectionForFly{iteration, 1}, polarityPosCheck))
                singleToCenter = 'PlusSingle';
%                 optimalResponseFieldPerRoi = [optimalResponseFieldPerRoi repmat({'PlusSingle'}, [1 size(roiResponsesOut, 2)])];
                optimalResponseFieldPerRoi = 'PlusSingle';
            else
                singleToCenter = 'MinusSingle';
%                 optimalResponseFieldPerRoi = [optimalResponseFieldPerRoi repmat({'MinusSingle'}, [1 size(roiResponsesOut, 2)])];
                optimalResponseFieldPerRoi = 'MinusSingle';
            end
        else
            roiResponsesOut = flyResp{ff};
            epochsForRois = epochs{ff};
            optimalResponseFieldPerRoi = optimalFieldIn; %[optimalResponseFieldPerRoi repmat({optimalFieldIn}, [1 size(roiResponsesOut, 2)])];
            epochsForSelectionForFly = epochsForSelectivity;
        end
        %% get processed trials
        analysis.indFly{ff} = GetProcessedTrials(roiResponsesOut,epochsForRois,params{ff},dataRate,dataType,varargin{:},'snipShift', 0, 'duration', []);
        
        %% remove epochs you dont want analyzed
        roiAlignResps = analysis.indFly{ff}{end}.snipMat(numIgnore+1:end,:);
        [numEpochs,numROIs(ff)] = size(roiAlignResps);
        
        %% Find optimal alignment between ROIs
        if false && ~simulation && size(epochsForSelectionForFly, 2) > 2
            % We're making an assumption here that the format for epochs for
            % selection is {dir pref, dir null, pref edge pol, null edge pol}
            edgeEpoch = ConvertEpochNameToIndex(params{ff},epochsForSelectionForFly(iteration, 3));
            % Since the probe stimulus presents multiple times, we have to know
            % how many columns in edgeResponsesMat are the response of one ROI
            numEdgeEpochPresentations = size(roiAlignResps{edgeEpoch, 1}, 2);
            edgeResponsesMat = cell2mat(roiAlignResps(edgeEpoch, :));
            
            % Linearize the responses by placing consecutive ones on top of
            % each other. Find the length of one to determine what modulus to
            % use when aligning to phase based on the xcorr
            edgeResponseMatLinear = [];
            for presentation = 1:numEdgeEpochPresentations
                edgeResponseMatLinear = [edgeResponseMatLinear; edgeResponsesMat(:, presentation:numEdgeEpochPresentations:end)];
            end
            edgeLength = size(roiAlignResps{edgeEpoch, 1}, 1);
            
            % We gotta take care of NaNs in the data. Online suggestion is to
            % nanmean subtract, nanstd normalize, and then set them to 0. This,
            % it's claimed, stops it from affecting xcorrs mu and sigma
            % calculation. Seems legit.
            edgeResponseMatLinear = bsxfun(@rdivide, bsxfun(@minus, edgeResponseMatLinear, nanmean(edgeResponseMatLinear)),nanstd(edgeResponseMatLinear));
            edgeResponseMatLinear(isnan(edgeResponseMatLinear)) = 0;
            
            % Find the optimal displacement by calculating the cross
            % correlation. xcorr does this between all columns, so the first
            % set of numROIs columns will provide us all alignment info to the
            % first ROI for the other ROIs
            edgeResponseXCorr = xcorr(edgeResponseMatLinear, 'coeff');
            [~, optimalDisplacementFromFirst] = max(edgeResponseXCorr(:, 1:numROIs(ff)));
            unwoundOptimalDisplacement = mod(optimalDisplacementFromFirst, edgeLength);
            negativeDisplacementCheck = unwoundOptimalDisplacement-edgeLength;
            unwoundOptimalDisplacement(abs(negativeDisplacementCheck)<unwoundOptimalDisplacement) = negativeDisplacementCheck(abs(negativeDisplacementCheck)<unwoundOptimalDisplacement);
            
            % Now we assume that the edge stimuli are going at 30dps
            edgeSpeed = 30;%dps
            degreeOptimalDisplacement = unwoundOptimalDisplacement/dataRate*edgeSpeed;%frames/fps*dps = degrees
            
            % write to output structure
            analysis.indFly{ff}{end+1}.name = 'roiAlignResps';
            analysis.indFly{ff}{end}.snipMat = roiAlignResps;
        end
        %% Get epochs with before/after timing as well
        roiBorderedResps = GetProcessedTrials(roiResponsesOut,epochsForRois,params{ff},dataRate,dataType,varargin{:},'snipShift', snipShift, 'duration', duration);
        roiBorderedTrials = roiBorderedResps{end}.snipMat(numIgnore+1:end,:);
        
        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'roiBorderedTrials';
        analysis.indFly{ff}{end}.snipMat = roiBorderedTrials;
        
        %% Remove epochs with too many NaNs
        droppedNaNTraces = RemoveMovingEpochs(roiBorderedTrials);
        
        analysis.indFly{ff}{end+1}.name = 'droppedNaNTraces';
        analysis.indFly{ff}{end}.snipMat = droppedNaNTraces;
        
        %% Separate out half the single bar responses for alignment purposes
        stillSingleEpochs = ~cellfun('isempty', regexp(epochNames, 'S[+-] '));
        presForAlign = cellfun(@(pres) randperm(size(pres, 2), floor(size(pres, 2)/2)), droppedNaNTraces(stillSingleEpochs, 1), 'UniformOutput', false);
        presForAlign = repmat(presForAlign, 1, size(droppedNaNTraces, 2));
        presForAvg = cellfun(@(pres, presAlign) find(~ismember(1:size(pres,2), presAlign)), droppedNaNTraces(stillSingleEpochs, :), presForAlign, 'UniformOutput', false);
        presTraceForAlign = cellfun(@(pres, presAlign) pres(:, presAlign), droppedNaNTraces(stillSingleEpochs, :), presForAlign, 'UniformOutput', false);
        presTraceForAvg = cellfun(@(pres, presAvg) pres(:, presAvg), droppedNaNTraces(stillSingleEpochs, :), presForAvg, 'UniformOutput', false);
        
        alignSepTraces = droppedNaNTraces;
        alignSepTraces(stillSingleEpochs, :) = presTraceForAvg;
        alignSepTraces = [alignSepTraces; presTraceForAlign];
        
        analysis.indFly{ff}{end+1}.name = 'alignSepTraces';
        analysis.indFly{ff}{end}.snipMat = alignSepTraces;
        
        %% average over trials
        averagedTrials = ReduceDimension(alignSepTraces,'trials',@nanmean);
        averagedTrialsSEM = ReduceDimension(alignSepTraces, 'trials', @NanSem);
        
        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedTrials';
        analysis.indFly{ff}{end}.snipMat = averagedTrials;
        
        %% Optimally align ROIs before averaging across them
        % First we've gotta find which is the preferred direction for this
        % roi
        if true %~simulation
            if ~iscell(flyEyes)
                regCheck = isempty(strfind(lower(epochsForSelectionForFly{iteration, 1}), flyEyes));
            else
                regCheck = isempty(strfind(lower(epochsForSelectionForFly{iteration, 1}), flyEyes{ff}));
            end
        else
            regCheck = regCheckIn;
        end
%         regCheck = 'We don''t use this anymore...';
        [barPairSortingStructure, numPhases, epochsOfInterestFirst] = SortBarPairBarLocations(params{ff}, interleaveEpoch+1);
        
        
        
        
            
            durationEpoch = params{ff}(14).duration/60;
            secondBarOn = params{ff}(14).secondBarDelay;
            if iscell(flyEyes)
                if strcmp(flyEyes{ff}, 'left')
                    mirrorCheck = true;
                else
                    mirrorCheck = false;
                end
            else
                if strcmp(flyEyes, 'left')
                    mirrorCheck = true;
                else
                    mirrorCheck = false;
                end
            end
                
            
            roiTrialResponseMatrixes = zeros(size(barPairSortingStructure.matrix, 2) ,length(averagedTrials{1, 1}), numROIs(ff));
            roiTrialSubOppMatrixes = [];
            roiModelFullMatrixes = [];
            roiModelHalfMatrixes = [];
            roiModelShortNeighMatrixes = [];
            roiModelSingleMatrixes = [];
            roiModelNeighMatrixes = [];
            
            if isempty(flyResponseMatrix)
                flyResponseMatrix = zeros(size(roiTrialResponseMatrixes, 1), size(roiTrialResponseMatrixes, 2), numFlies);
            end
            for roiNum = 1:numROIs(ff)
                optimalBar = optimalResponseFieldPerRoi;
                [roiTrialResponseMatrix, matDescription, sortingMatrix] = ComputeBarPairResponseMatrix(averagedTrials(interleaveEpoch+1:end, roiNum), barPairSortingStructure, barToCenter, mirrorCheck, optimalBar);
                [roiTrialResponseMatrixSem, matDescriptionSem, sortingMatrixSem] = ComputeBarPairResponseMatrix(averagedTrialsSEM(interleaveEpoch+1:end, roiNum), barPairSortingStructure, barToCenter, mirrorCheck, optimalBar);
                
                
                startOfSingleHalfBarPlusRows = matDescription{strcmp(matDescription(:, 1), '+ Still Half'), 3};%size(roiTrialResponseMatrix, 1)-numSingleBarRows+1;
                startOfSingleHalfBarMinusRows = matDescription{strcmp(matDescription(:, 1), '- Still Half'), 3};
                linearResponsesHalfPlusPol = roiTrialResponseMatrix(startOfSingleHalfBarPlusRows:startOfSingleHalfBarPlusRows+numPhases-1, :);
                linearResponsesHalfMinusPol = roiTrialResponseMatrix(startOfSingleHalfBarMinusRows:startOfSingleHalfBarMinusRows+numPhases-1, :);
                barsHalfOff = sortingMatrix(12, startOfSingleHalfBarPlusRows);
                
                startOfSingleShortBarPlusRows = matDescription{strcmp(matDescription(:, 1), '+ Still Short'), 3};%size(roiTrialResponseMatrix, 1)-numSingleBarRows+1;
                startOfSingleShortBarMinusRows = matDescription{strcmp(matDescription(:, 1), '- Still Short'), 3};
                linearResponsesShortPlusPol = roiTrialResponseMatrix(startOfSingleShortBarPlusRows:startOfSingleShortBarPlusRows+numPhases-1, :);
                linearResponsesShortMinusPol = roiTrialResponseMatrix(startOfSingleShortBarMinusRows:startOfSingleShortBarMinusRows+numPhases-1, :);
                barsShortOff = sortingMatrix(12, startOfSingleShortBarPlusRows);
 
                startOfSingleBarPlusRows = matDescription{strcmp(matDescription(:, 1), '+ Still'), 3};%size(roiTrialResponseMatrix, 1)-numSingleBarRows+1;
                startOfSingleBarMinusRows = matDescription{strcmp(matDescription(:, 1), '- Still'), 3};
                linearResponsesFullPlusPol = roiTrialResponseMatrix(startOfSingleBarPlusRows:startOfSingleBarPlusRows+numPhases-1, :);
                linearResponsesFullMinusPol = roiTrialResponseMatrix(startOfSingleBarMinusRows:startOfSingleBarMinusRows+numPhases-1, :);
                barsFullOff = sortingMatrix(12, startOfSingleBarPlusRows);
                
       
            
                %                 case {'PMinusPref', 'PMinusNull'}
                %                     linearResponsesPlusPol = roiTrialResponseMatrix(startOfSingleBarMinusRows:startOfSingleBarMinusRows+numPhases-1, :, roi);
                %                     linearResponsesMinusPol = roiTrialResponseMatrix(startOfSingleBarPlusRows:startOfSingleBarPlusRows+numPhases-1, :, roi);
                %             end
                % We gotta do some circshift--the preferred direction matrix is
                % oriented so that the first bar appears one row above the
                % second bar. Thus, we will circshift the second dimension up a
                % row to mimic the first bar appearing, and sum it to the
                % original linearResponses matrix time shifted by the second
                % bar delay to mimic the second bar appearing
                %             barOne = circshift(linearResponsesPlusPol(:, tVals>0 & tVals<barsOff), -1, 1);
                %             barTwo = linearResponsesPlusPol(:, tVals>-secondBarOn & tVals<-secondBarOn+barsOff);
                %             barTwo = barTwo(:, 1:size(barOne, 2));
                
                linearFullResponses = cat(3, linearResponsesFullPlusPol, linearResponsesFullMinusPol);
                linearHalfResponses = cat(3, linearResponsesHalfPlusPol, linearResponsesHalfMinusPol);
                linearShortResponses = cat(3, linearResponsesShortPlusPol, linearResponsesShortMinusPol);
                
               
                modelMatrixFullOneRoi=[];
                modelSingleResponseOneRoi = [];
                modelMatrixHalfOneRoi = [];
                modelMatrixShortOneRoi = [];
                
                % polCombos is formatted
                % row 1: bar one pol;
                % row 2: bar2 pol;
                % row 3: bar one shift dir;
                % its 3x8 because 8 is the eight
                % matrix combos sa they appear in roiTrialResponseMatrix
                polCombos = [1 1 2 2 1 1 2 2;
                    1 1 2 2 2 2 1 1;
                    1 -1 1 -1 1 -1 1 -1];
                tVals = linspace(snipShift/1000, (snipShift+duration)/1000, size(averagedTrials{interleaveEpoch+1}, 1));
                for combo = 1:size(polCombos, 2)
                    % Model from single bars
                    barOne = circshift(linearFullResponses(:, tVals>0 & tVals<barsFullOff, polCombos(1, combo)), polCombos(3, combo), 1);
                    barTwo = linearFullResponses(:, tVals>-secondBarOn & tVals<-secondBarOn+barsFullOff, polCombos(2, combo));
                    barTwo = barTwo(:, 1:size(barOne, 2));
                    modelMatrixFullOneRoi = [modelMatrixFullOneRoi; barOne+barTwo];
                    
                    % Model from half bars
                    barOneFirstHalf = circshift(linearHalfResponses(:, tVals>0 & tVals<=durationEpoch, polCombos(1, combo)), polCombos(3, combo), 1);
                    barOneSecondHalf = circshift(linearHalfResponses(:, tVals>-barsHalfOff & tVals<=durationEpoch-barsHalfOff, polCombos(1, combo)), polCombos(3, combo), 1);
                    barTwoFirstHalf = linearHalfResponses(:, tVals>-secondBarOn & tVals<=-secondBarOn+durationEpoch, polCombos(2, combo));
                    barTwoSecondHalf = linearHalfResponses(:, tVals>-secondBarOn-barsHalfOff & tVals<=durationEpoch-secondBarOn-barsHalfOff, polCombos(2, combo));
                    colSizes = [size(barOneFirstHalf, 2), size(barOneSecondHalf, 2), size(barTwoFirstHalf, 2), size(barTwoSecondHalf, 2)];
                    minColSize = min(colSizes);
                    barOneFirstHalf = barOneFirstHalf(:, 1:minColSize);
                    barOneSecondHalf = barOneSecondHalf(:, 1:minColSize);
                    barTwoFirstHalf = barTwoFirstHalf(:, 1:minColSize);
                    barTwoSecondHalf = barTwoSecondHalf(:, 1:minColSize);
                    modelMatrixHalfOneRoi = [modelMatrixHalfOneRoi; barOneFirstHalf + barOneSecondHalf + barTwoFirstHalf+barTwoSecondHalf];
                    
                    % Model from short bars to be added to neighboring bars
                    barOneShort = circshift(linearShortResponses(:, tVals>0 & tVals<durationEpoch, polCombos(1, combo)), polCombos(3, combo), 1);
                    modelMatrixShortOneRoi = [modelMatrixShortOneRoi; barOneShort];
                    
                    modelTemp = zeros(size(barTwo)); % We only really care about where the bars appeared
                    modelTemp(4, :) = barTwo(4, :); % 4 is a magic number that represents the 3rd phase (0-indexed) which is where things are aligned
                    % Keep in mind: the non-circshifted version of
                    % barOne wouldn't index barOne, but just take the
                    % optimal center bar at index 4--then we want to
                    % put that response at the location of the
                    % appearance of bar one
                    modelTemp(4+polCombos(3, combo), :) = barOne(4+polCombos(3, combo), :);
                    modelSingleResponseOneRoi = [modelSingleResponseOneRoi; modelTemp];
                end
                
                
                neighBarPPDescStart = find(strcmp(matDescription(:, 1), '++ Still'));
                neighBarPPStart =  matDescription{neighBarPPDescStart, 3};
                neighBarPPNumPhases = matDescription{neighBarPPDescStart, 2};
                neighBarNNDescStart = find(strcmp(matDescription(:, 1), '-- Still'));
                neighBarNNStart =  matDescription{neighBarNNDescStart, 3};
                neighBarNNNumPhases = matDescription{neighBarNNDescStart, 2};
                neighBarPNDescStart = find(strcmp(matDescription(:, 1), '+- Still'));
                neighBarPNStart =  matDescription{neighBarPNDescStart, 3};
                neighBarPNNumPhases = matDescription{neighBarPNDescStart, 2};
                neighBarNPDescStart = find(strcmp(matDescription(:, 1), '-+ Still'));
                neighBarNPStart =  matDescription{neighBarNPDescStart, 3};
                neighBarNPNumPhases = matDescription{neighBarNPDescStart, 2};
                
                % How much to shift neighboring matrixes if they
                % are initially in the pref position or the null
                % position
                prefToNullShift = -1;
                nullToPrefShift = 1;
                switch optimalBar
                    case 'PlusSingle'
                        doubleBarPPPrefComp = roiTrialResponseMatrix(neighBarPPStart:neighBarPPStart+neighBarPPNumPhases-1, :); % -1 because we overshoot by one if we add the #rows to the start row
                        doubleBarPPNullComp = circshift(roiTrialResponseMatrix(neighBarPPStart:neighBarPPStart+neighBarPPNumPhases-1, :), prefToNullShift);
                        doubleBarNNPrefComp = circshift(roiTrialResponseMatrix(neighBarNNStart:neighBarNNStart+neighBarNNNumPhases-1, :), nullToPrefShift);
                        doubleBarNNNullComp = roiTrialResponseMatrix(neighBarNNStart:neighBarNNStart+neighBarNNNumPhases-1, :);
                        doubleBarPNPrefComp = circshift(roiTrialResponseMatrix(neighBarPNStart:neighBarPNStart+neighBarPNNumPhases-1, :), nullToPrefShift); % -1 because we overshoot by one if we add the #rows to the start row
                        doubleBarPNNullComp = circshift(roiTrialResponseMatrix(neighBarNPStart:neighBarNPStart+neighBarNPNumPhases-1, :), prefToNullShift);
                        doubleBarNPPrefComp = roiTrialResponseMatrix(neighBarNPStart:neighBarNPStart+neighBarNPNumPhases-1, :);
                        doubleBarNPNullComp = roiTrialResponseMatrix(neighBarPNStart:neighBarPNStart+neighBarPNNumPhases-1, :);
                    case 'MinusSingle'
                        doubleBarPPPrefComp = circshift(roiTrialResponseMatrix(neighBarPPStart:neighBarPPStart+neighBarPPNumPhases-1, :), nullToPrefShift); % -1 because we overshoot by one if we add the #rows to the start row
                        doubleBarPPNullComp = roiTrialResponseMatrix(neighBarPPStart:neighBarPPStart+neighBarPPNumPhases-1, :);
                        doubleBarNNPrefComp = roiTrialResponseMatrix(neighBarNNStart:neighBarNNStart+neighBarNNNumPhases-1, :);
                        doubleBarNNNullComp = circshift(roiTrialResponseMatrix(neighBarNNStart:neighBarNNStart+neighBarNNNumPhases-1, :), prefToNullShift);
                        doubleBarPNPrefComp = roiTrialResponseMatrix(neighBarPNStart:neighBarPNStart+neighBarPNNumPhases-1, :); % -1 because we overshoot by one if we add the #rows to the start row
                        doubleBarPNNullComp = roiTrialResponseMatrix(neighBarNPStart:neighBarNPStart+neighBarNPNumPhases-1, :);
                        doubleBarNPPrefComp = circshift(roiTrialResponseMatrix(neighBarNPStart:neighBarNPStart+neighBarNPNumPhases-1, :), nullToPrefShift);
                        doubleBarNPNullComp = circshift(roiTrialResponseMatrix(neighBarPNStart:neighBarPNStart+neighBarPNNumPhases-1, :), prefToNullShift);
                end
                
                modelMatrixNeigh = [doubleBarPPPrefComp; doubleBarPPNullComp; doubleBarNNPrefComp; doubleBarNNNullComp; doubleBarPNPrefComp; doubleBarPNNullComp; doubleBarNPPrefComp; doubleBarNPNullComp];
                modelMatrixNeighForShort = modelMatrixNeigh(:, tVals>-barsShortOff & tVals<durationEpoch-barsShortOff);
                modelMatrixNeighForShort = modelMatrixNeighForShort(:, 1:size(modelMatrixShortOneRoi, 2));
                modelMatrixShortNeigh = modelMatrixShortOneRoi + modelMatrixNeighForShort;
                
                % polCombosStill is formatted
                % row 1: bar one pol;
                % row 2: bar2 pol;
                % row 3: bar one shift dir;
                % row 4: bar two shift dir;
                % its 4x8 because 8 is the eight matrix combos as they
                % appear in roiTrialResponseMatrix
                polCombosStill = [ 1 2 1 1;
                    1 2 2 2;
                    0 0 0 0;
                    1 -1 1 -1];
                secondBarOnStill = 0;
                for combo = 1:size(polCombosStill, 2)
                    barOne = circshift(linearFullResponses(:, tVals>0 & tVals<barsFullOff, polCombosStill(1, combo)), polCombosStill(3, combo), 1);
                    barTwo = circshift(linearFullResponses(:, tVals>-secondBarOnStill & tVals<-secondBarOnStill+barsFullOff, polCombosStill(2, combo)), polCombosStill(4, combo), 1);
                    barTwo = barTwo(:, 1:size(barOne, 2));
                    modelMatrixFullOneRoi = [modelMatrixFullOneRoi; barOne+barTwo];
                    
                    barOneFirstHalf = circshift(linearHalfResponses(:, tVals>0 & tVals<=durationEpoch, polCombosStill(1, combo)), polCombosStill(3, combo), 1);
                    barOneSecondHalf = circshift(linearHalfResponses(:, tVals>-barsHalfOff & tVals<=durationEpoch-barsHalfOff, polCombosStill(1, combo)), polCombosStill(3, combo), 1);
                    barTwoFirstHalf = circshift(linearHalfResponses(:, tVals>-secondBarOnStill & tVals<=-secondBarOnStill+durationEpoch, polCombosStill(2, combo)), polCombosStill(4, combo), 1);
                    barTwoSecondHalf = circshift(linearHalfResponses(:, tVals>-secondBarOnStill-barsHalfOff & tVals<=durationEpoch-secondBarOnStill-barsHalfOff, polCombosStill(2, combo)), polCombosStill(4, combo), 1);
                    minColSize = size(modelMatrixHalfOneRoi, 2);
                    barOneFirstHalf = barOneFirstHalf(:, 1:minColSize);
                    barOneSecondHalf = barOneSecondHalf(:, 1:minColSize);
                    barTwoFirstHalf = barTwoFirstHalf(:, 1:minColSize);
                    barTwoSecondHalf = barTwoSecondHalf(:, 1:minColSize);
                    modelMatrixHalfOneRoi = [modelMatrixHalfOneRoi; barOneFirstHalf + barOneSecondHalf + barTwoFirstHalf + barTwoSecondHalf];
                    
                    modelTemp = zeros(size(barTwo)); % We only really care about where the bars appeared
                    % Keep in mind: the non-circshifted version of
                    % barOne wouldn't index barOne, but just take the
                    % optimal center bar at index 4--then we want to
                    % put that response at the location of the
                    % appearance of bar one when it's at the center
                    modelTemp(4+polCombosStill(3, combo), :) = barTwo(4+polCombosStill(3, combo), :); % 4 is a magic number that represents the 3rd phase (0-indexed) which is where things are aligned
                    modelTemp(4+polCombosStill(4, combo), :) = barOne(4+polCombosStill(4, combo), :);
                    modelSingleResponseOneRoi = [modelSingleResponseOneRoi; modelTemp];
                end
                
                % Now the single half responses
                barsAllHalfFromFull = [linearFullResponses(:, tVals>0 & tVals<barsHalfOff, :) zeros(size(linearFullResponses, 1), sum(tVals>=barsHalfOff & tVals<durationEpoch), 2)];
                modelMatrixFullOneRoi = [modelMatrixFullOneRoi; barsAllHalfFromFull(:, :, 1); barsAllHalfFromFull(:, :, 2)];
                
                linearResponsesHalfStillAllEpoch = linearHalfResponses(:, tVals>0 & tVals<durationEpoch, :);
                linearResponsesHalfStillAllEpoch = linearResponsesHalfStillAllEpoch(:, 1:size(modelMatrixHalfOneRoi, 2), :);
                modelMatrixHalfOneRoi = [modelMatrixHalfOneRoi; linearResponsesHalfStillAllEpoch(:, :, 1); linearResponsesHalfStillAllEpoch(:, :, 2)];
                
                % Now the single short responses
                barsAllShortFromFull = [linearFullResponses(:, tVals>0 & tVals<barsShortOff, :) zeros(size(linearFullResponses, 1), sum(tVals>=barsShortOff & tVals<durationEpoch), 2)];
                modelMatrixFullOneRoi = [modelMatrixFullOneRoi; barsAllShortFromFull(:, :, 1); barsAllShortFromFull(:, :, 2)];
                
                barsAllShortFromHalf = [linearHalfResponses(:, (tVals>0 & tVals<barsShortOff) | (tVals>barsHalfOff & tVals < durationEpoch), :) zeros(size(linearHalfResponses, 1), sum(tVals>=barsShortOff & tVals<=barsHalfOff), 2)];
                barsAllShortFromHalf = barsAllShortFromHalf(:, 1:size(modelMatrixHalfOneRoi, 2), :);
                modelMatrixHalfOneRoi = [modelMatrixHalfOneRoi; barsAllShortFromHalf(:, :, 1); barsAllShortFromHalf(:, :, 2)];
                
                % Now the single full responses
                linearResponsesFullStill = linearFullResponses(:, tVals>0 & tVals<barsFullOff, :);
                modelMatrixFullOneRoi = [modelMatrixFullOneRoi; linearResponsesFullStill(:, :, 1); linearResponsesFullStill(:, :, 2)];
               
                barsAllFullFromFirstHalf = linearHalfResponses(:, tVals>0 & tVals<=durationEpoch, :);
                barsAllFullFromSecondHalf = linearHalfResponses(:, tVals>-barsHalfOff & tVals<=durationEpoch-barsHalfOff, :);
                barsAllFullFromFirstHalf = barsAllFullFromFirstHalf(:, 1:size(modelMatrixHalfOneRoi, 2), :);
                barsAllFullFromSecondHalf = barsAllFullFromSecondHalf(:, 1:size(modelMatrixHalfOneRoi, 2), :);
                barsAllFullFromHalf = barsAllFullFromFirstHalf + barsAllFullFromSecondHalf;
                modelMatrixHalfOneRoi = [modelMatrixHalfOneRoi; barsAllFullFromHalf(:, :, 1); barsAllFullFromHalf(:, :, 2)];
                
                
                
                
                modelMatrixFullOneRoi = [roiTrialResponseMatrix(1:size(modelMatrixFullOneRoi,1), tVals<=0), modelMatrixFullOneRoi, roiTrialResponseMatrix(1:size(modelMatrixFullOneRoi,1), tVals>=durationEpoch)];
                modelMatrixHalfOneRoi = [roiTrialResponseMatrix(1:size(modelMatrixHalfOneRoi,1), tVals<=0), modelMatrixHalfOneRoi, roiTrialResponseMatrix(1:size(modelMatrixHalfOneRoi,1), tVals>=durationEpoch)];
                modelSingleResponseOneRoi = [roiTrialResponseMatrix(1:size(modelSingleResponseOneRoi,1), tVals<=0), modelSingleResponseOneRoi, roiTrialResponseMatrix(1:size(modelSingleResponseOneRoi,1), tVals>=durationEpoch)];
                modelMatrixShortNeigh = [roiTrialResponseMatrix(1:size(modelMatrixShortNeigh,1), tVals<=0), modelMatrixShortNeigh, roiTrialResponseMatrix(1:size(modelMatrixShortNeigh,1), tVals>=durationEpoch)];
                
                roiResponseMatrixDirResps = roiTrialResponseMatrix(1:size(modelMatrixFullOneRoi, 1), :);
                realMinusLinearFullResponse = cat(3,realMinusLinearFullResponse, roiResponseMatrixDirResps-modelMatrixFullOneRoi);
                
                realMinusLinearHalfResponse = cat(3, realMinusLinearHalfResponse, roiResponseMatrixDirResps-modelMatrixHalfOneRoi);
                
                
                roiResponseMatrixNeighResps = roiTrialResponseMatrix(1:size(modelMatrixNeigh, 1), :);
                realMinusDoubleResponse = cat(3,realMinusDoubleResponse, roiResponseMatrixNeighResps-modelMatrixNeigh);
                realMinusLinearShortNeighResponse = cat(3,realMinusLinearShortNeighResponse, roiResponseMatrixNeighResps-modelMatrixShortNeigh);
                
                
                
                modelMatrixPerRoi = cat(3, modelMatrixPerRoi, modelMatrixFullOneRoi);
                
                if ~simulation
                    if size(epochsForSelectionForFly, 2) > 2
                        if any(strfind(lower(epochsForSelectionForFly{iteration, 1}), lower(flyEyes{ff})))
                            initTextDirection = epochsForSelectionForFly{iteration, 3};
                            textDirection = [flyEyes{ff} ' eye - Progressive' initTextDirection(length(flyEyes{ff})+1:end)];
                        else
                            initTextDirection = epochsForSelectionForFly{iteration, 3};
                            textDirection = [flyEyes{ff} ' eye - Regressive' initTextDirection(length(flyEyes{ff})+2:end)];
                        end
                    else
                        textDirection = [epochsForSelectionForFly{iteration, 1} ' Selective'];
                    end
                else
                    textDirection = 'Simulation';
                end
                paramsPlot = params{ff}(epochsOfInterestFirst:end);
                paramsPlot(1).optimalBar = optimalBar;
                if plotIndividualROIs
                    [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(roiTrialResponseMatrix, roiTrialResponseMatrixSem, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'Real');

                    fullText = sprintf('%s\n Fly %d - ROI %d/%d\n Real Only', textDirection, ff,  roiNum, numROIs(ff));
                    text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                   
                    figNames = strcat({figureHandles{end}.Name}, 'Real ');
                    [figureHandles{end}.Name] = deal(figNames{:});
                    
                    % Full bars linear model
                    [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(modelMatrixFullOneRoi, roiTrialResponseMatrix, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'LinModel');
                    fullText = sprintf('%s\n Fly %d - ROI %d/%d\n Full Length Bars LModel Only', textDirection, ff,  roiNum, numROIs(ff));
                    text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                    figNames = strcat({figureHandles{end}.Name}, 'FLBModel ');
                    [figureHandles{end}.Name] = deal(figNames{:});
                    
                    % Real - full bars linear model
                    [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(realMinusLinearFullResponse(:, :, end), modelMatrixFullOneRoi, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'Real-LinModel');
                    fullText = sprintf('%s\n Fly %d - ROI %d/%d\n Real - FLBModel', textDirection, ff,  roiNum, numROIs(ff));
                    text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                    figNames = strcat({figureHandles{end}.Name}, 'Real-FLBModel ');
                    [figureHandles{end}.Name] = deal(figNames{:});
                    
                    % Half model
                    [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(modelMatrixHalfOneRoi, roiTrialResponseMatrix, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'LinModel');
                    fullText = sprintf('%s\n Fly %d - ROI %d/%d\n Half Length Bars LModel Only', textDirection, ff,  roiNum, numROIs(ff));
                    text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                    figNames = strcat({figureHandles{end}.Name}, 'HLBModel ');
                    [figureHandles{end}.Name] = deal(figNames{:});
                    
                    % Real - half model
                    [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(realMinusLinearHalfResponse(:, :, end), roiTrialResponseMatrix, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'LinModel');
                    fullText = sprintf('%s\n Fly %d - ROI %d/%d\n Real - HLBModel', textDirection, ff,  roiNum, numROIs(ff));
                    text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                    figNames = strcat({figureHandles{end}.Name}, 'Real-HLBModel ');
                    [figureHandles{end}.Name] = deal(figNames{:});
                    
                    % Short Neigh model
                    [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(modelMatrixShortNeigh, roiTrialResponseMatrix, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'LinModel');
                    fullText = sprintf('%s\n Fly %d - ROI %d/%d\n Short Neigh Bars LModel Only', textDirection, ff,  roiNum, numROIs(ff));
                    text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                    figNames = strcat({figureHandles{end}.Name}, 'SNBModel ');
                    [figureHandles{end}.Name] = deal(figNames{:});
                    
                    % Real - shortNeigh model
                    [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(realMinusLinearShortNeighResponse(:, :, end), roiTrialResponseMatrix, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'LinModel');
                    fullText = sprintf('%s\n Fly %d - ROI %d/%d\n Real - SNBModel', textDirection, ff,  roiNum, numROIs(ff));
                    text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                    figNames = strcat({figureHandles{end}.Name}, 'Real-SNBModel ');
                    [figureHandles{end}.Name] = deal(figNames{:});
                    
                    % Neighbor model
                    [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(modelMatrixNeigh, roiTrialResponseMatrix, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'NeighModel');
                    fullText = sprintf('%s\n Fly %d - ROI %d/%d\n Neighbor Model', textDirection, ff,  roiNum, numROIs(ff));
                    text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                    figNames = strcat({figureHandles{end}.Name}, 'NModel ');
                    [figureHandles{end}.Name] = deal(figNames{:});
                    
                    % Real - neighbor model
                    [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(realMinusDoubleResponse(:, :, end), modelMatrixNeigh, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'Real-NeighModel');
                    fullText = sprintf('%s\n Fly %d - ROI %d/%d\n Real - Neighbor Model', textDirection, ff,  roiNum, numROIs(ff));
                    text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                    figNames = strcat({figureHandles{end}.Name}, 'Real-NModel ');
                    [figureHandles{end}.Name] = deal(figNames{:});
                    
                end
                
                
                
                roiTrialResponseMatrixes(:, :, roiNum) = roiTrialResponseMatrix;
               
                
                roiModelFullMatrixes(:, :, roiNum) = modelMatrixFullOneRoi;
                roiModelHalfMatrixes(:, :, roiNum) = modelMatrixHalfOneRoi;
                roiModelShortNeighMatrixes(:, :, roiNum) = modelMatrixShortNeigh;
                
                roiModelNeighMatrixes(:, :, roiNum) = modelMatrixNeigh;
            end
            
            flyResponseMatrix(:, :, ff) = nanmean(roiTrialResponseMatrixes, 3);
            flyResponseMatrixSem(:, :, ff) = NanSem(roiTrialResponseMatrixes, 3);
            
            
            
            % Full linear responses & real-full linear
            flyModelFullMatrix(:, :, ff) = mean(roiModelFullMatrixes, 3);
            flyRealMinusFullModelMatrix(:, :, ff) = flyResponseMatrix(1:size(flyModelFullMatrix, 1), :, ff) - flyModelFullMatrix(:, :, ff);
            % Half linear responses & real-halr linear
            flyModelHalfMatrix(:, :, ff) = mean(roiModelHalfMatrixes, 3);
            flyRealMinusHalfModelMatrix(:, :, ff) = flyResponseMatrix(1:size(flyModelHalfMatrix, 1), :, ff) - flyModelHalfMatrix(:, :, ff);
            % Short neigh linear respones & real-short neigh linear
            flyModelShortNeighMatrix(:, :, ff) = mean(roiModelShortNeighMatrixes, 3);
            flyRealMinusShortNeighModelMatrix(:, :, ff) = flyResponseMatrix(1:size(flyModelShortNeighMatrix, 1), :, ff) - flyModelShortNeighMatrix(:, :, ff);
            % neighboring bar responses & real-neighboring bar
            flyModelNeighMatrix(:, :, ff) = mean(roiModelNeighMatrixes, 3);
            flyRealMinusNeighMatrix(:, :, ff) = flyResponseMatrix(1:size(flyModelNeighMatrix, 1), :, ff) - flyModelNeighMatrix(:, :, ff);
            
            
            % Actual responses
            if plotIndividualFlies
                [figureHandles{end+1}, allAxesHandles{end+1}] = BarPairPlotFunction(flyResponseMatrix(:, :, ff), flyResponseMatrixSem(:, :, ff), barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'Real');
                fullText = sprintf('%s\n Fly %d - all %d ROIs\n Real Only', textDirection, ff,  numROIs(ff));
                text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                if ~isempty(figureHandles{1})
                    figNames = strcat({figureHandles{end}.Name}, 'Real');
                    [figureHandles{end}.Name] = deal(figNames{:});
                end
                
                % Full bars linear model
                [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(flyModelFullMatrix(:, :, ff), flyResponseMatrix(:, :, ff), barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'LinModel');
                fullText = sprintf('%s\n Fly %d - all %d ROIs\n Full Length Bars LModel Only', textDirection, ff, numROIs(ff));
                text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                figNames = strcat({figureHandles{end}.Name}, 'FLBModel ');
                [figureHandles{end}.Name] = deal(figNames{:});
                
                % Real - full bars linear model
                [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(flyRealMinusFullModelMatrix(:, :, ff), modelMatrixFullOneRoi, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'Real-LinModel');
                fullText = sprintf('%s\n Fly %d - all %d ROIs\n Real - FLBModel', textDirection, ff, numROIs(ff));
                text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                figNames = strcat({figureHandles{end}.Name}, 'Real-FLBModel ');
                [figureHandles{end}.Name] = deal(figNames{:});
                
                % Half model
                [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(flyModelHalfMatrix(:, :, ff), flyResponseMatrix(:, :, ff), barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'LinModel');
                fullText = sprintf('%s\n Fly %d - all %d ROIs\n Half Length Bars LModel Only', textDirection, ff, numROIs(ff));
                text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                figNames = strcat({figureHandles{end}.Name}, 'HLBModel ');
                [figureHandles{end}.Name] = deal(figNames{:});
                
                % Real - half model
                [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(flyRealMinusHalfModelMatrix(:, :, ff), modelMatrixFullOneRoi, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'LinModel');
                fullText = sprintf('%s\n Fly %d - all %d ROIs\n Real - HLBModel', textDirection, ff, numROIs(ff));
                text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                figNames = strcat({figureHandles{end}.Name}, 'Real-HLBModel ');
                [figureHandles{end}.Name] = deal(figNames{:});
                
                % Short Neigh model
                [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(flyModelShortNeighMatrix(:, :, ff), flyResponseMatrix(:, :, ff), barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'LinModel');
                fullText = sprintf('%s\n Fly %d - all %d ROIs\n Short Neigh Bars LModel Only', textDirection, ff, numROIs(ff));
                text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                figNames = strcat({figureHandles{end}.Name}, 'SNBModel ');
                [figureHandles{end}.Name] = deal(figNames{:});
                
                % Real - shortNeigh model
                [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(flyRealMinusShortNeighModelMatrix(:, :, ff), modelMatrixFullOneRoi, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'LinModel');
                fullText = sprintf('%s\n Fly %d - all %d ROIs\n Real - SNBModel', textDirection, ff, numROIs(ff));
                text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                figNames = strcat({figureHandles{end}.Name}, 'Real-SNBModel ');
                [figureHandles{end}.Name] = deal(figNames{:});
                
                % Neighbor model
                [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(flyModelNeighMatrix(:, :, ff), flyResponseMatrix(:, :, ff), barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'NeighModel');
                fullText = sprintf('%s\n Fly %d - all %d ROIs\n Neighbor Model', textDirection, ff, numROIs(ff));
                text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                figNames = strcat({figureHandles{end}.Name}, 'NModel ');
                [figureHandles{end}.Name] = deal(figNames{:});
                
                % Real - neighbor model
                [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(flyRealMinusNeighMatrix(:, :, ff), modelMatrixNeigh, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'Real-NeighModel');
                fullText = sprintf('%s\n Fly %d - all %d ROIs\n Real - Neighbor Model', textDirection, ff, numROIs(ff));
                text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                figNames = strcat({figureHandles{end}.Name}, 'Real-NModel ');
                [figureHandles{end}.Name] = deal(figNames{:});
                
                
            end
            
            analysis.indFly{ff}{end+1}.name = 'responseMatrix';
            analysis.indFly{ff}{end}.responseMatrix = flyResponseMatrix(:, :, ff);
            analysis.indFly{ff}{end}.paramsPlot = paramsPlot;
            analysis.indFly{ff}{end}.dataRate = dataRate;
            analysis.indFly{ff} = MakeAnalysisReadable(analysis.indFly{ff});
    end
    flyResponseMatrix(:, :, all(all(flyResponseMatrix==0))) = [];
    if plotFlyAverage
        [figureHandles{end+1}, allAxesHandles{end+1}] = BarPairPlotFunction(nanmean(flyResponseMatrix, 3), NanSem(flyResponseMatrix, 3), barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'Real');
        fullText = sprintf('%s\n All flies (%d)\n Real Only', textDirection, numFlies);
        text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
        if ~isempty(figureHandles{1})
            figNames = strcat({figureHandles{end}.Name}, 'Real ');
            [figureHandles{end}.Name] = deal(figNames{:});
        end
        
        % Full bars linear model
        flyModelFullMatrix(:, :, all(all(flyModelFullMatrix==0))) = [];
        [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(nanmean(flyModelFullMatrix, 3), nanmean(flyModelFullMatrix, 3), barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'LinModel');
        fullText = sprintf('%s\n All flies (%d)\n Full Length Bars LModel Only', textDirection, ff, numFlies);
        text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
        figNames = strcat({figureHandles{end}.Name}, 'FLBModel ');
        [figureHandles{end}.Name] = deal(figNames{:});
        
        % Real - full bars linear model
        flyRealMinusFullModelMatrix(:, :, all(all(flyRealMinusFullModelMatrix==0))) = [];
        [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(nanmean(flyRealMinusFullModelMatrix, 3), nanmean(flyRealMinusFullModelMatrix, 3), barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'Real-LinModel');
        fullText = sprintf('%s\n All flies (%d)\n Real - FLBModel', textDirection, ff, numFlies);
        text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
        figNames = strcat({figureHandles{end}.Name}, 'Real-FLBModel ');
        [figureHandles{end}.Name] = deal(figNames{:});
        
        % Half model
        flyModelHalfMatrix(:, :, all(all(flyModelHalfMatrix==0))) = [];
        [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(nanmean(flyModelHalfMatrix, 3), nanmean(flyModelHalfMatrix, 3), barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'LinModel');
        fullText = sprintf('%s\n All flies (%d)\n Half Length Bars LModel Only', textDirection, ff, numFlies);
        text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
        figNames = strcat({figureHandles{end}.Name}, 'HLBModel ');
        [figureHandles{end}.Name] = deal(figNames{:});
        
        % Real - half model
        flyRealMinusHalfModelMatrix(:, :, all(all(flyRealMinusHalfModelMatrix==0))) = [];
        [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(nanmean(flyRealMinusHalfModelMatrix, 3), nanmean(flyRealMinusHalfModelMatrix, 3), barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'LinModel');
        fullText = sprintf('%s\n All flies (%d)\n Real - HLBModel', textDirection, ff, numFlies);
        text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
        figNames = strcat({figureHandles{end}.Name}, 'Real-HLBModel ');
        [figureHandles{end}.Name] = deal(figNames{:});
        
        % Short Neigh model
        flyModelShortNeighMatrix(:, :, all(all(flyModelShortNeighMatrix==0))) = [];
        [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(nanmean(flyModelShortNeighMatrix, 3), nanmean(flyModelShortNeighMatrix, 3), barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'LinModel');
        fullText = sprintf('%s\n All flies (%d)\n Short Neigh Bars LModel Only', textDirection, ff, numFlies);
        text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
        figNames = strcat({figureHandles{end}.Name}, 'SNBModel ');
        [figureHandles{end}.Name] = deal(figNames{:});
        
        % Real - shortNeigh model
        flyRealMinusShortNeighModelMatrix(:, :, all(all(flyRealMinusShortNeighModelMatrix==0))) = [];
        [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(nanmean(flyRealMinusShortNeighModelMatrix, 3), nanmean(flyRealMinusShortNeighModelMatrix, 3), barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'LinModel');
        fullText = sprintf('%s\n All flies (%d)\n Real - SNBModel', textDirection, ff, numFlies);
        text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
        figNames = strcat({figureHandles{end}.Name}, 'Real-SNBModel ');
        [figureHandles{end}.Name] = deal(figNames{:});
        
        % Neighbor model
        flyModelNeighMatrix(:, :, all(all(flyModelNeighMatrix==0))) = [];
        [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(nanmean(flyModelNeighMatrix, 3), nanmean(flyModelNeighMatrix, 3), barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'NeighModel');
        fullText = sprintf('%s\n All flies (%d)\n Neighbor Model', textDirection, ff, numFlies);
        text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
        figNames = strcat({figureHandles{end}.Name}, 'NModel ');
        [figureHandles{end}.Name] = deal(figNames{:});
        
        % Real - neighbor model
        flyRealMinusNeighMatrix(:, :, all(all(flyRealMinusNeighMatrix==0))) = [];
        [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(nanmean(flyRealMinusNeighMatrix, 3), nanmean(flyRealMinusNeighMatrix, 3), barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'Real-NeighModel');
        fullText = sprintf('%s\n All flies (%d)\n Real - Neighbor Model', textDirection, ff, numFlies);
        text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
        figNames = strcat({figureHandles{end}.Name}, 'Real-NModel ');
        [figureHandles{end}.Name] = deal(figNames{:});
        
        
        
    end
    allAxesHandles = [allAxesHandles{:}];
    minC = min([allAxesHandles.CLim]);
    maxC = max([allAxesHandles.CLim]);
    [allAxesHandles.CLim] = deal([minC maxC]);
    allAxesParents = unique([allAxesHandles.Parent]);
    [allAxesParents.Colormap] = deal(colormap(b2r(minC, maxC)));
    if plotIndividualFlies || plotIndividualROIs
        keyboard
    end
    
    allFigureHandles = [figureHandles{:}];
    for figH = 1:length(allFigureHandles);
        allFigureHandles(figH).Name = [allFigureHandles(figH).Name figureName];
    end
    %         %% average over ROIs
    %         averagedROIs{ff} = ReduceDimension(averagedTrials,'Rois',@nanmean);
    %         averagedROIsSEM{ff} = ReduceDimension(averagedTrials, 'Rois', @NanSem);
    %
    %
    %         fprintf('%d ROIs for fly %d\n', numROIs(ff), ff);
    %         % regCheck tells us whether we're looking at a regressive
    %         % layer--true if it's true, which means the primary epoch for
    %         % selectivity is different than the fly eye
    %         regCheck = isempty(strfind(lower(epochsForSelection{ff}{1}), flyEyes{ff}));
    %
    % % %         regCheck = isempty(strfind(lower(epochsForSelection{1}{1}), 'left'));
    % %         BarPairPlotFunction(averagedROIs{ff}, averagedROIsSEM{ff}, barPairEpochsPhaseAndPolaritySorted, barToCenter, params{ff}, dataRate, snipShift/1000, duration/1000, regCheck);
    % %         if any(strfind(lower(epochsForSelection{ff}{1}), lower(flyEyes{ff})))
    % %             initTextDirection = epochsForSelection{ff}{3};
    % %             textDirection = ['Progressive  ' initTextDirection(length(flyEyes{ff}+1):end)];
    % %         else
    % %             initTextDirection = epochsForSelection{ff}{3};
    % %             textDirection = ['Regressive  ' initTextDirection(length(flyEyes{ff}+2):end)];
    % %         end
    % %         fullText = sprintf('%s\n Fly %d - Num ROIs %d', textDirection, ff,  numROIs(ff));
    % %         text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
    % % %         text(0, numPhases-1, sprintf('Fly %d - Num ROIs %d', ff, numROIs(ff)), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
    %         plotFigure = gcf;
    %         set(findall(plotFigure,'-property','FontName'),'FontName', 'Ebrima')
    %         text(0, 0, epochsForSelection{ff}{3}, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle')
    %         % write to output structure
    %         analysis.indFly{ff}{end+1}.name = 'averagedROIs';
    %         analysis.indFly{ff}{end}.snipMat = averagedROIs;
    %
    %         %% make analysis readable
    %         analysis.indFly{ff} = MakeAnalysisReadable(analysis.indFly{ff});
    %
    
% end



% We don't want to do corr analysis if we're in a simulation
% AND: possibly if there's only one response (i.e. one fly); might have to
% add this later...
if simulation || plotResponsesOnly
    return;
end

analysis.roiResps = roiResps;
analysis.roiModelResps = modelMatrixPerRoi;
analysis.params = params{1};
analysis.numPhases = numPhases;
analysis.numROIs = numROIs;



%% convert from snipMat to matrix wtih individual flies

%     respMatInd = SnipMatToMatrix(averagedROIs); % turn snipMat into a matrix
%     respMatIndSep = SeparateTraces(respMatInd,numSep,''); % separate every numSnips epochs into a new trace to plot
%     respMatIndPlot = squish(respMatIndSep); % remove all nonsingleton dimensions
%
%     analysis.respMatIndPlot = respMatIndPlot;

%     %% Average fly time traces
%     noTimeAveragedFlies = ReduceDimension(noTimeAveragedRois,'flies',@nanmean);
%     noTimeAveragedFliesSem = ReduceDimension(noTimeAveragedRois,'flies',@NanSem);
%
%     respMatNoTime = SnipMatToMatrix(noTimeAveragedFlies); % turn snipMat into a matrix
%     respMatNoTimeSep =  SeparateTraces(respMatNoTime,numSep,''); % turn snipMat into a matrix
%     respMatNoTimePlot = permute(respMatNoTimeSep,[1 3 6 7 2 4 5]); % magic permutations
%
%     respMatNoTimeSem = SnipMatToMatrix(noTimeAveragedFliesSem); % turn snipMat into a matrix
%     respMatNoTimeSepSem =  SeparateTraces(respMatNoTimeSem,numSep,''); % turn snipMat into a matrix
%     respMatNoTimeSemPlot = permute(respMatNoTimeSepSem,[1 3 6 7 2 4 5]); % magic permutations
%



end


function [meanResponse, crossCorrelation, meanResponseError, crossCorrsError] = BootstrapAnalysis(phaseResponses, numPhases)
% CrossCorrOfInterest should be phase 4 of the light or dark edge response

numPhaseResponses = size(phaseResponses, 1);
numBootstraps = 1000;
shifts = 0:8:numPhaseResponses-1;

numFlies = size(phaseResponses, 3);

meanResponse = mean(phaseResponses, 3);
crossCorrelation = corrcoef(meanResponse');

btstrpMeanResponse = zeros(size(phaseResponses, 1), size(phaseResponses, 2), numBootstraps);
btstrpCrossCorrs = zeros(size(phaseResponses, 1), size(phaseResponses, 1), numBootstraps);

for btstrp = 1:numBootstraps
    replacement = true;
    phaseIndsInit = randsample(numPhases,numPhases,replacement);
    flyIndsRan = randsample(numFlies, numFlies, replacement);
    phaseIndsRep = repmat(phaseIndsInit, 1, numPhaseResponses/numPhases);
    phaseIndsShifted = bsxfun(@plus, phaseIndsRep, shifts);
    phaseIndsShifted = phaseIndsShifted(:);
    meanResponsesBtstrp = mean(phaseResponses(phaseIndsShifted, :, flyIndsRan), 3);
    meanSubMeanResponsesBstrp = bsxfun(@minus, meanResponsesBtstrp, mean(meanResponsesBtstrp, 2));
    crossCorrelationBtsrp = corrcoef(meanResponsesBtstrp');
    btstrpMeanResponse(:, :, btstrp) = meanResponsesBtstrp;
    btstrpCrossCorrs(:, :, btstrp) = crossCorrelationBtsrp;%ReduceDimension(cat(2, subTrialsROI{flyInds}),'Rois',@nanmean);
end

meanResponseError = nanstd(btstrpMeanResponse, [], 3);
crossCorrsError = nanstd(btstrpCrossCorrs, [], 3);

end
