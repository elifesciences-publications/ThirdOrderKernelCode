function D = combineEpochRespSepandDoubles(varargin)
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
    numIgnore = 1;
    flipEven = 1;
    dataX = [];
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
    analysis.CD = combineDuplicates(analysis.CI1.comb);
    analysis.CI3 = combineInput(analysis.CD.comb,3);
    
    % throw in time traces
    plotTimeTrace
    
    D.analysis = analysis;
    
    %% graph data
    if isempty(dataX)
        dataX = (1:analysis.CI3.numEpochs/2)';
    end
    
    % separate epochs into even and odd numbered
    odd = analysis.CI3.comb(:,1+numIgnore:2:end,:,:);
    even = analysis.CI3.comb(:,2+numIgnore:2:end,:,:);
    
    % separate epochs sems into even and odd
    semOdd = analysis.CI3.sem(:,1+numIgnore:2:end,:,:);
    semEven = analysis.CI3.sem(:,2+numIgnore:2:end,:,:);
    
    ind = permute(analysis.CD.comb,[2 3 1 4]);
    indOdd = ind(:,1+numIgnore:2:end,:,:);
    indEven = ind(:,2+numIgnore:2:end,:,:);
    indLeg = arrayfun(@num2str,1:analysis.CD.numFlies,'unif',0);

    D.analysis.odd = odd;
    D.analysis.even = even;
    D.analysis.semOdd = semOdd;
    D.analysis.semEven = semEven;
    
    %plot theta vs average response overlayed
    makeFigure;
    plotXvsY(dataX,[odd(:,:,:,1)' flipEven*even(:,:,:,1)'],xLabel,yLabel,'error',[semOdd(:,:,:,1)' semEven(:,:,:,1)']);
    confAxis(varargin{:});
    legend({labelOdd labelEven});
    
    %plot theta vs average response
    makeFigure;
    plotXvsY(dataX,[odd(:,:,:,2)' even(:,:,:,2)'],xLabel,yLabel,'error',[semOdd(:,:,:,2)' semEven(:,:,:,2)']);
    confAxis(varargin{:});
    legend({labelOdd labelEven});
    
    if plotExtra
        %plot theta vs average turning response
        makeFigure;
        plotXvsY(dataX,odd(:,:,:,1)',[xLabel ' (' labelOdd ')'],yLabel,'error',semOdd(:,:,:,1)');
        confAxis(varargin{:});

        makeFigure;
        plotXvsY(dataX,even(:,:,:,1)',[xLabel ' (' labelEven ')'],yLabel,'error',semEven(:,:,:,1)');
        confAxis(varargin{:});

        %plot theta vs average response individual flies
        makeFigure;
        plotXvsY(dataX,indOdd(:,:,:,1),[xLabel ' (' labelOdd ')'],[yLabel 'indv flies'],'figLeg',indLeg);
        confAxis(varargin{:});

        makeFigure;
        plotXvsY(dataX,indEven(:,:,:,1),[xLabel ' (' labelEven ')'],[yLabel 'indv flies'],'figLeg',indLeg);
        confAxis(varargin{:});

        %plot theta vs average walking response
        makeFigure;
        plotXvsY(dataX,odd(:,:,:,2)',[xLabel ' (' labelOdd ')'],'response ave mm/s','error',semOdd(:,:,:,2)');
        confAxis(varargin{:});

        makeFigure;
        plotXvsY(dataX,even(:,:,:,2)',[xLabel ' (' labelEven ')'],'response ave mm/s','error',semEven(:,:,:,2)');
        confAxis(varargin{:});

        %plot theta vs average walking response individual flies
        makeFigure;
        plotXvsY(dataX,indOdd(:,:,:,2),[xLabel ' (' labelOdd ')'],['response ave mm/s' 'indv flies'],'figLeg',indLeg);
        confAxis(varargin{:});

        makeFigure;
        plotXvsY(dataX,indEven(:,:,:,2),[xLabel ' (' labelEven ')'],['response ave mm/s' 'indv flies'],'figLeg',indLeg);
        confAxis(varargin{:});
    end
end