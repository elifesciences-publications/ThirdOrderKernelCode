 function analysis = SweepTwoPhotonESIAnalysis(flyResp,epochs,params,~,dataRate, dataType,interleaveEpoch,varargin)

    combOpp = 1; % logical for combining symmetic epochs such as left and right
    numIgnore = 0; % number of epochs to ignore
    numSep = 1; % number of different traces in the paramter file
    dataX = [];
    labelX = '';
    fTitle = '';
    flyEyes = [];
    epochsForSelectivity = {'' ''};
    labelY = '\Delta F/F';
    snipShift = -500;
    duration = 3000;
    dt1Epoch = 1;
    dsiThresh = 0.4;
    plotOrderChange = false;
    prefNullCombo = 'bothPos';
    % Can't instantiate this as empty because plenty of figures will have
    % empty names as the default
    figureName = 'omgIHopeNoFigureIsEverNamedThis';

    fprintf('Two plots this time\n');
    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    if iscell(esiThresh) && strcmp(changeVal, 'ESI')
        varThreshHere = esiThresh{iteration};
    end
    if iscell(dsiThresh) && strcmp(changeVal, 'DSI')
        varThreshHere = dsiThresh{iteration};
    end
    
    if strcmp(changeVal, 'ESIDSI')
        varThreshHere{1} = esiThresh{iteration};
        varThreshHere{2} = dsiThresh{iteration};
    end
    
    if iscell(varThreshHere)
        userDataVal = [double(changeVal) varThreshHere{:}];
    else
        userDataVal = [double(changeVal) varThreshHere];
    end
    % Gotta unwrap the eyes because of how they're put in here
    flyEyes = cellfun(@(flEye) flEye{1}, flyEyes, 'UniformOutput', false);
%     params = cellfun(@(prm) prm{1}, params, 'UniformOutput', false);
    
    
    % If figureName is a cell, we need to change it depending on the
    % iteration (i.e. depending on the ROIs we've selected)    
    if iscell(figureName) && length(figureName)>1
        figureName = figureName{iteration};
    end
    
    fliesUsed = 1:length(flyResp);
    if any(cellfun('isempty', flyResp))
        nonResponsiveFlies = cellfun('isempty', flyResp);
        fprintf('The following flies did not respond: %s\n', num2str(find(nonResponsiveFlies)));
        flyResp(nonResponsiveFlies) = [];
        epochs(nonResponsiveFlies) = [];
        fliesUsed(nonResponsiveFlies) = [];
        if ~isempty(flyEyes)
            flyEyes(nonResponsiveFlies)=[];
        end
        params(nonResponsiveFlies) = [];
    else
        nonResponsiveFlies = [];
    end
    
    numFlies = length(flyResp);
    averagedROIs = cell(1,numFlies);
    averagedSubtractedROIs = cell(1,numFlies);
    averagedSubtractedUncorrROIs = cell(1,numFlies);
    timePlots = cell(1,numFlies);
    timePlotRoiAvg = cell(1,numFlies);
    
    if numFlies==0
        analysis = [];
        return
    end
    
    numROIs = zeros(1, numFlies);
    % run the algorithm for each fly
    for ff = numFlies:-1:1
        if any(cellfun('isempty', {params{ff}.epochName}))
            for epochInd = 1:length(params{ff})
                if isempty(params{ff}(epochInd).epochName) && ~isempty(params{ff}(epochInd).delayL) && params{ff}(epochInd).cL > 0
                    directions = {'L', 'R'};
                    signs = {'-', '+'};
                    params{ff}(epochInd).epochName = [directions{(params{ff}(epochInd).dirXL/2)+1.5} signs{(params{ff}(epochInd).phiL/2)+1.5} ' dt=' num2str(params{ff}(epochInd).delayL)];
                    params{ff}(epochInd).delay = params{ff}(epochInd).delayL;
                end
            end
        end
        
        epochNames = {params{ff}.epochName};
        %% get processed trials
        percNan = 100*sum(isnan(flyResp{ff}(:, 1)))/size(flyResp{ff}, 1);
%         fprintf('%%NaN = %f\n', percNan);
        if percNan>5
            numROIs(ff) = [];
            averagedROIs(ff) = [];
            epochs(ff) = [];
            flyEyes(ff) = [];
            params(ff) = [];
            flyResp(ff) = [];
            averagedSubtractedROIs(ff) = [];
            averagedSubtractedUncorrROIs(ff) = [];
            timePlots(ff) = [];
            timePlotRoiAvg(ff) = [];
            fliesUsed(ff) = [];
            continue
        end
        analysis.indFly{ff} = GetProcessedTrials(flyResp{ff},epochs{ff},params{ff},dataRate,dataType,varargin{:},'snipShift', 0, 'duration', []);
         %% grab roi bordered trials so we can do the Matt/Emilio correction before params{ff} changes
        roiBorderedResps = GetProcessedTrials(flyResp{ff},epochs{ff},params{ff},dataRate,dataType,varargin{:},'snipShift', snipShift, 'duration', duration);
        roiBorderedTrials = roiBorderedResps{end}.snipMat(numIgnore+1:end,:);
        

        %% remove epochs you dont want analyzed
        ignoreEpochs = analysis.indFly{ff}{end}.snipMat(numIgnore+1:end,:);
        
        %** Special to combine Matt & Emilio's stimuli--switch the
        % uncorrelated epochs to the end **%
        uncorrEpoch = strcmp(epochNames, 'Uncorrelated Bars');
        if sum(uncorrEpoch) == 0
            
            uncorrEpochLeft = strcmp(epochNames, 'L Uncorrelated Bars');
            uncorrEpochRight = strcmp(epochNames, 'R Uncorrelated Bars');
            if sum(uncorrEpochLeft) == 0
                % Don't need to do anything in this case
            else
                % Put the uncorrelated epochs to the end
                params{ff}(end+1:end+2) = params{ff}(uncorrEpochRight | uncorrEpochLeft);
                % Delete the earlier uncorrelated epochs
                params{ff}(uncorrEpochRight | uncorrEpochLeft) = [];
                epochNames = {params{ff}.epochName};
                % Do the same for the actual data;
                ignoreEpochs(end+1:end+2, :) = ignoreEpochs(uncorrEpochRight | uncorrEpochLeft, :);
                ignoreEpochs(uncorrEpochRight | uncorrEpochLeft, :) = [];
                % Do the same for the time trace data as well
                roiBorderedTrials(end+1:end+2, :) = roiBorderedTrials(uncorrEpochRight | uncorrEpochLeft, :);
                roiBorderedTrials(uncorrEpochRight | uncorrEpochLeft, :) = [];
            end
        end

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'ignoreEpochs';
        analysis.indFly{ff}{end}.snipMat = ignoreEpochs;
        
        %% Correct by eye
         % Eyes not being empty is an indication that we have to shuffle around
        % epochs to account for progressive/regressive stimulus differences
        % (direction-wise) in different eyes
        ignoreEpochsEyeCorrected = ignoreEpochs;
        if ~isempty(flyEyes)
            rightEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'R'));
            leftEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'L'));
            % We're gonna do this in a left-dominated world, so left eyes
            % don't have to be touched.
            if strfind('right', lower(flyEyes{ff}))
                if ~isempty(ignoreEpochs)
                    ignoreEpochsEyeCorrected(rightEpochs, :) = ignoreEpochs(leftEpochs, :);
                    ignoreEpochsEyeCorrected(leftEpochs, :) = ignoreEpochs(rightEpochs, :);
                end
            end
        end
        
        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'ignoreEpochsEyeCorrected';
        analysis.indFly{ff}{end}.snipMat = ignoreEpochsEyeCorrected;
        
        
        %% Get rid of epochs with too many NaNs
        droppedNaNTraces = RemoveMovingEpochs(ignoreEpochsEyeCorrected);
        
        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'droppedNaNTraces';
        analysis.indFly{ff}{end}.snipMat = droppedNaNTraces;
        %% average over time
        averagedTime = ReduceDimension(droppedNaNTraces, 'time', @nanmean);

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedTime';
        analysis.indFly{ff}{end}.snipMat = averagedTime;

        %% average over trials
        averagedTrialsOut{ff} = ReduceDimension(averagedTime,'trials',@nanmean);
        
        
        

        
