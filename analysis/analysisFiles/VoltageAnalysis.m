 function analysis = VoltageAnalysis(flyResp,epochs,params,~ ,dataRate,dataType,interleaveEpoch,varargin)
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
    else
        nonResponsiveFlies = [];
    end
    
    numFlies = length(flyResp);
    averagedROIs = cell(1,numFlies);
    
    numROIs = zeros(1, numFlies);
    % run the algorithm for each fly
    for ff = 1:numFlies
        %% This is voltage, so the responses are inverted
        flyResp{ff} = -flyResp{ff};
        
        %% get processed trials
        analysis.indFly{ff} = GetProcessedTrials(flyResp{ff},epochs{ff},params,dataRate,dataType,varargin{:},'snipShift', 0, 'duration', []);

        %% remove epochs you dont want analyzed
        ignoreEpochs = analysis.indFly{ff}{end}.snipMat(numIgnore+1:end,:);

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'ignoreEpochs';
        analysis.indFly{ff}{end}.snipMat = ignoreEpochs;

        %% average over time
        averagedTime = ReduceDimension(ignoreEpochs, 'time', @nanmean);

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedTime';
        analysis.indFly{ff}{end}.snipMat = averagedTime;

        %% average over trials
        averagedTrials = ReduceDimension(averagedTime,'trials',@nanmean);

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedTrials';
        analysis.indFly{ff}{end}.snipMat = averagedTrials;
        

        %% average over ROIs
        averagedROIs{ff} = ReduceDimension(averagedTrials,'Rois',@nanmean);
        [numEpochs,numROIs(ff)] = size(averagedTrials);
        fprintf('%d ROIs for fly %d\n', numROIs(ff), ff);
        
        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedROIs';
        analysis.indFly{ff}{end}.snipMat = averagedROIs;
        
        %% make analysis readable
        analysis.indFly{ff} = MakeAnalysisReadable(analysis.indFly{ff});
        
        %% Parallel scheme
        flyRespHere = GetProcessedTrials(flyResp{ff},epochs{ff},params,dataRate,dataType,varargin{:},'snipShift', timeShift, 'duration', duration);
        ignoreEpochs = flyRespHere{end}.snipMat(numIgnore+1:end,:);
        noTimeAveragedTrials{ff} = ReduceDimension(ignoreEpochs, 'trials', @nanmean);
        noTimeAveragedRois{ff} = ReduceDimension(noTimeAveragedTrials{ff}, 'Rois', @nanmean);
    end
    
    % Eyes not being empty is an indication that we have to shuffle around
    % epochs to account for progressive/regressive stimulus differences
    % (direction-wise) in different eyes
    if ~isempty(flyEyes)
        flyEyes(nonResponsiveFlies) = [];
        epochNames = {params.epochName};
        rightEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'R'));
        leftEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'L'));
        % We're gonna do this in a left-dominated world, so left eyes
        % don't have to be touched.
        for i = 1:length(flyEyes)
            if strfind('right', lower(flyEyes{i}))
                tempAvg = averagedROIs{i};
                tempNoTimeAvg = noTimeAveragedRois{i};
                if ~isempty(tempAvg)
                    averagedROIs{i}(rightEpochs) = tempAvg(leftEpochs);
                    averagedROIs{i}(leftEpochs) = tempAvg(rightEpochs);
                    noTimeAveragedRois{i}(rightEpochs) = tempNoTimeAvg(leftEpochs);
                    noTimeAveragedRois{i}(leftEpochs) = tempNoTimeAvg(rightEpochs);
                end
            end
        end
    end
    
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

    respMatInd = SnipMatToMatrix(averagedROIs); % turn snipMat into a matrix
    respMatIndSep = SeparateTraces(respMatInd,numSep,''); % separate every numSnips epochs into a new trace to plot
    respMatIndPlot = squish(respMatIndSep); % remove all nonsingleton dimensions
    
    analysis.respMatIndPlot = respMatIndPlot;
    
    %% Average fly time traces
    noTimeAveragedFlies = ReduceDimension(noTimeAveragedRois,'flies',@nanmean);
    noTimeAveragedFliesSem = ReduceDimension(noTimeAveragedRois,'flies',@NanSem);
    
    respMatNoTime = SnipMatToMatrix(noTimeAveragedFlies); % turn snipMat into a matrix
    respMatNoTimeSep =  SeparateTraces(respMatNoTime,numSep,''); % turn snipMat into a matrix
    respMatNoTimePlot = permute(respMatNoTimeSep,[1 3 6 7 2 4 5]); % magic permutations
    
    respMatNoTimeSem = SnipMatToMatrix(noTimeAveragedFliesSem); % turn snipMat into a matrix
    respMatNoTimeSepSem =  SeparateTraces(respMatNoTimeSem,numSep,''); % turn snipMat into a matrix
    respMatNoTimeSemPlot = permute(respMatNoTimeSepSem,[1 3 6 7 2 4 5]); % magic permutations
    
    
    %% plot
    if isempty(dataX)
        dataX = 1:size(respMatIndPlot,1);
    end
    
    yAxis = {'\Delta F/F'};
    
