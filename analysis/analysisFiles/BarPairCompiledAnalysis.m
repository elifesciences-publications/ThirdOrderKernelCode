 function analysis = BarPairCompiledAnalysis(flyResp,epochs,params,~ ,dataRate,dataType,~,varargin)
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
    
    % If figureName is a cell, we need to change it depending on the
    % iteration (i.e. depending on the ROIs we've selected)
    if iscell(figureName) && length(figureName)>1
        figureName = figureName{iteration};
    end
    
    if numFlies==0
        analysis = [];
        return
    end
    
    
    
    numROIs = zeros(1, numFlies);
    % run the algorithm for each fly
    roiResps = [];
    roiRespsFly = [];
    flyAvgResp = [];
    averagedTrialsOut = [];
    for ff = 1:numFlies
        
        %% get processed trials
        analysis.indFly{ff} = GetProcessedTrials(flyResp{ff},epochs{ff},params{ff},dataRate,dataType,varargin{:},'snipShift', 0, 'duration', []);

        %% remove epochs you dont want analyzed
        roiAlignResps = analysis.indFly{ff}{end}.snipMat(numIgnore+1:end,:);
        [numEpochs,numROIs(ff)] = size(roiAlignResps);
        
        %% Find optimal alignment between ROIs
        % We're making an assumption here that the format for epochs for
        % selection is {dir pref, dir null, pref edge pol, null edge pol}
        edgeEpoch = ConvertEpochNameToIndex(params{ff},epochsForSelection{ff}(3));
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
        roiBorderedResps = GetProcessedTrials(flyResp{ff},epochs{ff},params{ff},dataRate,dataType,varargin{:},'snipShift', snipShift, 'duration', duration);
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
        regCheck = isempty(strfind(lower(epochsForSelection{ff}{1}), flyEyes{ff}));
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
        
        T4check = strfind(lower(epochsForSelection{ff}{3}), 'light');
        % Finding which block of phases should have alignment based on
        % selectivity to light/dark edges and also
        % regressive/progressive splits
        if ~isempty(T4check)
            fieldOfOptimalResponse = 'PPlusPref';
        else
            fieldOfOptimalResponse = 'PMinusPref';
        end
        
        
        % We try to align them all to the 3rd bar, assuming that the preferred
        % direction positive correlations will have the maximum responses
        for roi = 1:numROIs(ff)
            
            % We try to align them all to the 3rd bar, using the selectivity based
            % block of responses to determine where the maximal response should be
            optimalResponseBlock = barPairEpochsPhaseAndPolaritySorted.(fieldOfOptimalResponse);
            meanOptimalResponse = mean(cat(2, averagedTrials{optimalResponseBlock, roi}));
            [~, locMOR] = max(meanOptimalResponse);
            
            numPhases = length(barPairEpochsPhaseAndPolaritySorted.(fieldOfOptimalResponse));
            halfPoint = round(numPhases/2);
            
            shift = halfPoint - locMOR;
            % shift
    
            for bpEpochFieldInd = 1:length(bpEpochFields)
                bpEpochField = bpEpochFields{bpEpochFieldInd};
                bpEpochInds = barPairEpochsPhaseAndPolaritySorted.(bpEpochField);
                
                averagedTrials(bpEpochInds, roi) = averagedTrials(circshift(bpEpochInds,shift,2), roi);
                averagedTrialsSEM(bpEpochInds, roi) =  averagedTrialsSEM(circshift(bpEpochInds, shift,2), roi);
            end
        end
        
        averagedTrialsOut{ff} = averagedTrials;
        %% Plot individual ROIs
        % regCheck tells us whether we're looking at a regressive
        % layer--true if it's true, which means the primary epoch for
        % selectivity is different than the fly eye
        numPhases = length(barPairEpochsPhaseAndPolaritySorted.PMinusNull);
        regCheck = isempty(strfind(lower(epochsForSelection{ff}{1}), flyEyes{ff}));
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

         %% Reaverage over all ROIs <.<
%         T4check = strfind(lower(epochsForSelection{ff}{3}), 'light');
% 
%         % Finding which block of phases should have alignment based on
%         % selectivity to light/dark edges and also
%         % regressive/progressive splits
%         if ~isempty(T4check)
%             fieldOfOptimalResponse = 'PPlusPref';
%         else
%             fieldOfOptimalResponse = 'PMinusPref';
%         end
%         
%         for roi = 1:numROIs(ff)
%             roiTrialResponseMatrix(:, :, roi) = CalculatedBarPairResponseMatrix(averagedTrials(:, roi), barPairEpochsPhaseAndPolaritySorted, fieldOfOptimalResponse);
%         end
%         
%         avgRoiResponseMatrix = nanmean(roiTrialResponseMatrix, 3);
%         semRoiResponseMatrix = nanstd(roiTrialResponseMatrix, [], 3)/size(roiTrialResponseMatrix, 3);

        %% average over ROIs
        averagedROIs{ff} = ReduceDimension(averagedTrials,'Rois',@nanmean);
        averagedROIsSEM{ff} = ReduceDimension(averagedTrials, 'Rois', @NanSem);
        
    
        fprintf('%d ROIs for fly %d\n', numROIs(ff), ff);
        % regCheck tells us whether we're looking at a regressive
        % layer--true if it's true, which means the primary epoch for
        % selectivity is different than the fly eye
        regCheck = isempty(strfind(lower(epochsForSelection{ff}{1}), flyEyes{ff}));
       
% %         regCheck = isempty(strfind(lower(epochsForSelection{1}{1}), 'left'));
%         BarPairPlotFunction(averagedROIs{ff}, averagedROIsSEM{ff}, barPairEpochsPhaseAndPolaritySorted, barToCenter, params{ff}, dataRate, snipShift/1000, duration/1000, regCheck);
%         if any(strfind(lower(epochsForSelection{ff}{1}), lower(flyEyes{ff})))
%             initTextDirection = epochsForSelection{ff}{3};
%             textDirection = ['Progressive  ' initTextDirection(length(flyEyes{ff}+1):end)];
%         else
%             initTextDirection = epochsForSelection{ff}{3};
%             textDirection = ['Regressive  ' initTextDirection(length(flyEyes{ff}+2):end)];
%         end
%         fullText = sprintf('%s\n Fly %d - Num ROIs %d', textDirection, ff,  numROIs(ff));
%         text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
% %         text(0, numPhases-1, sprintf('Fly %d - Num ROIs %d', ff, numROIs(ff)), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
%         plotFigure = gcf;
%         set(findall(plotFigure,'-property','FontName'),'FontName', 'Ebrima')
%         text(0, 0, epochsForSelection{ff}{3}, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle')
        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedROIs';
        analysis.indFly{ff}{end}.snipMat = averagedROIs;
        
        %% make analysis readable
        analysis.indFly{ff} = MakeAnalysisReadable(analysis.indFly{ff});
        
        
    end
    
    % Eyes not being empty is an indication that we have to shuffle around
    % epochs to account for progressive/regressive stimulus differences
    % (direction-wise) in different eyes
    roiAvgResp = [];
    if ~isempty(flyEyes)
%         flyEyes(nonResponsiveFlies) = [];
        rightEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'R'));
        leftEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'L'));
        % We're gonna do this in a left-dominated world, so left eyes
        % don't have to be touched.
        for i = 1:length(flyEyes)
            if strfind('right', lower(flyEyes{i}))
                tempAvgRois = averagedROIs{i};
                tempAvgTrialsOut = averagedTrialsOut{i};
