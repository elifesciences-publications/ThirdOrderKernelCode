function analysis = BarPairNewCompiledRoiAnalysis_catherine(flyResp,epochs,params,~ ,dataRate,dataType,interleaveEpoch,varargin)
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
snipShift = -500;
% This is used to determine how to check for the optimal alignment to a
% single bar--the first column of the epochsForSelectivity is being checked
% against having this term somewhere as an indication that this ROI should
% respond more to a positive contrast bar
polarityPosCheck = 'Light'; 
leftMotCheck = 'Left';

allAxesHandles = [];
figureHandles = [];

fprintf('Two plots this time\n');
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

BarPairPlotFunction = str2func(plottingFunction);
%     epochNames = {params.epochName};
% Gotta unwrap these because of how they're put in here
% try
flyEyes = [flyEyes{:}];
% catch
%     flyEyes = {};
% end
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
realMinusLinearResponse = [];
apparentMinusSingleResponse = [];
realMinusDoubleResponse = [];
modelMatrixPerRoi = [];
optimalResponseFieldPerRoi = [];
modelSingleMatrixPerRoi = [];
% for selEpochs = 1:size(epochsForSelectivity, 1)
    flyResponseMatrix = [];
    for ff = 1:numFlies
        
        if ~simulation
%             numEpochs = length(params{ff});
%             epochList = epochs{ff}(:, 1);
%             epochStartTimes = cell(numEpochs,1);
%             epochDurations = cell(numEpochs,1);
%             
%             for ee = 1:length(epochStartTimes)
%                 chosenEpochs = [0; epochList==ee; 0];
%                 startTimes = find(diff(chosenEpochs)==1);
%                 endTimes = find(diff(chosenEpochs)==-1)-1;
%                 
%                 epochStartTimes{ee} = startTimes;
%                 epochDurations{ee} = endTimes-startTimes+1;
%             end
            roiResponsesOut = flyResp{ff};
            epochsForRois = epochs{ff};
%             if progRegSplit
%                 [epochsForSelectionForFly, ~, ~] = AdjustEpochsForEye(dataPathsOut{ff}, [], [], varargin{:});
%             else
                epochsForSelectionForFly = epochsForSelectivity;
%             end
%             [roiResponsesOut,roiMaskOut, roiIndsOfInterest, pValsSum, valueStruct] = SelectionFunctionBarPair(flyResp{ff},roiMask{ff},epochStartTimes,epochDurations, epochsForSelectionForFly(selEpochs, :), params{ff},interleaveEpoch, varargin{:}, 'dataRate', dataRate);
%             
%             roiResponsesOut = roiResponsesOut{1};
%             epochsForRois= epochs{ff}(:, 1:size(roiResponsesOut, 2));
%             if isempty(roiResponsesOut)
%                 continue
%             end
            
            if any(strfind(epochsForSelectionForFly{iteration, 1}, polarityPosCheck))
                singleToCenter = 'PlusSingle';
%                 optimalResponseFieldPerRoi = [optimalResponseFieldPerRoi repmat({'PlusSingle'}, [1 size(roiResponsesOut, 2)])];
                optimalResponseFieldPerRoi = 'PlusSingle';
            else
                singleToCenter = 'MinusSingle';
%                 optimalResponseFieldPerRoi = [optimalResponseFieldPerRoi repmat({'MinusSingle'}, [1 size(roiResponsesOut, 2)])];
                optimalResponseFieldPerRoi = 'MinusSingle';
            end
            if any(strfind(epochsForSelection{ff}{1}, leftMotCheck))
                direction = 'left';
            else
                direction = 'right';
            end
            epochNames = {params{ff}.epochName};
        else
            roiResponsesOut = flyResp{ff};
            epochsForRois = epochs{ff};
            optimalResponseFieldPerRoi = optimalFieldIn;
            %optimalResponseFieldPerRoi = [optimalResponseFieldPerRoi repmat({optimalFieldIn}, [1 size(roiResponsesOut, 2)])];
            epochsForSelectionForFly = epochsForSelectivity;
        end
        %% get processed trials
        %analysis.indFly{ff} = GetProcessedTrials(roiResponsesOut,epochsForRois,params{ff},dataRate,dataType,varargin{:},'snipShift', snipShift, 'duration', duration);
        
        
        %% remove epochs you dont want analyzed
