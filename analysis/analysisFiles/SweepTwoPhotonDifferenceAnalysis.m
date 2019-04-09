 function analysis = SweepTwoPhotonDifferenceAnalysis(flyResp,epochs,params,~,dataRate,dataType,interleaveEpoch,varargin)

    combOpp = 1; % logical for combining symmetic epochs such as left and right
    numIgnore = 0; % number of epochs to ignore
    numSep = 1; % number of different traces in the paramter file
    dataX = [];
    labelX = '';
    fTitle = '';
    flyEyes = [];
    epochsForSelectivity = {'' ''};
    labelY = '\Delta F/F';
    % Can't instantiate this as empty because plenty of figures will have
    % empty names as the default
    figureName = 'omgIHopeNoFigureIsEverNamedThis';

    fprintf('Two plots this time\n');
    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    % Gotta unwrap the eyes because of how they're put in here
    flyEyes = cellfun(@(flEye) flEye{1}, flyEyes, 'UniformOutput', false);
    
    if any(cellfun('isempty', flyResp))
        nonResponsiveFlies = cellfun('isempty', flyResp);
        fprintf('The following flies did not respond: %s\n', num2str(find(nonResponsiveFlies)));
        flyResp(nonResponsiveFlies) = [];
        epochs(nonResponsiveFlies) = [];
        if ~isempty(flyEyes)
            flyEyes(nonResponsiveFlies)=[];
        end
    else
        nonResponsiveFlies = false(size(flyResp));
    end

    
    numFlies = length(flyResp);
    averagedROIs = cell(1,numFlies);
    
    numROIs = zeros(1, numFlies);
    % run the algorithm for each fly
    for ff = 1:numFlies
        %% get processed trials
        percNan = 100*sum(isnan(flyResp{ff}(:, 1)))/size(flyResp{ff}, 1);
        fprintf('%%NaN = %f\n', percNan);
        if percNan>10
            % Effectively killing everything here
            flyResp{ff} = nan(size(flyResp{ff}));
        end
        analysis.indFly{ff} = GetProcessedTrials(flyResp{ff},epochs{ff},params{ff},dataRate,dataType,varargin{:});

        %% remove epochs you dont want analyzed
        ignoreEpochs = analysis.indFly{ff}{end}.snipMat(numIgnore+1:end,:);

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'ignoreEpochs';
        analysis.indFly{ff}{end}.snipMat = ignoreEpochs;
        
%         %% Normalize responses to the direction selectivity epoch... trying for now
%         normalizedEpochs = NormalizeTwoPhotonFlies(ignoreEpochs, epochsForSelection{ff}(1), params);
%         
%         
%         % write to output structure
%         analysis.indFly{ff}{end+1}.name = 'normlizedEpochs';
%         analysis.indFly{ff}{end}.snipMat = normalizedEpochs;
        
        %% Get rid of epochs with too many NaNs
        droppedNaNTraces = RemoveMovingEpochs(ignoreEpochs);
        
        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'droppedNaNTraces';
        analysis.indFly{ff}{end}.snipMat = droppedNaNTraces;

        %% average over time
        averagedTime = ReduceDimension(droppedNaNTraces, 'time', @nanmean);
        
        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedTime';
        analysis.indFly{ff}{end}.snipMat = averagedTime;

        %% average over trials
        averagedTrials = ReduceDimension(averagedTime,'trials',@nanmean);

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedTrials';
        analysis.indFly{ff}{end}.snipMat = averagedTrials;
        
        %% Subtract trials
        
        % Eyes not being empty is an indication that we have to shuffle around
        % epochs to account for progressive/regressive stimulus differences
        % (direction-wise) in different eyes
        if ~isempty(flyEyes)
            epochNames = {params{ff}.epochName};
            rightEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'R'));
            leftEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'L'));
            % We're gonna do this in a left-dominated world, so left eyes
            % don't have to be touched.
            if strfind('right', lower(flyEyes{ff}))
                tempAvg = averagedTrials;
                if ~isempty(tempAvg)
                    averagedTrials(rightEpochs, :) = tempAvg(leftEpochs, :);
                    averagedTrials(leftEpochs, :) = tempAvg(rightEpochs, :);
                end
            end
        end
        
        uncorrEpoch = strcmp(epochNames, 'Uncorrelated Bars');


