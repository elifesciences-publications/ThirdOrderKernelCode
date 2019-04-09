function D = CLcombineEpochRespandDoubles(varargin)
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
    analysis.GS = CLgrabSnips(analysis.OD,D.data.params,'limits',limits,'epsilon',epsilon);
    analysis.CI1 = CLcombineInput(analysis.GS.comb,1,combType);
    analysis.CD = CLcombineDuplicates(analysis.CI1.comb);
    analysis.CI3 = CLcombineInput(analysis.CD.comb,3);
    
    D.analysis = analysis;
    
    %% throw in time traces
    analysis.GS_2 = CLgrabSnips(analysis.OD,D.data.params,'limits',[30 120]);
    analysis.CI3_2 = CLcombineInput(analysis.GS_2.comb,3);
    
    % plot lead turning
    makeFigure;
    plotXvsY((1:analysis.CI3_2.numData)',analysis.CI3_2.turn.lead,[xLabel ' lead'],'turning deg/sec','error',analysis.CI3_2.semTurn.lead);
    
    % plot yoked turning
    makeFigure;
    plotXvsY((1:analysis.CI3_2.numData)',analysis.CI3_2.turn.yoke,[xLabel ' yoke'],'turning deg/sec','error',analysis.CI3_2.semTurn.yoke);
    
    % plot lead walking
    makeFigure;
    plotXvsY((1:analysis.CI3_2.numData)',analysis.CI3_2.walk.lead,[xLabel ' lead'],'walking (response / interleave)','error',analysis.CI3_2.semWalk.lead);
    
    % plot yoked walking
    makeFigure;
    plotXvsY((1:analysis.CI3_2.numData)',analysis.CI3_2.walk.yoke,[xLabel ' yoke'],'walking (response / interleave)','error',analysis.CI3_2.semWalk.yoke);
    
    %% graph data
    x = (1:analysis.CI3.numEpochs)';
    
    indTurn.lead = permute(analysis.CD.turn.lead,[2 3 1]);
    indWalk.lead = permute(analysis.CD.walk.lead,[2 3 1]);
    
    indTurn.yoke = permute(analysis.CD.turn.yoke,[2 3 1]);
    indWalk.yoke = permute(analysis.CD.walk.yoke,[2 3 1]);
    
    indLeg = arrayfun(@num2str,1:analysis.CD.numFlies,'unif',0);
    
    %plot theta average response lead
    makeFigure;
    plotXvsY(x,analysis.CI3.turn.lead',[xLabel ' lead'],[yLabel ' turning (deg/sec)'],'error',analysis.CI3.semTurn.lead');
    confAxis(varargin{:});
    
    %plot theta average response individual flies lead
    makeFigure;
    plotXvsY(x,indTurn.lead,[xLabel ' lead'],[yLabel ' turning indv flies'],'figLeg',indLeg);
    confAxis(varargin{:});
    
    %plot theta average response yoke
    makeFigure;
    plotXvsY(x,analysis.CI3.turn.yoke',[xLabel ' yoke'],[yLabel ' turning (deg/sec)'],'error',analysis.CI3.semTurn.yoke');
    confAxis(varargin{:});
    
    %plot theta average response individual flies yoke
    makeFigure;
    plotXvsY(x,indTurn.yoke,[xLabel ' yoke'],[yLabel ' turning indv flies'],'figLeg',indLeg);
    confAxis(varargin{:});
    
    
    %plot walk average response lead
    makeFigure;
    plotXvsY(x,analysis.CI3.walk.lead',[xLabel ' lead'],[yLabel ' walking (response / interleave)'],'error',analysis.CI3.semWalk.lead');
    confAxis(varargin{:});
    
    %plot walk average response individual flies lead
    makeFigure;
    plotXvsY(x,indWalk.lead,[xLabel ' lead'],[yLabel ' walking indv flies'],'figLeg',indLeg);
    confAxis(varargin{:});
    
    %plot walk average response yoke
    makeFigure;
    plotXvsY(x,analysis.CI3.walk.yoke',[xLabel ' yoke'],[yLabel ' walking (response / interleave)'],'error',analysis.CI3.semWalk.yoke');
    confAxis(varargin{:});
    
    %plot walk average response individual flies yoke
    makeFigure;
    plotXvsY(x,indWalk.yoke,[xLabel ' yoke'],[yLabel ' walking indv flies'],'figLeg',indLeg);
    confAxis(varargin{:});
end