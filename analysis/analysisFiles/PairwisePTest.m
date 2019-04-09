function D = PairwisePTest(varargin)
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
    timeRange = [0 0];    
    
    for ii = 1:2:length(varargin)-1
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    if exist('dataPath','var')
        D = grabData(dataPath);
    else
        D = grabData();
    end
    
    %% perform analysis
    D = limitTime(D,timeRange);
    analysis.OD = organizeData(D,varargin{:});
    analysis.GS = grabSnips(analysis.OD,D.data.params,varargin{:});
    analysis.PPT = pTestAll(analysis.GS.snipMat);
    
    D.analysis = analysis;
    %% graph data
    
    analysis.PPT.turnSignificance
    
%     makeFigure;
%     HeatMap(analysis.PPT.turnDifferences)
%     title('Difference in Turning (degrees/s) (Epoch1 - Epoch2)');
%     xlabel('Epoch2');
%     ylabel('Epoch1');
%     
%     makeFigure;
%     HeatMap(analysis.PPT.walkDifferences)
%     title('Difference in Walking (mm/s) (Epoch1 - Epoch2)');
%     xlabel('Epoch2');
%     ylabel('Epoch1');
%     
%     makeFigure;
%     HeatMap(sign(analysis.PPT.turnDifferences).*analysis.PPT.turnSignificance)
%     title('P Value of Difference in Turning (degrees/s) (Epoch1 - Epoch2)');
%     xlabel('Epoch2');
%     ylabel('Epoch1');
%     
%     makeFigure;
%     HeatMap(sign(analysis.PPT.walkDifferences).*analysis.PPT.walkSignificance)
%     title('P Value of Difference in walking (mm/s) (Epoch1 - Epoch2)');
%     xlabel('Epoch2');
%     ylabel('Epoch1');
end