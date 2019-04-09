function analysis = BarPairCompiledRoiAnalysis(flyResp,epochs,params,~ ,dataRate,dataType,~,varargin)
% Call this with an empty roiSelectionFunction--all ROI selection will
% occur in here so we can compile all the ROIs together!

combOpp = 1; % logical for combining symmetic epochs such as left and right
numIgnore = 0; % number of epochs to ignore
numSep = 1; % number of different traces in the paramter file
dataX = [];
labelX = '';
fTitle = '';
flyEyes = [];
epochsForSelectivity = {'' ''};
timeShift = 0;
duration = 2000;
fps = 1;
barToCenter = 2;
plottingFunction = 'PlotBarPairROISummaryTrace';
% Can't instantiate this as empty because plenty of figures will have
% empty names as the default
figureName = 'omgIHopeNoFigureIsEverNamedThis';
figurePlotName = 'COMPILED!';

fprintf('Two plots this time\n');
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

BarPairPlotFunction = str2func(plottingFunction);
%     epochNames = {params.epochName};
% Gotta unwrap these because of how they're put in here
flyEyes = cellfun(@(flEye) flEye{1}, flyEyes, 'UniformOutput', false);
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
roiRespsFly = [];
flyAvgResp = [];
realMinusLinearResponse = [];
modelMatrixPerRoi = [];
optimalResponseFieldPerRoi = [];
for selEpochs = 1:size(epochsForSelectivity, 1)
    for ff = 1:numFlies
        
        numEpochs = length(params{ff});
        epochList = epochs{ff}(:, 1);
        epochStartTimes = cell(numEpochs,1);
        epochDurations = cell(numEpochs,1);
        
        for ee = 1:length(epochStartTimes)
            chosenEpochs = [0; epochList==ee; 0];
            startTimes = find(diff(chosenEpochs)==1);
            endTimes = find(diff(chosenEpochs)==-1)-1;
            
            epochStartTimes{ee} = startTimes;
            epochDurations{ee} = endTimes-startTimes+1;
        end
        [epochsForSelectionForFly, ~, ~] = AdjustEpochsForEye(dataPathsOut{ff}{1}, epochsForSelectivity, {}, varargin{:});
        
        [roiResponsesOut,roiMaskOut, roiIndsOfInterest, pValsSum, valueStruct] = SelectResponsiveRois(flyResp{ff},roiMask{ff},epochStartTimes,epochDurations, epochsForSelectionForFly(selEpochs, :), params{ff}, varargin{:}, 'dataRate', dataRate);
        
        roiResponsesOut = roiResponsesOut{1};
        epochsForRois= epochs{ff}(:, 1:size(roiResponsesOut, 2));
        if isempty(roiResponsesOut)
            continue
        end
        %% get processed trials
        analysis.indFly{ff} = GetProcessedTrials(roiResponsesOut,epochsForRois,params{ff},dataRate,dataType,varargin{:},'snipShift', 0, 'duration', []);
        
        %% remove epochs you dont want analyzed
        roiAlignResps = analysis.indFly{ff}{end}.snipMat(numIgnore+1:end,:);
        [numEpochs,numROIs(ff)] = size(roiAlignResps);
        
        %% Find optimal alignment between ROIs
        % We're making an assumption here that the format for epochs for
        % selection is {dir pref, dir null, pref edge pol, null edge pol}
        edgeEpoch = ConvertEpochNameToIndex(params{ff},epochsForSelectionForFly(selEpochs, 3));
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
        %% average over trials
        averagedTrials = ReduceDimension(droppedNaNTraces,'trials',@nanmean);
        averagedTrialsSEM = ReduceDimension(droppedNaNTraces, 'trials', @NanSem);
        
        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedTrials';
        analysis.indFly{ff}{end}.snipMat = averagedTrials;
        
        %% Optimally align ROIs before averaging across them
        % First we've gotta find which is the preferred direction for this
        % roi
        regCheck = isempty(strfind(lower(epochsForSelectionForFly{selEpochs, 1}), flyEyes{ff}));
        barPairEpochsPhaseAndPolaritySorted = SortBarPairPhaseResponse(params{ff}, flyEyes{ff}, barToCenter, regCheck);
        epochNames = {params{ff}.epochName};
        
        epochNames(barPairEpochsPhaseAndPolaritySorted.PPlusPref)
        barPairDisplacement = round(degreeOptimalDisplacement/params{ff}(end).barWd);
        
        bpEpochFields = fieldnames(barPairEpochsPhaseAndPolaritySorted);
        
        % We only want circular shifts within the fields of this output, so
        % we do this by going field by field.
        % TODO make sure the shifts are in the correct direction!! Also
        % that they are always in that direction for both
        % progressive/regressive and left/right eye distinctions...
        for bpEpochFieldInd = 1:length(bpEpochFields)
            bpEpochField = bpEpochFields{bpEpochFieldInd};
            bpEpochInds = barPairEpochsPhaseAndPolaritySorted.(bpEpochField);
            for roi = 1:numROIs(ff)
                averagedTrials(bpEpochInds, roi) = averagedTrials(circshift(bpEpochInds, barPairDisplacement(roi),2), roi);
                averagedTrialsSEM(bpEpochInds, roi) = averagedTrialsSEM(circshift(bpEpochInds, barPairDisplacement(roi),2), roi);
            end
        end
        
        
        
        % We try to align them all to the 3rd bar, assuming that the preferred
        % direction positive correlations will have the maximum responses
        for roi = 1:numROIs(ff)
            meanPPlusPref = mean(cat(2, averagedTrials{barPairEpochsPhaseAndPolaritySorted.PPlusPref, roi}));
            meanPMinusPref = mean(cat(2, averagedTrials{barPairEpochsPhaseAndPolaritySorted.PMinusPref, roi}));
            [maxPP, locMPP] = max(meanPPlusPref);
            [maxPM, locMPM] = max(meanPMinusPref);
            
            numPhases = length(barPairEpochsPhaseAndPolaritySorted.PPlusPref);
            halfPoint = round(numPhases/2);
            if maxPP>=maxPM
                shift = halfPoint - locMPP;
            else
                shift = halfPoint - locMPM;
            end
            
            for bpEpochFieldInd = 1:length(bpEpochFields)
                bpEpochField = bpEpochFields{bpEpochFieldInd};
                bpEpochInds = barPairEpochsPhaseAndPolaritySorted.(bpEpochField);
                
                averagedTrials(bpEpochInds, roi) = averagedTrials(circshift(bpEpochInds,shift,2), roi);
                averagedTrialsSEM(bpEpochInds, roi) =  averagedTrials(circshift(bpEpochInds, shift,2), roi);
            end
        end
        
        %% Plot individual ROIs
        % regCheck tells us whether we're looking at a regressive
        % layer--true if it's true, which means the primary epoch for
        % selectivity is different than the fly eye
        numPhases = length(barPairEpochsPhaseAndPolaritySorted.PMinusNull);
        % %         regCheck = isempty(strfind(lower(epochsForSelection{1}{1}), 'left'));
        %         for roiNum = 1:size(averagedTrials, 2)
        %             roiResps = cat(3, roiResps, BarPairPlotFunction(averagedTrials(:, roiNum), averagedTrialsSEM(:, roiNum), barPairEpochsPhaseAndPolaritySorted, barToCenter, params{ff}, dataRate, snipShift/1000, duration/1000, regCheck));
        %             roiRespsFly = cat(1, roiRespsFly, ff);
        %             if any(strfind(lower(epochsForSelection{ff}{1}), lower(flyEyes{ff})))
        %                 initTextDirection = epochsForSelection{ff}{3};
        %                 textDirection = ['Progressive  ' initTextDirection(length(flyEyes{ff}+1):end)];
        %             else
        %                 initTextDirection = epochsForSelection{ff}{3};
        %                 textDirection = ['Regressive  ' initTextDirection(length(flyEyes{ff}+2):end)];
        %             end
        %             fullText = sprintf('%s\n Fly %d - ROI %d', textDirection, ff, roiNum);
        %             text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
        % %             text(0, numPhases-1, sprintf('Fly %d - ROI %d', ff, roiNum), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
        %         end
        %% Adjust ROIs for fly
        % Eyes not being empty is an indication that we have to shuffle around
        % epochs to account for progressive/regressive stimulus differences
        % (direction-wise) in different eyes
        if ~isempty(flyEyes)
            %         flyEyes(nonResponsiveFlies) = [];
            rightEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'R'));
            leftEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'L'));
            
            stillEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'S'));
            % We're gonna do this in a left-dominated world, so left eyes
            % don't have to be touched.
            if strfind('right', lower(flyEyes{ff})) % the sorted phases are based on left dominance, so you need to switch right directions to left
                tempAvg = averagedTrials;
                %                 rightEpochs = find(rightEpochs);
                %                 leftEpochs = find(leftEpochs);
                epochPolarities = {'++', '--', '+-', '-+'};
                if ~isempty(tempAvg)
                    for polInd = 1:length(epochPolarities)
                        rightEpochsPol = cellfun(@(foundInds) ~isempty(foundInds), strfind(epochNames, epochPolarities{polInd})) & rightEpochs;
                        leftEpochsPol = cellfun(@(foundInds) ~isempty(foundInds), strfind(epochNames, epochPolarities{polInd})) & leftEpochs;
                        stillEpochsPol = cellfun(@(foundInds) ~isempty(foundInds), strfind(epochNames, epochPolarities{polInd})) & stillEpochs;
                        
                        rightEpochsPol = find(rightEpochsPol);
                        leftEpochsPol = find(leftEpochsPol);
                        stillEpochsPol = find(stillEpochsPol);
                        %                 tempNoTimeAvg = noTimeAveragedRois{i};
                        averagedTrials(rightEpochsPol, :) = tempAvg(leftEpochsPol([1 end:-1:2]), :);
                        % NOTE S-+ and S+- might have to be exchanged here
                        averagedTrials(leftEpochsPol, :) = tempAvg(rightEpochsPol([1 end:-1:2]), :);
                        
                        % Blargh I hate bar pairs but I'm pretty sure this
                        % indexing is the correct one
                        averagedTrials(stillEpochsPol, :) = tempAvg(stillEpochsPol([end:-1:1]), :);
                        %                     noTimeAveragedRois{i}(rightEpochs) = tempNoTimeAvg(leftEpochs);
                        %                     noTimeAveragedRois{i}(leftEpochs) = tempNoTimeAvg(rightEpochs);
                    end
                    
                    stillSingleEpochsPlus = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'S+ '));
                    stillSingleEpochsMinus = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'S- '));
                    
                    
                    stillEpochsPlusPol = find(stillSingleEpochsPlus);
                    stillEpochsMinusPol = find(stillSingleEpochsMinus);
                    % Bar pairs are so quite terrible, but this indexing I
                    % think maybe is the correct one?
                    averagedTrials(stillEpochsPlusPol, :) = tempAvg(stillEpochsPlusPol([2 1 end:-1:3]), :);
                    averagedTrials(stillEpochsMinusPol, :) = tempAvg(stillEpochsMinusPol([2 1 end:-1:3]), :);
                end
            end
            barPairEpochsPhaseAndPolaritySortedLeftDominant = SortBarPairPhaseResponse(params{ff}, 'left', barToCenter, regCheck);
            
            
            if regCheck % Switch it up so it's regressive/progressive split, not pref/null
                PPlusPref = barPairEpochsPhaseAndPolaritySortedLeftDominant.PPlusPref;
                PPlusNull = barPairEpochsPhaseAndPolaritySortedLeftDominant.PPlusNull;
                PMinusPref = barPairEpochsPhaseAndPolaritySortedLeftDominant.PMinusPref;
                PMinusNull = barPairEpochsPhaseAndPolaritySortedLeftDominant.PMinusNull;
                NPlusPref = barPairEpochsPhaseAndPolaritySortedLeftDominant.NPlusPref;
                NPlusNull = barPairEpochsPhaseAndPolaritySortedLeftDominant.NPlusNull;
                NMinusPref = barPairEpochsPhaseAndPolaritySortedLeftDominant.NMinusPref;
                NMinusNull = barPairEpochsPhaseAndPolaritySortedLeftDominant.NMinusNull;
                
                PlusSingle = barPairEpochsPhaseAndPolaritySortedLeftDominant.PlusSingle;
                MinusSingle = barPairEpochsPhaseAndPolaritySortedLeftDominant.MinusSingle;
                PPlusDouble = barPairEpochsPhaseAndPolaritySortedLeftDominant.PPlusDouble;
                PMinusDouble = barPairEpochsPhaseAndPolaritySortedLeftDominant.PMinusDouble;
                NPlusDouble = barPairEpochsPhaseAndPolaritySortedLeftDominant.NPlusDouble;
                NMinusDouble = barPairEpochsPhaseAndPolaritySortedLeftDominant.NMinusDouble;
                
                barPairEpochsPhaseAndPolaritySortedLeftDominant.PPlusPref = PPlusNull(end:-1:1);
                barPairEpochsPhaseAndPolaritySortedLeftDominant.PMinusPref = PMinusNull(end:-1:1);
                barPairEpochsPhaseAndPolaritySortedLeftDominant.NPlusPref = NPlusNull(end:-1:1);
                barPairEpochsPhaseAndPolaritySortedLeftDominant.NMinusPref = NMinusNull(end:-1:1);
                barPairEpochsPhaseAndPolaritySortedLeftDominant.PPlusNull = PPlusPref(end:-1:1);
                barPairEpochsPhaseAndPolaritySortedLeftDominant.PMinusNull = PMinusPref(end:-1:1);
                barPairEpochsPhaseAndPolaritySortedLeftDominant.NPlusNull = NPlusPref(end:-1:1);
                barPairEpochsPhaseAndPolaritySortedLeftDominant.NMinusNull = NMinusPref(end:-1:1);
                
                barPairEpochsPhaseAndPolaritySortedLeftDominant.PlusSingle = PlusSingle(end:-1:1);
                barPairEpochsPhaseAndPolaritySortedLeftDominant.MinusSingle = MinusSingle(end:-1:1);
                barPairEpochsPhaseAndPolaritySortedLeftDominant.PPlusDouble = PPlusDouble(end:-1:1);
                barPairEpochsPhaseAndPolaritySortedLeftDominant.PMinusDouble = PMinusDouble(end:-1:1);
                barPairEpochsPhaseAndPolaritySortedLeftDominant.NPlusDouble = NPlusDouble(end:-1:1);
                barPairEpochsPhaseAndPolaritySortedLeftDominant.NMinusDouble = NMinusDouble(end:-1:1);
            end
            
            
            
            T4check = strfind(lower(epochsForSelectionForFly{selEpochs, 3}), 'light');
            
            % Finding which block of phases should have alignment based on
            % selectivity to light/dark edges and also
            % regressive/progressive splits OR
            % We're finding which *single* bar to align to--they seem to be
            % much better/consistent indicators for the moment...
            if ~isempty(T4check)
                if regCheck
                    fieldOfOptimalResponse = 'PPlusNull';
                else
                    fieldOfOptimalResponse = 'PPlusPref';
                end
