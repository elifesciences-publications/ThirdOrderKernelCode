function [flyResp,epochs,params,stim,flyIds,dataRate] = ReadEphysData(dataPath,varargin)
    % for now just load the first data file. Make sue you don't give it
    % a folder that contains multiple runs
    blacklist = [];
    manualSync = 0;
    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end

    [rawResp,rawStim,params,finalPaths] = LoadData(dataPath,blacklist);

    [respDPI, stim, rawEpochs, mouseReads] = GetTimeSeries(rawResp,rawStim);

    if rawEpochs(end-20,1) == 0 % Postpended with Emilio's 0 epochs
        stim = stim(1:end-21,:,:);
        rawStim = rawStim(1:end-21,:,:);
        rawEpochs = rawEpochs(1:end-21,:);
        mouseReads = mouseReads(1:end-21,:);
        respDPI = respDPI(1:end-21,:,:);
    end

    abfFileInfo = dir(fullfile(finalPaths.folders{1},'*.abf'));
    abfFile = fullfile(finalPaths.folders{1},abfFileInfo.name);
    [rawEphysData,sampleLengthMicroseconds,abfStruct] = abfload(abfFile);
    rawData = rawEphysData(:,1);
    photoDiodeData = rawEphysData(:,2);
    dataRate = 1/(sampleLengthMicroseconds/1e6);
    frameStartTimes = rawStim(:,1);
    [flyRespSingle,epochs] = alignNeuralDataAndEpochs(rawData,photoDiodeData,dataRate,frameStartTimes,rawEpochs(:,1),manualSync);
%         hpFilt = designfilt('highpassfir','StopbandFrequency',0.1/(dataRate/2), ...
%                             'PassbandFrequency',1/(dataRate/2),'PassbandRipple',0.5, ...
%                             'StopbandAttenuation',65,'DesignMethod','kaiserwin');
%         flyRespFiltered = filter(hpFilt,flyRespSingle);
    flyResp = cell(1,1);
    flyResp{1} = flyRespSingle;%{repmat(flyRespSingle,1,1,2)};
    epochs = {epochs};
    
    ff = 1;
    runDetailsPath = fullfile(finalPaths.folders{1},'runDetails.mat');
    if exist(runDetailsPath,'file') == 2
        runDetails{ff} = load(fullfile(finalPaths.folders{1},'runDetails.mat'));
    else
        flyId = AssignFlyId();
        runDetails{ff}.flyId = flyId;
        save(runDetailsPath,'flyId');
    end
    flyIds = GetFlyIds(runDetails);
end