%          % Eyes not being empty is an indication that we have to shuffle around
%         % epochs to account for progressive/regressive stimulus differences
%         % (direction-wise) in different eyes
%         averagedTrialsOut{ff} = averagedTrialsEyeUncorrected;
%         if ~isempty(flyEyes)
%             epochNames = {params{ff}.epochName};
%             rightEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'R'));
%             leftEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'L'));
%             % We're gonna do this in a left-dominated world, so left eyes
%             % don't have to be touched.
%             if strfind('right', lower(flyEyes{ff}))
%                 if ~isempty(averagedTrialsEyeUncorrected)
%                     averagedTrialsOut{ff}(rightEpochs, :) = averagedTrialsEyeUncorrected(leftEpochs, :);
%                     averagedTrialsOut{ff}(leftEpochs, :) = averagedTrialsEyeUncorrected(rightEpochs, :);
%                 end
%             end
%         end
        
        
        % Normalize within ROI
%         averagedTrialsUnnormalized = averagedTrialsOut{ff};
%         uncorrBarsEpochLoc = strcmp(epochNames, 'Uncorrelated Bars');
%         averagedTrialsUnnormalized = cell2mat(averagedTrialsUnnormalized);
%         averagedTrialsNormalized = bsxfun(@minus, averagedTrialsUnnormalized, averagedTrialsUnnormalized(uncorrBarsEpochLoc, :));
%         
%         averagedTrials = mat2cell(averagedTrialsNormalized, ones(size(averagedTrialsNormalized,1),1),ones(size(averagedTrialsNormalized,2),1));
        averagedTrials = averagedTrialsOut{ff};
        
        
        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedTrials';
        analysis.indFly{ff}{end}.snipMat = averagedTrials;
        
        
        %% Subtract trials -- both left-right and direction-uncorrelated
        uncorrEpoch = strcmp(epochNames, 'Uncorrelated Bars');
        if sum(uncorrEpoch) == 0
            
            uncorrEpochLeft = strcmp(epochNames, 'L Uncorrelated Bars');
            uncorrEpochRight = strcmp(epochNames, 'R Uncorrelated Bars');
            if sum(uncorrEpochLeft) == 0
                paramDelaysCell = {params{ff}.delay};
                emptyParamDelays = cellfun('isempty', paramDelaysCell);
                [paramDelaysCell{emptyParamDelays}] = deal(0);
                paramDelays = [paramDelaysCell{:}];
                [maxDelay] = max(paramDelays);
                uncorrEpoch = paramDelays == maxDelay;
                uncorrEpochLeft = uncorrEpoch & leftEpochs;
                uncorrEpochRight = uncorrEpoch & rightEpochs;
            end
            resetUncorr = false;
        else
            uncorrEpochLeft = uncorrEpoch;
            uncorrEpochRight = uncorrEpoch;
            resetUncorr = true;
        end
        
        dt0Epoch = strfind(epochNames, 'dt=0');
        if sum(~cellfun('isempty', dt0Epoch)) > 2
            % do something here?
            warning('There are more than 2 dt0 epochs...')
        elseif sum(~cellfun('isempty', dt0Epoch))==2
            dt0Epochs = ~cellfun('isempty', dt0Epoch);
        end
        
        
        % Here we note that uncorrelated epochs are equivalent for left and
        % right
        uncorrEpochMean = mean([averagedTrials{uncorrEpochLeft, :}; averagedTrials{uncorrEpochRight, :}]);
        averagedTrials(uncorrEpochLeft, :) = num2cell(uncorrEpochMean);
        averagedTrials(uncorrEpochRight, :) = num2cell(uncorrEpochMean);
        
        % Here we note that dt0 epochs are equivalent for left and right
        % (but not positive and negative!)
        dt0EpochsMean = mean([averagedTrials{dt0Epochs, :}]);
        averagedTrials(dt0Epochs, :) = num2cell(dt0EpochsMean);
        
        subtractedTrialsUncorr = cell(size(averagedTrials));
        subtractedTrialsUncorr(repmat(leftEpochs', [1, size(averagedTrials, 2)])) = (num2cell(reshape([averagedTrials{leftEpochs, :}], sum(leftEpochs), size(averagedTrials, 2))-repmat(uncorrEpochMean,sum(leftEpochs), 1)));
        subtractedTrialsUncorr(repmat(rightEpochs', [1, size(averagedTrials, 2)])) = (num2cell(reshape([averagedTrials{rightEpochs, :}], sum(rightEpochs), size(averagedTrials, 2))-repmat(uncorrEpochMean,sum(rightEpochs), 1)));
        subtractedTrialsUncorr(cellfun('isempty', subtractedTrialsUncorr)) = {0};
        
        
        subtractedTrials = cell(size(subtractedTrialsUncorr));
        subtractedTrials(repmat(leftEpochs, [1, size(subtractedTrialsUncorr, 2)])) = (num2cell([subtractedTrialsUncorr{leftEpochs, :}]-[subtractedTrialsUncorr{rightEpochs, :}]));
        subtractedTrials(repmat(rightEpochs, [1, size(subtractedTrialsUncorr, 2)])) = (num2cell([subtractedTrialsUncorr{rightEpochs, :}]-[subtractedTrialsUncorr{leftEpochs, :}]));
%         if resetUncorr
%             subtractedTrials(uncorrEpoch, :) = subtractedTrialsUncorr(uncorrEpoch, :);
%         end
        
        subtractedTrials(cellfun('isempty', subtractedTrials)) = {0};
        subTrialsROI{ff} = subtractedTrials;
         
        %% averaged over subtracted trials
        averagedSubtractedROIs{ff} = ReduceDimension(subtractedTrials,'Rois',@nanmean);
        averagedSubtractedUncorrROIs{ff} = ReduceDimension(subtractedTrialsUncorr,'Rois',@nanmean);
        
        
        
        
        
        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedSubtractedROIs';
        analysis.indFly{ff}{end}.snipMat = averagedSubtractedROIs;
        
        
        analysis.indFly{ff}{end+1}.name = 'averagedSubtractedUncorrROIs';
        analysis.indFly{ff}{end}.snipMat = averagedSubtractedUncorrROIs;
        
        
        %% average over ROIs
        averagedROIs{ff} = ReduceDimension(averagedTrials,'Rois',@nanmean);
        
        [numEpochs,numROIs(ff)] = size(averagedTrials);
        fprintf('%d ROIs for fly %d\n', numROIs(ff), ff);
        
        
        
        
        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedROIs';
        analysis.indFly{ff}{end}.snipMat = averagedROIs;
        %% make analysis readable
        analysis.indFly{ff} = MakeAnalysisReadable(analysis.indFly{ff});
        
        
       
         %% Correct bordered trials by eye
         % Eyes not being empty is an indication that we have to shuffle around
        % epochs to account for progressive/regressive stimulus differences
        % (direction-wise) in different eyes
        roiBorderedTrialsEyeCorrected = roiBorderedTrials;
        if ~isempty(flyEyes)
            epochNames = {params{ff}.epochName};
            rightEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'R'));
            leftEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'L'));
            % We're gonna do this in a left-dominated world, so left eyes
            % don't have to be touched.
            if strfind('right', lower(flyEyes{ff}))
                if ~isempty(ignoreEpochs)
                    roiBorderedTrialsEyeCorrected(rightEpochs, :) = roiBorderedTrials(leftEpochs, :);
                    roiBorderedTrialsEyeCorrected(leftEpochs, :) = roiBorderedTrials(rightEpochs, :);
                end
            end
        end
        
         %% Get rid of epochs with too many NaNs in bordered trials and get averaged times
        roiBorderedNaNTracesGone = RemoveMovingEpochs(roiBorderedTrialsEyeCorrected);
        timePlots{ff} = ReduceDimension(roiBorderedNaNTracesGone,'trials',@nanmean);

        timePlotRoiAvg{ff} = ReduceDimension(timePlots{ff},'Rois',@nanmean);
        uncorrLeftTT = timePlotRoiAvg{ff}{uncorrEpochLeft};
        uncorrRightTT = timePlotRoiAvg{ff}{uncorrEpochRight};
        uncorrMeanTT = mean([uncorrLeftTT uncorrRightTT], 2);
        timePlotRoiAvg{ff}{uncorrEpochLeft} = uncorrMeanTT;
        timePlotRoiAvg{ff}{uncorrEpochRight} = uncorrMeanTT;
    end