%                 fieldOfOptimalResponse = 'PlusSingle';
            else
                if regCheck
                    fieldOfOptimalResponse = 'PMinusNull';
                else
                    fieldOfOptimalResponse = 'PMinusPref';
                end
%                 fieldOfOptimalResponse = 'MinusSingle';
            end
            
            
            barsOff = params{ff}(14).duration/60;
            secondBarOn = params{ff}(14).secondBarDelay;
            for roiNum = 1:numROIs(ff)
                roiTrialResponseMatrix = CalculatedBarPairResponseMatrix(averagedTrials(:, roiNum), barPairEpochsPhaseAndPolaritySortedLeftDominant, fieldOfOptimalResponse, snipShift, duration,barsOff*1000,secondBarOn*1000);
                flyAvgResp = cat(3, flyAvgResp, roiTrialResponseMatrix);
                % We keep track of these to know which single bar response
                % to subtract away
                optimalResponseFieldPerRoi{end+1} = fieldOfOptimalResponse;
                
                
                
                
                
                
                
                numSingleBarRows = 16;
                startOfSingleBarPlusRows = size(roiTrialResponseMatrix, 1)-numSingleBarRows+1;
                startOfSingleBarMinusRows = startOfSingleBarPlusRows+numPhases;
                roiOptimalResponseField = fieldOfOptimalResponse;
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
                
                % polCombos is formatted row 1: bar one pol; row 2: bar2 pol;
                % row 3: bar one shift dir; its 3x8 because 8 is the eight
                % matrix combos sa they appear in roiTrialResponseMatrix
                polCombos = [1 1 2 2 1 1 2 2;
                    1 1 2 2 2 2 1 1;
                    1 -1 1 -1 1 -1 1 -1];
                modelMatrixOneRoi=[];
                tVals = linspace(snipShift/1000, (snipShift+duration)/1000, size(averagedTrials{5}, 1));
                for combo = 1:size(polCombos, 2)
                    barOne = circshift(linearResponses(:, tVals>0 & tVals<barsOff, polCombos(1, combo)), polCombos(3, combo), 1);
                    barTwo = linearResponses(:, tVals>-secondBarOn & tVals<-secondBarOn+barsOff, polCombos(2, combo));
                    barTwo = barTwo(:, 1:size(barOne, 2));
                    modelMatrixOneRoi = [modelMatrixOneRoi; barOne+barTwo];
                end
                
                roiResponseMatrixDirResps = roiTrialResponseMatrix(1:size(modelMatrixOneRoi, 1), tVals>0&tVals<barsOff);
                realMinusLinearResponse = cat(3,realMinusLinearResponse, roiResponseMatrixDirResps-modelMatrixOneRoi);
                
                modelMatrixPerRoi = cat(3, modelMatrixPerRoi, modelMatrixOneRoi);
                
                
                if any(strfind(lower(epochsForSelectionForFly{selEpochs, 1}), lower(flyEyes{ff})))
                    initTextDirection = epochsForSelectionForFly{selEpochs, 3};
                    textDirection = ['Progressive  ' flyEyes{ff} ' ' initTextDirection(length(flyEyes{ff}+1):end)];
                else
                    initTextDirection = epochsForSelectionForFly{selEpochs, 3};
                    textDirection = ['Regressive  ' flyEyes{ff} ' ' initTextDirection(length(flyEyes{ff}+2):end)];
                end
                BarPairPlotFunction(modelMatrixOneRoi, modelMatrixOneRoi, barToCenter, params{ff}(barPairEpochsPhaseAndPolaritySortedLeftDominant.PPlusPref(1)), dataRate, snipShift/1000, duration/1000, regCheck, numPhases);
                fullText = sprintf('%s\n Fly %d - ROI %d/%d\n Model Only', textDirection, ff,  roiNum, numROIs(ff));
                text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                BarPairPlotFunction(roiTrialResponseMatrix, modelMatrixOneRoi, barToCenter, params{ff}(barPairEpochsPhaseAndPolaritySortedLeftDominant.PPlusPref(1)), dataRate, snipShift/1000, duration/1000, regCheck, numPhases);
                fullText = sprintf('%s\n Fly %d - ROI %d/%d\n Real Only', textDirection, ff,  roiNum, numROIs(ff));
                text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                BarPairPlotFunction(realMinusLinearResponse(:, :, end), modelMatrixOneRoi, barToCenter, params{ff}(barPairEpochsPhaseAndPolaritySortedLeftDominant.PPlusPref(1)), dataRate, snipShift/1000, duration/1000, regCheck, numPhases);
                fullText = sprintf('%s\n Fly %d - ROI %d/%d\n Real - Model', textDirection, ff,  roiNum, numROIs(ff));
                text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
                
                
                
                
                
            end
        end
        
        
    end
    keyboard
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
    
