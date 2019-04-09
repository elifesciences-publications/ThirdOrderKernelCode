function D = ComputeFilter(varargin)
    %reads in the data and cuts out snips around the given epochs and sums
    %them together then plots the average response to each epoch
    
    %% deal with inputs
    %initialize vars these can be changed through varargin with the form
    %func(...'varName','value')
    filterLength = 300;
    stimCol = 2;
    turnOrWalk = 1;
    eta = 0.01;
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
    numEpochs = size(D.data.params,2);
    
    respX = cell(numEpochs,1);
    vel = cell(numEpochs,1);
    filterCalc = cell(numEpochs,1);
    predFromFilter = cell(numEpochs,1);
    corrToPred = cell(numEpochs,1);
    
    for jj = 1:numEpochs
        respX{jj} = analysis.OD.XY(((jj-1)/numEpochs*analysis.OD.numData)+1:(jj/numEpochs*analysis.OD.numData),:,turnOrWalk);
        vel{jj} = analysis.OD.stim(((jj-1)/numEpochs*analysis.OD.numData)+1:(jj/numEpochs*analysis.OD.numData),stimCol,1);
        
        filterCalc{jj} = zeros(filterLength,analysis.OD.numFlies);
        predFromFilter{jj} = zeros(analysis.OD.numData/numEpochs,analysis.OD.numFlies);
        corrToPred{jj} = zeros(1,analysis.OD.numFlies);

        for ii = 1:analysis.OD.numFlies
            [filterCalc{jj}(:,ii),corrToPred{jj}(1,ii),predFromFilter{jj}(:,ii)] = back_out_1dfilter_new(vel{jj},respX{jj}(:,ii),filterLength,eta);
        end
        
        analysis.filterAve{jj} = mean(filterCalc{jj},2);
        analysis.filterSTD{jj} = std(filterCalc{jj},0,2);
        analysis.filterSEM{jj} = analysis.filterSTD{jj}/sqrt(analysis.OD.numFlies);
    end
    
    analysis.respX = respX;
    analysis.vel = vel;
    analysis.filterCalc = filterCalc;
    analysis.predFromFilter = predFromFilter;
    analysis.corrToPred = corrToPred;
    
    D.analysis = analysis;
    
    %plot stimulus
    %D.figures{end+1}.folder = 'RespAnalysis';
    %[D.figures{end}.handle,D.figures{end}.title] = plotData('plotXvsY',suppressOut,(1:analysis.CF.numData)/60,analysis.CF.combFly{1}(:,:,1),'time (sec)','stimulus');
    
    %plot prediction
    %plotData('plotXvsY',[suppressOut 1],(1:size(analysis.BF.pred,2))/60,analysis.BF.pred,'time (sec)','prediction(green) vs resp(blue) deg/sec','color',[0 1 0]);
    
    %plot filter
    for jj = 1:numEpochs
        makeFigure;
        plotXvsY((1:filterLength)'/60,analysis.filterAve{jj},'time (sec)','filter','error',analysis.filterSEM{jj});
    end
    
end