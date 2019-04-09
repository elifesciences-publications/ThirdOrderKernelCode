function D = combineEpochResp(varargin)
    % reads in the data and averages the flies' response to the stimuli,
    % keeping each epoch separate. Then plots out the average response to
    % that stimuli vs the log speed of the wave
    %% deal with inputs
    %initialize vars these can be changed through varargin with the form
    %func(...'varName','value')
    limits = zeros(2,1);
    combType = 'mean';
    xLabel = 'epoch #';
    yLabel = 'ave resp (degrees/sec) + SEM';
    normWalk = 1;
    epsilon = 0;
    ignoreInter = 1;
    TTlimits = [30 120];
    blacklist = [];
    
    for ii = 1:2:length(varargin)-1
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    if exist('dataPath','var')
        D = grabData(dataPath,blacklist);
    else
        D = grabData();
    end
    
    %% perform analysis
    analysis.OD = organizeData(D,varargin{:});
    analysis.GS = grabSnips(analysis.OD,D.data.params,varargin{:});
    analysis.CI1 = combineInput(analysis.GS.comb,1,combType);
    analysis.CI3 = combineInput(analysis.CI1.comb,3);
    
    % throw in time traces
    plotTimeTrace
    
    D.analysis = analysis;
    %% graph data
    x = (1:analysis.CI3.numEpochs)';
    
    indTurn = permute(analysis.CI1.turn,[2 3 1]);
    indWalk = permute(analysis.CI1.walk,[2 3 1]);
    indLeg = arrayfun(@num2str,1:analysis.CI1.numFlies,'unif',0);
    
    %plot theta vs average response
    makeFigure;
    plotXvsY(x,analysis.CI3.turn',xLabel,yLabel,'error',analysis.CI3.semTurn');
    confAxis(varargin{:});
    
    %plot theta vs average response individual flies
    makeFigure;
    plotXvsY(x,indTurn,xLabel,[yLabel ' indv flies'],'figLeg',indLeg);
    confAxis(varargin{:});
    
    %plot theta vs average response
    makeFigure;
    plotXvsY(x,analysis.CI3.walk',xLabel,'response ave mm/s','error',analysis.CI3.semWalk');
    confAxis(varargin{:});
    
    %plot theta vs average response individual flies
    makeFigure;
    plotXvsY(x,indWalk,xLabel,['response ave mm/s' ' indv flies'],'figLeg',indLeg);
    confAxis(varargin{:});
end