%                 rightEpochs = find(rightEpochs);
%                 leftEpochs = find(leftEpochs);
                epochPolarities = {'++', '--', '+-', '-+'};
                if ~isempty(tempAvgRois)
                    for polInd = 1:length(epochPolarities)
                        rightEpochsPol = cellfun(@(foundInds) ~isempty(foundInds), strfind(epochNames, epochPolarities{polInd})) & rightEpochs;
                        leftEpochsPol = cellfun(@(foundInds) ~isempty(foundInds), strfind(epochNames, epochPolarities{polInd})) & leftEpochs;
                        
                        rightEpochsPol = find(rightEpochsPol);
                        leftEpochsPol = find(leftEpochsPol);
                        %                 tempNoTimeAvg = noTimeAveragedRois{i};
                        averagedROIs{i}(rightEpochsPol) = tempAvgRois(leftEpochsPol([1 end:-1:2]));
                        averagedROIs{i}(leftEpochsPol) = tempAvgRois(rightEpochsPol([1 end:-1:2]));
                        averagedTrialsOut{i}(rightEpochsPol, :) = tempAvgTrialsOut(leftEpochsPol([1 end:-1:2]), :);
                        averagedTrialsOut{i}(leftEpochsPol, :) = tempAvgTrialsOut(rightEpochsPol([1 end:-1:2]), :);
                        %                     noTimeAveragedRois{i}(rightEpochs) = tempNoTimeAvg(leftEpochs);
                        %                     noTimeAveragedRois{i}(leftEpochs) = tempNoTimeAvg(rightEpochs);
                    end
                end
            end
            barPairEpochsPhaseAndPolaritySortedLeftDominant = SortBarPairPhaseResponse(params{ff}, 'left', barToCenter, regCheck);
            flyAvgResp = cat(3, flyAvgResp, CalculatedBarPairResponseMatrix(averagedROIs{i}, barPairEpochsPhaseAndPolaritySortedLeftDominant));
            
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
            
            T4check = strfind(lower(epochsForSelection{ff}{3}), 'light');
            
            % Finding which block of phases should have alignment based on
            % selectivity to light/dark edges and also
            % regressive/progressive splits
            if ~isempty(T4check)
                fieldOfOptimalResponse = preferredDirectionFields{1};
            else
                fieldOfOptimalResponse = preferredDirectionFields{2};
            end
            
            for roi = 1:size(averagedTrialsOut{i}, 2)
                roiAvgResp = cat(3, roiAvgResp, CalculatedBarPairResponseMatrix(averagedTrialsOut{i}(:, roi), barPairEpochsPhaseAndPolaritySortedLeftDominant, fieldOfOptimalResponse));
            end
        end
    end
    
    
    
    %% convert from snipMat to matrix with averaged flies
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
    
    
    
    T4check = strfind(lower(epochsForSelection{1}{3}), 'light');
    if ~isempty(T4check)
        if regCheck
            traceAvgColor = [1 0 1];
            traceRoiColor = [1 0.7 1];
        else
            traceAvgColor = [1 0 0];
            traceRoiColor = [1 0.7 0.7];
        end
        fieldOfOptimalResponse = preferredDirectionFields{1};
    else
        if regCheck
            traceAvgColor = [0 1 0];
            traceRoiColor = [0.7 1 0.7];
        else
            traceAvgColor = [0 0 1];
            traceRoiColor = [0.7 0.7 1];
        end
        fieldOfOptimalResponse = preferredDirectionFields{2};
