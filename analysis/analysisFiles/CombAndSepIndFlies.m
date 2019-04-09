 function analysis = CombAndSepIndFlies(flyResp,epochs,params,stim,varargin)
    combOpp = 1; % logical for combining symmetic epochs such as left and right
    numIgnore = []; % number of epochs to ignore
    numSep = 1; % number of different traces in the paramter file
    dataX = [];

    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    if isempty(numIgnore)
        switch combOpp
            case 0
                numIgnore = 3;
            case 1
                numIgnore = 2;
        end
    end

    %% get processed trials
    
    analysis = GetProcessedTrials(flyResp,epochs,params,varargin{:});
    
    %% average over trials
    averagedTrials = ReduceDimension(analysis{end}.snipMat,'trials');
    
    % write to output structure
    analysis{end+1}.name = 'averagedTrials';
    analysis{end}.snipMat = averagedTrials;
    
    %% combine left ward and rightward epochs
    if combOpp
        combinedOpposites = CombineOpposites(averagedTrials);
    else
        combinedOpposites = averagedTrials;
    end
    
    % write to output structure
    analysis{end+1}.name = 'combinedOpposites';
    analysis{end}.snipMat = combinedOpposites;
    
    %% average over time
    averagedTime = ReduceDimension(combinedOpposites, 'time');
    numFlies = size(averagedTime,2);
    
    % write to output structure
    analysis{end+1}.name = 'averagedTime';
    analysis{end}.snipMat = averagedTime;
    
    %% convert from snipMat to matrix

    respMat = SnipMatToMatrix(averagedTime); % turn snipMat into a matrix
    
    respMatSep = SeparateTraces(respMat(:,:,numIgnore+1:end,:,:),numSep); % separate every numSnips epochs into a new trace to plot
    respMatSepSquish = squish(respMatSep); % remove all nonsingleton dimensions
    
    % write to output structure
    analysis{end+1}.name = 'respMat';
    analysis{end}.snipMat = respMat;
    analysis{end}.respMatSepSquish = respMatSepSquish;
    
    analysis = MakeAnalysisReadable(analysis);
    
    %% plot
    if isempty(dataX)
        dataX = 1:size(respMatSepSquish,1);
    end
    
    for ss = 1:numSep
        MakeFigure;
        PlotXvsY(dataX',respMatSepSquish(:,:,1,ss));
        ConfAxis(varargin{:},'labelY',['turning response (deg/sec) - ' num2str(numFlies) ' flies']);

        MakeFigure;
        PlotXvsY(dataX',respMatSepSquish(:,:,2,ss));
        ConfAxis(varargin{:},'labelY',['walking respones (fold change) - ' num2str(numFlies) ' flies']);
    end
end