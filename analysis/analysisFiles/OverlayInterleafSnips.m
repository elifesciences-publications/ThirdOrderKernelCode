function D = OverlayInterleafSnips(varargin)
    %reads in the data from the interleaf epoch and sums
    %them together then plots the average response to each epoch
    
    %% deal with inputs
    %initialize vars these can be changed through varargin with the form
    %func(...'varName','value')
    limits = [30 120];
    suppressOut = 0;
    figLeg = {};
    numBins = 49;
    plotHM = 0;
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
    analysis.GS = grabInterleafSnips(analysis.OD,D.data.params,limits);
    analysis.CF = combineFlies(analysis.GS.combSnips);
    
    D.analysis = analysis;
    
    %% plot results
    dTheta = cell(length(analysis.CF.combFly),1);
    dThetaErr = cell(length(analysis.CF.combFly),1);
    mmWalked = cell(length(analysis.CF.combFly),1);
    mmWalkedErr = cell(length(analysis.CF.combFly),1);
    
    for ii = 1:length(dTheta)
        dTheta{ii} = analysis.CF.combFly{ii}(:,:,1);
        dThetaErr{ii} = analysis.CF.semFly{ii}(:,:,1);
        mmWalked{ii} = analysis.CF.combFly{ii}(:,:,2);
        mmWalkedErr{ii} = analysis.CF.semFly{ii}(:,:,2);
    end
    
    %plot theta vs timecourse of average response
    D.figures{end+1}.folder = 'RespAnalysis';
    [D.figures{end}.handle,D.figures{end}.title] = plotData('plotXvsCellY',suppressOut,(1:size(analysis.CF.combFly{1},1))/60,dTheta,'time (sec)','response (degrees/sec) + SEM','figLeg',figLeg,'cellError',dThetaErr);
    
    %plot theta vs timecourse of average response
    D.figures{end+1}.folder = 'RespAnalysis';
    [D.figures{end}.handle,D.figures{end}.title] = plotData('plotXvsCellY',suppressOut,(1:size(analysis.CF.combFly{1},1))/60,mmWalked,'time (sec)','response (mm/sec) + SEM','figLeg',figLeg,'cellError',mmWalkedErr);
    
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

            D.figures{end+1}.folder = 'RespAnalysis';
            [D.figures{end}.handle,D.figures{end}.title] = plotData('plotHeat',suppressOut,log(histRespAve),'time (sec)','resp (deg/sec)','yTick',yTick,'yTickL',yTickL);
        end
    end
end