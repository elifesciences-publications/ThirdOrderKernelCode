function D = PolynomialModel(varargin)
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
    yLabel = 'response + SEM';
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
    
    D.analysis = analysis;
    
    disp('pick xtPlot');
    XT = run_analysis('analysisFile','analyze_xtPlot','dataPath','D:\Documents\data\xtPlot\scintHz_0.25flick\2014\03_03\19_11_50_xtplot');
    
    %flyAuto = autocorr(XT.analysis.R.reichTime,500);
    %autoCorr0 = find(flyAuto<0,1,'first');
    autoCorr0 = 1;
    
    I = XT.analysis.R.recVis(1:autoCorr0:end,:);
    fly = XT.analysis.R.reichTimeAbs(1:autoCorr0:end);
    totalTime = size(I,1);
    totalX = size(I,2);
    
    xList = [0 1];
    xOff = max(xList) - min(xList);
    xSpan = totalX - xOff;
    
    tList = [1 12];
    tOff = max(tList) - min(tList);
    tSpan = totalTime - tOff;
    
    numPoints = length(xList)*length(tList);
    order = 4;
    
    points = zeros(tSpan,numPoints,xSpan);
    % unit moves the model across in the x diminsion so that you account for
    % full field
    for unit = 1:xSpan
        for xx = 1:length(xList)
            for tt = 1:length(tList)
                points(:,(xx-1)*length(tList)+tt,unit) = I(tList(tt):totalTime-(tOff-tList(tt)+1),unit+xList(xx));
            end
        end
    end

    % total number of terms is solved by the stars and bars problem, this
    % little program (stolen from http://stackoverflow.com/questions/9778644/iterating-over-values-from-fixed-sum-in-matlab)
    % outputs the full permutations in a convenient matrix where each row is a
    % term and each column is a different point. The values represent the
    % exponent to which that point is raised.

    termPowers = zeros(1,numPoints);
    
    for od = 1:order
        termPowers = [termPowers; starsAndBars(od,numPoints)];
    end
    
    numTerms = size(termPowers,1);

    modelMat = zeros(tSpan,numTerms,xSpan);

    for unit = 1:xSpan
        for nt = 1:numTerms
            modelMat(:,nt,unit) = prod(bsxfun(@power,points(:,:,unit),termPowers(nt,:)),2);
        end
    end
    
    modelMat = mean(modelMat,3);

    [pWeights,confInt,residuals,outlierInterval,stats] = regress(fly(1:tSpan,1,1),modelMat);
    
    %D.analysis.fits = fits;
 end