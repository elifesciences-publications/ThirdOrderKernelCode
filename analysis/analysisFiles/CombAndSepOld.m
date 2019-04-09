function D = CombAndSepOld(varargin)
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
    numIgnore = 2;
    flipEven = 1;
    combDup = 1;
    numSep = 1;
    dataX = [];
    normTurn = 0;
    normTrace = 0;
    TTlimits = [-30 120];
    figLeg = {};
    epsilon = 0;
    fitPolynomial = 0;
    polyOrder = 4;
    fitRes = 10;
    fitSpline = 0;
    logFit = 0;
    numBoot = 100;
    fitLength = 100;
    logScale = 1;
    tickLabelX = [];
    tickX = 1:2;
    numAroundFit = 3;
    plotTime = 1;
    blacklist = [];
    
    for ii = 1:2:length(varargin)-1
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    if ~exist('ignoreCol','var')
        ignoreCol = 1:numIgnore;
    end
    
    if exist('dataPath','var')
        D = GrabData(dataPath,blacklist);
    else
        D = grabData();
    end
    
    dataX = dataX(:);
    tickX = tickX(:);
    
    %% perform analysis
    analysis.OD = OrganizeData(D,varargin{:});
    analysis.GS = GrabSnips(analysis.OD,D.data.params,varargin{:});
    
    if isempty(tickLabelX) || iscellstr(tickLabelX);
        tickValX = 1:analysis.GS.numEpochs;
    else
        tickValX = tickLabelX;
    end
    tickValX = tickValX(:);
    
    useCol = 1:analysis.GS.numEpochs;
    useCol(ignoreCol) = [];
    analysis.CI1 = CombineInput(analysis.GS.comb(:,useCol,:,:),1,combType);
    
    analysis.CD = CombineDuplicates(analysis.CI1.comb,combDup);
    
    analysis.NT = NormalizeTurn(analysis.CD.comb,analysis.CI1.sem,normTurn,epsilon);
    
    analysis.CI3 = CombineInput(analysis.NT.comb,3);
    
    % throw in time traces
    if plotTime
        if combDup
            plotTimeTraceDoubles;
        else
            plotTimeTrace;
        end
    end
    
    D.analysis = analysis;
    
    %% graph data
    if isempty(dataX)
        dataX = (1:analysis.CI3.numEpochs/numSep)';
    end
    
    traces = zeros(analysis.CI3.numData,analysis.CI3.numEpochs/numSep,analysis.CI3.numFlies,2,numSep);
    semTraces = zeros(analysis.CI3.numData,analysis.CI3.numEpochs/numSep,analysis.CI3.numFlies,2,numSep);

    numTracePoints = analysis.CI3.numEpochs/numSep;
    indTraces = zeros(analysis.CI3.numData,numTracePoints,analysis.NT.numFlies,2,numSep);
    
    turnMaxLin = zeros(1,numSep);
    turnMaxLinSEM = zeros(1,numSep);
    
    walkMinLin = zeros(1,numSep);
    walkMinLinSEM = zeros(1,numSep);
    
    
    % separate epochs
    for ii = 1:numSep
        traces(:,:,:,:,ii) = analysis.CI3.comb(:,ii:numSep:end,:,:);
        semTraces(:,:,:,:,ii) = analysis.CI3.sem(:,ii:numSep:end,:,:);
        
        indTraces(:,:,:,:,ii) = analysis.NT.comb(:,ii:numSep:end,:,:);
        
        % calculate maximum for each trace turning
