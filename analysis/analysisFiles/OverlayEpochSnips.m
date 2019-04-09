function D = OverlayEpochSnips(varargin)
    %reads in the data and cuts out snips around the given epochs and sums
    %them together then plots the average response to each epoch
    
    %% deal with inputs
    %initialize vars these can be changed through varargin with the form
    %func(...'varName','value')
    limits = [-30 120];
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
    analysis.GS = grabSnips(analysis.OD,D.data.params,'limits',limits,varargin{:});
    analysis.CI3 = combineInput(analysis.GS.comb,3);
    % combine read data
    analysis.CI3_R = mean(analysis.GS.read,3);
    
    analysis.GS_A = grabSnips(analysis.OD,D.data.params,'limits',limits,'absTurn',1,varargin{:});
    analysis.CI3_A = combineInput(analysis.GS_A.comb,3);
    
    D.analysis = analysis;
    x = (1:analysis.CI3.numData)';
    
    makeFigure;
    plotXvsY(x,analysis.CI3.turn,xLabel,yLabel,'error',analysis.CI3.semTurn);
    
    makeFigure;
    plotXvsY(x,analysis.CI3_A.turn,xLabel,yLabel,'error',analysis.CI3.semTurn);
    
    makeFigure;
    plotXvsY(x,analysis.CI3.walk,xLabel,yLabel,'error',analysis.CI3.semWalk);
    
    makeFigure;
    plotXvsY(x,analysis.CI3_R,xLabel,'num reads');
    
    if plotHM
        %plot each trial from an epoch for every fly
        epochTrials = cell(analysis.GS.numEpochs,1);
        foldFromMaxTurn = 1;
        foldFromMaxWalk = 1;
        
        for ii = 1:analysis.GS.numEpochs
            % grab all trials from all flies into a cell array. each cell
            % is a different epoch
            epochTrials{ii} = cell2mat(analysis.GS.snipMat(ii,:));
            epochTrials{ii} = permute(epochTrials{ii},[2 1 3]);
            sizeX = analysis.GS.numData;
            % heat map of responses
            histRespAve = zeros(numBins,size(epochTrials{ii},2),2);

            % create a histogram of fly responses at every point of time
            % within the snip
            maxResp = max(max(epochTrials{ii}))/foldFromMaxTurn;
            minResp = min(min(epochTrials{ii}))/foldFromMaxWalk;
            limit = max([abs(maxResp),abs(minResp)]);
            histEdgeTurn = linspace(minResp(1),maxResp(1),numBins);
            histEdgeWalk = linspace(minResp(2),maxResp(2),numBins);

            %for each row pull out a hist of responses
            for jj = 1:sizeX
                histRespAve(:,jj,1) = histc(epochTrials{ii}(:,jj,1),histEdgeTurn);
                histRespAve(:,jj,2) = histc(epochTrials{ii}(:,jj,2),histEdgeWalk);
            end

            yTick = linspace(1,numBins,20);
%             yTickL = linspace(minResp(1),maxResp(1),20);
%             makeFigure;
%             imagesc(1:sizeX,yTick,log(histRespAve(:,:,1)))
%             xlabel('time (sec)')
%             ylabel('fly response (deg/sec)')
%             confAxis('tickY',yTick,'tickLabelY',yTickL,'fTitle',['epoch number ' num2str(ii)]);
% 
%             
            yTickL = linspace(minResp(2),maxResp(2),20);
            makeFigure;
            imagesc(1:sizeX,yTick(end:-1:1),log(histRespAve(:,:,2)))
            xlabel('time (sec)')
            ylabel('fly response (fold chnage)')
            confAxis('tickY',yTick,'tickLabelY',yTickL(end:-1:1),'fTitle',['epoch number ' num2str(ii)]);
        end
    end
end