%     
%     % Eyes not being empty is an indication that we have to shuffle around
%     % epochs to account for progressive/regressive stimulus differences
%     % (direction-wise) in different eyes
%     if ~isempty(flyEyes)
%         flyEyes(nonResponsiveFlies) = [];
%         epochNames = {params.epochName};
%         rightEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'R'));
%         leftEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'L'));
%         % We're gonna do this in a left-dominated world, so left eyes
%         % don't have to be touched.
%         for i = 1:length(flyEyes)
%             if strfind('right', lower(flyEyes{i}))
%                 tempAvg = averagedROIs{i};
%                 if ~isempty(tempAvg)
%                     averagedROIs{i}(rightEpochs) = tempAvg(leftEpochs);
%                     averagedROIs{i}(leftEpochs) = tempAvg(rightEpochs);
%                 end
%             end
%         end
%     end

    %% convert from snipMat to matrix wtih averaged flies
%     averagedFlies = {ReduceDimension(cat(2, averagedTrialsOut{:}),'Rois',@nanmean)};%
    averagedFlies = ReduceDimension(averagedROIs,'flies',@nanmean);
%     averagedFliesSem = {ReduceDimension(cat(2, averagedTrialsOut{:}),'Rois',@NanSem)};%
    averagedFliesSem = ReduceDimension(averagedROIs,'flies',@NanSem);
    if sum(uncorrEpochLeft|uncorrEpochRight)>1
        % Both of these epochs were averaged together to get this number,
        % so the Sem should take into account than double the values were
        % put into getting the mean
        uncorrEpochs = uncorrEpochLeft|uncorrEpochRight;
        averagedFliesSem{1}(uncorrEpochs) = num2cell([averagedFliesSem{1}{uncorrEpochs}]/sqrt(2));
    end
    
    if sum(dt0Epochs)>1
        averagedFliesSem{1}(dt0Epochs) = num2cell([averagedFliesSem{1}{dt0Epochs}]/sqrt(2));
    end
    
