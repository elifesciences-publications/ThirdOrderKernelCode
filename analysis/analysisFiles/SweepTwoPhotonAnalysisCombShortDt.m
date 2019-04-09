 function analysis = SweepTwoPhotonAnalysisCombShortDt(flyResp,epochs,params,~,dataRate, dataType,interleaveEpoch,varargin)

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
    plotOrderChange = false;
    % Can't instantiate this as empty because plenty of figures will have
    % empty names as the default
    figureName = 'omgIHopeNoFigureIsEverNamedThis';

    fprintf('Two plots this time\n');
    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    % Gotta unwrap the eyes because of how they're put in here
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
        fprintf('%%NaN = %f\n', percNan);
        if percNan>5
            % Effectively killing everything here
            flyResp{ff} = nan(size(flyResp{ff}));
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

        shortDts = {'dt=1$', 'dt=2$', 'dt=3$'};
        leftShort = false(1,length(epochNames));
        for i = 1:length(shortDts)
            leftShort = leftShort |( ~cellfun('isempty',regexp(epochNames, shortDts{i})) & leftEpochs);
        end
        leftShort = find(leftShort);
        
        rightShort = false(1,length(epochNames));
        for i = 1:length(shortDts)
            rightShort = rightShort | (~cellfun('isempty',regexp(epochNames, shortDts{i})) & ~leftEpochs);
        end
        rightShort = find(rightShort);
        
        for trlCols = 1:size(averagedTrials, 2)
            averagedTrials(leftShort, trlCols) = num2cell(nanmean([averagedTrials{leftShort, trlCols}]));
            averagedTrials(rightShort, trlCols) = num2cell(nanmean([averagedTrials{rightShort, trlCols}]));
        end

%         subtractedTrials = SubtractTrials(averagedTrials, trialsBase, trialsToSubtract);
        uncorrEpochMean = mean([averagedTrials{uncorrEpochLeft, :}; averagedTrials{uncorrEpochRight, :}]);
        averagedTrials(uncorrEpochLeft, :) = num2cell(uncorrEpochMean);
        averagedTrials(uncorrEpochRight, :) = num2cell(uncorrEpochMean);
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
    
    
%     averagedFlies{1}(leftShort) = num2cell(mean([averagedFlies{1}{leftShort}]));
    averagedFliesSem{1}(leftShort) = num2cell([averagedFliesSem{1}{leftShort}]/sqrt(length(leftShort)));
