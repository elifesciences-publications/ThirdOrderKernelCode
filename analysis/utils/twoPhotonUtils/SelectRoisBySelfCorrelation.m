function selectedRois = SelectRoisBySelfCorrelation(timeByRois,roiMask,epochStartTimes,epochDurations,correlationPercentThreshold)
    numRois = size(timeByRois,2);
    numEpochs = size(epochStartTimes,1);
    roiCorrValues = zeros(1,numRois);
    colorShift = 0.01;
    corrMap = zeros(size(roiMask))-colorShift;
    numEpochsIncluded = 0;

    for ee = 1:numEpochs
        if (length(epochStartTimes{ee}) > 1)
            timeTraces = GetTimeTracesFromRoiMat(timeByRois,epochStartTimes,epochDurations,ee);
            averagedTrials = mean(timeTraces,3);
            averagedTrialsAndTime = mean(averagedTrials,1);

            squaredDeviationFromAveragedTrials = sum(sum(bsxfun(@minus,timeTraces,averagedTrials).^2,1),3);
            squaredDeviationFromAveragedTrialsAndTime = sum(sum(bsxfun(@minus,timeTraces,averagedTrialsAndTime).^2,1),3);

            r2 = 1-squaredDeviationFromAveragedTrials./squaredDeviationFromAveragedTrialsAndTime;

            roiCorrValues = roiCorrValues + r2;

            numEpochsIncluded = numEpochsIncluded + 1;
        end
    end

    roiCorrValues = roiCorrValues/numEpochsIncluded;

    roiSelectivityThreshold = prctile(roiCorrValues,correlationPercentThreshold);
    selectedRois = roiCorrValues > roiSelectivityThreshold;

    %% plot the correlation values for each ROI
    for rr = 1:numRois
        corrMap(roiMask==rr)=roiCorrValues(rr);
    end

    MakeFigure;
    imagesc(corrMap);
    ConfAxis('fTitle','correlation map');
    caxis([-colorShift+0 1]);
    colorbar;
    colormap([0 0 0; flipud(cbrewer('div','RdBu',100))]);
end