%         roiAlignResps = analysis.indFly{ff}{end}.snipMat(numIgnore+1:end,:);
%         [numEpochs,numROIs(ff)] = size(roiAlignResps);
        
        %% Find optimal alignment between ROIs
%         if false && ~simulation && size(epochsForSelectionForFly, 2) > 2
%             % We're making an assumption here that the format for epochs for
%             % selection is {dir pref, dir null, pref edge pol, null edge pol}
%             edgeEpoch = ConvertEpochNameToIndex(params{ff},epochsForSelection{iteration}{1});
%             % Since the probe stimulus presents multiple times, we have to know
%             % how many columns in edgeResponsesMat are the response of one ROI
%             numEdgeEpochPresentations = size(roiAlignResps{edgeEpoch, 1}, 2);
%             edgeResponsesMat = cell2mat(roiAlignResps(edgeEpoch, :));
%             
%             % Linearize the responses by placing consecutive ones on top of
%             % each other. Find the length of one to determine what modulus to
%             % use when aligning to phase based on the xcorr
%             edgeResponseMatLinear = [];
%             for presentation = 1:numEdgeEpochPresentations
%                 edgeResponseMatLinear = [edgeResponseMatLinear; edgeResponsesMat(:, presentation:numEdgeEpochPresentations:end)];
%             end
%             edgeLength = size(roiAlignResps{edgeEpoch, 1}, 1);
%             
%             % We gotta take care of NaNs in the data. Online suggestion is to
%             % nanmean subtract, nanstd normalize, and then set them to 0. This,
%             % it's claimed, stops it from affecting xcorrs mu and sigma
%             % calculation. Seems legit.
%             edgeResponseMatLinear = bsxfun(@rdivide, bsxfun(@minus, edgeResponseMatLinear, nanmean(edgeResponseMatLinear)),nanstd(edgeResponseMatLinear));
%             edgeResponseMatLinear(isnan(edgeResponseMatLinear)) = 0;
%             [RFCenter,xBest] =  AlignRoiByEdges(edgeResponseMatLinear, direction, dataRate, edgeVel, barWidth, numPhases);
%             % Find the optimal displacement by calculating the cross
%             % correlation. xcorr does this between all columns, so the first
%             % set of numROIs columns will provide us all alignment info to the
%             % first ROI for the other ROIs
% %             edgeResponseXCorr = xcorr(edgeResponseMatLinear, 'coeff');
% %             [~, optimalDisplacementFromFirst] = max(edgeResponseXCorr(:, 1:numROIs(ff)));
% %             unwoundOptimalDisplacement = mod(optimalDisplacementFromFirst, edgeLength);
% %             negativeDisplacementCheck = unwoundOptimalDisplacement-edgeLength;
% %             unwoundOptimalDisplacement(abs(negativeDisplacementCheck)<unwoundOptimalDisplacement) = negativeDisplacementCheck(abs(negativeDisplacementCheck)<unwoundOptimalDisplacement);
% %             
% %             % Now we assume that the edge stimuli are going at 30dps
% %             edgeSpeed = 30;%dps
% %             degreeOptimalDisplacement = unwoundOptimalDisplacement/dataRate*edgeSpeed;%frames/fps*dps = degrees
%             
%             % write to output structure
%             analysis.indFly{ff}{end+1}.name = 'roiAlignResps';
%             analysis.indFly{ff}{end}.snipMat = roiAlignResps;
%         end
        %% Get epochs with before/after timing as well
%         roiBorderedResps = GetProcessedTrials(roiResponsesOut,epochsForRois,params{ff},dataRate,dataType,varargin{:},'snipShift', snipShift, 'duration', duration);
%         roiBorderedTrials = roiBorderedResps{end}.snipMat(numIgnore+1:end,:);

        analysis.indFly{ff} = GetProcessedTrials(roiResponsesOut,epochsForRois,params{ff},dataRate,dataType,varargin{:},'snipShift', snipShift, 'duration', duration);
        roiBorderedTrials = analysis.indFly{ff}{end}.snipMat(numIgnore+1:end,:);
        
        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'roiBorderedTrials';
        analysis.indFly{ff}{end}.snipMat = roiBorderedTrials;
        
