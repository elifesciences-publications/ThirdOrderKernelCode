function meta = MetaAnalysis(D,varargin)
    %reads in data and performs analysis not directly related to the
    %response, but checking for inconsistancies among statistics in case
    %there is something off about a particular test
    
    %% this is the world's dirtiest file and should be cleaned up at some
    %  but I'm too lazy to do it. -MSC
    
    %% deal with inputs
    %initialize vars these can be changed through varargin with the form
    %func(...'varName','value')
    limits = zeros(2,1);
    suppressFourier = 1;
    aveSize = 60*60; %average over a minute
    numBins = 199;
    
    meta.figures = cell(0,1);
    
    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    %% perform analysis and plot
    %grab average response on a rig
    meta.OD = organizeData(D,'meanSubtract',0,'removeOutliers',0,'normMouseRead',0,'normWalk',0);
    meta.CT = combineTrace(meta.OD.XY,1);
    meta.CR = combineRigs(meta.CT.comb,meta.OD.rig);
    
    %numTrials is a matrix (epochs,flies) containing the number of trials each fly had
    %at that cell's epoch. average together flies to see how many epochs
    %each fly saw
    meta.GS = grabSnips(meta.OD,D.data.params,limits);
    
    % combine read data
    meta.CI_R = mean(meta.GS.read,3);
    
    makeFigure;
    plotXvsY((1:meta.GS.numData)',meta.CI_R,'frames','average reads');
    
    if meta.GS.numEpochs > 1
        meta.CT2 = combineTrace(meta.GS.numTrials,2);
        
        %combine the responses for each fly to a given epoch and use it to
        %calculate the autocorrelation
        meta.CI3 = combineInput(meta.GS.comb,3);
        meta.CA = calcAutoCorr(meta.CI3.comb);
    
    end
    
    %calculate the standard deviation over a block of time for the entire
    %trace
    meta.CS = calcSTD(meta.OD.XY,aveSize);
    
    
    %create histogram of the average response to each trial of a
    %stimulus.
    %first get the sum response at each individual trial, then put it in a
    %giant matrix where the rows are trials from every fly and the columns
    %are epochs.
    trialRespAve = cell(meta.GS.numEpochs,1);
    histRespAve = zeros(numBins,meta.GS.numEpochs);
    absHistRespAve = zeros(numBins,meta.GS.numEpochs);
    for ii = 1:meta.GS.numEpochs
        %returns a cell array of each flies average response to each trial
        %of this epoch (ii).
        trialResp = combineResponses(meta.GS.snipMat(ii,:)','mean');
        %the averages for each trial are row vectors. transpose the cells
        %holding them so that when you transform the cell array into a
        %matrix you get one giant row vector which can then be transposed
        %to a column vector. Faster than transposing individual cell
        %contents first
        trialResp.combResp = cell2mat(trialResp.combResp');
        trialResp.combResp = permute(trialResp.combResp,[2 1 3]);
        %make this cell a column vector of every average response to every
        %trial in this epoch
        trialRespAve{ii} = trialResp.combResp;
        trialRespAve{ii} = trialRespAve{ii}(:,:,1);
    end
    %find max and min
    maxResp = max(cellfun(@max,trialRespAve));
    minResp = min(cellfun(@min,trialRespAve));
    limit = max([abs(maxResp),abs(minResp)])/2;
    histEdge = linspace(-limit,limit,numBins);
    
    yTick = linspace(1,size(histEdge,2),20);
    yTickL = linspace(-limit,limit,20);
    yTickL = cellfun(@num2str, num2cell(yTickL), 'UniformOutput', false);
    
    for ii = 1:meta.GS.numEpochs
        histRespAve(:,ii) = histc(trialRespAve{ii},histEdge);
        absHistRespAve(:,ii) = histc(abs(trialRespAve{ii}),histEdge);
    end
    
    % plot histogram of turn and walk speeds
    
    %get rid of of the middle values because they're too big? not a problem
    %when looking at the log of this hist.
    histRespAve(ceil(numBins/2),:) = 0;
    absHistRespAve(ceil(numBins/2),:) = 0;
    
    %% plot data
    if meta.GS.numEpochs > 1
        makeFigure;
        plotHeat(log(absHistRespAve),'Epoch#','abs(Response) (degrees/sec)');
        confAxis('tickY',yTick,'tickLabelY',yTickL);
        
        %plot heat map of all trial sums for each epoch
        %figure;
        makeFigure;
        plotHeat(log(histRespAve),'Epoch#','Response (degrees/sec)');
        confAxis('tickY',yTick,'tickLabelY',yTickL);
        % plot autocorrelation for each epoch snip
        autoLeg = arrayfun(@num2str,1:meta.CA.numEpochs,'unif',0);
        
        makeFigure;
        plotXvsY((1:meta.CA.numData)',meta.CA.aCorr(:,:,:,1),'time (sec)','autocorrelation','figLeg',autoLeg);

        %% plot ave num trials for each epoch
        makeFigure;
        plotXvsY(1:size(meta.CT2.comb,1),meta.CT2.comb,'epoch #','average num trials + SEM','graphType','bar','error',meta.CT2.std);
    end
    
    %% plot standard deviation as a function of time for all flies
    makeFigure;
    stdLeg = arrayfun(@num2str,1:meta.CS.numFlies,'unif',0);
    plotXvsY((1:meta.CS.numData)'/60,meta.CS.stdTrace(:,:,1),'time (sec)','STD','figLeg',stdLeg);
    
    %% plot hist of frames that took longer than 18ms
    uniqueTime = meta.OD.time(:,1:5:end);
    frameTime = diff(uniqueTime(:));
    frameTime = frameTime(frameTime>.018);

    makeFigure;
    plotHist(frameTime,['frameTimes>18ms over ' num2str(size(uniqueTime,2)) ' run(s)'],'bins',51);

    %% plot fly average and std
    makeFigure;
    plotXvsY((1:meta.CT.numFlies)',meta.CT.comb(:,:,1)','fly #','average response (degrees/sec) + STD','graphType','bar','error',meta.CT.std(:,:,1)');
    
    %% plot fly average and std
    makeFigure;
    plotXvsY((1:meta.CT.numFlies)',meta.CT.comb(:,:,2)','fly #','average response (mm/sec) + STD','graphType','bar','error',meta.CT.std(:,:,2)');
    
    %% plot rig average and std
    makeFigure;
    plotXvsY((1:5)',meta.CR.comb(:,:,1)','rig #','average response (degrees/sec) + STD','graphType','bar','error',meta.CR.std(:,:,1)');
    
    makeFigure;
    plotXvsY((1:5)',meta.CR.comb(:,:,2)','rig #','average response (degrees/sec) + STD','graphType','bar','error',meta.CR.std(:,:,2)');
    
     %% plot the fourier transform for each fly
    if ~suppressFourier
        PS = cell(meta.OD.numFlies,1);

        Fs = 60;
        L = size(meta.OD.XY,1);
        NFFT = 2^nextpow2(L);
        f = Fs/2*linspace(0,1,NFFT/2+1);

        for ii = 1:meta.OD.numFlies
            PS{ii} = fft(meta.OD.XY(:,ii,2),NFFT)/L;
        end

        for ii = 1:size(PS,1)
            makeFigure;
            plotXvsY(f,2*abs(PS{ii}(1:NFFT/2+1)),['Fly#' num2str(ii) 'Frequency(Hz)'],'|Y(t)|');
        end

        makeFigure;
        plot(diff(meta.OD.time*1000));
        xlabel('frames')
        ylabel('duration of flip (ms)');
    end
end