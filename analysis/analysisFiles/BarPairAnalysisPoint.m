 function analysis = BarPairAnalysisPoint(flyResp,epochs,params,~ ,dataRate,dataType,~,varargin)
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
    % Can't instantiate this as empty because plenty of figures will have
    % empty names as the default
    figureName = 'omgIHopeNoFigureIsEverNamedThis';

    fprintf('Two plots this time\n');
    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
%     epochNames = {params.epochName};
    % Gotta unwrap these because of how they're put in here
    flyEyes = cellfun(@(flEye) flEye{1}, flyEyes, 'UniformOutput', false);
    
    if any(cellfun('isempty', flyResp))
        nonResponsiveFlies = cellfun('isempty', flyResp);
        fprintf('The following flies did not respond: %s\n', num2str(find(nonResponsiveFlies)));
        flyResp(nonResponsiveFlies) = [];
        epochs(nonResponsiveFlies) = [];
        if ~isempty(flyEyes)
            flyEyes(nonResponsiveFlies)=[];
        end
        params(nonResponsiveFlies) = [];
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

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedTrials';
        analysis.indFly{ff}{end}.snipMat = averagedTrials;
        
        %% Average in time
        averagedTime = ReduceDimension(averagedTrials, 'time', @nanmean);
        
        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedTime';
        analysis.indFly{ff}{end}.snipMat = averagedTime;
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
                averagedTime(bpEpochInds, roi) = averagedTime(circshift(bpEpochInds, barPairDisplacement(roi),2), roi);
            end
        end
        
        %% Plot individual ROIs
        % regCheck tells us whether we're looking at a regressive
        % layer--true if it's true, which means the primary epoch for
        % selectivity is different than the fly eye
        numPhases = length(barPairEpochsPhaseAndPolaritySorted.PMinusNull);
        regCheck = isempty(strfind(lower(epochsForSelection{1}{1}), flyEyes{ff}));
%         regCheck = isempty(strfind(lower(epochsForSelection{1}{1}), 'left'));
        for roiNum = 1:size(averagedTime, 2)
            PlotBarPairROISummaryPoint(averagedTime(:, roiNum), barPairEpochsPhaseAndPolaritySorted, barToCenter, params{ff}, dataRate, snipShift/1000, duration/1000, regCheck)
            if any(strfind(lower(epochsForSelection{ff}{1}), lower(flyEyes{ff})))
                initTextDirection = epochsForSelection{ff}{3};
                textDirection = ['Progressive  ' initTextDirection(length(flyEyes{ff}+1):end)];
            else
                initTextDirection = epochsForSelection{ff}{3};
                textDirection = ['Regressive  ' initTextDirection(length(flyEyes{ff}+2):end)];
            end
            text(0, 0, textDirection, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
            text(0, numPhases-1, sprintf('Fly %d - ROI %d', ff, roiNum), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
        end

        %% average over ROIs
        averagedROIs{ff} = ReduceDimension(averagedTime,'Rois',@nanmean);
        fprintf('%d ROIs for fly %d\n', numROIs(ff), ff);
        % regCheck tells us whether we're looking at a regressive
        % layer--true if it's true, which means the primary epoch for
        % selectivity is different than the fly eye
        regCheck = isempty(strfind(lower(epochsForSelection{1}{1}), flyEyes{ff}));
%         regCheck = isempty(strfind(lower(epochsForSelection{1}{1}), 'left'));
        PlotBarPairROISummaryTrace(averagedROIs{ff}, barPairEpochsPhaseAndPolaritySorted, barToCenter, params{ff}, dataRate, snipShift/1000, duration/1000, regCheck)
        if any(strfind(lower(epochsForSelection{ff}{1}), lower(flyEyes{ff})))
            initTextDirection = epochsForSelection{ff}{3};
            textDirection = ['Progressive  ' initTextDirection(length(flyEyes{ff}+1):end)];
        else
            initTextDirection = epochsForSelection{ff}{3};
            textDirection = ['Regressive  ' initTextDirection(length(flyEyes{ff}+2):end)];
        end
        text(0, 0, textDirection, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
        text(0, numPhases-1, sprintf('Fly %d - Num ROIs %d', ff, numROIs(ff)), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
        plotFigure = gcf;
        set(findall(plotFigure,'-property','FontName'),'FontName', 'Ebrima')
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
