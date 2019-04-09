function selectedRois = SelectRoisByEpochResponse_v2(timeByRois,roiMask,epochStartTimes,epochDurations,epochsForSelectivity,params,percentMostSelective)
    %% read in the epoch names and turn them into epoch indicies
    selectivityThreshold = percentMostSelective;
    selectedEpochs = ConvertEpochNameToIndex(params,epochsForSelectivity);
    colorShift = 0.001;
    
    if ~iscell(epochsForSelectivity)
        epochsForSelectivity = num2cell(epochsForSelectivity);
    end

    %% extract responses to the chosen epochs and average over trials
    epochRespA = nanmean(GetResponsesFromRoiMat(timeByRois,epochStartTimes,epochDurations,selectedEpochs(1)));
    epochRespB = nanmean(GetResponsesFromRoiMat(timeByRois,epochStartTimes,epochDurations,selectedEpochs(2)));
    minCBResp = min([epochRespA epochRespB]);
    esi = ((epochRespA-minCBResp) - (epochRespB - minCBResp))./(epochRespA -minCBResp + epochRespB - minCBResp)
    %esi = epochRespA-epochRespB;


    selectedRois = esi>selectivityThreshold;

    %% some useful plotting
    selectivityMap = zeros(size(roiMask))-max(esi)-colorShift;
    for rr = 1:size(timeByRois,2)
        selectivityMap(roiMask==rr)=esi(rr);
    end
    try
    MakeFigure;
    imagesc(selectivityMap);
    ConfAxis('fTitle',[epochsForSelectivity{1} ' vs ' epochsForSelectivity{2} ' epoch selectivity index']);
    colorbar;
    caxis([-max(max(selectivityMap)) max(max(selectivityMap))]);
    colormap([0 0 0; flipud(cbrewer('div','RdBu',100))]);
    catch
    end
end