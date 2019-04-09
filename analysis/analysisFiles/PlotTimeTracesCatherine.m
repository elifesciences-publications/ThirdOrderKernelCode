 function analysis = PlotTimeTraces(flyResp,epochs,params,stim,dataRate,dataType,interleaveEpoch,varargin)
    combOpp = 1; % logical for combining symmetic epochs such as left and right
    numIgnoreInt = interleaveEpoch; % number of epochs to ignore
    figLeg = {};
    ttSnipShift = [];
    ttDuration = [];
    imagingSelectedEpochs = {'' ''};
    fTitle = '';
    plotOnly = '';
    reassignEpochs = '';
    ttSnipShift = -1000;
    epochsForSelection = {'' ''};
    plotTime = [];
    plotTimeLabel = [];
    linescan = 0;
    numEpochsToPlot = [];

    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    if ~iscell(imagingSelectedEpochs)
        imagingSelectedEpochs = num2cell(imagingSelectedEpochs);
    end
    
    % Convert variables related to time from units of milliseconds to
    % samples
    if ~isempty(reassignEpochs) % resize params struct array to get rid of
                                % merged epochs and sum the durations of
                                % the merged epochs
        [newParamList,oldParamIdx,~] = unique(reassignEpochs);
        newParams(newParamList) = params{1}(oldParamIdx);
        for param = newParamList
            newParams(param).duration = sum(cell2mat({params{1}(reassignEpochs == param).duration}));
        end
        params = newParams;
    end
    
    %% Grab numIgnore if it doesn't exist based on interleaveEpoch
    % interleaveEpoch (which is in numIgnoreInt) will be a cell for imaging
    % data. numIgnoreSet is a flag for later determining whether we've got
    % to change numIgnore based on the fly (basically serves as
    % exist('numIgnore', 'var') for later once we've already set numIgnore
    if ~exist('numIgnore', 'var') || isempty(numIgnore)
        if iscell(numIgnoreInt)
            numIgnore = numIgnoreInt{1};
        else
            numIgnore = numIgnoreInt;
        end
        numIgnoreSet = false;
    else
        numIgnoreSet = true;
    end
    
    %% duration and snip shift should be entered in miliseconds
    % params duration is in projector frames; divide by 60 to get it into
    % seconds (because the projector presents at 60 frames/s; multiply by
    % 1000 to get it into ms
    longestDuration = params{1}(numIgnore+1).duration/60*1000;
    for pp = numIgnore+2:length(params{1})
        thisDuration = params{1}(pp).duration/60*1000;
        if thisDuration>longestDuration
            longestDuration = thisDuration;
        end
    end
    
    % snip shift reads in ttSnipShift so that PlotTimeTraces and CombAndSep
    % do not interact
    snipShift = ttSnipShift;
    
    if isempty(ttDuration)
        duration = longestDuration + 2500;
    else
        duration = ttDuration;
    end
    
    numFlies = length(flyResp);
    averagedRois = cell(1,numFlies);
    
    %% get processed trials
    
    for ff = 1:numFlies
        % If numIgnore wasn't set, we're going to adjust based on the
        % interleaveEpoch of each stimulusPres--this might change if, for
        % example, there were a different probe for each stim file (this
        % has happened before <.< --Emilio)
        if ~numIgnoreSet
            if iscell(numIgnoreInt)
                numIgnore = numIgnoreInt{ff};
            else
                numIgnore = numIgnoreInt;
            end
        end
        
        if ~isempty(reassignEpochs)
            for ii = 1:length(reassignEpochs)
                newEpochs(epochs{ff} == ii) = reassignEpochs(ii);
            end
            epochs{ff} = newEpochs';
        end
        
        analysis.indFly{ff} = GetProcessedTrials(flyResp{ff},epochs{ff},params{ff},dataRate,...
                                                 dataType,varargin{:},'duration',duration, ...
                                                 'snipShift',snipShift);
                                      
        % Remove ignored epochs
        selectedEpochs = analysis.indFly{ff}{end}.snipMat(numIgnore+1:end,:);

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'selectedEpochs';
        analysis.indFly{ff}{end}.snipMat = selectedEpochs;

        %% average over trials
        averagedTrials = ReduceDimension(selectedEpochs,'trials');

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
    averagedFliesSem = ReduceDimension(averagedRois,'flies',@NanSem);
    
    respMat = SnipMatToMatrix(averagedFlies); % turn snipMat into a matrix
    respMatPlot = permute(respMat,[1 3 6 7 2 4 5]);

    respMatSem = SnipMatToMatrix(averagedFliesSem); % turn snipMat into a matrix
    respMatSemPlot = permute(respMatSem,[1 3 6 7 2 4 5]);
    
    analysis.respMatPlot = respMatPlot;
    analysis.respMatSemPlot = respMatSemPlot;
        
    
    %%
    if isempty(figLeg) && isfield(params{1}(1),'epochName')
        for ii = (1+numIgnore):length(params{1})
            if ischar(params{1}(ii).epochName)
                figLeg{ii-numIgnore} = params{1}(ii).epochName;
            else
                figLeg{ii-numIgnore} = '';
            end
        end
    end
            
    
    %% plot
    if linescan == 1
        dataRate = dataRate*1024;
    end  
    timeX = ((1:round(duration*dataRate/1000))'+round(snipShift*dataRate/1000))*1000/dataRate;
    middleTime = linspace(0,longestDuration,5);
    timeStep = middleTime(2)-middleTime(1);
    earlyTime = fliplr(0:-timeStep:snipShift);
    endTime = longestDuration:timeStep:duration+snipShift;
    % plotTime = round([earlyTime(1:end-1) middleTime endTime(2:end)]*10)/10;
    if isempty(plotTime)
        plotTime = round([0 ttDuration]*10)/10;
    end
    if isempty(plotTimeLabel)
        plotTimeLabel = plotTime;
    end
    switch dataType
        case 'behavioralData'
            yAxis = {'turning response (deg/sec)','walking response (fold change)'};
        case 'imagingData'
            yAxis = {'\DeltaF / F'};
        case 'ephysData'
            yAxis = {'Neural Response (mV)'};
    end
    
    if strcmp(dataType,'imagingData')
        if ~exist('progRegSplit', 'var') || ~progRegSplit
            if strcmp(epochsForSelection{1}{1}, 'Left Light Edge') && strcmp(epochsForSelection{1}{2}, 'Left Dark Edge')
                finalTitle = [fTitle ': ' ' T4 Regressive'];
            elseif strcmp(epochsForSelection{1}{1}, 'Left Dark Edge') && strcmp(epochsForSelection{1}{2}, 'Left Light Edge')
                finalTitle = [fTitle ': ' ' T5 Regressive'];
            elseif strcmp(epochsForSelection{1}{1}, 'Right Dark Edge') && strcmp(epochsForSelection{1}{2}, 'Right Light Edge')
                finalTitle = [fTitle ': ' ' T5 Progressive'];
            elseif strcmp(epochsForSelection{1}{1}, 'Right Light Edge') && strcmp(epochsForSelection{1}{2}, 'Right Dark Edge')
                finalTitle = [fTitle ': ' ' T4 Progressive'];
            else
                finalTitle = fTitle;
            end
        else
            if strcmp(epochsForSelection{1}{1}, 'Left Light Edge') && strcmp(epochsForSelection{1}{2}, 'Left Dark Edge')
                finalTitle = [fTitle ': ' ' T4 Progressive'];
            elseif strcmp(epochsForSelection{1}{1}, 'Left Dark Edge') && strcmp(epochsForSelection{1}{2}, 'Left Light Edge')
                finalTitle = [fTitle ': ' ' T5 Progressive'];
            elseif strcmp(epochsForSelection{1}{1}, 'Right Dark Edge') && strcmp(epochsForSelection{1}{2}, 'Right Light Edge')
                finalTitle = [fTitle ': ' ' T5 Regressive'];
            elseif strcmp(epochsForSelection{1}{1}, 'Right Light Edge') && strcmp(epochsForSelection{1}{2}, 'Right Dark Edge')
                finalTitle = [fTitle ': ' ' T4 Regressive'];
            else
                finalTitle = fTitle;
            end
        end
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
        if ~isempty(numEpochsToPlot)
            PlotXvsY(timeX,respMatPlot(:,1+numIgnore:(numIgnore+numEpochsToPlot),pp),'error',respMatSemPlot(:,1+numIgnore:(numIgnore+numEpochsToPlot),pp));
        else
            PlotXvsY(timeX,respMatPlot(:,:,pp),'error',respMatSemPlot(:,:,pp));
        end
        hold on;
        PlotConstLine(0);
        PlotConstLine(0,2);
        PlotConstLine(longestDuration,2);
        %PlotConstLine(5000,2);
        
        if ~isempty(numEpochsToPlot)
            ConfAxis('tickX',plotTime,'tickLabelX',plotTimeLabel,'labelX','time (ms)','labelY',[yAxis{pp} ' - ' num2str(numFlies) ' flies'],'fTitle', finalTitle,'figLeg',{figLeg{1+numIgnore:(numIgnore+numEpochsToPlot)}});
        else
            ConfAxis('tickX',plotTime,'tickLabelX',plotTimeLabel,'labelX','time (ms)','labelY',[yAxis{pp} ' - ' num2str(numFlies) ' flies'],'fTitle', finalTitle,'figLeg', figLeg);
        end

        hold off;
    end
 end