%         [~,maxTurnIndex] = max(analysis.NT.comb(:,ii:numSep:end,:,1),[],2);
%         [~,minWalkIndex] = min(analysis.NT.comb(:,ii:numSep:end,:,2),[],2);
        
        %turnMaxLin(ii) = mean(tickValX(maxTurnIndex),3);
        %turnMaxLinSEM(ii) = std(tickValX(maxTurnIndex),[],3)./sqrt(analysis.NT.numFlies);
        
        % calculate maximum for each trace turning
        %walkMinLin(ii) = mean(tickValX(minWalkIndex),3);
        %walkMinLinSEM(ii) = std(tickValX(minWalkIndex),[],3)./sqrt(analysis.NT.numFlies);
        
        
        if normTrace
            semTraces(:,:,:,1,ii) = semTraces(:,:,:,1,ii)./max(abs(traces(:,:,:,1,ii)),[],2);
            traces(:,:,:,1,ii) = traces(:,:,:,1,ii)./max(abs(traces(:,:,:,1,ii)),[],2);
        end
    end
    
    indTraces = permute(indTraces,[2 3 4 5 1]);
    
    %% calculate expected value of curves
    indTracesNorm = zeros(size(indTraces));
    indTracesNorm(:,:,1) = bsxfun(@minus,indTraces(:,:,1),min(indTraces(:,:,1),[],1));
    indTracesNorm(:,:,2) = bsxfun(@minus,indTraces(:,:,2),max(indTraces(:,:,2),[],1));
    indTracesNorm = bsxfun(@rdivide,indTracesNorm,sum(indTracesNorm,1));
    
    weightedTraces = bsxfun(@times,indTracesNorm,dataX);
    indExpectValue = sum(weightedTraces,1);
    if logScale
        indExpectValue = exp(indExpectValue);
    end
    
    expectValue = mean(indExpectValue,2);
    expectValueSTD = std(indExpectValue,[],2);
    expectValueSEM = expectValueSTD./sqrt(size(indExpectValue,2));
    
    %% save variables in D
    %D.analysis.linMax.turnMax = turnMaxLin;
    %D.analysis.linMax.turnMaxSEM = turnMaxLinSEM;
    %D.analysis.linMax.walkMin = walkMinLin;
    %D.analysis.linMax.walkMinSEM = walkMinLinSEM;
    D.analysis.expectValue.indTraces = indTraces;
    D.analysis.expectValue.indExpValue = indExpectValue;
    D.analysis.expectValue.expValue = expectValue;
    D.analysis.expectValue.expValueSTD = expectValueSTD;
    D.analysis.expectValue.expValueSEM = expectValueSEM;
    
    
    
    plotTraces = permute(traces,[2 5 4 1 3]);
    plotSEMTraces = permute(semTraces,[2 5 4 1 3]);
    
    D.analysis.traces = traces;
    D.analysis.semTraces = semTraces;
    
    D.analysis.pTraces = plotTraces;
    D.analysis.pSEMTraces = plotSEMTraces;
    
    if fitPolynomial
        polyFitTraceLocal;
    end
    
    % plot theta vs average response overlayed
    MakeFigure;
    PlotXvsY(dataX,plotTraces(:,:,1,:,:),'error',plotSEMTraces(:,:,1,:,:));
    ConfAxis(varargin{:});
    legend(figLeg);
    
    if fitPolynomial
        hold on;
            plotXvsY(fitX(:,:,1),D.analysis.polyFit.traceFit(:,:,1),xLabel,['turning response (deg/sec) - ' num2str(analysis.CI1.numFlies) ' flies'],'lineStyle','- -','error',D.analysis.polyFit.traceSEM(:,:,1));
        hold off;
    end
    
    % plot walk vs average response
    MakeFigure;
    PlotXvsY(dataX,plotTraces(:,:,2,:,:),'error',plotSEMTraces(:,:,2,:,:));
    ConfAxis(varargin{:});
    legend(figLeg);
    
    if fitPolynomial
        hold on;
            plotXvsY(fitX(:,:,2),D.analysis.polyFit.traceFit(:,:,2,:,:),xLabel,['walking response (fold change) - ' num2str(analysis.CI1.numFlies) ' flies'],'lineStyle','- -','error',D.analysis.polyFit.traceSEM(:,:,2));
        hold off;
    end
  
    if plotExtra
        for ii = 1:numSep
            makeFigure;
            plotXvsY(dataX,indTraces(:,:,1,ii),xLabel,'turning response (deg/sec)');
            confAxis('fTitle',['trace #' num2str(ii)]);
        end
        
        for ii = 1:numSep
            makeFigure;
            plotXvsY(dataX,indTraces(:,:,2,ii),xLabel,'walking response (fold change)');
            confAxis('fTitle',['trace #' num2str(ii)]);
        end
    end
end