%     averagedFliesTime = {ReduceDimension(cat(2, timePlots{:}),'Rois',@nanmean)};
    averagedFliesTime = ReduceDimension(timePlotRoiAvg,'flies',@nanmean);
    averagedFliesTimeSem = ReduceDimension(timePlotRoiAvg,'flies',@NanSem);
    if sum(uncorrEpochLeft|uncorrEpochRight)>1
        % Both of these epochs were averaged together to get this number,
        % so the Sem should take into account than double the values were
        % put into getting the mean
        uncorrEpochs = uncorrEpochLeft|uncorrEpochRight;
        averagedFliesTimeSem{1}(uncorrEpochs) = mat2cell([averagedFliesTimeSem{1}{uncorrEpochs}]/sqrt(2), size([averagedFliesTimeSem{1}{uncorrEpochs}], 1), [1 1]);
    end
    
    if sum(dt0Epochs)>1
        averagedFliesTimeSem{1}(dt0Epochs) = mat2cell([averagedFliesTimeSem{1}{dt0Epochs}]/sqrt(2), size([averagedFliesTimeSem{1}{dt0Epochs}], 1), [1 1]);
    end
%     flyBootstrapAverages = cell(size(averagedFlies{1}, 1), 1000);
%     for i = 1:10000
%         replacement = true;
%         flyInds = randsample(numFlies,numFlies,replacement);
%         flyBootstrapAverages(:, i) = ReduceDimension(cat(2, averagedTrialsOut{flyInds}),'Rois',@nanmean);
%     end
%     flyBootstrapSem = nanstd(cell2mat(flyBootstrapAverages), [], 2);
%     averagedFliesSem = {mat2cell(flyBootstrapSem, ones(1, length(flyBootstrapSem)), 1)};
%     if any(isnan(flyBootstrapSem))
%         keyboard
%     end
%     averagedFlies = ReduceDimension(averagedROIs,'flies',@nanmean);
%     averagedFliesSem = ReduceDimension(averagedROIs,'flies',@NanSem);
    
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
    
    %% Do this junk for diff vals
%     averagedDiffFlies = {ReduceDimension(cat(2, subTrialsROI{:}),'Rois',@nanmean)};%
    averagedDiffFlies = ReduceDimension(averagedSubtractedROIs,'flies',@nanmean);
%     averagedDiffFliesSem = {ReduceDimension(cat(2, subTrialsROI{:}),'Rois',@NanSem)};%
    averagedDiffFliesSem = ReduceDimension(averagedSubtractedROIs,'flies',@NanSem);
    
    respMatDiffInd = SnipMatToMatrix(averagedSubtractedROIs); % turn snipMat into a matrix
    respMatDiffIndSep = SeparateTraces(respMatDiffInd,numSep,''); % separate every numSnips epochs into a new trace to plot
    respMatDiffIndPlot = squish(respMatDiffIndSep); % remove all nonsingleton dimensions
    
    analysis.respMatDiffIndPlot = respMatDiffIndPlot;
    analysis.fliesUsed = fliesUsed;
%     flyBootstrapAverages = cell(size(averagedFlies{1}, 1), 1000);
%     for i = 1:10000
%         replacement = true;
%         flyInds = randsample(numFlies,numFlies,replacement);
%         flyBootstrapAverages(:, i) = ReduceDimension(cat(2, subTrialsROI{flyInds}),'Rois',@nanmean);
%     end
%     flyBootstrapDiffSem = nanstd(cell2mat(flyBootstrapAverages), [], 2);
%     averagedDiffFliesSem = {mat2cell(flyBootstrapDiffSem, ones(1, length(flyBootstrapSem)), 1)};
%     if any(isnan(flyBootstrapDiffSem))
%         keyboard
%     end
%     averagedFlies = ReduceDimension(averagedROIs,'flies',@nanmean);
%     averagedFliesSem = ReduceDimension(averagedROIs,'flies',@NanSem);

    
    respMatDiff = SnipMatToMatrix(averagedDiffFlies); % turn snipMat into a matrix
    respMatDiffSep = SeparateTraces(respMatDiff,numSep,''); % separate every numSnips epochs into a new trace to plot
    respMatDiffPlot = permute(respMatDiffSep,[3 7 6 1 2 4 5]);
    %     respMatPlot = squish(respMatSepPerm); % remove all nonsingleton dimensions
    
    analysis.respMatDiffPlot = respMatDiffPlot;
    
    respMatDiffSem = SnipMatToMatrix(averagedDiffFliesSem); % turn snipMat into a matrix
    respMatDiffSemSep = SeparateTraces(respMatDiffSem,numSep,''); % separate every numSnips epochs into a new trace to plot
    respMatDiffSemPlot = permute(respMatDiffSemSep,[3 7 6 1 2 4 5]);
    
    analysis.respMatDiffSemPlot = respMatDiffSemPlot;
    %% Do this junk for diff uncorr vals
%     averagedDiffFlies = {ReduceDimension(cat(2, subTrialsROI{:}),'Rois',@nanmean)};%
    averagedDiffUncorrFlies = ReduceDimension(averagedSubtractedUncorrROIs,'flies',@nanmean);
%     averagedDiffFliesSem = {ReduceDimension(cat(2, subTrialsROI{:}),'Rois',@NanSem)};%
    averagedDiffUncorrFliesSem = ReduceDimension(averagedSubtractedUncorrROIs,'flies',@NanSem);
    
    if sum(uncorrEpochLeft|uncorrEpochRight)>1
        % Both of these epochs were averaged together to get this number,
        % so the Sem should take into account than double the values were
        % put into getting the mean
        uncorrEpochs = uncorrEpochLeft|uncorrEpochRight;
        averagedDiffUncorrFliesSem{1}(uncorrEpochs) = num2cell([averagedDiffUncorrFliesSem{1}{uncorrEpochs}]/sqrt(2));
    end
    
    if sum(dt0Epochs)>1
        averagedDiffUncorrFliesSem{1}(dt0Epochs) = num2cell([averagedDiffUncorrFliesSem{1}{dt0Epochs}]/sqrt(2));
    end
    