end





%% convert from snipMat to matrix wtih averaged flies
averagedFlies = ReduceDimension(averagedROIs,'flies',@nanmean);
averagedFliesSem = ReduceDimension(averagedROIs,'flies',@NanSem);

barPairEpochsPhaseAndPolaritySortedLeftDominant = SortBarPairPhaseResponse(params{ff}, 'left', barToCenter, regCheck);
if regCheck % Switch it up so it's regressive/progressive split, not pref/null
    PPlusPref = barPairEpochsPhaseAndPolaritySortedLeftDominant.PPlusPref;
    PPlusNull = barPairEpochsPhaseAndPolaritySortedLeftDominant.PPlusNull;
    PMinusPref = barPairEpochsPhaseAndPolaritySortedLeftDominant.PMinusPref;
    PMinusNull = barPairEpochsPhaseAndPolaritySortedLeftDominant.PMinusNull;
    NPlusPref = barPairEpochsPhaseAndPolaritySortedLeftDominant.NPlusPref;
    NPlusNull = barPairEpochsPhaseAndPolaritySortedLeftDominant.NPlusNull;
    NMinusPref = barPairEpochsPhaseAndPolaritySortedLeftDominant.NMinusPref;
    NMinusNull = barPairEpochsPhaseAndPolaritySortedLeftDominant.NMinusNull;
    
    barPairEpochsPhaseAndPolaritySortedLeftDominant.PPlusPref = PPlusNull;
    barPairEpochsPhaseAndPolaritySortedLeftDominant.PMinusPref = PMinusNull;
    barPairEpochsPhaseAndPolaritySortedLeftDominant.NPlusPref = NPlusNull;
    barPairEpochsPhaseAndPolaritySortedLeftDominant.NMinusPref = NMinusNull;
    barPairEpochsPhaseAndPolaritySortedLeftDominant.PPlusNull = PPlusPref;
    barPairEpochsPhaseAndPolaritySortedLeftDominant.PMinusNull = PMinusPref;
    barPairEpochsPhaseAndPolaritySortedLeftDominant.NPlusNull = NPlusPref;
    barPairEpochsPhaseAndPolaritySortedLeftDominant.NMinusNull = NMinusPref;
    
    preferredDirectionFields = {'PPlusNull', 'PMinusNull'};
