function D = OverlayEpochSnipsAndDoubles(varargin)
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
    analysis.GS = grabSnips(analysis.OD,D.data.params,varargin{:},'limits',[30 120]);
    analysis.CD = combineDuplicates(analysis.GS.comb);
    analysis.CI3 = combineInput(analysis.CD.comb,3);
    % combine read data
    analysis.CI_R = mean(analysis.GS.read,3);
    
    D.analysis = analysis;
    
    x = (1:analysis.CI3.numData)';
    
    makeFigure;
    plotXvsY(x,analysis.CI3.turn,xLabel,yLabel,'error',analysis.CI3.semTurn);
    
    makeFigure;
    plotXvsY(x,analysis.CI3.walk,xLabel,yLabel,'error',analysis.CI3.semWalk);
    
    makeFigure;
    plotXvsY(x,analysis.CI_R,xLabel,'average reads');
    
    if plotHM
        %plot each trial from an epoch for every fly
        epochTrials = cell(analysis.GS.numEpochs,1);
        for ii = 1:analysis.GS.numEpochs
            epochTrials{ii} = cell2mat(analysis.GS.snipMat(ii,:));
            epochTrials{ii} = epochTrials{ii}(:,:,1)';
            histRespAve = zeros(numBins,size(epochTrials{ii},2));

            maxResp = max(max(epochTrials{ii}))/2;
            minResp = min(min(epochTrials{ii}))/2;
            limit = max([abs(maxResp),abs(minResp)])/4;
            histEdge = linspace(minResp,maxResp,numBins);

            %for each row pull out a hist of responses
            for jj = 1:size(epochTrials{ii},2)
                histRespAve(:,jj) = histc(epochTrials{ii}(:,jj),histEdge);
            end

            yTick = linspace(1,size(histEdge,2),20);
            yTickL = linspace(minResp,maxResp,20);
            yTickL = cellfun(@num2str, num2cell(yTickL), 'UniformOutput', false);

            makeFigure;
            plotHeat(log(histRespAve),'time (sec)','resp (deg/sec)','yTick',yTick,'yTickL',yTickL);
            confAxis('tickY',yTick,'tickLabelY',yTickL);
        end
    end
end