 function analysis = SweepWidthTwoPhotonAnalysis(flyResp,epochs,params,~,dataRate, dataType,interleaveEpoch,varargin)

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
    params = cellfun(@(prm) prm{1}, params, 'UniformOutput', false);
    
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
        %% get processed trials
        percNan = 100*sum(isnan(flyResp{ff}(:, 1)))/size(flyResp{ff}, 1);
        fprintf('%%NaN = %f\n', percNan);
        if percNan>5
            % Effectively killing everything here
            flyResp{ff} = nan(size(flyResp{ff}));
        end
        analysis.indFly{ff} = GetProcessedTrials(flyResp{ff},epochs{ff},params{ff},dataRate,dataType,varargin{:},'snipShift', 0000, 'duration', []);

        %% remove epochs you dont want analyzed
        ignoreEpochs = analysis.indFly{ff}{end}.snipMat(numIgnore+1:end,:);

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'ignoreEpochs';
        analysis.indFly{ff}{end}.snipMat = ignoreEpochs;
        
        %% Correct by eye
         % Eyes not being empty is an indication that we have to shuffle around
        % epochs to account for progressive/regressive stimulus differences
        % (direction-wise) in different eyes
        ignoreEpochsEyeCorrected = ignoreEpochs;
        if ~isempty(flyEyes)
            epochNames = {params{ff}.epochName};
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
        
        
        %% Subtract trials
        uncorrEpoch = strcmp(epochNames, 'Uncorrelated Bars');


%         subtractedTrials = SubtractTrials(averagedTrials, trialsBase, trialsToSubtract);
        subtractedTrials = cell(size(averagedTrials));
        subtractedTrials(repmat(leftEpochs, [1, size(averagedTrials, 2)])) = (num2cell([averagedTrials{leftEpochs, :}]-[averagedTrials{rightEpochs, :}]));
        subtractedTrials(repmat(rightEpochs, [1, size(averagedTrials, 2)])) = (num2cell([averagedTrials{rightEpochs, :}]-[averagedTrials{leftEpochs, :}]));
        subtractedTrials(uncorrEpoch, :) = averagedTrials(uncorrEpoch, :);
        subtractedTrials(cellfun('isempty', subtractedTrials)) = {0};
        subTrialsROI{ff} = subtractedTrials;
        
        %% averaged over subtracted trials
        averagedSubtractedROIs{ff} = ReduceDimension(subtractedTrials,'Rois',@nanmean);
        
        
        
        
        
        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedSubtractedROIs';
        analysis.indFly{ff}{end}.snipMat = averagedSubtractedROIs;
        
        
        %% average over ROIs
        averagedROIs{ff} = ReduceDimension(averagedTrials,'Rois',@nanmean);
        
        [numEpochs,numROIs(ff)] = size(averagedTrials);
        fprintf('%d ROIs for fly %d\n', numROIs(ff), ff);
        
        
        
        
        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedROIs';
        analysis.indFly{ff}{end}.snipMat = averagedROIs;
        %% make analysis readable
        analysis.indFly{ff} = MakeAnalysisReadable(analysis.indFly{ff});
        
        
        %% grab roi bordered trials
        roiBorderedResps = GetProcessedTrials(flyResp{ff},epochs{ff},params{ff},dataRate,dataType,varargin{:},'snipShift', snipShift, 'duration', duration);
        roiBorderedTrials = roiBorderedResps{end}.snipMat(numIgnore+1:end,:);
        
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
    
    averagedFliesTime = {ReduceDimension(cat(2, timePlots{:}),'Rois',@nanmean)};
    
    
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
    averagedDiffFlies = ReduceDimension(averagedROIs,'flies',@nanmean);