else
    preferredDirectionFields = {'PPlusPref', 'PMinusPref'};
end

if any(strfind(figureName, 'T4' ))
    if regCheck
        traceColor = [1 0 1];
    else
        traceColor = [1 0 0];
    end
elseif any(strfind(figureName, 'T5' ))
    if regCheck
        traceColor = [0 1 0];
    else
        traceColor = [0 0 1];
    end
else
    warning('I dunno what cell type this is! Color''s gonna be gray...' )
    traceColor = [0.5 0.5 0.5];
end

% Get the polarity sorted version for all eyes

%     avgFlyResps = BarPairPlotFunction(averagedFlies{1}, averagedFliesSem{1}, barPairEpochsPhaseAndPolaritySortedLeftDominant, barToCenter, params{ff}, dataRate, snipShift/1000, duration/1000, regCheck, 'preferredDirectionFields', preferredDirectionFields, 'traceColor', traceColor, 'figurePlotName', figurePlotName);
timeShift = snipShift/1000;
durationSeconds = duration/1000;
numTimePoints = size(flyAvgResp, 2);
tVals = linspace(timeShift, timeShift+durationSeconds,numTimePoints);

calciumDelay = 0;
secondBarDelay = params{ff}(14).secondBarDelay+calciumDelay;
bothBarsOff = params{ff}(14).duration/60; % divide by 60 for 60Hz projector