%     averagedFlies{1}(rightShort) = num2cell(mean([averagedFlies{1}{rightShort}]));
    averagedFliesSem{1}(rightShort) = num2cell([averagedFliesSem{1}{rightShort}]/sqrt(length(rightShort)));
    
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

    respMatDiffSem = SnipMatToMatrix(averagedDiffFliesSem); % turn snipMat into a matrix
    respMatDiffSemSep = SeparateTraces(respMatDiffSem,numSep,''); % separate every numSnips epochs into a new trace to plot
    respMatDiffSemPlot = permute(respMatDiffSemSep,[3 7 6 1 2 4 5]);
    
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
    averagedDiffUncorrFliesSem{1}(leftShort) = num2cell([averagedDiffUncorrFliesSem{1}{leftShort}]/sqrt(length(leftShort)));
    averagedDiffUncorrFliesSem{1}(rightShort) = num2cell([averagedDiffUncorrFliesSem{1}{rightShort}]/sqrt(length(rightShort)));

    
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

    respMatUncorrDiffSem = SnipMatToMatrix(averagedDiffUncorrFliesSem); % turn snipMat into a matrix
    respMatUncorrDiffSemSep = SeparateTraces(respMatUncorrDiffSem,numSep,''); % separate every numSnips epochs into a new trace to plot
    respMatUncorrDiffSemPlot = permute(respMatUncorrDiffSemSep,[3 7 6 1 2 4 5]);

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
    
    
    
    plotFigureIndividualFlies = findobj('Type', 'Figure', 'Name', figureName);
    plotFigureSem = findobj('Type', 'Figure', 'Name', [figureName ' SEM']);
    plotFigureTT = findobj('Type', 'Figure', 'Name', [figureName ' TT']);
    plotFigureDiffSem = findobj('Type', 'Figure', 'Name', [figureName ' Diff SEM']);
    if isempty(plotFigureIndividualFlies)
        plotFigureIndividualFlies = MakeFigure;
        plotFigureSem=MakeFigure;
        plotFigureTT = MakeFigure;
        plotFigureDiffSem = MakeFigure;
        newPlot = true;
    else
        newPlot = false;
    end
    
    tVals = linspace(snipShift, snipShift+duration, size(timePlots{1}{1}, 1));
    
    if ~isempty(flyEyes)
        figure(plotFigureIndividualFlies);
        if newPlot || (isempty(get(subplot(2, 2, 3), 'children')) && plotOrderChange)%We're in the progressive regime now
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
            if ~isempty(prefEpochs)% && ~plotOrderChange
                if ~isempty(uncorrBarsEpoch)
                    prefEpochs = [prefEpochs uncorrBarsEpoch(1)];
                    nullEpochs = [nullEpochs uncorrBarsEpoch(2)];
                end
                subplotNums = {2, 2, 1};
                PlotAllCurves(subplotNums, plotFigureSem, plotFigureIndividualFlies, plotFigureDiffSem, plotFigureTT,...
                    params{ff}, tVals, dataX, prefEpochs, nullEpochs, finalTitle,...
                    averagedFliesTime, averagedFliesTimeSem, respMatIndPlot, respMatPlot, respMatSemPlot, respMatDiffPlot, respMatDiffSemPlot, respMatUncorrDiffPlot, respMatUncorrDiffSemPlot);
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
                subplotNums = {2, 2, 3};
                PlotAllCurves(subplotNums, plotFigureSem, plotFigureIndividualFlies, plotFigureDiffSem, plotFigureTT,...
                    params{ff}, tVals, dataX, prefEpochs, nullEpochs, finalTitle,...
                    averagedFliesTime, averagedFliesTimeSem, respMatIndPlot, respMatPlot, respMatSemPlot, respMatDiffPlot, respMatDiffSemPlot, respMatUncorrDiffPlot, respMatUncorrDiffSemPlot);
            end
            
            plotFigureIndividualFlies.Name = figureName;
            plotFigureSem.Name = [figureName ' SEM'];
            plotFigureTT.Name = [figureName ' TT'];
            plotFigureDiffSem.Name = [figureName ' Diff SEM'];
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
            if ~isempty(prefEpochs)% && ~plotOrderChange
                if ~isempty(uncorrBarsEpoch)
                    prefEpochs = [prefEpochs uncorrBarsEpoch(1)];
                    nullEpochs = [nullEpochs uncorrBarsEpoch(2)];
                end
                subplotNums = {2, 2, 2};
                PlotAllCurves(subplotNums, plotFigureSem, plotFigureIndividualFlies, plotFigureDiffSem, plotFigureTT,...
                    params{ff}, tVals, dataX, prefEpochs, nullEpochs, finalTitle,...
                    averagedFliesTime, averagedFliesTimeSem, respMatIndPlot, respMatPlot, respMatSemPlot, respMatDiffPlot, respMatDiffSemPlot, respMatUncorrDiffPlot, respMatUncorrDiffSemPlot);
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
                subplotNums = {2, 2, 4};
                PlotAllCurves(subplotNums, plotFigureSem, plotFigureIndividualFlies, plotFigureDiffSem, plotFigureTT,...
                    params{ff}, tVals, dataX, prefEpochs, nullEpochs, finalTitle,...
                    averagedFliesTime, averagedFliesTimeSem, respMatIndPlot, respMatPlot, respMatSemPlot, respMatDiffPlot, respMatDiffSemPlot, respMatUncorrDiffPlot, respMatUncorrDiffSemPlot);
                
            end
            
            flyAxes = plotFigureIndividualFlies.Children.findobj('Type','Axes');
            flyAxes(cellfun('isempty', {flyAxes.Children})) = [];
            flySemAxes = plotFigureSem.Children.findobj('Type','Axes');
            flyTTAxes = plotFigureTT.Children.findobj('Type','Axes');
            flyDiffSemAxes = plotFigureDiffSem.Children.findobj('Type', 'Axes');
            minY = min([flyAxes.YLim 0]);
            maxY = max([flyAxes.YLim]);
            [flyAxes.YLim] = deal([minY maxY]);
            
            minY = min([flySemAxes.YLim 0]);
            maxY = max([flySemAxes.YLim]);
            [flySemAxes.YLim] = deal([minY maxY]);
            
            minY = min([flyTTAxes.YLim 0]);
            maxY = max([flyTTAxes.YLim]);
            [flyTTAxes.YLim] = deal([minY maxY]);
            
            minY = min([flyDiffSemAxes.YLim 0]);
            maxY = max([flyDiffSemAxes.YLim]);
            [flyDiffSemAxes.YLim] = deal([minY maxY]);            
            
            [flyAxes.XTick] = deal(tickX);
            [flyAxes.XTickLabel] = deal(tickLabelX);
            [flyAxes.XTickLabelRotation] = deal(45);
            
            [flySemAxes.XTick] = deal(tickX);
            [flySemAxes.XTickLabel] = deal(tickLabelX);
            [flySemAxes.XTickLabelRotation] = deal(45);
            
            [flyDiffSemAxes.XTick] = deal(tickX);
            [flyDiffSemAxes.XTickLabel] = deal(tickLabelX);
            [flyDiffSemAxes.XTickLabelRotation] = deal(45);
            
            for figInd = 1:length(flyAxes)
                flyAxes(figInd).XLabel.String = labelX;
                flyAxes(figInd).YLabel.String = labelY;
                flySemAxes(figInd).XLabel.String = labelX;
                flySemAxes(figInd).YLabel.String = labelY;
                flyDiffSemAxes(figInd).XLabel.String = labelX;
                flyDiffSemAxes(figInd).YLabel.String = labelY;
                flyTTAxes(figInd).XLabel.String = 'Time (ms)';
                flyTTAxes(figInd).YLabel.String = labelY;
            end
        end
    else
        
