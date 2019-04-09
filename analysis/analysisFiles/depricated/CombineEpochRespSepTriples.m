function D = combineEpochRespSepTriples(varargin)
    % reads in the data and averages the flies' response to the stimuli,
    % keeping each epoch separate. Then plots out the average response to
    % that stimuli vs the log speed of the wave
    %% deal with inputs
    %initialize vars these can be changed through varargin with the form
    %func(...'varName','value')
    limits = zeros(2,1);
    TTlimits = [30 120];
    combType = 'mean';
    xLabel = 'epoch #';
    yLabel = 'ave resp (degrees/sec) + SEM';
    labelOne = '';
    labelTwo = '';
    labelThree = '';
    plotExtra = 0;
    numIgnore = 0;
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
    analysis.GS = grabSnips(analysis.OD,D.data.params,'limits',limits);
    analysis.CI1 = combineInput(analysis.GS.comb,1,combType);
    analysis.CI3 = combineInput(analysis.CI1.comb,3);
    
    % throw in time traces
    plotTimeTrace
    
    D.analysis = analysis;
    
    %% graph data
    x = (1:analysis.CI3.numEpochs/3)';
    
    % separate fly response into 3 categories
    one = analysis.CI3.comb(:,1+numIgnore:3:end,:,:);
    two = analysis.CI3.comb(:,2+numIgnore:3:end,:,:);
    three = analysis.CI3.comb(:,3+numIgnore:3:end,:,:);
    
    % separate fly sem into 3 categories
    semOne = analysis.CI3.sem(:,1+numIgnore:3:end,:,:);
    semTwo = analysis.CI3.sem(:,2+numIgnore:3:end,:,:);
    semThree = analysis.CI3.sem(:,3+numIgnore:3:end,:,:);
    
    % set up individual fly responses
    ind = permute(analysis.CI1.comb,[3 2 1 4]);
    indRespOne = ind(:,1+numIgnore:3:end,:,:);
    indRespTwo = ind(:,2+numIgnore:3:end,:,:);
    indRespThree = ind(:,3+numIgnore:3:end,:,:);
    indLeg = arrayfun(@num2str,1:analysis.CI1.numFlies,'unif',0);

    D.analysis.aveRespOne = one;
    D.analysis.aveRespTwo = two;
    D.analysis.aveRespThree = three;
    
    D.analysis.semAveRespOne = semOne;
    D.analysis.semAveRespTwo = semTwo;
    D.analysis.semAveRespThree = semThree;
    
    %plot theta vs average response overlayed
    makeFigure;
    plotXvsY(x,[one(:,:,:,1)' two(:,:,:,1)' three(:,:,:,1)'],xLabel,yLabel,'error',[semOne(:,:,:,1)' semTwo(:,:,:,1)' semThree(:,:,:,1)']);
    confAxis(varargin{:});
    legend({labelOne labelTwo labelThree});
    
    %plot theta vs average response
    makeFigure;
    plotXvsY(x,[one(:,:,:,2)' two(:,:,:,2)' three(:,:,:,2)'],xLabel,yLabel,'error',[semOne(:,:,:,2)' semTwo(:,:,:,2)' semThree(:,:,:,2)']);
    confAxis(varargin{:});
    legend({labelOne labelTwo labelThree});
    
    if plotExtra
        %plot theta vs average turning response
        makeFigure;
        plotXvsY(x,one(:,:,:,1)',[xLabel ' (' labelOne ')'],yLabel,'error',semOne(:,:,:,1)');
        confAxis(varargin{:});

        makeFigure;
        plotXvsY(x,two(:,:,:,1)',[xLabel ' (' labelTwo ')'],yLabel,'error',semTwo(:,:,:,1)');
        confAxis(varargin{:});

        makeFigure;
        plotXvsY(x,three(:,:,:,1)',[xLabel ' (' labelThree ')'],yLabel,'error',semThree(:,:,:,1)');
        confAxis(varargin{:});

        %plot theta vs average response individual flies
        makeFigure;
        plotXvsY(x,indRespOne(:,:,:,1)',[xLabel ' (' labelOne ')'],[yLabel 'indv flies'],'figLeg',indLeg);
        confAxis(varargin{:});

        makeFigure;
        plotXvsY(x,indRespTwo(:,:,:,1)',[xLabel ' (' labelTwo ')'],[yLabel 'indv flies'],'figLeg',indLeg);
        confAxis(varargin{:});

        makeFigure;
        plotXvsY(x,indRespThree(:,:,:,1)',[xLabel ' (' labelThree ')'],[yLabel 'indv flies'],'figLeg',indLeg);
        confAxis(varargin{:});

        %plot theta vs average walking response
        makeFigure;
        plotXvsY(x,one(:,:,:,2)',[xLabel ' (' labelOne ')'],'response ave mm/s','error',semOne(:,:,:,2)');
        confAxis(varargin{:});

        makeFigure;
        plotXvsY(x,two(:,:,:,2)',[xLabel ' (' labelTwo ')'],'response ave mm/s','error',semTwo(:,:,:,2)');
        confAxis(varargin{:});

        makeFigure;
        plotXvsY(x,three(:,:,:,2)',[xLabel ' (' labelThree ')'],'response ave mm/s','error',semThree(:,:,:,2)');
        confAxis(varargin{:});

        %plot theta vs average walking response individual flies
        makeFigure;
        plotXvsY(x,indRespOne(:,:,:,2)',[xLabel ' (' labelOne ')'],['response ave mm/s' 'indv flies'],'figLeg',indLeg);
        confAxis(varargin{:});

        makeFigure;
        plotXvsY(x,indRespTwo(:,:,:,2)',[xLabel ' (' labelTwo ')'],['response ave mm/s' 'indv flies'],'figLeg',indLeg);
        confAxis(varargin{:});

        makeFigure;
        plotXvsY(x,indRespThree(:,:,:,2)',[xLabel ' (' labelThree ')'],['response ave mm/s' 'indv flies'],'figLeg',indLeg);
        confAxis(varargin{:});
    end
end