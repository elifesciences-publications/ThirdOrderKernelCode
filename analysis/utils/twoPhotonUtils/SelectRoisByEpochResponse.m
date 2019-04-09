function selectedRois = SelectRoisByEpochResponse(timeByRois,roiMask,epochStartTimes,epochDurations,epochsForSelectivity,params,percentMostSelective)
    %% read in the epoch names and turn them into epoch indicies
    selectedEpochs = ConvertEpochNameToIndex(params,epochsForSelectivity);
    colorShift = 0.001;
    
    if ~iscell(epochsForSelectivity)
        epochsForSelectivity = num2cell(epochsForSelectivity);
    end

    %% extract responses to the chosen epochs and average over trials
    epochRespA = mean(GetResponsesFromRoiMat(timeByRois,epochStartTimes,epochDurations,selectedEpochs(1)));
    epochRespB = mean(GetResponsesFromRoiMat(timeByRois,epochStartTimes,epochDurations,selectedEpochs(2)));

    esi = epochRespA-epochRespB;

    selectivityThreshold = prctile(esi,percentMostSelective);
    selectedRois = esi>selectivityThreshold;

    %% some useful plotting
    selectivityMap = zeros(size(roiMask))-max(esi)-colorShift;
    for rr = 1:size(timeByRois,2)
        selectivityMap(roiMask==rr)=esi(rr);
    end
    
    MakeFigure;
    imagesc(selectivityMap);
    ConfAxis('fTitle',[epochsForSelectivity{1} ' vs ' epochsForSelectivity{2} ' epoch selectivity index']);
    colorbar;
    caxis([-max(max(selectivityMap)) max(max(selectivityMap))]);
    colormap([0 0 0; flipud(cbrewer('div','RdBu',100))]);
end