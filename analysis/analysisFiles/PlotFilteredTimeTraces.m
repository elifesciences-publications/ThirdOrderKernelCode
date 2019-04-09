 function analysis = PlotFilteredTimeTraces(flyResp,epochs,params,stim,varargin)
    combOpp = 1; % logical for combining symmetic epochs such as left and right
    numIgnore = []; % number of epochs to ignore
    snipShift = -30;
    duration = 150;

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
    
    analysis = GetProcessedFilteredTrials(flyResp,epochs,params,'snipShift',snipShift,'duration',duration,varargin{:});
    
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
    
    %% average over flies
    averagedFlies = ReduceDimension(combinedOpposites,'flies');
    
    % get SEM for plotting
    averagedFliesSem = CalcRespSEM(combinedOpposites,'flies');
    
    % write to output structure
    analysis{end+1}.name = 'averagedFlies';
    analysis{end}.snipMat = averagedFlies;
    
    %% convert from snipMat to matrix

    respMat = SnipMatToMatrix(averagedFlies); % turn snipMat into a matrix
    respMatSquish = squish(respMat); % remove all nonsingleton dimensions

    respMatSem = SnipMatToMatrix(averagedFliesSem); % turn snipMat into a matrix
    respMatSemSquish = squish(respMatSem); % remove all nonsingleton dimensions

    % write to output structure
    analysis{end+1}.name = 'respMat';
    analysis{end}.snipMat = respMat;
    analysis{end}.respMatSquish = respMatSquish;
    
    analysis{end}.respMatSem = respMatSem;
    analysis{end}.respMatSemSquish = respMatSemSquish;
    
    analysis = MakeAnalysisReadable(analysis);
    
    %% plot
    timeX = (1:size(respMatSquish,1))'/60*1000;
    
    MakeFigure;
    PlotXvsY(timeX,respMatSquish(:,numIgnore+1:end,1),'error',respMatSemSquish(:,numIgnore+1:end,1));
    ConfAxis(varargin{:},'labelY','turning response (deg/sec)');
    
    MakeFigure;
    PlotXvsY(timeX,respMatSquish(:,numIgnore+1:end,2),'error',respMatSemSquish(:,numIgnore+1:end,2));
    ConfAxis(varargin{:},'labelY','walking respones (fold change)');
end