%     finalTitle = [fTitle ': ' epochsForSelectivity{1} ' - ' epochsForSelectivity{2}];
%     MakeFigure;
    
    
    plotFigure = findobj('Type', 'Figure', 'Name', figureName);
    plotFigureTraces = findobj('Type', 'Figure', 'Name', [figureName ' SEM']);
    if isempty(plotFigure)
        plotFigure = MakeFigure;
        plotFigureTraces=MakeFigure;
        plotEdgeTraces = MakeFigure;
        newPlot = true;
    else
        newPlot = false;
    end
    
    if ~isempty(flyEyes)
        if newPlot %We're in the progressive regime now
            finalTitle = ['Progressive Positive ' num2str(numROIs(1)) sprintf(',%d', numROIs(2:end))];
            progPosPrefDir = 'L+'; % Remember that we're in a left dominated world
            progPosNullDir = 'R+';
            progPosPrefEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, progPosPrefDir));
        	progPosNullEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, progPosNullDir));
            figure(plotFigure);
            subplot(2, 2, 1);
            dataToPlot = [respMatIndPlot(progPosPrefEpochs, :) respMatIndPlot(progPosNullEpochs, :) respMatPlot(progPosPrefEpochs,:) respMatPlot(progPosNullEpochs,:)];
            colors = [repmat([1 .8 .8], numFlies, 1); repmat([.8 .8 1], numFlies, 1); 1 0 0; 0 0 1];
            if length(dataX) == 1
                dataX = dataX * ones(size(dataToPlot));
            end
            PlotXvsY(dataX', dataToPlot, 'color', colors, 'graphType', 'scatter');
            ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis],'fTitle',finalTitle, 'MarkerStyle','*');
            
           
            
            finalTitle = ['Progressive Negative ' num2str(numROIs(1)) sprintf(',%d', numROIs(2:end))];
            progNegPrefDir = 'L-'; % Remember that we're in a left dominated world
            progNegNullDir = 'R-';
            progNegPrefEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, progNegPrefDir));
        	progNegNullEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, progNegNullDir));
           
            subplot(2, 2, 3)
            dataToPlot = [respMatIndPlot(progNegPrefEpochs, :) respMatIndPlot(progNegNullEpochs, :) respMatPlot(progNegPrefEpochs,:) respMatPlot(progNegNullEpochs,:)];
            colors = [repmat([1 .8 .8], numFlies, 1); repmat([.8 .8 1], numFlies, 1); 1 0 0; 0 0 1];
            PlotXvsY(dataX', dataToPlot, 'color', colors, 'graphType', 'scatter');
            ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis],'fTitle',finalTitle);
            
            subplot(1, 2, 2);
            epochsPlot = 1:4;
            PlotXvsY(linspace(timeShift, timeShift+duration,size(respMatNoTimePlot, 1))'/1000, respMatNoTimePlot(:, epochsPlot), 'error', respMatNoTimeSemPlot(:,epochsPlot));
            l = axis;hold on;
            plot([0 0], l(3:4), 'k--');
            plot([1 1], l(3:4), 'k--');
            ConfAxis(varargin{:},'labelX','Time (s)','labelY',[yAxis],'fTitle','Averaged Traces');
            legend(epochNames{epochsPlot});
            
            
            figure(plotFigureTraces)
            subplot(1, 2, 1);
            epochsPlot = 6:10;
            PlotXvsY(linspace(timeShift, timeShift+duration,size(respMatNoTimePlot, 1))'/1000, respMatNoTimePlot(:, epochsPlot), 'error', respMatNoTimeSemPlot(:,epochsPlot));
            l = axis;hold on;
            plot([0 0], l(3:4), 'k--');
            plot([1 1], l(3:4), 'k--');
            ConfAxis(varargin{:},'labelX','Time (s)','labelY',[yAxis],'fTitle','Averaged Traces');
            legend(epochNames{epochsPlot});
            
            ax = [];
            minY = [];
            maxY = [];
            for i = 1:numFlies
                for j = 0:length(epochsPlot)-1
                    subplot(length(epochsPlot), numFlies, j*numFlies+i);
                    plotData = cat(2, noTimeAveragedTrials{i}{epochsPlot(j+1), :});
                    PlotXvsY(linspace(timeShift, timeShift+duration,size(respMatNoTimePlot, 1))'/1000, plotData)
                    ax(j+1, i) = gca;
                    l = axis;hold on;
                    minY(j+1, i) = min(plotData(:));
                    maxY(j+1, i) = max(plotData(:));
                    plot([0 0], l(3:4), 'k--');
                    plot([1 1], l(3:4), 'k--');
                    ConfAxis(varargin{:},'labelX','Time (s)','labelY',[yAxis],'fTitle',epochNames(epochsPlot(j+1)));
                end
                set(ax(:, i), 'YLim', [min(minY(:, i)) max(maxY(:, i))]);
            end
            
            figure(plotEdgeTraces)
            subplot(1, 2, 1);
            epochsPlot = 1:4;
            
            ax = [];
            minY = [];
            maxY = [];
            for i = 1:numFlies
                for j = 0:length(epochsPlot)-1
                    subplot(length(epochsPlot), numFlies, j*numFlies+i);
                    plotData = cat(2, noTimeAveragedTrials{i}{epochsPlot(j+1), :});
                    PlotXvsY(linspace(timeShift, timeShift+duration,size(respMatNoTimePlot, 1))'/1000, plotData)
                    ax(j+1, i) = gca;
                    l = axis;hold on;
                    minY(j+1, i) = min(plotData(:));
                    maxY(j+1, i) = max(plotData(:));
                    plot([0 0], l(3:4), 'k--');
                    plot([1 1], l(3:4), 'k--');
                    ConfAxis(varargin{:},'labelX','Time (s)','labelY',[yAxis],'fTitle',epochNames(epochsPlot(j+1)));
                end
                set(ax(:, i), 'YLim', [min(minY(:, i)) max(maxY(:, i))]);
            end
            
        end
    else
        
%         for pp = 1:size(respMatPlot,3)
%             PlotXvsY(dataX',respMatPlot(:,:,pp),'error',respMatSemPlot(:,:,pp));
%             ConfAxis(varargin{:},'labelX',labelX,'labelY',[yAxis{pp} ' - ' num2str(numFlies) ' flies'],'fTitle',finalTitle);
%         end
    end
end