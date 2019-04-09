function D = CLcombineEpochResp(varargin)
    % reads in the data and averages the flies' response to the stimuli,
    % keeping each epoch separate. Then plots out the average response to
    % that stimuli vs the log speed of the wave
    %% deal with inputs
    %initialize vars these can be changed through varargin with the form
    %func(...'varName','value')
    limits = zeros(2,1);
    combType = 'mean';
    xLabel = 'epoch #';
    yLabel = '';
    normWalk = 1;
    epsilon = 0;
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
    analysis.GS = CLgrabSnips(analysis.OD,D.data.params,'limits',limits,'normWalk',normWalk,'epsilon',epsilon);
    analysis.CI1 = CLcombineInput(analysis.GS.comb,1,combType);
    analysis.CI3 = CLcombineInput(analysis.CI1.comb,3);
    
    D.analysis = analysis;
    
    %% throw in time traces
    CLplotTimeTrace;
    
    %% graph data
    x = (1:analysis.CI3.numEpochs)';
    
    indTurn.lead = permute(analysis.CI1.turn.lead,[2 3 1]);
    indWalk.lead = permute(analysis.CI1.walk.lead,[2 3 1]);
    
    indTurn.yoke = permute(analysis.CI1.turn.yoke,[2 3 1]);
    indWalk.yoke = permute(analysis.CI1.walk.yoke,[2 3 1]);
    
    indLeg = arrayfun(@num2str,1:analysis.CI1.numFlies,'unif',0);
    
    %plot theta average response lead
    makeFigure;
    plotXvsY(x,analysis.CI3.turn.lead',[xLabel 'lead'],'deg/sec lead','error',analysis.CI3.semTurn.lead');
    confAxis(varargin{:});
    
    %plot theta average response individual flies lead
    makeFigure;
    plotXvsY(x,indTurn.lead,xLabel,'deg/sec indv lead','figLeg',indLeg);
    confAxis(varargin{:});
    
    %plot theta average response yoke
    makeFigure;
    plotXvsY(x,analysis.CI3.turn.yoke',xLabel,'deg/sec yoke','error',analysis.CI3.semTurn.yoke');
    confAxis(varargin{:});
    
    %plot theta average response individual flies yoke
    makeFigure;
    plotXvsY(x,indTurn.yoke,xLabel,'deg/sec indv yoke','figLeg',indLeg);
    confAxis(varargin{:});
    
    
    %plot walk average response lead
    makeFigure;
    plotXvsY(x,analysis.CI3.walk.lead',xLabel,'mm/sec lead','error',analysis.CI3.semWalk.lead');
    confAxis(varargin{:});
    
    %plot walk average response individual flies lead
    makeFigure;
    plotXvsY(x,indWalk.lead,xLabel,'mm/sec indv lead','figLeg',indLeg);
    confAxis(varargin{:});
    
    %plot walk average response yoke
    makeFigure;
    plotXvsY(x,analysis.CI3.walk.yoke',xLabel,'mm/sec yoke','error',analysis.CI3.semWalk.yoke');
    confAxis(varargin{:});
    
    %plot walk average response individual flies yoke
    makeFigure;
    plotXvsY(x,indWalk.yoke,xLabel,'mm/sec indv yoke','figLeg',indLeg);
    confAxis(varargin{:});
end