%     flyBootstrapAverages = cell(size(averagedFlies{1}, 1), 1000);
%     for i = 1:10000
%         replacement = true;
%         flyInds = randsample(numFlies,numFlies,replacement);
%         flyBootstrapAverages(:, i) = ReduceDimension(cat(2, subTrialsROI{flyInds}),'Rois',@nanmean);
%     end
%     flyBootstrapDiffSem = nanstd(cell2mat(flyBootstrapAverages), [], 2);
%     averagedDiffFliesSem = {mat2cell(flyBootstrapDiffSem, ones(1, length(flyBootstrapSem)), 1)};
%     if any(isnan(flyBootstrapDiffSem))
%         keyboard
%     end
%     averagedFlies = ReduceDimension(averagedROIs,'flies',@nanmean);
%     averagedFliesSem = ReduceDimension(averagedROIs,'flies',@NanSem);

    
    respMatUncorrDiff = SnipMatToMatrix(averagedDiffUncorrFlies); % turn snipMat into a matrix
    respMatUncorrDiffSep = SeparateTraces(respMatUncorrDiff,numSep,''); % separate every numSnips epochs into a new trace to plot
    respMatUncorrDiffPlot = permute(respMatUncorrDiffSep,[3 7 6 1 2 4 5]);
    %     respMatPlot = squish(respMatSepPerm); % remove all nonsingleton dimensions
    analysis.respMatUncorrDiffPlot = respMatUncorrDiffPlot;
    
    respMatUncorrDiffSem = SnipMatToMatrix(averagedDiffUncorrFliesSem); % turn snipMat into a matrix
    respMatUncorrDiffSemSep = SeparateTraces(respMatUncorrDiffSem,numSep,''); % separate every numSnips epochs into a new trace to plot
    respMatUncorrDiffSemPlot = permute(respMatUncorrDiffSemSep,[3 7 6 1 2 4 5]);
    analysis.respMatUncorrDiffSemPlot = respMatUncorrDiffSemPlot;
    %% convert from snipMat to matrix wtih individual flies

    respMatInd = SnipMatToMatrix(averagedROIs); % turn snipMat into a matrix
    respMatIndSep = SeparateTraces(respMatInd,numSep,''); % separate every numSnips epochs into a new trace to plot
    respMatIndPlot = squish(respMatIndSep); % remove all nonsingleton dimensions
    
    analysis.respMatIndPlot = respMatIndPlot;
    
    %% plot
    if isempty(dataX)
        dataX = 1:size(respMatIndPlot,1);
    end
    
    yAxis = {'\Delta F/F'};
    
%     finalTitle = [fTitle ': ' epochsForSelectivity{1} ' - ' epochsForSelectivity{2}];
    
    
    

    plotFigureSem = findobj('Type', 'Figure', 'Name', [figureName ' ' changeVal ' sweep SEM']);
   
    if isempty(plotFigureSem)
        plotFigureSem=MakeFigure;
        newPlot = true;
    else
        newPlot = false;
    end
    
    tVals = linspace(snipShift, snipShift+duration, size(timePlots{1}{1}, 1));
    
    if ~isempty(flyEyes)
        figure(plotFigureSem);
        switch prefNullCombo
            case 'bothPos'
%                 subplotFigSem = subplot(2, 2, 1);
%                 subplotFig2Sem = subplot(2, 2, 4);
                
                if plotOrderChange
                    %  && any(cellfun(@(prev, curr) isequal(prev,curr), subplotFigSem.UserData, repmat({userDataVal}, [1, length(subplotFigSem.UserData)])))
                    %  if isequal(subplotFigSem.UserData, subplotFig2Sem.UserData)
                    %      subplotFigSem.UserData = [];
                    %      subplotFig2Sem.UserData = [];
                    %  end
                    subplotFigSem = subplot(2, 2, 3);
                else
                    subplotFigSem = subplot(2, 2, 1);
                    
                end
                
                firstIfStatement = isempty(subplotFigSem.UserData) || any(strfind(epochsForSelectivity{iteration, 1}, 'Left'));%~any(cellfun(@(prev, curr) isequal(prev,curr), subplotFigSem.UserData, repmat({userDataVal}, [1, length(subplotFigSem.UserData)])));
            case 'prefPosNullNeg'
                subplotFigSem = subplot(2, 1, 1);
                subplotFig2Sem = subplot(2, 1, 2);
                
                if plotOrderChange && any(cellfun(@(prev, curr) isequal(prev,curr), subplotFigSem.UserData, repmat({userDataVal}, [1, length(subplotFigSem.UserData)])))
                    if isequal(subplotFigSem.UserData, subplotFig2Sem.UserData)
                        subplotFigSem.UserData = [];
                        subplotFig2Sem.UserData = [];
                    end
                end
%                 if ~plotOrderChange
                    firstIfStatement = isempty(subplotFigSem.UserData) || any(strfind(epochsForSelectivity{iteration, 1}, 'Left'));% ~any(cellfun(@(prev, curr) isequal(prev,curr), subplotFigSem.UserData, repmat({userDataVal}, [1, length(subplotFigSem.UserData)])));