%     averagedDiffFliesSem = {ReduceDimension(cat(2, subTrialsROI{:}),'Rois',@NanSem)};%
    averagedDiffFliesSem = ReduceDimension(averagedROIs,'flies',@NanSem);
    
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
    
    
    
    plotFigure = findobj('Type', 'Figure', 'Name', figureName);
    plotFigureSem = findobj('Type', 'Figure', 'Name', [figureName ' SEM']);
    plotFigureTT = findobj('Type', 'Figure', 'Name', [figureName ' TT']);
    if isempty(plotFigure)
        plotFigure = MakeFigure;
        plotFigureSem=MakeFigure;
        plotFigureTT = MakeFigure;
        newPlot = true;
    else
        newPlot = false;
    end
    
    tVals = linspace(snipShift, snipShift+duration, size(timePlots{1}{1}, 1));
    
    if ~isempty(flyEyes)
        figure(plotFigure);
        if newPlot || (isempty(get(subplot(2, 2, 3), 'children')) && plotOrderChange)%We're in the progressive regime now
            finalTitle = ['Progressive Positive ' num2str(numROIs(1)) sprintf(',%d', numROIs(2:end))];
            progPosPrefDir = 'L+'; % Remember that we're in a left dominated world
            progPosNullDir = 'R+';
            uncorrelatedDir = 'Uncorrelated';
            zeroPosDir = 'S+';
            uncorrBarsEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, uncorrelatedDir));
            zeroPosEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, zeroPosDir));
            progPosPrefEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, progPosPrefDir));
        	progPosNullEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, progPosNullDir));
            progPosPrefEpochs = [find(progPosPrefEpochs)];
            progPosNullEpochs = [find(progPosNullEpochs)];
            if ~isempty(progPosPrefEpochs)
                dt1Epoch = find([params{ff}(progPosPrefEpochs).delay]==1, 1, 'first');
                figure(plotFigure);
                subplot(2, 2, 1);
                % Plot mean twice--first for legend, then to be on top in graph
                dataToPlot = [ respMatPlot(progPosPrefEpochs,:) respMatPlot(progPosNullEpochs,:) respMatPlot(uncorrBarsEpochs,:) respMatPlot(zeroPosEpochs,:) respMatIndPlot(progPosPrefEpochs, :) respMatIndPlot(progPosNullEpochs, :) respMatIndPlot(uncorrBarsEpochs,:) respMatIndPlot(zeroPosEpochs,:)  respMatPlot(progPosPrefEpochs,:) respMatPlot(progPosNullEpochs,:) respMatPlot(uncorrBarsEpochs,:) respMatPlot(zeroPosEpochs,:) ];
                colors = [ 1 0 0; 0 0 1; 0 1 0; 1 0 1;repmat([1 .8 .8], numFlies, 1); repmat([.8 .8 1], numFlies, 1); repmat([.8 1 .8], numFlies, 1); repmat([1 .8 1], numFlies, 1); 1 0 0; 0 0 1;0 1 0; 1 0 1];
                if length(dataX) == 1
                    dataX = dataX * ones(size(dataToPlot));
                end
                if ~isempty(dataToPlot)
                    PlotXvsY(dataX', dataToPlot, 'color', colors);
                    ConfAxis('fTitle',finalTitle);%ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis],'fTitle',finalTitle, 'MarkerStyle','*');
                    legend({'Preferred', 'Null', 'Uncorr', 'Zero', 'Individual Fly'})
                end
                
                figure(plotFigureSem);
                subplot(2, 2, 1);
                prefEpochs = progPosPrefEpochs;
                nullEpochs = progPosNullEpochs;
                zUnpaired = (respMatPlot(prefEpochs(1:end-1), :)-respMatPlot(nullEpochs(1:end-1), :))./sqrt(respMatSemPlot(prefEpochs(1:end-1), :).^2+respMatSemPlot(nullEpochs(1:end-1), :).^2);
                zPrefUncorr = (respMatPlot(prefEpochs(1:end-1), :)-respMatPlot(prefEpochs(end), :))./sqrt(respMatSemPlot(prefEpochs(1:end-1), :).^2+respMatSemPlot(prefEpochs(end), :).^2);
                zNullUncorr = (respMatPlot(nullEpochs(1:end-1), :)-respMatPlot(nullEpochs(end), :))./sqrt(respMatSemPlot(nullEpochs(1:end-1), :).^2+respMatSemPlot(nullEpochs(end), :).^2);
                zPaired = (respMatDiffPlot(prefEpochs(1:end-1), :))./sqrt(respMatDiffSemPlot(prefEpochs(1:end-1), :).^2);
                zVals = [zPrefUncorr zNullUncorr zUnpaired zPaired];
                PlotXvsY(dataX',[respMatPlot(progPosPrefEpochs,:) respMatPlot(progPosNullEpochs,:) respMatPlot(uncorrBarsEpochs,:) respMatPlot(zeroPosEpochs,:)],'error',[respMatSemPlot(progPosPrefEpochs,:) respMatSemPlot(progPosNullEpochs,:) respMatSemPlot(uncorrBarsEpochs,:) respMatSemPlot(zeroPosEpochs,:)], 'color', [1 0 0; 0 0 1; 0 1 0; 1 0 1]);
                for zValInd = 1:length(dataX)-1
                    text(dataX(zValInd),respMatPlot(prefEpochs(1)), sprintf('%0.2d\\newline ', zVals(zValInd,:)), 'Rotation', 45)
                end
                text(dataX(end), respMatPlot(end), 'Z Pref\newline Z Null\newline Z Unpaired\newline Z Paired');
                %             PlotXvsY(dataX',respMatIndPlot(progPosPrefEpochs, :), 'color', [1 .8 .8]);
                %             PlotXvsY(dataX',respMatIndPlot(progPosNullEpochs, :), 'color', [.8 .8 1]);
                %             PlotXvsY(dataX',[respMatPlot(progPosPrefEpochs,:) respMatPlot(progPosNullEpochs,:)], 'color', [0 0 1; 1 0 0]);
                ConfAxis('fTitle',finalTitle);%ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis],'fTitle',finalTitle);
                legend({'Preferred', 'Null', 'Uncorr', 'Zero'})
                
                figure(plotFigureTT);
                subplot(2, 2, 1);
                colorsPref = bsxfun(@times, (1-((1:length(progPosPrefEpochs))-1)/length(progPosPrefEpochs))', repmat([1 0 0], length(progPosPrefEpochs),1));
                colorsNull = bsxfun(@times, (1-((1:length(progPosNullEpochs))-1)/length(progPosNullEpochs))', repmat([0 0 1], length(progPosNullEpochs),1));
                colors = [colorsPref; colorsNull];
                timeTraces = cat(2, averagedFliesTime{1}{[progPosPrefEpochs(dt1Epoch) progPosNullEpochs(dt1Epoch) progPosNullEpochs(end)]});
                PlotXvsY(tVals', timeTraces, 'color', [colors([1, length(progPosPrefEpochs)+1],:); 0 1 0]);
                ConfAxis('fTitle',finalTitle);
            end
            
            finalTitle = ['Progressive Negative ' num2str(numROIs(1)) sprintf(',%d', numROIs(2:end))];
            progNegPrefDir = 'L-'; % Remember that we're in a left dominated world
            progNegNullDir = 'R-';
            uncorrelatedDir = 'Uncorrelated';
            zeroNegDir = 'S-';
            uncorrBarsEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, uncorrelatedDir));
            zeroNegEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, zeroNegDir));
            progNegPrefEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, progNegPrefDir));
        	progNegNullEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, progNegNullDir));
            progNegPrefEpochs = [find(progNegPrefEpochs)];
            progNegNullEpochs = [find(progNegNullEpochs)];
            if ~isempty(progNegPrefEpochs)
                dt1Epoch = find([params{ff}(progNegPrefEpochs).delay]==1, 1, 'first');
                figure(plotFigure);
                subplot(2, 2, 3)
                % Plot mean twice--first for legend, then to be on top in graph
                dataToPlot = [ respMatPlot(progNegPrefEpochs,:) respMatPlot(progNegNullEpochs,:) respMatPlot(uncorrBarsEpochs,:) respMatPlot(zeroNegEpochs,:) respMatIndPlot(progNegPrefEpochs, :) respMatIndPlot(progNegNullEpochs, :) respMatIndPlot(uncorrBarsEpochs,:) respMatIndPlot(zeroNegEpochs,:) respMatPlot(progNegPrefEpochs,:) respMatPlot(progNegNullEpochs,:) respMatPlot(uncorrBarsEpochs,:) respMatPlot(zeroNegEpochs,:)];
                colors = [ 1 0 0; 0 0 1; 0 1 0; 1 0 1;repmat([1 .8 .8], numFlies, 1); repmat([.8 .8 1], numFlies, 1); repmat([.8 1 .8], numFlies, 1); repmat([1 .8 1], numFlies, 1); 1 0 0; 0 0 1;0 1 0; 1 0 1];
            
                PlotXvsY(dataX', dataToPlot, 'color', colors);
                ConfAxis('fTitle',finalTitle);%ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis],'fTitle',finalTitle);
                legend({'Preferred', 'Null', 'Uncorr', 'Zero', 'Individual Fly'})
                    
                figure(plotFigureSem);
                subplot(2, 2, 3)
                PlotXvsY(dataX',[respMatPlot(progNegPrefEpochs,:) respMatPlot(progNegNullEpochs,:) respMatPlot(uncorrBarsEpochs,:) respMatPlot(zeroNegEpochs,:)],'error',[respMatSemPlot(progNegPrefEpochs,:) respMatSemPlot(progNegNullEpochs,:) respMatSemPlot(uncorrBarsEpochs,:) respMatSemPlot(zeroNegEpochs,:)], 'color', [1 0 0; 0 0 1; 0 1 0; 1 0 1]);
                prefEpochs = progNegPrefEpochs;
                nullEpochs = progNegNullEpochs;
                zUnpaired = (respMatPlot(prefEpochs(1:end-1), :)-respMatPlot(nullEpochs(1:end-1), :))./sqrt(respMatSemPlot(prefEpochs(1:end-1), :).^2+respMatSemPlot(nullEpochs(1:end-1), :).^2);
                zPrefUncorr = (respMatPlot(prefEpochs(1:end-1), :)-respMatPlot(prefEpochs(end), :))./sqrt(respMatSemPlot(prefEpochs(1:end-1), :).^2+respMatSemPlot(prefEpochs(end), :).^2);
                zNullUncorr = (respMatPlot(nullEpochs(1:end-1), :)-respMatPlot(nullEpochs(end), :))./sqrt(respMatSemPlot(nullEpochs(1:end-1), :).^2+respMatSemPlot(nullEpochs(end), :).^2);
                zPaired = (respMatDiffPlot(prefEpochs(1:end-1), :))./sqrt(respMatDiffSemPlot(prefEpochs(1:end-1), :).^2);
                zVals = [zPrefUncorr zNullUncorr zUnpaired zPaired];
                for zValInd = 1:length(dataX)-1
                    text(dataX(zValInd),respMatPlot(prefEpochs(1)), sprintf('%0.2d\\newline ', zVals(zValInd,:)), 'Rotation', 45)
                end
                text(dataX(end), respMatPlot(end), 'Z Pref\newline Z Null\newline Z Unpaired\newline Z Paired');
                %             PlotXvsY(dataX',respMatIndPlot(progNegPrefEpochs, :), 'color', [1 .8 .8]);
                %             PlotXvsY(dataX',respMatIndPlot(progNegNullEpochs, :), 'color', [.8 .8 1]);
                %             PlotXvsY(dataX',[respMatPlot(progNegPrefEpochs,:) respMatPlot(progNegNullEpochs,:)], 'color', [1 0 0; 0 0 1]);
                ConfAxis('fTitle',finalTitle);%ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis],'fTitle',finalTitle);
                legend({'Preferred', 'Null', 'Uncorr', 'Zero'})
                
                figure(plotFigureTT);
                subplot(2, 2, 3);
                colorsPref = bsxfun(@times, (1-((1:length(progNegPrefEpochs))-1)/length(progNegPrefEpochs))', repmat([1 0 0], length(progNegPrefEpochs),1));
                colorsNull = bsxfun(@times, (1-((1:length(progNegNullEpochs))-1)/length(progNegNullEpochs))', repmat([0 0 1], length(progNegNullEpochs),1));
                colors = [colorsPref; colorsNull];
                timeTraces = cat(2, averagedFliesTime{1}{[progNegPrefEpochs(dt1Epoch) progNegNullEpochs([dt1Epoch end])]});
                PlotXvsY(tVals', timeTraces, 'color', [colors([1 length(progNegPrefEpochs)+1],:); 0 1 0]);
                ConfAxis('fTitle',finalTitle);
            end
            
            plotFigure.Name = figureName;
            plotFigureSem.Name = [figureName ' SEM'];
            plotFigureTT.Name = [figureName ' TT'];
        else % Regressive regime
            finalTitle = ['Regressive Positive ' num2str(numROIs(1)) sprintf(',%d', numROIs(2:end))];
            regPosPrefDir = 'R+'; % Remember that we're in a left dominated world
            regPosNullDir = 'L+';
            uncorrelatedDir = 'Uncorrelated';
            zeroPosDir = 'S+';
            uncorrBarsEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, uncorrelatedDir));
            zeroPosEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, zeroPosDir));
            regPosPrefEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, regPosPrefDir));
        	regPosNullEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, regPosNullDir));
            regPosPrefEpochs = [find(regPosPrefEpochs)];
            regPosNullEpochs = [find(regPosNullEpochs)];
            if ~isempty(regPosPrefEpochs)
                dt1Epoch = find([params{ff}(regPosPrefEpochs).delay]==1, 1, 'first');
                figure(plotFigureSem);
                subplot(2, 2, 2);
                PlotXvsY(dataX',[respMatPlot(regPosPrefEpochs,:) respMatPlot(regPosNullEpochs,:) respMatPlot(uncorrBarsEpochs,:) respMatPlot(zeroPosEpochs,:)],'error',[respMatSemPlot(regPosPrefEpochs,:) respMatSemPlot(regPosNullEpochs,:) respMatSemPlot(uncorrBarsEpochs,:) respMatSemPlot(zeroPosEpochs,:)], 'color', [1 0 0; 0 0 1; 0 1 0; 1 0 1]);
                prefEpochs = regPosPrefEpochs;
                nullEpochs = regPosNullEpochs;
                zUnpaired = (respMatPlot(prefEpochs(1:end-1), :)-respMatPlot(nullEpochs(1:end-1), :))./sqrt(respMatSemPlot(prefEpochs(1:end-1), :).^2+respMatSemPlot(nullEpochs(1:end-1), :).^2);
                zPrefUncorr = (respMatPlot(prefEpochs(1:end-1), :)-respMatPlot(prefEpochs(end), :))./sqrt(respMatSemPlot(prefEpochs(1:end-1), :).^2+respMatSemPlot(prefEpochs(end), :).^2);
                zNullUncorr = (respMatPlot(nullEpochs(1:end-1), :)-respMatPlot(nullEpochs(end), :))./sqrt(respMatSemPlot(nullEpochs(1:end-1), :).^2+respMatSemPlot(nullEpochs(end), :).^2);
                zPaired = (respMatDiffPlot(prefEpochs(1:end-1), :))./sqrt(respMatDiffSemPlot(prefEpochs(1:end-1), :).^2);
                zVals = [zPrefUncorr zNullUncorr zUnpaired zPaired];
                for zValInd = 1:length(dataX)-1
                    text(dataX(zValInd),respMatPlot(prefEpochs(1)), sprintf('%0.2d\\newline ', zVals(zValInd,:)), 'Rotation', 45)
                end
                text(dataX(end), respMatPlot(end), 'Z Pref\newline Z Null\newline Z Unpaired\newline Z Paired');
                ConfAxis('fTitle',finalTitle);%ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis],'fTitle',finalTitle);
                legend({'Preferred', 'Null', 'Uncorr', 'Zero'})
                
                figure(plotFigure);
                subplot(2, 2, 2);
                % Plot mean twice--first for legend, then to be on top in graph
                dataToPlot = [ respMatPlot(regPosPrefEpochs,:) respMatPlot(regPosNullEpochs,:) respMatPlot(uncorrBarsEpochs,:) respMatPlot(zeroPosEpochs,:) respMatIndPlot(regPosPrefEpochs, :) respMatIndPlot(regPosNullEpochs, :) respMatIndPlot(uncorrBarsEpochs,:) respMatIndPlot(zeroPosEpochs,:)  respMatPlot(regPosPrefEpochs,:) respMatPlot(regPosNullEpochs,:) respMatPlot(uncorrBarsEpochs,:) respMatPlot(zeroPosEpochs,:) ];
                colors = [ 1 0 0; 0 0 1; 0 1 0; 1 0 1;repmat([1 .8 .8], numFlies, 1); repmat([.8 .8 1], numFlies, 1); repmat([.8 1 .8], numFlies, 1); repmat([1 .8 1], numFlies, 1); 1 0 0; 0 0 1;0 1 0; 1 0 1];
                if length(dataX) == 1
                    dataX = dataX * ones(size(dataToPlot));
                end
                if ~isempty(dataToPlot)
                    PlotXvsY(dataX', dataToPlot, 'color', colors);
                    ConfAxis('fTitle',finalTitle);%ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis],'fTitle',finalTitle, 'MarkerStyle','*');
                    legend({'Preferred', 'Null', 'Uncorr', 'Zero', 'Individual Fly'})
                end
                
                figure(plotFigureTT);
                subplot(2, 2, 2);
                colorsPref = bsxfun(@times, (1-((1:length(regPosPrefEpochs))-1)/length(regPosPrefEpochs))', repmat([1 0 0], length(regPosPrefEpochs),1));
                colorsNull = bsxfun(@times, (1-((1:length(regPosNullEpochs))-1)/length(regPosNullEpochs))', repmat([0 0 1], length(regPosNullEpochs),1));
                colors = [colorsPref; colorsNull];
                timeTraces = cat(2, averagedFliesTime{1}{[regPosPrefEpochs(dt1Epoch) regPosNullEpochs([dt1Epoch end])]});
                PlotXvsY(tVals', timeTraces, 'color', [colors([1 length(regPosPrefEpochs)+1], :); 0 1 0]);
                ConfAxis('fTitle',finalTitle);
            end
            
            finalTitle = ['Regressive Negative ' num2str(numROIs(1)) sprintf(',%d', numROIs(2:end))];
            regNegPrefDir = 'R-'; % Remember that we're in a left dominated world
            regNegNullDir = 'L-';
            uncorrelatedDir = 'Uncorrelated';
            zeroNegDir = 'S-';
            uncorrBarsEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, uncorrelatedDir));
            zeroNegEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, zeroNegDir));
            regNegPrefEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, regNegPrefDir));
        	regNegNullEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, regNegNullDir));
            regNegPrefEpochs = [find(regNegPrefEpochs)];
            regNegNullEpochs = [find(regNegNullEpochs)];
            if ~isempty(regNegPrefEpochs)
                dt1Epoch = find([params{ff}(regNegPrefEpochs).delay]==1, 1, 'first');
                figure(plotFigureSem);
                subplot(2, 2, 4);
                PlotXvsY(dataX',[respMatPlot(regNegPrefEpochs,:) respMatPlot(regNegNullEpochs,:) respMatPlot(uncorrBarsEpochs,:) respMatPlot(zeroNegEpochs,:)],'error',[respMatSemPlot(regNegPrefEpochs,:) respMatSemPlot(regNegNullEpochs,:) respMatSemPlot(uncorrBarsEpochs,:) respMatSemPlot(zeroNegEpochs,:)], 'color', [1 0 0; 0 0 1; 0 1 0; 1 0 1]);
                prefEpochs = regNegPrefEpochs;
                nullEpochs = regNegNullEpochs;
                zUnpaired = (respMatPlot(prefEpochs(1:end-1), :)-respMatPlot(nullEpochs(1:end-1), :))./sqrt(respMatSemPlot(prefEpochs(1:end-1), :).^2+respMatSemPlot(nullEpochs(1:end-1), :).^2);
                zPrefUncorr = (respMatPlot(prefEpochs(1:end-1), :)-respMatPlot(prefEpochs(end), :))./sqrt(respMatSemPlot(prefEpochs(1:end-1), :).^2+respMatSemPlot(prefEpochs(end), :).^2);
                zNullUncorr = (respMatPlot(nullEpochs(1:end-1), :)-respMatPlot(nullEpochs(end), :))./sqrt(respMatSemPlot(nullEpochs(1:end-1), :).^2+respMatSemPlot(nullEpochs(end), :).^2);
                zPaired = (respMatDiffPlot(prefEpochs(1:end-1), :))./sqrt(respMatDiffSemPlot(prefEpochs(1:end-1), :).^2);
                zVals = [zPrefUncorr zNullUncorr zUnpaired zPaired];
                for zValInd = 1:length(dataX)-1
                    text(dataX(zValInd),respMatPlot(prefEpochs(1)), sprintf('%0.2d\\newline ', zVals(zValInd,:)), 'Rotation', 45)
                end
                text(dataX(end), respMatPlot(end), 'Z Pref\newline Z Null\newline Z Unpaired\newline Z Paired');
                ConfAxis('fTitle',finalTitle);%ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis],'fTitle',finalTitle);
                legend({'Preferred', 'Null', 'Uncorr', 'Zero'})
                
                figure(plotFigure);
                subplot(2, 2, 4);
                % Plot mean twice--first for legend, then to be on top in graph
                dataToPlot = [ respMatPlot(regNegPrefEpochs,:) respMatPlot(regNegNullEpochs,:) respMatPlot(uncorrBarsEpochs,:) respMatPlot(zeroNegEpochs,:) respMatIndPlot(regNegPrefEpochs, :) respMatIndPlot(regNegNullEpochs, :) respMatIndPlot(uncorrBarsEpochs,:) respMatIndPlot(zeroNegEpochs,:) respMatPlot(regNegPrefEpochs,:) respMatPlot(regNegNullEpochs,:) respMatPlot(uncorrBarsEpochs,:) respMatPlot(zeroNegEpochs,:)];
                colors = [ 1 0 0; 0 0 1; 0 1 0; 1 0 1;repmat([1 .8 .8], numFlies, 1); repmat([.8 .8 1], numFlies, 1); repmat([.8 1 .8], numFlies, 1); repmat([1 .8 1], numFlies, 1); 1 0 0; 0 0 1;0 1 0; 1 0 1];
            
                PlotXvsY(dataX', dataToPlot, 'color', colors);
                ConfAxis('fTitle',finalTitle);%ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis],'fTitle',finalTitle);
                legend({'Preferred', 'Null', 'Uncorr', 'Zero', 'Individual Fly'})
                
                figure(plotFigureTT);
                subplot(2, 2, 4);
                colorsPref = bsxfun(@times, (1-((1:length(regNegPrefEpochs))-1)/length(regNegPrefEpochs))', repmat([1 0 0], length(regNegPrefEpochs),1));
                colorsNull = bsxfun(@times, (1-((1:length(regNegNullEpochs))-1)/length(regNegNullEpochs))', repmat([0 0 1], length(regNegNullEpochs),1));
                colors = [colorsPref; colorsNull];
                timeTraces = cat(2, averagedFliesTime{1}{[regNegPrefEpochs(dt1Epoch) regNegNullEpochs([dt1Epoch end])]});
                PlotXvsY(tVals', timeTraces, 'color', [colors([1 length(regNegPrefEpochs)+1], :); 0 1 0 ]);
                ConfAxis('fTitle',finalTitle);
            end
            
            flyAxes = plotFigure.Children.findobj('Type','Axes');
            flyAxes(cellfun('isempty', {flyAxes.Children})) = [];
            flySemAxes = plotFigureSem.Children.findobj('Type','Axes');
            flyTTAxes = plotFigureTT.Children.findobj('Type','Axes');
            minY = min([flyAxes.YLim]);
            maxY = max([flyAxes.YLim]);
            [flyAxes.YLim] = deal([minY maxY]);
            
            minY = min([flySemAxes.YLim]);
            maxY = max([flySemAxes.YLim]);
            [flySemAxes.YLim] = deal([minY maxY]);
            
            minY = min([flyTTAxes.YLim]);
            maxY = max([flyTTAxes.YLim]);
            [flyTTAxes.YLim] = deal([minY maxY]);
            
            [flyAxes.XTick] = deal(tickX);
            [flyAxes.XTickLabel] = deal(tickLabelX);
            [flyAxes.XTickLabelRotation] = deal(45);
            
            [flySemAxes.XTick] = deal(tickX);
            [flySemAxes.XTickLabel] = deal(tickLabelX);
            [flySemAxes.XTickLabelRotation] = deal(45);
            
            for figInd = 1:length(flyAxes)
                flyAxes(figInd).XLabel.String = labelX;
                flyAxes(figInd).YLabel.String = labelY;
                flySemAxes(figInd).XLabel.String = labelX;
                flySemAxes(figInd).YLabel.String = labelY;
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