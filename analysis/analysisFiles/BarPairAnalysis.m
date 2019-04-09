 function analysis = BarPairAnalysis(flyResp,epochs,params,~ ,dataRate,dataType,~,varargin)
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
    
    if numFlies==0
        analysis = [];
        return
    end
    
    
    
    numROIs = zeros(1, numFlies);
    % run the algorithm for each fly
    roiResps = [];
    roiRespsFly = [];
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
        
        %% Plot individual ROIs
        % regCheck tells us whether we're looking at a regressive
        % layer--true if it's true, which means the primary epoch for
        % selectivity is different than the fly eye
        numPhases = length(barPairEpochsPhaseAndPolaritySorted.PMinusNull);
%         regCheck = isempty(strfind(lower(epochsForSelection{ff}{1}), flyEyes{ff}));
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
        T4check = strfind(lower(epochsForSelection{ff}{3}), 'light');

        % Finding which block of phases should have alignment based on
        % selectivity to light/dark edges and also
        % regressive/progressive splits
        if ~isempty(T4check)
            fieldOfOptimalResponse = 'PPlusPref';
        else
            fieldOfOptimalResponse = 'PMinusPref';
        end
        
        roiTrialResponseMatrix = [];
        % The fifth epoch in averagedTrials should have the full duration
        tVals = linspace(snipShift/1000, (snipShift+duration)/1000, size(averagedTrials{5}, 1));
        barsOff = params{ff}(14).duration/60;
        secondBarOn = params{ff}(14).secondBarDelay;
        for roi = 1:numROIs(ff)
            roiTrialResponseMatrix(:, :, roi) = CalculatedBarPairResponseMatrix(averagedTrials(:, roi), barPairEpochsPhaseAndPolaritySorted, fieldOfOptimalResponse, snipShift/1000, duration/1000, barsOff);
            %        BarPairPlotFunction(roiTrialResponseMatrix(:, :, roi), zeros(size(roiTrialResponseMatrix(:, :, roi))), barToCenter, params{ff}(barPairEpochsPhaseAndPolaritySorted.PPlusPref(1)), dataRate, snipShift/1000, duration/1000, regCheck, numPhases);
            % Note that the last 16 rows are the responses to single bars; the
            % way that CalculateBarPairResponseMatrix outputs them is so that
            % the first eight of those rows is the plus response, and the
            % second eight is the minus response
            numSingleBarRows = 16;
            startOfSingleBarPlusRows = size(roiTrialResponseMatrix, 1)-numSingleBarRows+1;
            startOfSingleBarMinusRows = startOfSingleBarPlusRows+numPhases;
            roiOptimalResponseField = fieldOfOptimalResponse;
%             switch roiOptimalResponseField
%                 case {'PPlusPref', 'PPlusNull'}
                    linearResponsesPlusPol = roiTrialResponseMatrix(startOfSingleBarPlusRows:startOfSingleBarPlusRows+numPhases-1, :, roi);
                    linearResponsesMinusPol = roiTrialResponseMatrix(startOfSingleBarMinusRows:startOfSingleBarMinusRows+numPhases-1, :, roi);
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
            for combo = 1:size(polCombos, 2)
                barOne = circshift(linearResponses(:, tVals>0 & tVals<barsOff, polCombos(1, combo)), polCombos(3, combo), 1);
                barTwo = linearResponses(:, tVals>-secondBarOn & tVals<-secondBarOn+barsOff, polCombos(2, combo));
                barTwo = barTwo(:, 1:size(barOne, 2));
                modelMatrixOneRoi = [modelMatrixOneRoi; barOne+barTwo];
            end
            
            modelMatrixPerRoi(:, :, roi) = modelMatrixOneRoi;
            roiResponseMatrixDirResps = roiTrialResponseMatrix(1:size(modelMatrixOneRoi, 1), tVals>0&tVals<barsOff, roi);
            realMinusLinearResponse(:, :, roi) = roiResponseMatrixDirResps-modelMatrixOneRoi;
            % Then we sum them
        end
        
        avgRoiResponseMatrix = nanmean(roiTrialResponseMatrix, 3);
        semRoiResponseMatrix = nanstd(roiTrialResponseMatrix, [], 3)/sqrt(size(roiTrialResponseMatrix, 3));
        
        avgRoiDiffLinearResponseMatrix = nanmean(realMinusLinearResponse, 3);
        semRoiDiffLinearResponseMatrix = nanstd(realMinusLinearResponse, [], 3)/sqrt(size(realMinusLinearResponse, 3));
        
        avgModelRespMat = nanmean(modelMatrixPerRoi, 3);

       

        %% average over ROIs
%         averagedROIs{ff} = ReduceDimension(averagedTrials,'Rois',@nanmean);
%         averagedROIsSEM{ff} = ReduceDimension(averagedTrials, 'Rois', @NanSem);
        fprintf('%d ROIs for fly %d\n', numROIs(ff), ff);

        