%         subtractedTrials = SubtractTrials(averagedTrials, trialsBase, trialsToSubtract);
        subtractedTrials = cell(size(averagedTrials));
        subtractedTrials(repmat(leftEpochs, [1, size(averagedTrials, 2)])) = (num2cell([averagedTrials{leftEpochs, :}]-[averagedTrials{rightEpochs, :}]));
        subtractedTrials(repmat(rightEpochs, [1, size(averagedTrials, 2)])) = (num2cell([averagedTrials{rightEpochs, :}]-[averagedTrials{leftEpochs, :}]));
        subtractedTrials(uncorrEpoch, :) = averagedTrials(uncorrEpoch, :);
        subtractedTrials(cellfun('isempty', subtractedTrials)) = {0};
        subTrialsROI{ff} = subtractedTrials;
        
        
        %% average over ROIs
        averagedROIs{ff} = ReduceDimension(subtractedTrials,'Rois',@nanmean);
        [numEpochs,numROIs(ff)] = size(subtractedTrials);
        fprintf('%d ROIs for fly %d\n', numROIs(ff), ff);
        
        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedROIs';
        analysis.indFly{ff}{end}.snipMat = averagedROIs;
        
        %% make analysis readable
        analysis.indFly{ff} = MakeAnalysisReadable(analysis.indFly{ff});
    end
    
    if isempty(averagedROIs)
        analysis = 'No ROIs remained after it all :/';
        return
    end
    
    %% convert from snipMat to matrix wtih averaged flies
    averagedFlies = {ReduceDimension(cat(2, subTrialsROI{:}),'Rois',@nanmean)};%ReduceDimension(averagedROIs,'flies',@nanmean);
    averagedFliesSem = {ReduceDimension(cat(2, subTrialsROI{:}),'Rois',@NanSem)};%ReduceDimension(averagedROIs,'flies',@NanSem);
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
    if isempty(plotFigure)
        plotFigure = MakeFigure;
        plotFigureSem=MakeFigure;
        newPlot = true;
    else
        newPlot = false;
    end
    
    if ~isempty(flyEyes)
        if newPlot %We're in the progressive regime now
            finalTitle = ['Progressive Positive ' num2str(numROIs(1)) sprintf(',%d', numROIs(2:end))];
            progPosPrefDir = 'L+'; % Remember that we're in a left dominated world
            progPosNullDir = 'R+';
            uncorrBarsEpoch = strcmp(epochNames, 'Uncorrelated Bars');
            progPosPrefEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, progPosPrefDir));
            progPosPrefEpochs = [find(progPosPrefEpochs) find(uncorrBarsEpoch)];
        	progPosNullEpochs = [];
            figure(plotFigure);
            subplot(2, 2, 1);
            dataToPlot = [respMatIndPlot(progPosPrefEpochs, :) respMatIndPlot(progPosNullEpochs, :) respMatPlot(progPosPrefEpochs,:) respMatPlot(progPosNullEpochs,:)];
            colors = [repmat([1 .8 .8], numFlies, 1); repmat([.8 .8 1], numFlies, 1); 1 0 0; 0 0 1];
            PlotXvsY(dataX', dataToPlot, 'color', colors);
            bounds = axis;
            hold on; plot(bounds(1:2), [0 0], 'k--');
            ConfAxis('fTitle', finalTitle);%ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis],'fTitle',finalTitle);
            legend('Preferred - Null per fly')
            
            figure(plotFigureSem);
            subplot(2, 2, 1);
            PlotXvsY(dataX',[respMatPlot(progPosPrefEpochs,:) respMatPlot(progPosNullEpochs,:)],'error',[respMatSemPlot(progPosPrefEpochs,:) respMatSemPlot(progPosNullEpochs,:)], 'color', [1 0 0; 0 0 1]);
            bounds = axis;
            hold on; plot(bounds(1:2), [0 0], 'k--');
%             PlotXvsY(dataX',respMatIndPlot(progPosPrefEpochs, :), 'color', [1 .8 .8]);
%             PlotXvsY(dataX',respMatIndPlot(progPosNullEpochs, :), 'color', [.8 .8 1]);
%             PlotXvsY(dataX',[respMatPlot(progPosPrefEpochs,:) respMatPlot(progPosNullEpochs,:)], 'color', [0 0 1; 1 0 0]);
            ConfAxis('fTitle', finalTitle);%ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis],'fTitle',finalTitle);
            legend('Preferred - Null')
            
            finalTitle = ['Progressive Negative ' num2str(numROIs(1)) sprintf(',%d', numROIs(2:end))];
            progNegPrefDir = 'L-'; % Remember that we're in a left dominated world
            progNegNullDir = 'R-';
            progNegPrefEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, progNegPrefDir));
            progNegPrefEpochs = [find(progNegPrefEpochs) find(uncorrBarsEpoch)];
        	progNegNullEpochs = [];
            figure(plotFigure);
            subplot(2, 2, 3)
            dataToPlot = [respMatIndPlot(progNegPrefEpochs, :) respMatIndPlot(progNegNullEpochs, :) respMatPlot(progNegPrefEpochs,:) respMatPlot(progNegNullEpochs,:)];
            colors = [repmat([1 .8 .8], numFlies, 1); repmat([.8 .8 1], numFlies, 1); 1 0 0; 0 0 1];
            PlotXvsY(dataX', dataToPlot, 'color', colors);
            bounds = axis;
            hold on; plot(bounds(1:2), [0 0], 'k--');
            ConfAxis('fTitle', finalTitle);%ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis],'fTitle',finalTitle);
            legend('Preferred - Null per fly')
            
            figure(plotFigureSem);
            subplot(2, 2, 3)
            PlotXvsY(dataX',[respMatPlot(progNegPrefEpochs,:) respMatPlot(progNegNullEpochs,:)],'error',[respMatSemPlot(progNegPrefEpochs,:) respMatSemPlot(progNegNullEpochs,:)], 'color', [1 0 0; 0 0 1]);
            bounds = axis;
            hold on; plot(bounds(1:2), [0 0], 'k--');
%             PlotXvsY(dataX',respMatIndPlot(progNegPrefEpochs, :), 'color', [1 .8 .8]);
%             PlotXvsY(dataX',respMatIndPlot(progNegNullEpochs, :), 'color', [.8 .8 1]);
%             PlotXvsY(dataX',[respMatPlot(progNegPrefEpochs,:) respMatPlot(progNegNullEpochs,:)], 'color', [1 0 0; 0 0 1]);
            ConfAxis('fTitle', finalTitle);%ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis],'fTitle',finalTitle);
            legend('Preferred - Null')
            plotFigure.Name = figureName;
            plotFigureSem.Name = [figureName ' SEM'];
        else % Regressive regime
            finalTitle = ['Regressive Positive ' num2str(numROIs(1)) sprintf(',%d', numROIs(2:end))];
            regPosPrefDir = 'R+'; % Remember that we're in a left dominated world
            regPosNullDir = 'L+';
            uncorrBarsEpoch = strcmp(epochNames, 'Uncorrelated Bars');
            subplot(2, 2, 2);
            regPosPrefEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, regPosPrefDir));
            regPosPrefEpochs = [find(regPosPrefEpochs) find(uncorrBarsEpoch)];
        	regPosNullEpochs = [];
            figure(plotFigureSem);
            subplot(2, 2, 2);
            PlotXvsY(dataX',[respMatPlot(regPosPrefEpochs,:) respMatPlot(regPosNullEpochs,:)],'error',[respMatSemPlot(regPosPrefEpochs,:) respMatSemPlot(regPosNullEpochs,:)], 'color', [1 0 0; 0 0 1]);
            bounds = axis;
            hold on; plot(bounds(1:2), [0 0], 'k--');
            ConfAxis('fTitle', finalTitle);%ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis],'fTitle',finalTitle);
            legend('Preferred - Null')
            
            figure(plotFigure);
            subplot(2, 2, 2);
            dataToPlot = [respMatIndPlot(regPosPrefEpochs, :) respMatIndPlot(regPosNullEpochs, :) respMatPlot(regPosPrefEpochs,:) respMatPlot(regPosNullEpochs,:)];
            colors = [repmat([1 .8 .8], numFlies, 1); repmat([.8 .8 1], numFlies, 1); 1 0 0; 0 0 1];
            bounds = axis;
            hold on; plot(bounds(1:2), [0 0], 'k--');
            PlotXvsY(dataX', dataToPlot, 'color', colors);
%             PlotXvsY(dataX',respMatIndPlot(regPosPrefEpochs, :), 'color', [1 .8 .8]);
%             PlotXvsY(dataX',respMatIndPlot(regPosNullEpochs, :), 'color', [.8 .8 1]);
%             PlotXvsY(dataX',[respMatPlot(regPosPrefEpochs,:) respMatPlot(regPosNullEpochs,:)], 'color', [1 0 0; 0 0 1]);
            
            ConfAxis('fTitle', finalTitle);%ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis],'fTitle',finalTitle);
            legend('Preferred - Null per fly')
            
            finalTitle = ['Regressive Negative ' num2str(numROIs(1)) sprintf(',%d', numROIs(2:end))];
            regNegPrefDir = 'R-'; % Remember that we're in a left dominated world
            regNegNullDir = 'L-';
            subplot(2, 2, 4)
            regNegPrefEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, regNegPrefDir));
            regNegPrefEpochs = [find(regNegPrefEpochs) find(uncorrBarsEpoch)];
        	regNegNullEpochs = [];
            figure(plotFigureSem);
            subplot(2, 2, 4);
            PlotXvsY(dataX',[respMatPlot(regNegPrefEpochs,:) respMatPlot(regNegNullEpochs,:)],'error',[respMatSemPlot(regNegPrefEpochs,:) respMatSemPlot(regNegNullEpochs,:)], 'color', [1 0 0; 0 0 1]);
            bounds = axis;
            hold on; plot(bounds(1:2), [0 0], 'k--');
            ConfAxis('fTitle', finalTitle);%(varargin{:},'labelX',labelX,'labelY',[yAxis],'fTitle',finalTitle);
            legend('Preferred - Null')
            
            figure(plotFigure);
            subplot(2, 2, 4);
            dataToPlot = [respMatIndPlot(regNegPrefEpochs, :) respMatIndPlot(regNegNullEpochs, :) respMatPlot(regNegPrefEpochs,:) respMatPlot(regNegNullEpochs,:)];
            colors = [repmat([1 .8 .8], numFlies, 1); repmat([.8 .8 1], numFlies, 1); 1 0 0; 0 0 1];
            PlotXvsY(dataX', dataToPlot, 'color', colors);
            bounds = axis;
            hold on; plot(bounds(1:2), [0 0], 'k--');
%             PlotXvsY(dataX',respMatIndPlot(regNegPrefEpochs, :), 'color', [1 .8 .8]);
%             PlotXvsY(dataX',respMatIndPlot(regNegNullEpochs, :), 'color', [.8 .8 1]);
%             PlotXvsY(dataX',[respMatPlot(regNegPrefEpochs,:) respMatPlot(regNegNullEpochs,:)], 'color', [1 0 0; 0 0 1]);
            
            ConfAxis('fTitle', finalTitle);%ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis],'fTitle',finalTitle);
            legend('Preferred - Null per fly')
            
            flyAxes = plotFigure.Children.findobj('Type','Axes');
            flySemAxes = plotFigureSem.Children.findobj('Type','Axes');
            minY = min([flyAxes.YLim]);
            maxY = max([flyAxes.YLim]);
            [flyAxes.YLim] = deal([minY maxY]);
            
            minY = min([flySemAxes.YLim]);
            maxY = max([flySemAxes.YLim]);
            [flySemAxes.YLim] = deal([minY maxY]);
            
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
            end
%             [plotFigure.Children.XLabel] = deal(matlab.graphics.primitive.Text('String', labelX));
%             [plotFigure.Children.YLabel] = deal(matlab.graphics.primitive.Text('String', labelY));
            
%             [plotFigureSem.Children.XLabel] = deal(matlab.graphics.primitive.Text('String', labelX));
%             [plotFigureSem.Children.YLabel] = deal(matlab.graphics.primitive.Text('String', labelY));
        end
    else
        
%         for pp = 1:size(respMatPlot,3)
%             PlotXvsY(dataX',respMatPlot(:,:,pp),'error',respMatSemPlot(:,:,pp));
%             ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis{pp} ' - ' num2str(numFlies) ' flies'],'fTitle',finalTitle);
%         end
    end
end