%                 else
%                     firstIfStatement = isempty(subplotFigSem.UserData) || sum(cellfun(@(prev, curr) isequal(prev,curr), subplotFigSem.UserData, repmat({selIndThresh}, [1, length(subplotFigSem.UserData)])))<2;
%                 end
        end
        
        if plotOrderChange
            pol = 'Neg';
        else
            pol = 'Pos';
        end
        
        firstTwoCellTypeRepeatLoc = find(strcmp(epochsForSelectivity{1, 1}, epochsForSelectivity(:, 1)), 2, 'first');
        numManipulations = length(esiThresh)/diff(firstTwoCellTypeRepeatLoc);
        
        if ~iscell(varThreshHere)
            if length(varThreshHere)==2
                legendEntry = sprintf('%s %.2f<%s<%.2f', pol, varThreshHere(1), changeVal, varThreshHere(2));
            else
                legendEntry = sprintf('%s %.2f<%s', pol, varThreshHere, changeVal);
            end
        else
            if length(varThreshHere{1})==2
                legendEntry = sprintf('%s %.2f<ESI<%.2f', pol, varThreshHere{1}(1), varThreshHere{1}(2));
            else
                legendEntry = sprintf('%s %.2f<ESI', pol, varThreshHere{1});
            end
            
            if length(varThreshHere{2})==2
                legendEntry = sprintf('%s; %.2f<DSI<%.2f', legendEntry, varThreshHere{2}(1), varThreshHere{2}(2));
            else
                legendEntry = sprintf('%s; %.2f<DSI', legendEntry, varThreshHere{2});
            end
        end
        
        if newPlot || (firstIfStatement)%We're in the progressive regime now
            finalTitle = ['Progressive Positive ' num2str(numROIs(1)) sprintf(',%d', numROIs(2:end))];
            progPosPrefDir = 'L+'; % Remember that we're in a left dominated world
            progPosNullDir = 'R+';
            uncorrBarsEpoch = strcmp(epochNames, 'Uncorrelated Bars');
            if ~any(uncorrBarsEpoch)
                prefUncorrBarsEpoch = strcmp(epochNames, 'L Uncorrelated Bars');
                nullUncorrBarsEpoch = strcmp(epochNames, 'R Uncorrelated Bars');
                uncorrBarsEpoch = [find(prefUncorrBarsEpoch) find(nullUncorrBarsEpoch)];
            else
                uncorrBarsEpoch = [find(uncorrBarsEpoch) find(uncorrBarsEpoch)];
            end
            progPosPrefEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, progPosPrefDir));
        	progPosNullEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, progPosNullDir));
            prefEpochs = find(progPosPrefEpochs);
            nullEpochs = find(progPosNullEpochs);
            analysis.prefEpochs = prefEpochs;
            analysis.nullEpochs = nullEpochs;
            if ~isempty(prefEpochs)% && ~plotOrderChange
                if ~isempty(uncorrBarsEpoch)
                    prefEpochs = [prefEpochs uncorrBarsEpoch(1)];
                    nullEpochs = [nullEpochs uncorrBarsEpoch(2)];
                end
                switch prefNullCombo
                    case 'bothPos'
                        subplotNums = {2, 2, 1};
                    case 'prefPosNullNeg'
                        subplotNums = {2, 1, 1};
                end
                        
                PlotAllCurves(subplotNums, plotFigureSem,...
                    params{ff}, dataX, prefEpochs, nullEpochs, finalTitle,...
                    respMatIndPlot, respMatPlot, respMatSemPlot,...
                    respMatUncorrDiffPlot, respMatUncorrDiffSemPlot,...
                    legendEntry, prefNullCombo, numManipulations);
                
                subplotFig = subplot(subplotNums{:});
                subplotFig.UserData = [subplotFig.UserData, {userDataVal}];
            end
            
            finalTitle = ['Progressive Negative ' num2str(numROIs(1)) sprintf(',%d', numROIs(2:end))];
            progNegPrefDir = 'L-'; % Remember that we're in a left dominated world
            progNegNullDir = 'R-';
            progNegPrefEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, progNegPrefDir));
        	progNegNullEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, progNegNullDir));
            prefEpochs = find(progNegPrefEpochs);
            nullEpochs = find(progNegNullEpochs);
            if ~isempty(prefEpochs)% && plotOrderChange
                if ~isempty(uncorrBarsEpoch)
                    prefEpochs = [prefEpochs uncorrBarsEpoch(1)];
                    nullEpochs = [nullEpochs uncorrBarsEpoch(2)];
                end
                switch prefNullCombo
                    case 'bothPos'
                        subplotNums = {2, 2, 3};
                    case 'prefPosNullNeg'
                        subplotNums = {2, 1, 1};
                end
                PlotAllCurves(subplotNums, plotFigureSem,...
                    params{ff}, dataX, prefEpochs, nullEpochs, finalTitle,...
                    respMatIndPlot, respMatPlot, respMatSemPlot,...
                    respMatUncorrDiffPlot, respMatUncorrDiffSemPlot,...
                    legendEntry, prefNullCombo, numManipulations);
                subplotFig = subplot(subplotNums{:});
                subplotFig.UserData = [subplotFig.UserData, {userDataVal}];
            end
            
            plotFigureSem.Name = [figureName ' ' changeVal ' sweep SEM'];
        else % Regressive regime
            finalTitle = ['Regressive Positive ' num2str(numROIs(1)) sprintf(',%d', numROIs(2:end))];
            regPosPrefDir = 'R+'; % Remember that we're in a left dominated world
            regPosNullDir = 'L+';
            uncorrBarsEpoch = strcmp(epochNames, 'Uncorrelated Bars');
            if ~any(uncorrBarsEpoch)
                prefUncorrBarsEpoch = strcmp(epochNames, 'L Uncorrelated Bars');
                nullUncorrBarsEpoch = strcmp(epochNames, 'R Uncorrelated Bars');
                uncorrBarsEpoch = [find(prefUncorrBarsEpoch) find(nullUncorrBarsEpoch)];
            else
                uncorrBarsEpoch = [find(uncorrBarsEpoch) find(uncorrBarsEpoch)];
            end
            regPosPrefEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, regPosPrefDir));
        	regPosNullEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, regPosNullDir));
            prefEpochs = find(regPosPrefEpochs);
            nullEpochs = find(regPosNullEpochs);
            analysis.prefEpochs = prefEpochs;
            analysis.nullEpochs = nullEpochs;
            if ~isempty(prefEpochs)% && ~plotOrderChange
                if ~isempty(uncorrBarsEpoch)
                    prefEpochs = [prefEpochs uncorrBarsEpoch(1)];
                    nullEpochs = [nullEpochs uncorrBarsEpoch(2)];
                end
                switch prefNullCombo
                    case 'bothPos'
                        subplotNums = {2, 2, 2};
                    case 'prefPosNullNeg'
                        subplotNums = {2, 1, 2};
                end
                PlotAllCurves(subplotNums, plotFigureSem,...
                    params{ff}, dataX, prefEpochs, nullEpochs, finalTitle,...
                    respMatIndPlot, respMatPlot, respMatSemPlot,...
                    respMatUncorrDiffPlot, respMatUncorrDiffSemPlot,...
                    legendEntry, prefNullCombo, numManipulations);
                subplotFig = subplot(subplotNums{:});
                subplotFig.UserData = [subplotFig.UserData, {userDataVal}];
            end
            
            finalTitle = ['Regressive Negative ' num2str(numROIs(1)) sprintf(',%d', numROIs(2:end))];
            regNegPrefDir = 'R-'; % Remember that we're in a left dominated world
            regNegNullDir = 'L-';
            regNegPrefEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, regNegPrefDir));
        	regNegNullEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, regNegNullDir));
            prefEpochs = find(regNegPrefEpochs);
            nullEpochs = find(regNegNullEpochs);
            if ~isempty(prefEpochs)% && plotOrderChange
                if ~isempty(uncorrBarsEpoch)
                    prefEpochs = [prefEpochs uncorrBarsEpoch(1)];
                    nullEpochs = [nullEpochs uncorrBarsEpoch(2)];
                end
                switch prefNullCombo
                    case 'bothPos'
                        subplotNums = {2, 2, 4};
                    case 'prefPosNullNeg'
                        subplotNums = {2, 1, 2};
                end
                PlotAllCurves(subplotNums, plotFigureSem,...
                    params{ff}, dataX, prefEpochs, nullEpochs, finalTitle,...
                    respMatIndPlot, respMatPlot, respMatSemPlot,...
                    respMatUncorrDiffPlot, respMatUncorrDiffSemPlot,...
                    legendEntry, prefNullCombo, numManipulations);
                subplotFig = subplot(subplotNums{:});
                subplotFig.UserData = [subplotFig.UserData, {userDataVal}];
                
            end
            
            flySemAxes = plotFigureSem.Children.findobj('Type','Axes');
            
            minY = min([flySemAxes.YLim 0]);
            maxY = max([flySemAxes.YLim]);
            [flySemAxes.YLim] = deal([minY maxY]);
            
            [flySemAxes.XTick] = deal(tickX);
            [flySemAxes.XTickLabel] = deal(tickLabelX);
            [flySemAxes.XTickLabelRotation] = deal(45);
            
            for figInd = 1:length(flySemAxes)
                flySemAxes(figInd).XLabel.String = labelX;
                flySemAxes(figInd).YLabel.String = labelY;
            end
        end
    else
        