if bothBarsOff<1
    bothBarsOff=bothBarsOff+calciumDelay;
end


%% Here we check covariances mean of second bar presentation (+0.3s for calcium signal delay)
timeAvgResponses  = squeeze(mean(flyAvgResp(:, tVals>secondBarDelay & tVals<bothBarsOff, :), 2));
alphaValue = 1-2*normcdf(-1);% alpha of 1 std
[responseCorrelations, pVals, lower95Perc, upper95perc] = corrcoef(timeAvgResponses', 'alpha', alphaValue);
PlotAnswers(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases)
title('Covar second bar only response mean');

PlotAnswers(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases, false)
title('Covar second bar only response mean fourth phase');

%% Here we check covariances after subracting response of only the first bar
timeAvgBarOneResponses  = mean(flyAvgResp(:, tVals>0 & tVals<secondBarDelay, :), 2);
timeTraceBarTwoResponses  = flyAvgResp(:, tVals>secondBarDelay & tVals<bothBarsOff, :);
timeTraceDiffResponses = squeeze(mean(timeTraceBarTwoResponses - repmat(timeAvgBarOneResponses, [1 size(timeTraceBarTwoResponses, 2) 1]), 2));
%     for diffResp = 1:size(timeTraceDiffResponses, 3)
%         respCorr(:, :, diffResp) = corrcoef(timeTraceDiffResponses(:, :, diffResp)');
%     end
alphaValue = 1-2*normcdf(-1);% alpha of 1 std
[responseCorrelations, pVals, lower95Perc, upper95perc] = corrcoef(timeTraceDiffResponses', 'alpha', alphaValue);
PlotAnswers(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases)
title('Covar second bar minus first bar response mean');
PlotAnswers(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases, false)
title('Covar second bar minus first bar response mean fourth phase');

%% Here we check covariances after subtracting the response to the first bar of the appropriate polarity
% What we do is look only at phase 4 (the purportedly aligned phase)
% Then we subtract the shifted single bar response--shifted so that it
% would appear at the time of the second bar. Then we integrate/mean
% over the second bar region and see what the covariance is
timeAvgOneBarResponses  = mean(flyAvgResp(:, tVals>calciumDelay & tVals<bothBarsOff-secondBarDelay, :), 2);
optimalPhase = 4;
timeTraceBarTwoResponses  = flyAvgResp(:, tVals>secondBarDelay & tVals<bothBarsOff, :);
for roi = 1:length(optimalResponseFieldPerRoi)
    % Note that the last 16 rows are the responses to single bars; the
    % way that CalculateBarPairResponseMatrix outputs them is so that
    % the first eight of those rows is the plus response, and the
    % second eight is the minus response
    numSingleBarRows = 16;
    startOfSingleBarRows = size(timeAvgOneBarResponses, 1)-numSingleBarRows+1;
    plusSingleResponseOptimal = startOfSingleBarRows+optimalPhase-1;
    minusSingleResponseOptimal = startOfSingleBarRows+numPhases+optimalPhase-1;
    roiOptimalResponseField = optimalResponseFieldPerRoi{roi};
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
PlotAnswers(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases, false)
title('Covar second bar minus single bar response mean fourth phase');

%% Here we're looking at the actual responses minus the linear model--this will give us a measure of the interation term
%**** NOT SURE THIS WORKS ****%
numTimePoints = size(realMinusLinearResponse, 2);
tValsModelComp = linspace(0, barsOff,numTimePoints);
modelRealDiffs = squeeze(mean(realMinusLinearResponse(:, tValsModelComp>secondBarDelay & tValsModelComp<=barsOff, :), 2));
[responseCorrelations, pVals, lower95Perc, upper95perc] = corrcoef(modelRealDiffs', 'alpha', alphaValue);
PlotAnswers(responseCorrelations, pVals, lower95Perc, upper95perc, barToCenter, numPhases, true)
title('Covar actual responses - linear response');



respMat = SnipMatToMatrix(averagedFlies); % turn snipMat into a matrix
respMatSep = SeparateTraces(respMat,numSep,''); % separate every numSnips epochs into a new trace to plot
respMatPlot = permute(respMatSep,[3 7 6 1 2 4 5]);
%     respMatPlot = squish(respMatSepPerm); % remove all nonsingleton dimensions

respMatSem = SnipMatToMatrix(averagedFliesSem); % turn snipMat into a matrix
respMatSemSep = SeparateTraces(respMatSem,numSep,''); % separate every numSnips epochs into a new trace to plot
respMatSemPlot = permute(respMatSemSep,[3 7 6 1 2 4 5]);
%     respMatSemPlot = squish(respMatSemPerm); % remove all nonsingleton dimensions

analysis.respMatPlot = respMatPlot;
analysis.respMatSemPlot = respMatSemPlot;


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

function PlotAnswers(responseCorrelations, pVals, lower95Perc, upper95Perc, barToCenter, numPhases, plotAllCovariances)

if nargin < 7
    plotAllCovariances = true;
end

MakeFigure;
optimalPhases = [4, 4+numPhases, 4+2*numPhases, 4+3*numPhases];
numSbpltRows = length(optimalPhases)+1;
minY = [];
maxY = [];
for i = 1:length(optimalPhases)
    if plotAllCovariances
        phasesOfInterest = 1:size(responseCorrelations, 1);
    else
        phasesOfInterest = optimalPhases(1):numPhases:size(responseCorrelations, 1);
    end
    
    sbpltHandles(i) = subplot(numSbpltRows, 1, i+1);
    
    corrOfInt = responseCorrelations(optimalPhases(i), phasesOfInterest);
    lowerVals = lower95Perc(optimalPhases(i), phasesOfInterest);
    upperVals = upper95Perc(optimalPhases(i), phasesOfInterest);
    pValsInt = pVals(optimalPhases(i), phasesOfInterest);
    lowerError = corrOfInt - lowerVals;
    upperError = upperVals - corrOfInt;
    errorVals = cat(3, lowerError', upperError');
    
    dataX = (1:length(corrOfInt))';
    PlotXvsY(dataX, corrOfInt', 'error', errorVals, 'graphType', 'bar' )
    pValStat = 0.05/(length(dataX)-1); % Correcting for multiple comparisons
    plotY = max(upperError+corrOfInt)+0.25;
    text(dataX(pValsInt<pValStat), plotY*ones(sum(pValsInt<pValStat), 1), '*', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [1 0 0]);
    hold on
    plot(dataX(pValsInt<pValStat), plotY*ones(sum(pValsInt<pValStat), 1)+0.25, '*', 'MarkerSize', 0.5);
    axVals = axis;
    minY = [minY axVals(3)];
    maxY = [maxY plotY+0.25];
    if length(optimalPhases)/2>=i && length(optimalPhases)/2<(i+1)
        ylabel('Normalized Correlation');
    end
    axis tight
    set(gca,'box','off');
end

[sbpltHandles.YLim] = deal([min(minY) max(maxY)]);

if plotAllCovariances
    for sbplt = 1:length(sbpltHandles)
        axes(sbpltHandles(sbplt))
        xValsSeparation = [(numPhases+0.5):numPhases:size(responseCorrelations, 1)];
        plot([xValsSeparation; xValsSeparation], bsxfun(@plus, zeros(2, length(xValsSeparation)), [min(minY); max(maxY)]), 'k--');
    end
end

%% Plot directional bar pairs
barColors = [1 1 1; 0 0 0];
barColorOrderOne = [1 2 1 2];
barColorOrderTwo = [1 2 2 1];
% Plotting the actual bar alignment
if barToCenter == 0
    barShift = 0;
elseif barToCenter == 1;
    barShift = 1;
else
    barShift = -1;
end

secondBarDelay = 0.15;
bothBarsOff = 1;
ind = 1;
if plotAllCovariances
    numCols = length(corrOfInt)/numPhases;
else
    numCols = length(corrOfInt);
end

for i = 1:4
    barsPlot = subplot(numSbpltRows, numCols, i*2-1);
    axis([0 bothBarsOff -3.5 4.5])
    patch([0 0 bothBarsOff bothBarsOff], [1.5 2.5 2.5 1.5], barColors(barColorOrderOne(ind), :))
    patch([secondBarDelay secondBarDelay bothBarsOff bothBarsOff], [0.5 1.5 1.5 0.5], barColors(barColorOrderTwo(ind), :))
    
    barsPlot.Color = get(gcf,'color');
    barsPlot.YColor = get(gcf,'color');
    barsPlot.XTick = [0 secondBarDelay bothBarsOff];
    barsPlot.XTickLabel = [0 secondBarDelay bothBarsOff];
    xlabel('Time (s)');
    
    barsPlot = subplot(numSbpltRows, numCols, i*2);
    axis([0 bothBarsOff -3.5 4.5])
    patch([0 0 bothBarsOff bothBarsOff], [0.5 1.5 1.5 0.5] + barShift, barColors(barColorOrderOne(ind), :))
    patch([secondBarDelay secondBarDelay bothBarsOff bothBarsOff], [1.5 2.5 2.5 1.5] + barShift, barColors(barColorOrderTwo(ind), :))
    
    ind = ind + 1;
    barsPlot.Color = get(gcf,'color');
    barsPlot.YColor = get(gcf,'color');
    barsPlot.XTick = [0 secondBarDelay bothBarsOff];
    barsPlot.XTickLabel = [0 secondBarDelay bothBarsOff];
    xlabel('Time (s)');
end

%% Plot still double bars
if numCols>8
    barColors = [1 1 1; 0 0 0];
    barColorOrderOne = [1 2 1 2];
    barColorOrderTwo = [1 2 2 1];
    ind = 1;
    for i = 5:6
        secondBarDelay = 0;
        
        barsPlot = subplot(numSbpltRows, numCols, i*2-1);
        axis([0 bothBarsOff -3.5 4.5])
        patch([0 0 bothBarsOff bothBarsOff], [1.5 2.5 2.5 1.5], barColors(barColorOrderOne(ind), :))
        patch([secondBarDelay secondBarDelay bothBarsOff bothBarsOff], [-0.5 0.5 0.5 -0.5], barColors(barColorOrderTwo(ind), :))
        
        ind = ind + 1;
        barsPlot.Color = get(gcf,'color');
        barsPlot.YColor = get(gcf,'color');
        barsPlot.XTick = [0 bothBarsOff];
        barsPlot.XTickLabel = [0 bothBarsOff];
        xlabel('Time (s)');
        
        barsPlot = subplot(numSbpltRows, numCols, i*2);
        axis([0 bothBarsOff -3.5 4.5])
        patch([0 0 bothBarsOff bothBarsOff], [1.5 2.5 2.5 1.5], barColors(barColorOrderOne(ind), :))
        patch([secondBarDelay secondBarDelay bothBarsOff bothBarsOff], [-0.5 0.5 0.5 -0.5], barColors(barColorOrderTwo(ind), :))
        
        ind = ind + 1;
        barsPlot.Color = get(gcf,'color');
        barsPlot.YColor = get(gcf,'color');
        barsPlot.XTick = [0 bothBarsOff];
        barsPlot.XTickLabel = [0 bothBarsOff];
        xlabel('Time (s)');
    end
end

%% Plot single bars
if numCols>12
    barColors = [1 1 1; 0 0 0];
    barColorOrderOne = [1 2];
    ind = 1;
    for i = 7
        secondBarDelay = 0;
        barsPlot = subplot(numSbpltRows, numCols, i*2-1);
        axis([0 bothBarsOff -3.5 4.5])
        patch([secondBarDelay secondBarDelay bothBarsOff bothBarsOff], [0.5 1.5 1.5 0.5], barColors(barColorOrderOne(ind), :))
        
        ind = ind + 1;
        barsPlot.Color = get(gcf,'color');
        barsPlot.YColor = get(gcf,'color');
        barsPlot.XTick = [0 bothBarsOff];
        barsPlot.XTickLabel = [0 bothBarsOff];
        xlabel('Time (s)');
        
        barsPlot = subplot(numSbpltRows, numCols, i*2);
        axis([0 bothBarsOff -3.5 4.5])
        patch([secondBarDelay secondBarDelay bothBarsOff bothBarsOff], [0.5 1.5 1.5 0.5], barColors(barColorOrderOne(ind), :))
        
        ind = ind + 1;
        barsPlot.Color = get(gcf,'color');
        barsPlot.YColor = get(gcf,'color');
        barsPlot.XTick = [0 bothBarsOff];
        barsPlot.XTickLabel = [0 bothBarsOff];
        xlabel('Time (s)');
        
    end
    
end

end