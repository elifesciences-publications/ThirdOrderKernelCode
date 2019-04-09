function D = CLcombineEpochRespSepDoubles(varargin)
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
    labelOdd = '';
    labelEven = '';
    plotExtra = 0;
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
    analysis.CI3 = CLcombineInput(analysis.CI1.comb,3);
    
    D.analysis = analysis;
    
    %% throw in time traces
    analysis.GS_2 = CLgrabSnips(analysis.OD,D.data.params,'limits',[30 120]);
    analysis.CI3_2 = CLcombineInput(analysis.GS_2.comb,3);
    
    % plot lead turning
    makeFigure;
    plotXvsY((1:analysis.CI3_2.numData)',analysis.CI3_2.turn.lead,xLabel,['deg/sec lead ' yLabel],'error',analysis.CI3_2.semTurn.lead);
    
    % plot yoked turning
    makeFigure;
    plotXvsY((1:analysis.CI3_2.numData)',analysis.CI3_2.turn.yoke,xLabel,['deg/sec yoke ' yLabel],'error',analysis.CI3_2.semTurn.yoke);
    
    % plot lead walking
    makeFigure;
    plotXvsY((1:analysis.CI3_2.numData)',analysis.CI3_2.walk.lead,xLabel,['mm/sec lead ' yLabel],'error',analysis.CI3_2.semWalk.lead);
    
    % plot yoked walking
    makeFigure;
    plotXvsY((1:analysis.CI3_2.numData)',analysis.CI3_2.walk.yoke,xLabel,['mm/sec yoke ' yLabel],'error',analysis.CI3_2.semWalk.yoke);
    
    
    %% graph data
    x = (1:analysis.CI3.numEpochs/2)';
    
    % lead - separate epochs into even and odd numbered
    odd.lead = analysis.CI3.comb.lead(:,1:2:end,:,:);
    even.lead = analysis.CI3.comb.lead(:,2:2:end,:,:);
    
    % yoke - separate epochs into even and odd numbered
    odd.yoke = analysis.CI3.comb.yoke(:,1:2:end,:,:);
    even.yoke = analysis.CI3.comb.yoke(:,2:2:end,:,:);
    
    % lead - separate epochs sems into even and odd
    semOdd.lead = analysis.CI3.sem.lead(:,1:2:end,:,:);
    semEven.lead = analysis.CI3.sem.lead(:,2:2:end,:,:);
    
    % yoke - separate epochs sems into even and odd
    semOdd.yoke = analysis.CI3.sem.yoke(:,1:2:end,:,:);
    semEven.yoke = analysis.CI3.sem.yoke(:,2:2:end,:,:);
    
    % ind traces not currently working for closed loop cause I'm lazy and
    % don't want to fix this right now -MSC
    ind = permute(analysis.CI1.comb,[2 3 1 4]);
    indOdd = [ind(:,1,:,:); ind(:,2:2:end,:,:)];
    indEven = [ind(:,1,:,:); ind(:,3:2:end,:,:)];
    indLeg = arrayfun(@num2str,1:analysis.CI1.numFlies,'unif',0);

    D.analysis.odd.lead = odd.lead;
    D.analysis.even.lead = even.lead;
    D.analysis.odd.yoke = odd.yoke;
    D.analysis.even.yoke = even.yoke;
    
    D.analysis.semOdd.lead = semOdd.lead;
    D.analysis.semEven.lead = semEven.lead;
    D.analysis.semOdd.yoke = semOdd.yoke;
    D.analysis.semEven.yoke = semEven.yoke;
    
    % lead - plot theta vs average response overlayed
    makeFigure;
    plotXvsY(x,[odd.lead(:,:,:,1)' even.lead(:,:,:,1)'],[xLabel ' lead flies'],'turning (deg/sec)','error',[semOdd.lead(:,:,:,1)' semEven.lead(:,:,:,1)']);
    confAxis(varargin{:});
    legend({labelOdd labelEven});
    
    % yoke - plot theta vs average response overlayed
    makeFigure;
    plotXvsY(x,[odd.yoke(:,:,:,1)' even.yoke(:,:,:,1)'],[xLabel ' yoked flies'],'turning (deg/sec)','error',[semOdd.yoke(:,:,:,1)' semEven.yoke(:,:,:,1)']);
    confAxis(varargin{:});
    legend({labelOdd labelEven});
    
    % lead - plot theta vs average response
    makeFigure;
    plotXvsY(x,[odd.lead(:,:,:,2)' even.lead(:,:,:,2)'],[xLabel ' lead flies'],'walking','error',[semOdd.lead(:,:,:,2)' semEven.lead(:,:,:,2)']);
    confAxis(varargin{:});
    legend({labelOdd labelEven});
    
    % yoke - plot theta vs average response
    makeFigure;
    plotXvsY(x,[odd.yoke(:,:,:,2)' even.yoke(:,:,:,2)'],[xLabel 'yoked flies'],'walking','error',[semOdd.yoke(:,:,:,2)' semEven.yoke(:,:,:,2)']);
    confAxis(varargin{:});
    legend({labelOdd labelEven});
    
    if plotExtra
        %plot theta vs average turning response
        makeFigure;
        plotXvsY(x,odd(:,:,:,1)',[xLabel ' (' labelOdd ')'],yLabel,'error',semOdd(:,:,:,1)');
        confAxis(varargin{:});

        makeFigure;
        plotXvsY(x,even(:,:,:,1)',[xLabel ' (' labelEven ')'],yLabel,'error',semOdd(:,:,:,1)');
        confAxis(varargin{:});

        %plot theta vs average response individual flies
        makeFigure;
        plotXvsY(x,indOdd(:,:,:,1),[xLabel ' (' labelOdd ')'],[yLabel 'indv flies'],'figLeg',indLeg);
        confAxis(varargin{:});

        makeFigure;
        plotXvsY(x,indEven(:,:,:,1),[xLabel ' (' labelEven ')'],[yLabel 'indv flies'],'figLeg',indLeg);
        confAxis(varargin{:});

        %plot theta vs average walking response
        makeFigure;
        plotXvsY(x,odd(:,:,:,2)',[xLabel ' (' labelOdd ')'],'response ave mm/s','error',semOdd(:,:,:,2)');
        confAxis(varargin{:});

        makeFigure;
        plotXvsY(x,even(:,:,:,2)',[xLabel ' (' labelEven ')'],'response ave mm/s','error',semEven(:,:,:,2)');
        confAxis(varargin{:});

        %plot theta vs average walking response individual flies
        makeFigure;
        plotXvsY(x,indOdd(:,:,:,2),[xLabel ' (' labelOdd ')'],['response ave mm/s' 'indv flies'],'figLeg',indLeg);
        confAxis(varargin{:});

        makeFigure;
        plotXvsY(x,indEven(:,:,:,2),[xLabel ' (' labelEven ')'],['response ave mm/s' 'indv flies'],'figLeg',indLeg);
        confAxis(varargin{:});
    end
end