%     else
%         warning('I dunno what cell type this is! Color''s gonna be gray...' )
%         traceColor = [0.5 0.5 0.5];
    end
    
    % Get the polarity sorted version for all eyes
    [averagedRoisRespBtstrp, averagedRoisCrossCorrBtstrp, averagedRoisSemBootstrap, averagedRoisCrossCorrSemBootstrap] = BootstrapAnalysis(roiAvgResp, numPhases);
    barPairResponseMatrix = CalculatedBarPairResponseMatrix(averagedFlies{1}, barPairEpochsPhaseAndPolaritySortedLeftDominant, fieldOfOptimalResponse);
%     barPairResponseSemMatrix = CalculatedBarPairResponseMatrix(averagedFliesSem{1}, barPairEpochsPhaseAndPolaritySortedLeftDominant, fieldOfOptimalResponse);
%     avgFlyResps = BarPairPlotFunction(barPairResponseMatrix, barPairResponseSemMatrix, barToCenter, params{ff}(barPairEpochsPhaseAndPolaritySortedLeftDominant.PPlusPref(1)), dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'preferredDirectionFields', preferredDirectionFields, 'traceColor', traceColor, 'figurePlotName', figurePlotName);
%     BarPairPlotFunction(roiAvgResp, [], barToCenter, params{ff}(barPairEpochsPhaseAndPolaritySortedLeftDominant.PPlusPref(1)), dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'preferredDirectionFields', preferredDirectionFields, 'traceColor', traceRoiColor, 'figurePlotName', figureName);
    % NOTE THIS ENTIRE THING IS NOW BY ROI!!!!
    BarPairPlotFunction(mean(roiAvgResp, 3), averagedRoisSemBootstrap, barToCenter, params{ff}(barPairEpochsPhaseAndPolaritySortedLeftDominant.PPlusPref(1)), dataRate, snipShift/1000, duration/1000, regCheck, numPhases, 'preferredDirectionFields', preferredDirectionFields, 'traceColor', traceAvgColor, 'figurePlotName', figureName);
    timeShift = snipShift/1000;
    durationSeconds = duration/1000;
    numTimePoints = size(flyAvgResp, 2);
    tVals = linspace(timeShift, timeShift+durationSeconds,numTimePoints);
