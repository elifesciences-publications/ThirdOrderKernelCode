 function analysis = PlotTimeHistogram(flyResp,epochs,params,~,dataRate,dataType,interleaveEpoch,varargin)
    combOpp = 1; % logical for combining symmetic epochs such as left and right
    numIgnore = interleaveEpoch; % number of epochs to ignore
    figLeg = {};
    snipShift = [];
    duration = [];
    imagingSelectedEpochs = {'' ''};
    fTitle = '';
    plotOnly = '';
    reassignEpochs = '';


    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    if ~iscell(imagingSelectedEpochs)
        imagingSelectedEpochs = num2cell(imagingSelectedEpochs);
    end
    
    % Convert variables related to time from units of milliseconds to
    % samples
    snipShift = round(snipShift*dataRate/1000);
    duration = round(duration*dataRate/1000);
    
    if ~isempty(reassignEpochs) % resize params struct array to get rid of
                                % merged epochs and sum the durations of
                                % the merged epochs
        [newParamList,oldParamIdx,~] = unique(reassignEpochs);
        newParams(newParamList) = params(oldParamIdx);
        for param = newParamList
            newParams(param).duration = sum(cell2mat({params(reassignEpochs == param).duration}));
        end
        params = newParams;
    end
    
    longestDuration = params(interleaveEpoch+1).duration*dataRate/60;
    for pp = interleaveEpoch+2:length(params)
        thisDuration = params(pp).duration*dataRate/60;
        if thisDuration>longestDuration
            longestDuration = thisDuration;
        end
    end
    
    if isempty(snipShift)
        snipShift = round(-1*dataRate);
    end
    
    if isempty(duration)
        duration = longestDuration + 2.5*dataRate;
    end
    
    numFlies = length(flyResp);
    averagedRois = cell(1,numFlies);
    
    %% get processed trials
    
    for ff = 1:numFlies
        
        if ~isempty(reassignEpochs)
            newEpochs = zeros(size(epochs));
            for ii = 1:length(reassignEpochs)
                newEpochs(epochs{ff} == ii) = reassignEpochs(ii);
            end
            epochs{ff} = newEpochs';
        end
        
        analysis.indFly{ff} = GetProcessedTrials(flyResp{ff},epochs{ff},params,dataRate,...
                                                 dataType,'duration',duration*1000/dataRate, ...
                                                 'snipShift',snipShift*1000/dataRate,varargin{:});
                                      
        % Remove ignored epochs
        selectedEpochs = analysis.indFly{ff}{end}.snipMat(numIgnore+1:end,:);

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'selectedEpochs';
        analysis.indFly{ff}{end}.snipMat = selectedEpochs;

        %% average over trials
        edges = cat(2,linspace(-600,600,30)',linspace(-0.25,1.25,30)');
        centers = (edges(1:end-1) + edges(2:end))/2;
        histogramTrials = HistogramTrials(selectedEpochs,edges);

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'histogramTrials';
        analysis.indFly{ff}{end}.snipMat = histogramTrials;

        %% combine left ward and rightward epochs
        if combOpp
            combinedOpposites = CombineOppositeHistograms(histogramTrials);
        else
            combinedOpposites = histogramTrials;
        end

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'combinedOpposites';
        analysis.indFly{ff}{end}.snipMat = combinedOpposites;

        %% average over Rois
        averagedRois{ff} = ReduceDimension(combinedOpposites,'Rois');

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedRois';
        analysis.indFly{ff}{end}.snipMat = averagedRois{ff};


        %% Change names of analysis structures
        analysis.indFly{ff} = MakeAnalysisReadable(analysis.indFly{ff});
    end
    
    %% convert from snipMat to matrix wtih averaged flies
    averagedFlies = ReduceDimension(averagedRois,'flies',@nanmean);
    
    respMat = SnipMatToMatrix(averagedFlies); % turn snipMat into a matrix
    respMatPlot = permute(respMat,[1 3 6 7 2 4 5]);
    
    analysis.respMatPlot = respMatPlot;
        
    
    %%
    if isfield(params(1),'epochName')
        figLeg = cell(length(params)-numIgnore,1);
        for ii = (1+numIgnore):length(params)
            if ischar(params(ii).epochName)
                figLeg{ii-numIgnore} = params(ii).epochName;
            else
                figLeg{ii-numIgnore} = '';
            end
        end
    end
            
    
    %% plot
    timeX = ((1:duration)'+snipShift)*1000/dataRate;
    middleTime = linspace(0,longestDuration*1000/dataRate,5);
    timeStep = middleTime(2)-middleTime(1);
    earlyTime = fliplr(0:-timeStep:(1+snipShift)*1000/dataRate);
    endTime = longestDuration*1000/dataRate:timeStep:(duration+snipShift)*1000/dataRate;
    plotTime = round([earlyTime(1:end-1) middleTime endTime(2:end)]*10)/10;
    
    switch dataType
        case 'behavioralData'
            yAxis = {'turning response (deg/sec)','walking response (fold change)'};
        case 'imagingData'
            yAxis = {'\DeltaF / F'};
        case 'ephysData'
            yAxis = {'Neural Response (mV)'};
    end
    
    if strcmp(dataType,'imagingData');
        finalTitle = [fTitle ': ' imagingSelectedEpochs{1} ' - ' imagingSelectedEpochs{2}];
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
        numEpochs = size(respMatPlot,2);
        for ee = 1:numEpochs
            subplotSize = ceil(sqrt(numEpochs));
            subplot(subplotSize,subplotSize,ee)
            imagesc(log(squeeze(respMatPlot(:,ee,1,1,:))'));
            hold on;
%             PlotConstLine(0);
%             PlotConstLine(0,2);
%             PlotConstLine(longestDuration,2);


            %ConfAxis('tickX',plotTime,'tickLabelX',plotTime,'tickLabelX',centers,'labelX','time (ms)','labelY',[yAxis{pp} ' - ' num2str(numFlies) ' flies'],'fTitle',finalTitle,'figLeg',figLeg);
            hold off;
        end
    end
end