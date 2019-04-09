 function analysis = CombAndSepFlies(flyResp,epochs,params,stim,varargin)
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
    
    %% combine left ward and rightward epochs
    if combOpp
        combinedOpposites = CombineOppositeTrials(analysis{end}.snipMat);
    else
        combinedOpposites = analysis{end}.snipMat;
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
    averagedTrials = ReduceDimension(averagedTime,'trials');
    
    % get SEM for plotting
    averagedTrialsSem = CalcRespSEM(averagedTime,'trials');
    
    % write to output structure
    analysis{end+1}.name = 'averagedTrials';
    analysis{end}.snipMat = averagedTrials;
    
    %% convert from snipMat to matrix

    respMat = SnipMatToMatrix(averagedTrials); % turn snipMat into a matrix
    [~,~,numEpochs,numFlies,~] = size(respMat);
    respMatSquish = reshape(respMat,numEpochs,numFlies,2); % remove all nonsingleton dimensions

    respMatSem = SnipMatToMatrix(averagedTrialsSem); % turn snipMat into a matrix
    respMatSemSquish = reshape(respMatSem,numEpochs,numFlies,2); % remove all nonsingleton dimensions

    % write to output structure
    analysis{end+1}.name = 'respMat';
    analysis{end}.snipMat = respMat;
    analysis{end}.respMatSquish = respMatSquish;
    
    analysis{end}.respMatSem = respMatSem;
    analysis{end}.respMatSemSquish = respMatSemSquish;
    
    analysis = MakeAnalysisReadable(analysis);
    
    %% plot
    if isempty(dataX)
        dataX = meshgrid(1:(size(respMatSquish,1)-numIgnore),1:size(respMatSquish,2));
    end
    
    MakeFigure;
    PlotXvsY(dataX',respMatSquish(numIgnore+1:end,:,1),'error',respMatSemSquish(numIgnore+1:end,:,1));
    ConfAxis(varargin{:},'labelY','turning response (deg/sec)');
    
    MakeFigure;
    PlotXvsY(dataX',respMatSquish(numIgnore+1:end,:,2),'error',respMatSemSquish(numIgnore+1:end,:,2));
    ConfAxis(varargin{:},'labelY','walking respones (fold change)');
end