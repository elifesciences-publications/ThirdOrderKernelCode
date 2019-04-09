function D = CLoverlayEpochSnipsAndDoubles(varargin)
    %reads in the data and cuts out snips around the given epochs and sums
    %them together then plots the average response to each epoch
    
    %% deal with inputs
    %initialize vars these can be changed through varargin with the form
    %func(...'varName','value')
    limits = [30 120];
    figLeg = {};
    numBins = 49;
    plotHM = 0;
    xLabel = 'time (sec)';
    yLabel = '';
    combType = 'mean';
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
    analysis.GS = CLgrabSnips(analysis.OD,D.data.params,'limits',limits);
    analysis.CD = CLcombineDuplicates(analysis.GS.comb);
    analysis.CI3 = CLcombineInput(analysis.CD.comb,3,combType);
    
    analysis.GS_2 = grabSnips(analysis.OD,D.data.params,'limits',limits);
    analysis.CI3_2 = combineInput(analysis.GS_2.comb,3,combType);
    
    D.analysis = analysis;
    
    x = (1:analysis.CI3.numData)';
    
    % plot combined lead and yoke so that the noise doesn't kill your
    % opinion of the fly's behavior
    makeFigure;
    plotXvsY(x,analysis.CI3_2.turn,xLabel,['deg/sec lead&yoke ' yLabel],'error',analysis.CI3_2.semTurn);
    
    makeFigure;
    plotXvsY(x,analysis.CI3_2.walk,xLabel,['deg/sec lead&yoke ' yLabel],'error',analysis.CI3_2.semWalk);
    
    % plot lead turning
    makeFigure;
    plotXvsY(x,analysis.CI3.turn.lead,xLabel,['deg/sec lead ' yLabel],'error',analysis.CI3.semTurn.lead);
    
    % plot yoked turning
    makeFigure;
    plotXvsY(x,analysis.CI3.turn.yoke,xLabel,['deg/sec yoke ' yLabel],'error',analysis.CI3.semTurn.yoke);
    
    % plot lead walking
    makeFigure;
    plotXvsY(x,analysis.CI3.walk.lead,xLabel,['mm/sec lead ' yLabel],'error',analysis.CI3.semWalk.lead);
    
    % plot yoked walking
    makeFigure;
    plotXvsY(x,analysis.CI3.walk.yoke,xLabel,['mm/sec yoke ' yLabel],'error',analysis.CI3.semWalk.yoke);
end