%     [averagedFliesResp, averagedFliesCrossCorr, averagedFliesSemBootstrap, averagedFliesCrossCorrSemBootstrap] = BootstrapAnalysis(flyAvgResp(:, tVals>0.15 & tVals<0.65, :), numPhases);
%     % This is based on how CalculatedBarPairResponseMatrix works
%     optimalPhase = 4;
%     T4check = strfind(lower(epochsForSelection{1}{3}), 'light');
%     
%     if ~isempty(T4check)
%         crossCorrOfInterest = optimalPhase; % This is because the ++ pref responses are the first 8
%     else
%         crossCorrOfInterest = optimalPhase+numPhases; % This is because the -- pref responses are the second 8
%     end
%     
%     phaseOfInterest = optimalPhase:numPhases:size(averagedFliesCrossCorr, 1);
%     
%     corrComparisons = averagedFliesCrossCorr(crossCorrOfInterest, phaseOfInterest);
%     corrComparisonErrors = averagedFliesCrossCorrSemBootstrap(crossCorrOfInterest, phaseOfInterest);
%     MakeFigure;PlotXvsY((1:8)', corrComparisons', 'error', corrComparisonErrors', 'graphType', 'bar' )
    
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
 numBootstraps = 10000;
 
 numFlies = size(phaseResponses, 3);
 
 
 btstrpMeanResponse = zeros(size(phaseResponses, 1), size(phaseResponses, 2), numBootstraps);
 btstrpCrossCorrs = zeros(size(phaseResponses, 1), size(phaseResponses, 1), numBootstraps);
 
 for btstrp = 1:numBootstraps
     replacement = true;
     phaseIndsRand = randsample(numPhaseResponses,numPhaseResponses,replacement);
     flyIndsRan = randsample(numFlies, numFlies, replacement);
     meanResponsesBtstrp = mean(phaseResponses(phaseIndsRand, :, flyIndsRan), 3);
     crossCorrelationBtsrp = corrcoef(meanResponsesBtstrp');
     btstrpMeanResponse(:, :, btstrp) = meanResponsesBtstrp;
     btstrpCrossCorrs(:, :, btstrp) = crossCorrelationBtsrp;%ReduceDimension(cat(2, subTrialsROI{flyInds}),'Rois',@nanmean);
 end
 
 
 meanResponse = mean(btstrpMeanResponse, 3);
 crossCorrelation = corrcoef(meanResponse');
 
 meanResponseError = nanstd(btstrpMeanResponse, [], 3);
 crossCorrsError = nanstd(btstrpCrossCorrs, [], 3);
 
 %% This code is if we want to restrict bootstrapping within the epoch type (i.e. L+-) for all phases
%  numPhaseResponses = size(phaseResponses, 1);
%  numBootstraps = 1000;
%  shifts = 0:8:numPhaseResponses-1;
%  
%  numFlies = size(phaseResponses, 3);
%  
%  meanResponse = mean(phaseResponses, 3);
%  crossCorrelation = corrcoef(meanResponse');
%  
%  btstrpMeanResponse = zeros(size(phaseResponses, 1), size(phaseResponses, 2), numBootstraps);
%  btstrpCrossCorrs = zeros(size(phaseResponses, 1), size(phaseResponses, 1), numBootstraps);
%  
%  for btstrp = 1:numBootstraps
%      replacement = true;
%      phaseIndsInit = randsample(numPhases,numPhases,replacement);
%      flyIndsRan = randsample(numFlies, numFlies, replacement);
%      phaseIndsRep = repmat(phaseIndsInit, 1, numPhaseResponses/numPhases);
%      phaseIndsShifted = bsxfun(@plus, phaseIndsRep, shifts);
%      phaseIndsShifted = phaseIndsShifted(:);
%      meanResponsesBtstrp = mean(phaseResponses(phaseIndsShifted, :, flyIndsRan), 3);
%      meanSubMeanResponsesBstrp = bsxfun(@minus, meanResponsesBtstrp, mean(meanResponsesBtstrp, 2));
%      crossCorrelationBtsrp = corrcoef(meanResponsesBtstrp');
%      btstrpMeanResponse(:, :, btstrp) = meanResponsesBtstrp;
%      btstrpCrossCorrs(:, :, btstrp) = crossCorrelationBtsrp;%ReduceDimension(cat(2, subTrialsROI{flyInds}),'Rois',@nanmean);
%  end
%  
%  meanResponseError = nanstd(btstrpMeanResponse, [], 3);
%  crossCorrsError = nanstd(btstrpCrossCorrs, [], 3);
 
 end