 function analysis = PlotSingleFlyTimeTraces(flyResp,epochs,params,stim,varargin)
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
    
    analysis = GetProcessedTrials(flyResp,epochs,params,'snipShift',snipShift,'duration',duration,varargin{:});
    
    %% combine left ward and rightward epochs
    if combOpp
        combinedOpposites = CombineOppositeTrials(analysis{end}.snipMat);
    else
        combinedOpposites = analysis{end}.snipMat;
    end
    
    % write to output structure
    analysis{end+1}.name = 'combinedOpposites';
    analysis{end}.snipMat = combinedOpposites;
    
    %% average over flies
    averagedTrials = ReduceDimension(combinedOpposites,'trials');
    
    % get SEM for plotting
    averagedTrialsSem = CalcRespSEM(combinedOpposites,'trials');
    
    % write to output structure
    analysis{end+1}.name = 'averagedTrials';
    analysis{end}.snipMat = averagedTrials;
    
    %% convert from snipMat to matrix

    respMat = SnipMatToMatrix(averagedTrials); % turn snipMat into a matrix
    respMatSem = SnipMatToMatrix(averagedTrialsSem); % turn snipMat into a matrix
    
    % Since we want separate traces for all flies, combine the fly and
    % epoch dimensions
    [numTimePoints,~,numEpochs,numFlies,~] = size(respMat);
    respMatSquishComb = reshape(respMat(:,:,numIgnore+1:end,:,:),numTimePoints,(numEpochs-numIgnore)*numFlies,2);
    respMatSemSquishComb = reshape(respMatSem(:,:,numIgnore+1:end,:,:),numTimePoints,(numEpochs-numIgnore)*numFlies,2);

    % write to output structure
    analysis{end+1}.name = 'respMat';
    analysis{end}.snipMat = respMat;
    analysis{end}.respMatSquishComb = respMatSquishComb;
    
    analysis{end}.respMatSem = respMatSem;
    analysis{end}.respMatSemSquishComb = respMatSemSquishComb;
    
    analysis = MakeAnalysisReadable(analysis);
    
    %% plot
    timeX = (1:size(respMatSquishComb,1))'/60*1000;
    
    MakeFigure;
    PlotXvsY(timeX,respMatSquishComb(:,:,1),'error',respMatSemSquishComb(:,:,1));
    ConfAxis(varargin{:},'labelY','turning response (deg/sec)');
    
    MakeFigure;
    PlotXvsY(timeX,respMatSquishComb(:,:,2),'error',respMatSemSquishComb(:,:,2));
    ConfAxis(varargin{:},'labelY','walking respones (fold change)');
end