%         roinonBorderedResps = GetProcessedTrials(roiResponsesOut,epochsForRois,params{ff},dataRate,dataType,varargin{:},'snipShift', 0, 'duration', 1000);
%         roinonBorderedTrials = roinonBorderedResps{end}.snipMat(numIgnore+1:end,:);
%         realDuration = size(roinonBorderedTrials{1}, 1);
%         roinonBorderedResps = GetProcessedTrials(roiResponsesOut,epochsForRois,params{ff},dataRate,dataType,varargin{:},'snipShift', -500, 'duration', 500);
%         roinonBorderedTrials = roinonBorderedResps{end}.snipMat(numIgnore+1:end,:);
%         initialDuration = size(roinonBorderedTrials{1}, 1);
        
        % write to output structure
%         analysis.indFly{ff}{end+1}.name = 'roiBorderedTrials';
%         analysis.indFly{ff}{end}.snipMat = roiBorderedTrials;
        
        %% Remove epochs with too many NaNs
        droppedNaNTraces = RemoveMovingEpochs(roiBorderedTrials);
        
        analysis.indFly{ff}{end+1}.name = 'droppedNaNTraces';
        analysis.indFly{ff}{end}.snipMat = droppedNaNTraces;
        %%
        
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
        
        %%
        %% average over trials
        averagedTrials = ReduceDimension(droppedNaNTraces,'trials',@nanmean);
        averagedTrialsSEM = ReduceDimension(droppedNaNTraces, 'trials', @NanSem);