%         for pp = 1:size(respMatPlot,3)
%             PlotXvsY(dataX',respMatPlot(:,:,pp),'error',respMatSemPlot(:,:,pp));
%             ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis{pp} ' - ' num2str(numFlies) ' flies'],'fTitle',finalTitle);
%         end
    end
 end
 
 function PlotAllCurves(subplotNums, plotFigureSem, plotFigureIndividualFlies, plotFigureDiffSem, plotFigureTT, params, tVals, dataX, prefEpochs, nullEpochs, finalTitle, averagedFliesTime, averagedFliesTimeSem, respMatIndPlot, respMatPlot, respMatSemPlot, respMatDiffPlot, respMatDiffSemPlot, respMatUncorrDiffPlot, respMatUncorrDiffSemPlot)
 % Plot all the curves in one bundle!
 dt1Epoch = find([params(nullEpochs).delay]==1, 1, 'first');
 figure(plotFigureSem);
 subplot(subplotNums{:});
 PlotSemCurves(dataX, prefEpochs, nullEpochs, finalTitle, respMatPlot, respMatSemPlot, respMatDiffPlot, respMatDiffSemPlot, respMatUncorrDiffPlot, respMatUncorrDiffSemPlot);
%  PlotSemCurves(dataX, prefEpochs, nullEpochs, finalTitle, respMatUncorrDiffPlot, respMatUncorrDiffSemPlot, respMatDiffPlot, respMatDiffSemPlot, respMatUncorrDiffPlot, respMatUncorrDiffSemPlot);
 
 figure(plotFigureIndividualFlies);
 subplot(subplotNums{:});
 PlotIndividualFlies(dataX, finalTitle, respMatPlot, respMatIndPlot, prefEpochs,nullEpochs)
 
 figure(plotFigureDiffSem)
 subplot(subplotNums{:});
 PlotDiffSemCurves(dataX, prefEpochs, finalTitle, respMatDiffPlot, respMatDiffSemPlot);
 
 
 figure(plotFigureTT);
 subplot(subplotNums{:});
 PlotTimeTraces(tVals, finalTitle, averagedFliesTime,averagedFliesTimeSem,prefEpochs, nullEpochs, dt1Epoch)
 end

 function PlotSemCurves(dataX, prefEpochs, nullEpochs, finalTitle, respMatPlot, respMatSemPlot, respMatDiffPlot, respMatDiffSemPlot, respMatUncorrDiffPlot, respMatUncorrDiffSemPlot)
 % Plots dem SEM curves!
 zUnpaired = (respMatPlot(prefEpochs(1:end-1), :)-respMatPlot(nullEpochs(1:end-1), :))./sqrt(respMatSemPlot(prefEpochs(1:end-1), :).^2+respMatSemPlot(nullEpochs(1:end-1), :).^2);
 zPrefUncorr = (respMatPlot(prefEpochs(1:end-1), :)-respMatPlot(prefEpochs(end), :))./sqrt(respMatSemPlot(prefEpochs(1:end-1), :).^2+respMatSemPlot(prefEpochs(end), :).^2);
 zNullUncorr = (respMatPlot(nullEpochs(1:end-1), :)-respMatPlot(nullEpochs(end), :))./sqrt(respMatSemPlot(nullEpochs(1:end-1), :).^2+respMatSemPlot(nullEpochs(end), :).^2);
 zPaired = (respMatDiffPlot(prefEpochs(1:end-1), :))./sqrt(respMatDiffSemPlot(prefEpochs(1:end-1), :).^2);
 zPrefUncorr = (respMatUncorrDiffPlot(prefEpochs(1:end-1), :))./sqrt(respMatUncorrDiffSemPlot(prefEpochs(1:end-1), :).^2);
 zNullUncorr = (respMatUncorrDiffPlot(nullEpochs(1:end-1), :))./sqrt(respMatUncorrDiffSemPlot(nullEpochs(1:end-1), :).^2);
 zVals = [zPrefUncorr zNullUncorr zUnpaired zPaired];
 PlotXvsY(dataX(1:end-1)',[respMatPlot(prefEpochs(1:end-1),:) respMatPlot(nullEpochs(1:end-1),:) repmat(respMatPlot(nullEpochs(end),:), length(dataX)-1, 1)],'error',[respMatSemPlot(prefEpochs(1:end-1),:) respMatSemPlot(nullEpochs(1:end-1),:) repmat(respMatSemPlot(nullEpochs(end),:), length(dataX)-1, 1)], 'color', [1 0 0; 0 0 1; .5 .5 .5]);
%  for zValInd = 1:length(dataX)-1
%      text(dataX(zValInd),respMatPlot(prefEpochs(1)), sprintf('%0.2d\\newline ', zVals(zValInd,:)), 'Rotation', 45, 'FontSize', 5)
%  end
%  text(dataX(end), respMatPlot(end), 'Z Pref\newline Z Null\newline Z Unpaired\newline Z Paired');

dataPointsPref = respMatPlot(prefEpochs,:);
dataPointsPrefSem = respMatSemPlot(prefEpochs,:);
dataPointsNull = respMatPlot(nullEpochs,:);
dataPointsNullSem = respMatSemPlot(nullEpochs,:);
zPrefUncorr = abs(zPrefUncorr);
zNullUncorr = abs(zNullUncorr);
dataPointsComboBest = [dataPointsPref(zPrefUncorr>2)+dataPointsPrefSem(zPrefUncorr>2); dataPointsNull(zNullUncorr>2)+dataPointsNullSem(zNullUncorr>2)];
dataPointsComboBestSem = [dataPointsPrefSem(zPrefUncorr>2); dataPointsNullSem(zNullUncorr>2)];
[maxVal, maxInd] = max(dataPointsComboBest);

comparisonNum = length(nullEpochs)+length(prefEpochs)-2; % subtract 2 for uncorrelated epochs
pThresh = 0.05;
pThresh = pThresh/comparisonNum;
zThresh = norminv(1-pThresh);

pThreshStrict = 0.01;
pThreshStrict = pThreshStrict/comparisonNum;
zThreshStrict = norminv(1-pThreshStrict);

dataPointsComboAll = [dataPointsPref+dataPointsPrefSem; dataPointsNull+dataPointsNullSem];
dataPointsComboAllSem = [dataPointsPrefSem; dataPointsNullSem];
[maxOverall, maxOverallInd] = max(dataPointsComboAll);
if ~isempty(maxVal)
    if maxOverall>maxVal
        maxVal = maxOverall;
        shiftUp = dataPointsComboAllSem(maxOverallInd);
    else
        shiftUp = dataPointsComboBestSem(maxInd);
    end
    plotY = maxVal + shiftUp;
    % Preferred
    text(dataX(zPrefUncorr>zThresh & zPrefUncorr<zThreshStrict), plotY*ones(sum(zPrefUncorr>zThresh & zPrefUncorr<zThreshStrict), 1), '*', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [1 0 0]);
    text(dataX(zPrefUncorr>zThreshStrict), plotY*ones(sum(zPrefUncorr>zThreshStrict), 1), '**', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [1 0 0]);
    % Null
    text(dataX(zNullUncorr>zThresh & zNullUncorr<zThreshStrict), (plotY+shiftUp)*ones(sum(zNullUncorr>zThresh & zNullUncorr<zThreshStrict), 1), '*', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [0 0 1]);
    text(dataX(zNullUncorr>zThreshStrict), (plotY+shiftUp)*ones(sum(zNullUncorr>zThreshStrict), 1), '**', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [0 0 1]);
    
    currAx = axis;
    if currAx(end) < plotY + 2*shiftUp;
        currAx(end) = plotY + 2*shiftUp;
        axis(currAx);
    end
end

hold on;
PlotConstLine(dataPointsNull(end),1);

 ConfAxis('fTitle',finalTitle);%ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis],'fTitle',finalTitle);