%         for pp = 1:size(respMatPlot,3)
%             PlotXvsY(dataX',respMatPlot(:,:,pp),'error',respMatSemPlot(:,:,pp));
%             ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis{pp} ' - ' num2str(numFlies) ' flies'],'fTitle',finalTitle);
%         end
    end
 end
 
 function PlotAllCurves(subplotNums, plotFigureSem, params, dataX, prefEpochs, nullEpochs, finalTitle, respMatIndPlot, respMatPlot, respMatSemPlot, respMatUncorrDiffPlot, respMatUncorrDiffSemPlot, legendEntry, prefNullCombo, numManipulations)
 % Plot all the curves in one bundle!
 dt1Epoch = find([params(nullEpochs).delay]==1, 1, 'first');
 figure(plotFigureSem);
 subplot(subplotNums{:});
%  PlotSemCurves(dataX, prefEpochs, nullEpochs, finalTitle, respMatIndPlot, respMatPlot, respMatSemPlot, legendEntry, prefNullCombo);
  PlotSemCurves(dataX, prefEpochs, nullEpochs, finalTitle, respMatIndPlot, respMatUncorrDiffPlot, respMatUncorrDiffSemPlot, legendEntry, prefNullCombo, numManipulations);

 
 end

 function PlotSemCurves(dataX, prefEpochs, nullEpochs, finalTitle, respMatIndPlot, respMatPlot, respMatSemPlot, legendEntry, prefNullCombo, numManipulations)

 % Plot null as negative dt values
 currAx = gca;
 switchBaseColor = false;
 if any(strfind(finalTitle, 'Negative'));
     switchBaseColor = true;
 end
 switch prefNullCombo
     case 'bothPos' 
         if ~isempty(currAx.UserData) % Remember UserData gets saved after plotting so this means we've already plotted one
             % We want them light and getting lighter...
             if ~switchBaseColor
                 addFactor = [0 .2 .2; 0.2 0.2 0.2]+length(currAx.UserData)/(numManipulations+1)*0.3;
%                  addFactor(1, 1) = 0;
             else
                 addFactor = [.2 .2 0; 0.2 0.2 0.2]+length(currAx.UserData)/(numManipulations+1)*0.3;
