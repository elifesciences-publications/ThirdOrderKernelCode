 function analysis = CombAndSepFilterTrials(flyResp,epochs,params,stim,varargin)
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
    
    analysis = GetProcessedFilteredTrials(flyResp,epochs,params,varargin{:});
    
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
    
    % write to output structure
    analysis{end+1}.name = 'averagedTime';
    analysis{end}.snipMat = averagedTime;
    
    %% average over flies
    averagedFlies = ReduceDimension(averagedTime,'flies');
    
    % get SEM for plotting
    averagedFliesSem = CalcRespSEM(averagedTime,'flies');
    
    % write to output structure
    analysis{end+1}.name = 'averagedFlies';
    analysis{end}.snipMat = averagedFlies;
    
    %% convert from snipMat to matrix

    respMat = SnipMatToMatrix(averagedFlies); % turn snipMat into a matrix
    respMatSquish = squish(respMat); % remove all nonsingleton dimensions
    respMatSquishSep = SeparateTraces(respMatSquish(numIgnore+1:end,:),numSep); % separate every numSnips epochs into a new trace to plot

    respMatSem = SnipMatToMatrix(averagedFliesSem); % turn snipMat into a matrix
    respMatSemSquish = squish(respMatSem); % remove all nonsingleton dimensions
    respMatSemSquishSep = SeparateTraces(respMatSemSquish(numIgnore+1:end,:),numSep); % separate every numSnips epochs into a new trace to plot

    % write to output structure
    analysis{end+1}.name = 'respMat';
    analysis{end}.snipMat = respMat;
    analysis{end}.respMatSquish = respMatSquish;
    analysis{end}.respMatSquishSep = respMatSquishSep;
    
    analysis{end}.respMatSem = respMatSem;
    analysis{end}.respMatSemSquish = respMatSemSquish;
    analysis{end}.respMatSemSquishSep = respMatSemSquishSep;
    
    analysis = MakeAnalysisReadable(analysis);
    
    %% plot
    if ~exist('dataX','var')
        dataX = 1:size(respMatSquishSep,1);
    end
    
    MakeFigure;
    PlotXvsY(dataX',respMatSquishSep(:,:,1),'error',respMatSemSquishSep(:,:,1));
    ConfAxis(varargin{:},'labelY','turning response (deg/sec)');
    
    MakeFigure;
    PlotXvsY(dataX',respMatSquishSep(:,:,2),'error',respMatSemSquishSep(:,:,2));
    ConfAxis(varargin{:},'labelY','walking respones (fold change)');
end