%  legend({'Preferred\newline ** Z>3 from uncorr\newline * Z>2 from uncorr', 'Null\newline ** Z>3 from uncorr\newline * Z>2 from uncorr'})
legend({sprintf('Preferred'), sprintf('Null')})
text(0, 0, sprintf('** p<%0.1d from uncorr\\newline * p<%0.1d from uncorr', pThreshStrict, pThresh), 'VerticalAlignment', 'bottom',  'HorizontalAlignment', 'left');
 
 end
 
 function PlotDiffSemCurves(dataX, prefEpochs, finalTitle, respMatDiffPlot, respMatDiffSemPlot)
 % Diff sem plots!
 zPaired = (respMatDiffPlot(prefEpochs(1:end-1), :))./sqrt(respMatDiffSemPlot(prefEpochs(1:end-1), :).^2);
 
 PlotXvsY(dataX',[respMatDiffPlot(prefEpochs,:)],'error',[respMatDiffSemPlot(prefEpochs,:)], 'color', [1 0 0; 0 0 1]);
 hold on
 dataPoints = respMatDiffPlot(prefEpochs,:);
 dataPointsSem = respMatDiffSemPlot(prefEpochs,:);
 zPaired = abs(zPaired);
 [maxVal, maxInd] = max(dataPoints(zPaired>2)+dataPointsSem(zPaired>2));
 
 comparisonNum = length(prefEpochs)-1; % subtract 1 for uncorrelated epoch
pThresh = 0.05;
pThresh = pThresh/comparisonNum;
zThresh = norminv(1-pThresh);

pThreshStrict = 0.01;
pThreshStrict = pThreshStrict/comparisonNum;
zThreshStrict = norminv(1-pThreshStrict);

 
 if ~isempty(maxVal)
     plotY = maxVal + dataPointsSem(maxInd);
     text(dataX(zPaired>zThresh & zPaired<zThreshStrict), plotY*ones(sum(zPaired>zThresh & zPaired<zThreshStrict), 1), '*', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [0 0 0]);
     text(dataX(zPaired>zThreshStrict), plotY*ones(sum(zPaired>zThreshStrict), 1), '**', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [0 0 0]);
     currAx = axis;
     if currAx(end) < plotY + dataPointsSem(maxInd);
         currAx(end) = plotY + dataPointsSem(maxInd);
         axis(currAx);
     end
 end
 ConfAxis('fTitle',finalTitle);
 legend({sprintf('Preferred-Null')});
 text(0, 0, sprintf('** p<%0.1d from uncorr\\newline * p<%0.1d from uncorr', pThreshStrict, pThresh), 'VerticalAlignment', 'bottom',  'HorizontalAlignment', 'left');

 end
 
 function PlotTimeTraces(tVals, finalTitle, averagedFliesTime,averagedFliesTimeSem,prefEpochs, nullEpochs, dt1Epoch)
 % Time traces!
 colorsPref = bsxfun(@times, (1-((1:length(prefEpochs))-1)/length(prefEpochs))', repmat([1 0 0], length(prefEpochs),1));
 colorsNull = bsxfun(@times, (1-((1:length(nullEpochs))-1)/length(nullEpochs))', repmat([0 0 1], length(nullEpochs),1));
 colors = [colorsPref; colorsNull];
 timeTraces = cat(2, averagedFliesTime{1}{[prefEpochs(dt1Epoch) nullEpochs([dt1Epoch end])]});
 timeTraceErrors = cat(2, averagedFliesTimeSem{1}{[prefEpochs(dt1Epoch) nullEpochs([dt1Epoch end])]});
 PlotXvsY(tVals', timeTraces, 'error', timeTraceErrors, 'color', [colors([1 length(prefEpochs)+1], :); 0 1 0 ]);
 ConfAxis('fTitle',finalTitle);
 legend({'dt=1 preferred', 'dt=1 null', 'Uncorrelated Epochs'});
 end
 
 function PlotIndividualFlies(dataX, finalTitle, respMatPlot, respMatIndPlot, prefEpochs,nullEpochs)
 % Individual flies dt sweep!
 % Plot mean twice--first for legend, then to be on top in graph
 dataToPlot = [ respMatPlot(prefEpochs,:) respMatPlot(nullEpochs,:) respMatIndPlot(prefEpochs, :) respMatIndPlot(nullEpochs, :) respMatPlot(prefEpochs,:) respMatPlot(nullEpochs,:)];
 numFlies = size(respMatIndPlot, 2);
 colors = [ 1 0 0; 0 0 1;repmat([1 .8 .8], numFlies, 1); repmat([.8 .8 1], numFlies, 1); 1 0 0; 0 0 1];
 if length(dataX) == 1
     dataX = dataX * ones(size(dataToPlot));
 end
 if ~isempty(dataToPlot)
     PlotXvsY(dataX', dataToPlot, 'color', colors);
     ConfAxis('fTitle',finalTitle);%ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis],'fTitle',finalTitle, 'MarkerStyle','*');
     legend({'Preferred', 'Null', 'Individual Fly'})
 end
 end