 function analysis = CombAndSepSubtractFirst(flyResp,epochs,params,stim,dataRate,dataType,interleaveEpoch,varargin)
    combOpp = 1; % logical for combining symmetic epochs such as left and right
    numSep = 1; % number of different traces in the paramter file
    dataX = [];
    labelX = '';
    fTitle = '';
    epochsForSelection = {'' ''};
    plotInd = 0;
    tickLabelX = [];
    sepType = 'interleaved';
    plotOnly = '';
    plotSubtracted = 0;

    switch dataType
        case 'imagingData'
            numIgnore = interleaveEpoch;
        case 'behavioralData'
            numIgnore = interleaveEpoch+2;
        case 'ephysData'
            numIgnore = interleaveEpoch;
        otherwise
            numIgnore = interleaveEpoch;
    end
    
    %% ignore flies that don't have any ROIs
     if any(cellfun('isempty', flyResp))
        nonResponsiveFlies = cellfun('isempty', flyResp);
        fprintf('The following flies did not respond: %s\n', num2str(find(nonResponsiveFlies)));
        flyResp(nonResponsiveFlies) = [];
        epochs(nonResponsiveFlies) = [];
%         if ~isempty(flyEyes)
%             flyEyes(nonResponsiveFlies)=[];
%         end
    else
        nonResponsiveFlies = [];
    end
    
    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    if ~iscell(epochsForSelection)
        epochsForSelection = num2cell(epochsForSelection);
    end
    
    for ss = 1:length(epochsForSelection)
        for dd = 1:length(epochsForSelection{ss})
            if ~ischar(epochsForSelection{ss}{dd})
                epochsForSelection{ss}{dd} = num2str(epochsForSelection{ss}{dd});
            end
        end
    end
    
    numFlies = length(flyResp);
    averagedRois = cell(1,numFlies);
    
    % run the algorithm for each fly
     for ff = 1:numFlies
        %% get processed trials
        analysis.indFly{ff} = GetProcessedTrials(flyResp{ff},epochs{ff},params{ff},dataRate,dataType,varargin{:});
        
        %% remove epochs you dont want analyzed
        ignoreEpochs = analysis.indFly{ff}{end}.snipMat(numIgnore+1:end,:);

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'ignoreEpochs';
        analysis.indFly{ff}{end}.snipMat = ignoreEpochs;

        %% average over trials
        averagedTrials = ReduceDimension(ignoreEpochs,'trials');

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedTrials';
        analysis.indFly{ff}{end}.snipMat = averagedTrials;

        %% combine left ward and rightward epochs
        if combOpp
            combinedOpposites = CombineOpposites(averagedTrials);
        else
            combinedOpposites = averagedTrials;
        end

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'combinedOpposites';
        analysis.indFly{ff}{end}.snipMat = combinedOpposites;

        %% average over time
        averagedTime = ReduceDimension(combinedOpposites, 'time');

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedTime';
        analysis.indFly{ff}{end}.snipMat = averagedTime;

        %% subtract first epoch val from other epochs
        firstSubtracted = cell(size(averagedTime));
        
        for ee = 1:size(averagedTime,1)
            for rr = 1:size(averagedTime,2)
                firstSubtracted{ee,rr} = averagedTime{ee,rr} - averagedTime{1,rr};
            end
        end
        
        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'firstSubtracted';
        analysis.indFly{ff}{end}.snipMat = firstSubtracted;
        
        %% average over Rois
        averagedRois{ff} = ReduceDimension(firstSubtracted,'Rois',@nanmean);
        
        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedRois';
        analysis.indFly{ff}{end}.snipMat = averagedRois;
        
        %% make analysis readable
        analysis.indFly{ff} = MakeAnalysisReadable(analysis.indFly{ff});
    end
    
    %% convert from snipMat to matrix wtih averaged flies
    averagedFlies = ReduceDimension(averagedRois,'flies',@nanmean);
    averagedFliesSem = ReduceDimension(averagedRois,'flies',@NanSem);
    
    respMat = SnipMatToMatrix(averagedFlies); % turn snipMat into a matrix
    if plotSubtracted == 0
        respMat = respMat(:,:,2:end,:,:,:);
    end
    
    respMatSep = SeparateTraces(respMat,numSep,sepType); % separate every numSnips epochs into a new trace to plot
    respMatPlot = permute(respMatSep,[3 7 6 1 2 4 5]);

    respMatSem = SnipMatToMatrix(averagedFliesSem); % turn snipMat into a matrix
    if plotSubtracted == 0
        respMatSem = respMatSem(:,:,2:end,:,:,:);
    end
    respMatSemSep = SeparateTraces(respMatSem,numSep,sepType); % separate every numSnips epochs into a new trace to plot
    respMatSemPlot = permute(respMatSemSep,[3 7 6 1 2 4 5]);
    
    analysis.respMatPlot = respMatPlot;
    analysis.respMatSemPlot = respMatSemPlot;
    
    %% convert from snipMat to matrix wtih individual flies

    respMatInd = SnipMatToMatrix(averagedRois); % turn snipMat into a matrix
    if plotSubtracted == 0
        respMatInd = respMatInd(:,:,2:end,:,:,:);
    end
    
    respMatIndSep = SeparateTraces(respMatInd,numSep,sepType); % separate every numSnips epochs into a new trace to plot
    respMatIndPlot = permute(respMatIndSep,[3 5 6 1 2 4 7]); % remove all nonsingleton dimensions
    
    analysis.respMatIndPlot = respMatIndPlot;
    
    %% plot
    if isempty(dataX)
        dataX = (1:size(respMatPlot,1));
    end
    
%     if isempty(tickLabelX) && isfield(params(1),'epochName')
%         for ii = (1+numIgnore):length(params)
%             tickLabelX{ii-numIgnore} = params(ii).epochName{1};
%         end
%     end
    
    switch dataType
        case 'behavioralData'
            yAxis = {'turning response (deg/sec)','walking response (fold change)'};
        case 'imagingData'
            yAxis = {'Fluorescence (\DeltaF / F)'};
        case 'ephysData'
            yAxis = {'Neural Response (mV)'};
    end
    
    if strcmp(dataType,'imagingData')
        finalTitle = [fTitle ': ' epochsForSelection{1}{1} ' - ' epochsForSelection{1}{2}];
    else
        finalTitle = fTitle;
    end
        
    for pp = 1:size(respMatPlot,3)
        if strcmp(plotOnly,'walking') && pp == 1
            continue;
        end
        if strcmp(plotOnly,'turning') && pp == 2
            continue;
        end
        
        MakeFigure;
        PlotXvsY(dataX',respMatPlot(:,:,pp),'error',respMatSemPlot(:,:,pp));
        
        hold on;
        PlotConstLine(0);
        
        if pp == 2
            PlotConstLine(1);
        end
        hold off;
        
        ConfAxis(varargin{:},'tickLabelX',tickLabelX,'labelX',labelX,'labelY',[yAxis{pp} ' - ' num2str(numFlies) ' flies'],'fTitle',finalTitle);
        
        if plotInd
            for ss = 1:numSep
            MakeFigure;
            PlotXvsY(dataX',respMatIndPlot(:,:,pp, ss));

            hold on;
            PlotConstLine(0);

            if pp == 2
                PlotConstLine(1);
            end
            hold off;

            ConfAxis(varargin{:},'tickLabelX',tickLabelX,'labelX',labelX,'labelY',[yAxis{pp} ' - ' num2str(numFlies) ' flies'],'fTitle',finalTitle);
            end
        end
    end
end