function [flyResp,epochs,params,stim,flyIds,numTotalFlies] = ReadBehavioralData(dataFolders,varargin)
    blacklist = [];
    removeFlies = [];
    removeNonBehaving = 1;
    dataFromRig = [];
    rigSize = 5;

    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end

    % get data from file in format [time, [dx dy], files]
    [rawResp,rawStim,params,finalPaths,runDetails] = LoadData(dataFolders,blacklist,dataFromRig);
    % reorder data into [time, flies, [dy dy]]
    [respDPI, stimAll, epochsAll, mouseReads] = GetTimeSeries(rawResp,rawStim);
    % rename this, convert from dpi to deg/sec and mm/sec
    flyRespAll = ConvertMouseFromDPI(respDPI,mouseReads);

    % get flyIds
    singleFlyIds = GetFlyIds(runDetails);

    flyIds = RepFlyIds(singleFlyIds,rigSize);

    % remove nonbehaving/dead flies
    % get list of flies that behave
    if(removeNonBehaving)
        selectedFlies = GetResponsiveFlies(flyRespAll,epochsAll);
    else
        selectedFlies = true(1,size(flyRespAll,2));
    end 

    numTotalFlies = size(flyRespAll,2);
    
    selectFlies = ones(size(selectedFlies));
    selectFlies(removeFlies) = 0;

    selectedFlies = selectedFlies & selectFlies;

    if(~any(selectedFlies))
        error('No flies selected / no flies behaved');
    end

    % update resp matrix with behaving flies
    flyRespSelected = flyRespAll(:,selectedFlies,:);
    
    flyIds = flyIds(selectedFlies);

    % update time/fly epoch matrix to only include behaving flies
    epochsSelected = epochsAll(:,selectedFlies);

    % update stim matrix with behaving flies
    stimSelected = stimAll(:,:,selectedFlies);

    numFlies = size(flyRespSelected,2);

    flyResp = cell(1,numFlies);
    epochs = cell(1,numFlies);
    stim = cell(1,numFlies);

    for ff = 1:numFlies
        flyResp{ff} = flyRespSelected(:,ff,:);
        epochs{ff} = epochsSelected(:,ff);
        stim{ff} = stimSelected(:,:,ff);
    end
end