%             barPairResponseMatrix = CalculatedBarPairResponseMatrix(averagedROIs{ff}, barPairEpochsPhaseAndPolaritySorted, fieldOfOptimalResponse);
%             BarPairPlotFunction(averagedROIs{ff}, averagedROIsSEM{ff}, barPairEpochsPhaseAndPolaritySorted, barToCenter, params{ff}, dataRate, snipShift/1000, duration/1000, regCheck);
        BarPairPlotFunction(avgRoiResponseMatrix, semRoiResponseMatrix, barToCenter, params{ff}(barPairEpochsPhaseAndPolaritySorted.PPlusPref(1)), dataRate, snipShift/1000, duration/1000, regCheck, numPhases);
        if any(strfind(lower(epochsForSelection{ff}{1}), lower(flyEyes{ff})))
            initTextDirection = epochsForSelection{ff}{3};
            textDirection = ['Progressive  ' initTextDirection(length(flyEyes{ff}+1):end)];
        else
            initTextDirection = epochsForSelection{ff}{3};
            textDirection = ['Regressive  ' initTextDirection(length(flyEyes{ff}+2):end)];
        end
        fullText = sprintf('%s\n Fly %d - Num ROIs %d', textDirection, ff,  numROIs(ff));
        text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
        text(0, numPhases-1, sprintf('Fly %d - Num ROIs %d', ff, numROIs(ff)), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
        plotFigure = gcf;
        set(findall(plotFigure,'-property','FontName'),'FontName', 'Ebrima')
%         text(0, 0, epochsForSelection{ff}{3}, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle')
        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedROIs';
        analysis.indFly{ff}{end}.snipMat = avgRoiResponseMatrix;
        
        %% Plot those linear response diffs!
        BarPairPlotFunction(avgRoiDiffLinearResponseMatrix, semRoiDiffLinearResponseMatrix, barToCenter, params{ff}(barPairEpochsPhaseAndPolaritySorted.PPlusPref(1)), dataRate, 0, params{ff}(14).duration/60, regCheck, numPhases);
        if any(strfind(lower(epochsForSelection{ff}{1}), lower(flyEyes{ff})))
            initTextDirection = epochsForSelection{ff}{3};
            textDirection = ['Progressive  ' initTextDirection(length(flyEyes{ff}+1):end)];
        else
            initTextDirection = epochsForSelection{ff}{3};
            textDirection = ['Regressive  ' initTextDirection(length(flyEyes{ff}+2):end)];
        end
        fullText = sprintf('%s\n Fly %d - Num ROIs %d\n Model Diff', textDirection, ff,  numROIs(ff));
        text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
        text(0, numPhases-1, sprintf('Fly %d - Num ROIs %d', ff, numROIs(ff)), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
        plotFigure = gcf;
        set(findall(plotFigure,'-property','FontName'),'FontName', 'Ebrima')
        
         BarPairPlotFunction(avgModelRespMat, avgModelRespMat, barToCenter, params{ff}(barPairEpochsPhaseAndPolaritySorted.PPlusPref(1)), dataRate, 0, params{ff}(14).duration/60, regCheck, numPhases);
        if any(strfind(lower(epochsForSelection{ff}{1}), lower(flyEyes{ff})))
            initTextDirection = epochsForSelection{ff}{3};
            textDirection = ['Progressive  ' initTextDirection(length(flyEyes{ff}+1):end)];
        else
            initTextDirection = epochsForSelection{ff}{3};
            textDirection = ['Regressive  ' initTextDirection(length(flyEyes{ff}+2):end)];
        end
        fullText = sprintf('%s\n Fly %d - Num ROIs %d\n Model Only', textDirection, ff,  numROIs(ff));
        text(0, 0, fullText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
        text(0, numPhases-1, sprintf('Fly %d - Num ROIs %d', ff, numROIs(ff)), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
        plotFigure = gcf;
        set(findall(plotFigure,'-property','FontName'),'FontName', 'Ebrima')
        
        
        analysis.indFly{ff}{end+1}.name = 'averagedROIsDiffLinearModel';
        analysis.indFly{ff}{end}.snipMat = avgRoiDiffLinearResponseMatrix;
        %% make analysis readable
        analysis.indFly{ff} = MakeAnalysisReadable(analysis.indFly{ff});
        
        uiwait
        close all
        
    end
    
    % Eyes not being empty is an indication that we have to shuffle around
    % epochs to account for progressive/regressive stimulus differences
    % (direction-wise) in different eyes
%     if ~isempty(flyEyes)
%         flyEyes(nonResponsiveFlies) = [];
%         rightEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'R'));
%         leftEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'L'));
%         % We're gonna do this in a left-dominated world, so left eyes
%         % don't have to be touched.
%         for i = 1:length(flyEyes)
%             if strfind('right', lower(flyEyes{i}))
%                 tempAvg = averagedROIs{i};
%                 tempNoTimeAvg = noTimeAveragedRois{i};
%                 if ~isempty(tempAvg)
%                     averagedROIs{i}(rightEpochs) = tempAvg(leftEpochs);
%                     averagedROIs{i}(leftEpochs) = tempAvg(rightEpochs);
%                     noTimeAveragedRois{i}(rightEpochs) = tempNoTimeAvg(leftEpochs);
%                     noTimeAveragedRois{i}(leftEpochs) = tempNoTimeAvg(rightEpochs);
%                 end
%             end
%         end
%     end
    
    %% convert from snipMat to matrix wtih averaged flies
    averagedFlies = ReduceDimension(averagedROIs,'flies',@nanmean);
    averagedFliesSem = ReduceDimension(averagedROIs,'flies',@NanSem);
%     averagedFliesSemBootstrap = BootstrapError(averagedFlies{1});
    
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

 function bootstrapError = BootstrapError(phaseResponses)
 
 
 numPhaseResponses = size(phaseResponses, 1);
 numBootstraps = 1000;
 
 for btstrp = 1:numBootstraps
     replacement = true;
     phaseInds = randsample(numPhaseResponses,numPhaseResponses,replacement);
     phaseIndAverages(btstrp, :) = phaseResponses(phaseInds, :);%ReduceDimension(cat(2, subTrialsROI{flyInds}),'Rois',@nanmean);
 end
 
 bootstrapError = nanstd(phaseIndAverages, 3);
 
 end