%         averagedTrials = ReduceDimension(alignSepTraces,'trials',@nanmean);
%         averagedTrialsSEM = ReduceDimension(alignSepTraces, 'trials', @NanSem);
        
        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedTrials';
        analysis.indFly{ff}{end}.snipMat = averagedTrials;
        
        %% Optimally align ROIs before averaging across them
        % First we've gotta find which is the preferred direction for this
        % roi
        if ~simulation
            if ~iscell(flyEyes)
                regCheck = isempty(strfind(lower(epochsForSelectionForFly{iteration, 1}), flyEyes));
            else
                regCheck = isempty(strfind(lower(epochsForSelectionForFly{iteration, 1}), flyEyes{ff}));
            end
        else
            regCheck = regCheckIn;
        end
        [barPairSortingStructure, numPhases, epochsOfInterestFirst] = SortBarPairBarLocations(params{ff}, interleaveEpoch+1);
                barWidth = barPairSortingStructure.barWidth(barPairSortingStructure.bar2contrast==0);
        barWidth = barWidth(end);
        
        
                analysis.indFly{ff} = GetProcessedTrials(roiResponsesOut,epochsForRois,params{ff},dataRate,dataType,varargin{:},'snipShift', 0, 'duration', []);
        
        %% remove epochs you dont want analyzed
        roiAlignResps = analysis.indFly{ff}{end}.snipMat(numIgnore+1:end,:);
        [numEpochs,numROIs(ff)] = size(roiAlignResps);
            
            
            barsOff = params{ff}(14).duration/60;
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
            roiModelMatrixes = [];
            roiModelNeighMatrixes = [];
            if isempty(flyResponseMatrix)
                flyResponseMatrix = zeros(size(roiTrialResponseMatrixes, 1), size(roiTrialResponseMatrixes, 2), numFlies);
            end
            for roiNum = 1:numROIs(ff)
                optimalBar = optimalResponseFieldPerRoi;
                [roiTrialResponseMatrix, matDescription] = ComputeBarPairResponseMatrix(averagedTrials(interleaveEpoch+1:end, roiNum), barPairSortingStructure, barToCenter, mirrorCheck, optimalBar, numPhases);
                %[roiTrialResponseMatrix, matDescription] = ComputeBarPairResponseMatrix_catherine(averagedTrials(interleaveEpoch+1:end, roiNum), barPairSortingStructure, barToCenter, mirrorCheck, optimalBar, realDuration, initialDuration);

               % [roiTrialResponseMatrixSem, matDescriptionSem] = ComputeBarPairResponseMatrix_catherine(averagedTrialsSEM(interleaveEpoch+1:end, roiNum), barPairSortingStructure, barToCenter, mirrorCheck, optimalBar, realDuration, initialDuration);
                
                if ignoreNeighboringBars % This is to combine older data, which has no neighboring responses, with the newere data, so we can look at just the directional responses
                    neighBarPPDescStart = find(strcmp(matDescription(:, 1), '++ Still'));
                    if ~isempty(neighBarPPDescStart)
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
                        
                        phaseChecker = [neighBarPPNumPhases neighBarNNNumPhases neighBarPNNumPhases neighBarNPNumPhases];
                        blockChecker = sort([neighBarPPStart neighBarNNStart neighBarPNStart neighBarNPStart]);
                        % Make sure each of them has the same number of
                        % phases (they really should) and they're in a
                        % contiguous block (also should) so you can snip
                        % out all that part of roiTrialResponseMatrix
                        if all(phaseChecker==phaseChecker(1)) && all(diff(blockChecker) == phaseChecker(1))
                            roiTrialResponseMatrix(blockChecker(1):blockChecker(end)+phaseChecker(1)-1, :) = [];
                            descInds = sort([neighBarPPDescStart neighBarNNDescStart neighBarPNDescStart neighBarNPDescStart]);
                            if all(diff(descInds)==1)
                                matDescription(descInds, :) = []; % we're half assing the fix to matDescription because we don't appropriately change the later rows' third columns
                                params{ff} = params{ff}(cellfun(@(match) isempty(match), regexp({params{ff}.epochName}, 'Sn[+-][+-]')));
                            end
                            if size(roiTrialResponseMatrixes,1) ~= size(roiTrialResponseMatrix, 1)
                                roiTrialResponseMatrixes = zeros(size(roiTrialResponseMatrix, 1) ,length(averagedTrials{1, 1}), numROIs(ff));
                            end
                        else
                            error('Something''s gone wrong in how these phases were defined');
                        end
                    end
                end
                % We're subtracting opposites here (which happen every
                % 2*numPhases
                roiTrialSubOppMatrix = [];
                for subOppInd = 1:2*numPhases:size(roiTrialResponseMatrix, 1)
                    roiTrialSubOppMatrix = [roiTrialSubOppMatrix; roiTrialResponseMatrix(subOppInd:subOppInd+numPhases-1, :) - roiTrialResponseMatrix(subOppInd+numPhases:subOppInd+2*numPhases-1, :)];
                end
                
                roiResps = cat(3, roiResps, roiTrialResponseMatrix);
                
                
                
                
                
                
                numSingleBarRows = 16;
                
                 numSingleBarRows = 40;
                startOfSingleBarPlusRows = size(roiTrialResponseMatrix, 1)-numSingleBarRows+1;
                startOfSingleBarMinusRows = startOfSingleBarPlusRows+numPhases;
                %             switch roiOptimalResponseField
                %                 case {'PPlusPref', 'PPlusNull'}
                linearResponsesPlusPol = roiTrialResponseMatrix(startOfSingleBarPlusRows:startOfSingleBarPlusRows+numPhases-1, :);
                linearResponsesMinusPol = roiTrialResponseMatrix(startOfSingleBarMinusRows:startOfSingleBarMinusRows+numPhases-1, :);
                
       
            
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
                
                linearResponses = cat(3, linearResponsesPlusPol, linearResponsesMinusPol);
                
                modelSingleResponseOneRoi = [];
                modelMatrixOneRoi=[];
                if calculateModelMatrix
                    % polCombos is formatted 
                    % row 1: bar one pol; 
                    % row 2: bar2 pol;
                    % row 3: bar one shift dir; 
                    % its 3x8 because 8 is the eight
                    % matrix combos sa they appear in roiTrialResponseMatrix
                    polCombos = [1 1 2 2 1 1 2 2;
                        1 1 2 2 2 2 1 1;
                        1 -1 1 -1 1 -1 1 -1];
                    tVals = linspace(snipShift/1000, (snipShift+duration)/1000, size(averagedTrials{5}, 1));
                    for combo = 1:size(polCombos, 2)
                        barOne = circshift(linearResponses(:, tVals>0 & tVals<barsOff, polCombos(1, combo)), polCombos(3, combo), 1);
                        barTwo = linearResponses(:, tVals>-secondBarOn & tVals<-secondBarOn+barsOff, polCombos(2, combo));
                        barTwo = barTwo(:, 1:size(barOne, 2));
                        modelMatrixOneRoi = [modelMatrixOneRoi; barOne+barTwo];
                        
                        modelTemp = zeros(size(barTwo)); % We only really care about where the bars appeared
                        modelTemp(4, :) = barTwo(4, :); % 4 is a magic number that represents the 3rd phase (0-indexed) which is where things are aligned
                        % Keep in mind: the non-circshifted version of
                        % barOne wouldn't index barOne, but just take the
                        % optimal center bar at index 4--then we want to
                        % put that response at the location of the
                        % appearance of bar one
                        modelTemp(4+polCombos(3, combo), :) = barOne(4+polCombos(3, combo), :); 
                        modelSingleResponseOneRoi = [modelSingleResponseOneRoi; modelTemp];vvv
                        
                    end
                    
                    
                    neighBarPPDescStart = find(strcmp(matDescription(:, 1), '++ Still'));
                    if ~isempty(neighBarPPDescStart)
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
                        prefToNullShift = 1;
                        nullToPrefShift = -1;
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

                    end
                    
                    % polCombosStill is formatted 
                    % row 1: bar one pol; 
                    % row 2: bar2 pol;
                    % row 3: bar one shift dir; 
                    % row 4: bar two shift dir;
                    % its 4x8 because 8 is the eight matrix combos as they
                    % appear in roiTrialResponseMatrix
                    if ~isempty(neighBarPPDescStart) % Check if there are, in fact, next nearest bars
                        polCombosStill = [1 2 1 1 1 2 1 1;
                            1 2 2 2 1 2 2 2;
                            -1 -1 1 -1 0 0 0 0;
                            1 1 -1 1 1 -1 1 -1];
                    else
                        polCombosStill = [1 2 1 1;
                            1 2 2 2;
                            -1 -1 1 -1;
                            1 1 -1 1];
                    end
                        secondBarOnStill = 0;
                    for combo = 1:size(polCombosStill, 2)
                        barOne = circshift(linearResponses(:, tVals>0 & tVals<barsOff, polCombosStill(1, combo)), polCombosStill(3, combo), 1);
                        barTwo = circshift(linearResponses(:, tVals>-secondBarOnStill & tVals<-secondBarOnStill+barsOff, polCombosStill(2, combo)), polCombosStill(4, combo), 1);
                        barTwo = barTwo(:, 1:size(barOne, 2));
                        modelMatrixOneRoi = [modelMatrixOneRoi; barOne+barTwo];
                        
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
                    
                    % Add back in the single bar responses
                    linearResponsesStill = linearResponses(:, tVals>0 & tVals<barsOff, :);
                    modelMatrixOneRoi = [modelMatrixOneRoi; linearResponsesStill(:, :, 1); linearResponsesStill(:, :, 2)];
                    modelSingleResponseOneRoi = [modelSingleResponseOneRoi; linearResponsesStill(:, :, 1); linearResponsesStill(:, :, 2)];
                    
                    modelMatrixOneRoi = [roiTrialResponseMatrix(1:size(modelMatrixOneRoi,1), tVals<=0), modelMatrixOneRoi, roiTrialResponseMatrix(1:size(modelMatrixOneRoi,1), tVals>=barsOff)];
                                        modelSingleResponseOneRoi = [roiTrialResponseMatrix(1:size(modelSingleResponseOneRoi,1), tVals<=0), modelSingleResponseOneRoi, roiTrialResponseMatrix(1:size(modelSingleResponseOneRoi,1), tVals>=barsOff)];

                                        
                    roiResponseMatrixDirResps = roiTrialResponseMatrix(1:size(modelMatrixOneRoi, 1), :);
                    realMinusLinearResponse = cat(3,realMinusLinearResponse, roiResponseMatrixDirResps-modelMatrixOneRoi);
                    
                                        apparentMinusSingleResponse = cat(3, apparentMinusSingleResponse, roiResponseMatrixDirResps - modelSingleResponseOneRoi);

                                        
                    if ~isempty(neighBarPPDescStart) % Check if there are, in fact, next nearest bars
                        roiResponseMatrixNeighResps = roiTrialResponseMatrix(1:size(modelMatrixNeigh, 1), :);
                        realMinusDoubleResponse = cat(3,realMinusDoubleResponse, roiResponseMatrixNeighResps-modelMatrixNeigh);
                    end
                    
                    
                                        modelMatrixPerRoi = cat(3, modelMatrixPerRoi, modelMatrixOneRoi);
                    modelSingleMatrixPerRoi =  cat(3, modelSingleMatrixPerRoi, modelSingleResponseOneRoi);
                end
                
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
                    %[figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(roiTrialResponseMatrix, roiTrialResponseMatrixSem, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'Real');
                    [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(roiTrialResponseMatrix, roiTrialResponseMatrixSem, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases);

                    fullText = sprintf('%s\n Fly %d - ROI %d/%d\n Real Only', textDirection, ff,  roiNum, numROIs(ff));
                    text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                    if ~isempty(figureHandles{1})
                        figNames = strcat({figureHandles{end}.Name}, 'Real');
                        [figureHandles{end}.Name] = deal(figNames{:});
                    end
%                     figNames = strcat({figureHandles{end}.Name}, 'Real ');
%                     [figureHandles{end}.Name] = deal(figNames{:});
                    
                    if calculateModelMatrix
                        [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(modelMatrixOneRoi, roiTrialResponseMatrix, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'LinModel');
                        fullText = sprintf('%s\n Fly %d - ROI %d/%d\n Model Only', textDirection, ff,  roiNum, numROIs(ff));
                        text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                        figNames = strcat({figureHandles{end}.Name}, 'LModel ');
                        [figureHandles{end}.Name] = deal(figNames{:});
                    end
                    if calculateModelMatrix
                        [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(realMinusLinearResponse(:, :, end), modelMatrixOneRoi, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'Real-LinModel');
                        fullText = sprintf('%s\n Fly %d - ROI %d/%d\n Real - Model', textDirection, ff,  roiNum, numROIs(ff));
                        text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                        figNames = strcat({figureHandles{end}.Name}, 'Real-LModel ');
                        [figureHandles{end}.Name] = deal(figNames{:});
                    end
                    if calculateModelMatrix && ~isempty(neighBarPPDescStart) % Check if there are, in fact, next nearest bars
                        [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(modelMatrixNeigh, roiTrialResponseMatrix, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'NeighModel');
                        fullText = sprintf('%s\n Fly %d - ROI %d/%d\n Real - Neighbor Model', textDirection, ff,  roiNum, numROIs(ff));
                        text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                        figNames = strcat({figureHandles{end}.Name}, 'NModel ');
                        [figureHandles{end}.Name] = deal(figNames{:});
                        
                        [figureHandles{end+1} allAxesHandles{end+1}] = BarPairPlotFunction(realMinusDoubleResponse(:, :, end), modelMatrixNeigh, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'Real-NeighModel');
                        fullText = sprintf('%s\n Fly %d - ROI %d/%d\n Real - Neighbor Model', textDirection, ff,  roiNum, numROIs(ff));
                        text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                        figNames = strcat({figureHandles{end}.Name}, 'Real-NModel ');
                        [figureHandles{end}.Name] = deal(figNames{:});
                    end
                end
                
                
                
                roiTrialResponseMatrixes(:, :, roiNum) = roiTrialResponseMatrix;
                if calculateModelMatrix 
                    roiModelMatrixes(:, :, roiNum) = modelMatrixOneRoi;
                end
                if calculateModelMatrix  && ~isempty(neighBarPPDescStart) % Check if there are, in fact, next nearest bars
                    roiModelNeighMatrixes(:, :, roiNum) = modelMatrixNeigh;
                end
            end
            
            flyResponseMatrix(:, :, ff) = nanmean(roiTrialResponseMatrixes, 3);
            flyResponseMatrixSem(:, :, ff) = NanSem(roiTrialResponseMatrixes, 3)/sqrt(size(roiTrialResponseMatrix, 3));
            
            flyRespSubOppMatrix(:, :, ff) = nanmean(roiTrialSubOppMatrixes, 3);
            flyRespSubOppMatrixSem(:, :, ff) = NanSem(roiTrialSubOppMatrixes, 3);
            
            if calculateModelMatrix
                % Linear responses & real-linear
                flyModelMatrix(:, :, ff) = mean(roiModelMatrixes, 3);
                flyModelSingleMatrix(:, :, ff) = mean(roiModelSingleMatrixes, 3);
                flyRealMinusModelMatrix(:, :, ff) = flyResponseMatrix(1:size(flyModelMatrix, 1), :, ff) - flyModelMatrix(:, :, ff);
                roiRealMinusModelMatrixes =  roiTrialResponseMatrixes(1:size(roiTrialResponseMatrixes, 1), :, :) - roiModelMatrixes;
                flyHereRealMinusSingleMatrix = flyResponseMatrix(1:size(flyModelSingleMatrix, 1), :, ff) - flyModelSingleMatrix(:, :, ff);
                roiRealMinusSingleMatrixes = roiTrialResponseMatrixes(1:size(roiModelSingleMatrixes, 1), :, :) - roiModelSingleMatrixes;
                roiRealMinusSingleMatrixes(roiModelSingleMatrixes == 0) = 0;
                flyHereRealMinusSingleMatrix(flyModelSingleMatrix(:, :, ff)==0) = 0;
                flyRealMinusSingleMatrix(:, :, ff) = flyHereRealMinusSingleMatrix;
                % neighboring bar responses & real-neighboring bar
                if ~isempty(neighBarPPDescStart) % Check if there are, in fact, next nearest bars
                    flyModelNeighMatrix(:, :, ff) = mean(roiModelNeighMatrixes, 3);
                    flyRealMinusNeighMatrix(:, :, ff) = flyResponseMatrix(1:size(flyModelNeighMatrix, 1), :, ff) - flyModelNeighMatrix(:, :, ff);
                    roiRealMinusNeighMatrixes = roiTrialResponseMatrixes(1:size(roiModelNeighMatrixes, 1), :, :) - roiModelNeighMatrixes;
                end
            end
            
            % Actual responses
            if plotIndividualFlies
               % [figureHandles{end+1}, allAxesHandles{end+1}] = BarPairPlotFunction(flyResponseMatrix(:, :, ff), flyResponseMatrixSem(:, :, ff), barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'Real');
                [figureHandles{end+1}, allAxesHandles{end+1}] = BarPairPlotFunction(flyResponseMatrix(:, :, ff), flyResponseMatrixSem(:, :, ff), barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases);
                fullText = sprintf('%s\n Fly %d - all %d ROIs\n Real Only', textDirection, ff,  numROIs(ff));
                text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                if ~isempty(figureHandles{1})
                    figNames = strcat({figureHandles{end}.Name}, 'Real');
                    [figureHandles{end}.Name] = deal(figNames{:});
                end
                
                % Linear and Real - linear responses
                if calculateModelMatrix
                    [figureHandles{end+1}, allAxesHandles{end+1}] = BarPairPlotFunction(roiModelMatrixes, flyResponseMatrix(:, :, ff), barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'LinModel');
                    fullText = sprintf('%s\n Fly %d - all %d ROIs\n Model Only', textDirection, ff,  numROIs(ff));
                    text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                    figNames = strcat({figureHandles{end}.Name}, 'LModel ');
                    [figureHandles{end}.Name] = deal(figNames{:});
                    
                    [figureHandles{end+1}, allAxesHandles{end+1}] = BarPairPlotFunction(roiRealMinusModelMatrixes, modelMatrixOneRoi, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'Real-LinModel');
                    fullText = sprintf('%s\n Fly %d - all %d ROIs\n real-model', textDirection, ff,  numROIs(ff));
                    text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                    figNames = strcat({figureHandles{end}.Name}, 'Real-LModel ');
                    [figureHandles{end}.Name] = deal(figNames{:});
                    
                    [figureHandles{end+1}, allAxesHandles{end+1}] = BarPairPlotFunction(roiRealMinusSingleMatrixes, modelSingleResponseOneRoi, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'Real-LinModel');
                    fullText = sprintf('%s\n Fly %d - all %d ROIs\n real-single', textDirection, ff,  numROIs(ff));
                    text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                    figNames = strcat({figureHandles{end}.Name}, 'Real-Single ');
                    [figureHandles{end}.Name] = deal(figNames{:});
                end
                
                % Real - neighboring bars responses as long as there are, in fact, next nearest bars
                if calculateModelMatrix && ~isempty(neighBarPPDescStart) 
                    [figureHandles{end+1}, allAxesHandles{end+1}] = BarPairPlotFunction(flyModelNeighMatrix(:, :, ff), flyResponseMatrix(:, :, ff), barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'NeighModel');
                    fullText = sprintf('%s\n Fly %d - all %d ROIs\n neigh', textDirection, ff,  numROIs(ff));
                    text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                    figNames = strcat({figureHandles{end}.Name}, 'NModel ');
                    [figureHandles{end}.Name] = deal(figNames{:});
                    
                    [figureHandles{end+1}, allAxesHandles{end+1}] = BarPairPlotFunction(flyRealMinusNeighMatrix(:, :, ff), modelMatrixNeigh, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'Real-NeighModel');
                    fullText = sprintf('%s\n Fly %d - all %d ROIs\n real-neigh', textDirection, ff,  numROIs(ff));
                    text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                    figNames = strcat({figureHandles{end}.Name}, 'Real-NModel ');
                    [figureHandles{end}.Name] = deal(figNames{:});
                end
            end
            
            analysis.indFly{ff}{end+1}.name = 'responseMatrix';
            analysis.indFly{ff}{end}.responseMatrix = flyResponseMatrix(:, :, ff);
            analysis.indFly{ff}{end}.paramsPlot = paramsPlot;
            analysis.indFly{ff}{end}.dataRate = dataRate;
            analysis.indFly{ff} = MakeAnalysisReadable(analysis.indFly{ff});
    end
    flyResponseMatrix(:, :, all(all(flyResponseMatrix==0))) = [];
    if plotFlyAverage
        %[figureHandles{end+1}, allAxesHandles{end+1}] = BarPairPlotFunction(nanmean(flyResponseMatrix, 3), NanSem(flyResponseMatrix, 3), barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'Real');
        [figureHandles{end+1}, allAxesHandles{end+1}] = BarPairPlotFunction(nanmean(flyResponseMatrix, 3), NanSem(flyResponseMatrix, 3), barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases);

        fullText = sprintf('%s\n All flies (%d)\n Real Only', textDirection, numFlies);
        text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
        if ~isempty(figureHandles{1})
            figNames = strcat({figureHandles{end}.Name}, 'Real ');
            [figureHandles{end}.Name] = deal(figNames{:});
        end
        
        if calculateModelMatrix
            % Linear model
            flyModelMatrix(:, :, all(all(flyModelMatrix==0))) = [];
            [figureHandles{end+1}, allAxesHandles{end+1}] = BarPairPlotFunction(nanmean(flyModelMatrix, 3), nanmean(flyResponseMatrix, 3), barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'LinModel');
            fullText = sprintf('%s\n All flies (%d)\n Model Only', textDirection, numFlies);
            text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
            figNames = strcat({figureHandles{end}.Name}, 'LModel ');
            [figureHandles{end}.Name] = deal(figNames{:});
            
            % Real - linear matrix
            flyRealMinusModelMatrix(:, :, all(all(flyRealMinusModelMatrix==0))) = [];
            [figureHandles{end+1}, allAxesHandles{end+1}] = BarPairPlotFunction(nanmean(flyRealMinusModelMatrix, 3), modelMatrixOneRoi, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'Real-LinModel');
            fullText = sprintf('%s\n All flies (%d)\n real-model', textDirection, numFlies);
            text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
            figNames = strcat({figureHandles{end}.Name}, 'Real-LModel ');
            [figureHandles{end}.Name] = deal(figNames{:});
            
            % Real - single matrix
            flyRealMinusSingleMatrix(:, :, all(all(flyRealMinusSingleMatrix==0))) = [];
            [figureHandles{end+1}, allAxesHandles{end+1}] = BarPairPlotFunction(flyRealMinusSingleMatrix, modelSingleResponseOneRoi, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'Real-LinModel');
            fullText = sprintf('%s\n All flies (%d)\n real-single', textDirection, numFlies);
            text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
            figNames = strcat({figureHandles{end}.Name}, 'Real-Single ');
            [figureHandles{end}.Name] = deal(figNames{:});
            
            % Real - neigh matrix if there are neighboring bars
            if ~isempty(neighBarPPDescStart)
                flyModelNeighMatrix(:, :, all(all(flyModelNeighMatrix==0))) = [];
                [figureHandles{end+1}, allAxesHandles{end+1}] = BarPairPlotFunction(nanmean(flyModelNeighMatrix, 3), nanmean(flyResponseMatrix, 3), barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'NeighModel');
                fullText = sprintf('%s\n All flies (%d)\n neigh', textDirection, numFlies);
                text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                figNames = strcat({figureHandles{end}.Name}, 'NModel ');
                [figureHandles{end}.Name] = deal(figNames{:});
                
                flyRealMinusNeighMatrix(:, :, all(all(flyRealMinusNeighMatrix==0))) = [];
                [figureHandles{end+1}, allAxesHandles{end+1}] = BarPairPlotFunction(nanmean(flyRealMinusNeighMatrix, 3), modelMatrixNeigh, barToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'PlotType', 'Real-NeighModel');
                fullText = sprintf('%s\n All flies (%d)\n real-neigh', textDirection, numFlies);
                text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                figNames = strcat({figureHandles{end}.Name}, 'Real-NModel ');
                [figureHandles{end}.Name] = deal(figNames{:});
            end
        end
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