%                  addFactor(1, end) = 0;
             end
         else
             addFactor = [0 0 0; 0 0 0];
         end
         if ~switchBaseColor
             colorLines = [.7 0 0; 0.5 0.5 0.5] + addFactor;
         else
             colorLines = [0 0 .7; 0.5 0.5 0.5] + addFactor;
         end
         % Plot pref and null on top of each other
         PlotXvsY(dataX([end-1:-1:1 1:end-1])',[[respMatPlot(prefEpochs(end-1:-1:1),:); respMatPlot(nullEpochs(1:end-1),:)] repmat(respMatPlot(nullEpochs(end),:), 2*(length(dataX)-1), 1)], 'color', colorLines);
         currPlotAx = gca;
         currLines = currPlotAx.Children.findobj('Type', 'Line');
         currLines(1).Annotation.LegendInformation.IconDisplayStyle = 'off';
     case 'prefPosNullNeg'
         if ~isempty(currAx.UserData) % Remember UserData gets saved after plotting so this means we've already plotted one
             % We want them light and getting lighter...
             if ~switchBaseColor
                 addFactor = [0 .2 .2; 0.2 0.2 0.2]+length(currAx.UserData)/5*0.3;
%                  addFactor(1, 1) = 0;
             else
                 addFactor = [.2 .2 0; 0.2 0.2 0.2]+length(currAx.UserData)/5*0.3;
%                  addFactor(1, end) = 0;
             end
         else
             addFactor = [0 0 0; 0 0 0];
         end
         if ~switchBaseColor
             colorLines = [.7 0 0; 0.5 0.5 0.5] + addFactor;
         else
             colorLines = [0 0 .7; 0.5 0.5 0.5] + addFactor;
         end
         PlotXvsY(dataX(1:end-1)',[[respMatPlot(nullEpochs(end-1:-1:2),:); respMatPlot(prefEpochs(1:end-1),:)] repmat(respMatPlot(nullEpochs(end),:), length(dataX)-1, 1)], 'color', colorLines);
         currPlotAx = gca;
         currLines = currPlotAx.Children.findobj('Type', 'Line');
         currLines(1).Annotation.LegendInformation.IconDisplayStyle = 'off';
 end
 


%  for zValInd = 1:length(dataX)-1
%      text(dataX(zValInd),respMatPlot(prefEpochs(1)), sprintf('%0.2d\\newline ', zVals(zValInd,:)), 'Rotation', 45, 'FontSize', 5)
%  end
%  text(dataX(end), respMatPlot(end), 'Z Pref\newline Z Null\newline Z Unpaired\newline Z Paired');

dataPointsPref = respMatPlot(prefEpochs,:);
dataPointsPrefSem = respMatSemPlot(prefEpochs,:);
dataPointsNull = respMatPlot(nullEpochs,:);
dataPointsNullSem = respMatSemPlot(nullEpochs,:);

comparisonNum = length(nullEpochs)+length(prefEpochs)-2; % subtract 2 for uncorrelated epochs
pThresh = 0.05;
pThresh = pThresh/comparisonNum;

pThreshStrict = 0.01;
pThreshStrict = pThreshStrict/comparisonNum;

% TTEST!
%  [~, pPrefUncorr] = ttest(respMatIndPlot(prefEpochs(1:end-1), :)', respMatIndPlot(prefEpochs(end)*ones(length(prefEpochs)-1, 1), :)'); %2 is index of CIS epoch
%  [~, pNullUncorr] = ttest(respMatIndPlot(nullEpochs(1:end-1), :)', respMatIndPlot(nullEpochs(end)*ones(length(prefEpochs)-1, 1), :)'); %2 is index of CIS epoch
for i = 1:length(prefEpochs(1:end-1))
    pPrefUncorr(i) = signrank(respMatIndPlot(prefEpochs(i), :)', respMatIndPlot(prefEpochs(end), :)'); %2 is index of CIS epoch
    pNullUncorr(i) = signrank(respMatIndPlot(nullEpochs(i), :)', respMatIndPlot(nullEpochs(end), :)'); %2 is index of CIS epoch
end

dataPointsComboBest = [dataPointsPref(pPrefUncorr<pThreshStrict)+dataPointsPrefSem(pPrefUncorr<pThreshStrict); dataPointsNull(pNullUncorr<pThreshStrict)+dataPointsNullSem(pNullUncorr<pThreshStrict)];
dataPointsComboBestSem = [dataPointsPrefSem(pPrefUncorr<pThreshStrict); dataPointsNullSem(pNullUncorr<pThreshStrict)];
[maxVal, maxInd] = max(dataPointsComboBest);

dataPointsComboAll = [dataPointsPref+dataPointsPrefSem; dataPointsNull+dataPointsNullSem];
dataPointsComboAllSem = [dataPointsPrefSem; dataPointsNullSem];
[maxOverall, maxOverallInd] = max(dataPointsComboAll);
[minOverall, minOverallind] = min(dataPointsComboAll);
if isempty(maxVal)
    maxVal = maxOverall;
end
if ~isempty(maxVal)
    if maxOverall>maxVal
        maxVal = maxOverall;
        shiftUp = dataPointsComboAllSem(maxOverallInd);
    elseif ~isempty(maxInd)
        shiftUp = dataPointsComboBestSem(maxInd);
    else
        shiftUp = 0.2*maxVal;
    end
    plotY = maxVal + shiftUp;
    switch prefNullCombo
        case 'bothPos'
            
            % Preferred
            % Sign rank p-threshold
            %     text(dataX(pPrefUncorr<pThresh & pPrefUncorr>pThreshStrict), plotY*ones(sum(pPrefUncorr<pThresh & pPrefUncorr>pThreshStrict), 1), '*', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [1 0 0]);
            %     text(dataX(pPrefUncorr<pThreshStrict), plotY*ones(sum(pPrefUncorr<pThreshStrict), 1), '**', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [1 0 0]);
            % Z-threshold (not used anymore)
            %     text(dataX(zPrefUncorr>zThresh & zPrefUncorr<zThreshStrict), plotY*ones(sum(zPrefUncorr>zThresh & zPrefUncorr<zThreshStrict), 1), '*', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [1 0 0]);
            %     text(dataX(zPrefUncorr>zThreshStrict), plotY*ones(sum(zPrefUncorr>zThreshStrict), 1), '**', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [1 0 0]);
            % p-values in text
%             text(dataX(1:end-1), plotY*ones(length(dataX)-1, 1), strcat('p=',cellfun(@num2str, num2cell(pPrefUncorr), 'UniformOutput', false)), 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [0 0 0], 'Rotation', 70);
            
            % Null
            % Sign rank p-threshold
            %     text(dataX(pNullUncorr<pThresh & pNullUncorr>pThreshStrict), (plotY+shiftUp)*ones(sum(pNullUncorr<pThresh & pNullUncorr>pThreshStrict), 1), '*', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [0 0 1]);
            %     text(dataX(pNullUncorr<pThreshStrict), (plotY+shiftUp)*ones(sum(pNullUncorr<pThreshStrict), 1), '**', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [0 0 1]);
            % Z-threshold (not used anymore)
            %     text(dataX(zNullUncorr>zThresh & zNullUncorr<zThreshStrict), (plotY+shiftUp)*ones(sum(zNullUncorr>zThresh & zNullUncorr<zThreshStrict), 1), '*', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [0 0 1]);
            %     text(dataX(zNullUncorr>zThreshStrict), (plotY+shiftUp)*ones(sum(zNullUncorr>zThreshStrict), 1), '**', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [0 0 1]);
            % p-values in text
%             text(dataX(1:end-1), (plotY+shiftUp)*ones(length(dataX)-1, 1), strcat('p=',cellfun(@num2str, num2cell(pNullUncorr), 'UniformOutput', false)), 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [0 0 0], 'Rotation', 70);
            
        case 'prefPosNullNeg'
            % Combine preferred and null
%             text(dataX(1:end-1), (plotY+shiftUp)*ones(length(dataX)-1, 1), strcat('p=',cellfun(@num2str, num2cell([pNullUncorr(end:-1:2) pPrefUncorr]), 'UniformOutput', false)), 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [0 0 0], 'Rotation', 70);
    end
    
    currAx = axis;
    if currAx(end) < plotY + 2*shiftUp;
        currAx(end) = plotY + 2*shiftUp;
        axis(currAx);
    end
    if currAx(end-1) > minOverall-2*shiftUp;
        currAx(end-1) = minOverall-2*shiftUp;
        axis(currAx);
    end
end

hold on;
constLine = PlotConstLine(dataPointsNull(end),1);
constLine.Annotation.LegendInformation.IconDisplayStyle = 'off';

 ConfAxis('fTitle',finalTitle);%ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis],'fTitle',finalTitle);
%  legend({'Preferred\newline ** Z>3 from uncorr\newline * Z>2 from uncorr', 'Null\newline ** Z>3 from uncorr\newline * Z>2 from uncorr'})

currLeg = legend;
legend([currLeg.String {legendEntry}]);%, 'Location', 'NorthEastOutside')
text(0, 0, sprintf('** p<%0.1d from uncorr\\newline * p<%0.1d from uncorr', pThreshStrict, pThresh), 'VerticalAlignment', 'bottom',  'HorizontalAlignment', 'left');
 
 end