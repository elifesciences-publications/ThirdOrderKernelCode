%% Receptive field mapping
% close all;
roiSizeIcaMin = 20;
plotIndividualROIs = false;
plotIndividualFlies = true;
%epochsForSelectivity = {'Off', 'On'; 'On', 'Off'};
epochsForSelectivity = {'Off', 'On'};
%epochsForSelectivity = {};
polarityPosCheck = 'On';
calculateModelMatrix = false;
 roiSelectionFile = 'RoiSelectionSizeAndResp';
%roiSelectionFile = 'SelectFullFieldResponsiveRois';
epochRespPercentThreshold = 90;
%roiSelectionFile = '';
plotResponsesOnly = true;
plottingFunction = 'PlotSquareWaveEdgesROISummary'

dataPathsBarPair = GetPathsFromDatabase('Tm1', {'barPair_10dBars_singleOnly_8p_modified_longer'}, 'iGluSnFR', '', '', 'date', '>', '2016-05-15');
RunAnalysis('dataPath', dataPathsBarPair(:), 'analysisFile', {'BarPairNewCompiledRoiAnalysis'}, 'figureName', 'Bar Pair Tm1', 'dataX', (1:6)/60, 'progRegSplit', true, 'plotIndividualROIs', plotIndividualROIs, 'plotIndividualFlies', plotIndividualFlies, 'roiExtractionFile','watershedRoiExtraction_v2','epochsForSelectivity', epochsForSelectivity, 'snipShift', -500, 'duration', 2000, 'forceRois', 0, 'roiSelectionFile', roiSelectionFile, 'plottingFunction', plottingFunction, 'figurePlotName', 'Unnormalized', 'polarityPosCheck', polarityPosCheck, 'calculateModelMatrix', calculateModelMatrix, 'plotResponsesOnly', plotResponsesOnly, 'roiSizeIcaMin', roiSizeIcaMin, 'ttSnipShift', -500, 'ttDuration', 2000, 'numIgnore', 0, 'combOpp', 0, 'ignoreNeighboringBars', true);

dataPathsBarPair = GetPathsFromDatabase('Tm1', {'barPair_5dBars_singleOnly_8p_longer'}, 'iGluSnFR', '', '', 'date', '>', '2016-05-15');
RunAnalysis('dataPath', dataPathsBarPair([1 3]), 'analysisFile', {'BarPairNewCompiledRoiAnalysis'}, 'figureName', 'Bar Pair Tm1', 'dataX', (1:6)/60, 'progRegSplit', true, 'plotIndividualROIs', plotIndividualROIs, 'plotIndividualFlies', plotIndividualFlies, 'roiExtractionFile','watershedRoiExtraction_v2','epochsForSelectivity', epochsForSelectivity, 'snipShift', -500, 'duration', 2000, 'forceRois', 0, 'roiSelectionFile', roiSelectionFile, 'plottingFunction', plottingFunction, 'figurePlotName', 'Unnormalized', 'polarityPosCheck', polarityPosCheck, 'calculateModelMatrix', calculateModelMatrix, 'plotResponsesOnly', plotResponsesOnly, 'roiSizeIcaMin', roiSizeIcaMin, 'ttSnipShift', -500, 'ttDuration', 2000, 'numIgnore', 0, 'combOpp', 0, 'ignoreNeighboringBars', true);


dataPathsBarPair = GetPathsFromDatabase('Tm1', {'barPair_5dBars_20p_longer'}, 'iGluSnFR', '', '', 'date', '>', '2016-05-15');
RunAnalysis('dataPath', dataPathsBarPair([1:2 4:end]), 'analysisFile', {'BarPairNewCompiledRoiAnalysis'}, 'figureName', 'Bar Pair Tm1', 'dataX', (1:6)/60, 'progRegSplit', true, 'plotIndividualROIs', plotIndividualROIs, 'plotIndividualFlies', plotIndividualFlies, 'roiExtractionFile','watershedRoiExtraction_v2','epochsForSelectivity', epochsForSelectivity, 'snipShift', -500, 'duration', 2000, 'forceRois', 0, 'roiSelectionFile', roiSelectionFile, 'plottingFunction', plottingFunction, 'figurePlotName', 'Unnormalized', 'polarityPosCheck', polarityPosCheck, 'calculateModelMatrix', calculateModelMatrix, 'plotResponsesOnly', plotResponsesOnly, 'roiSizeIcaMin', roiSizeIcaMin, 'ttSnipShift', -500, 'ttDuration', 2000, 'numIgnore', 0, 'combOpp', 0, 'ignoreNeighboringBars', true);

%dataPathsBarPair = GetPathsFromDatabase('Tm1', {'fullFieldFlash_50-100-50-0_1s'}, 'iGluSnFR', '', '', 'date', '>', '2016-05-15');
% The first three have the wrong probe, and there is as of yet no way to
% filter by the probe in the database (forthcoooming)
RunAnalysis('dataPath', dataPathsBarPair([7:end]), 'analysisFile', {'BarPairNewCompiledRoiAnalysis_catherine'}, 'figureName', 'Bar Pair Tm1', 'dataX', (1:6)/60, 'progRegSplit', true, 'plotIndividualROIs', plotIndividualROIs, 'plotIndividualFlies', plotIndividualFlies, 'roiExtractionFile','watershedRoiExtraction_v2','epochsForSelectivity', epochsForSelectivity, 'snipShift', -500, 'duration', 2000, 'forceRois', 0, 'roiSelectionFile', roiSelectionFile, 'plottingFunction', plottingFunction, 'figurePlotName', 'Unnormalized', 'polarityPosCheck', polarityPosCheck, 'calculateModelMatrix', calculateModelMatrix, 'plotResponsesOnly', plotResponsesOnly, 'roiSizeIcaMin', roiSizeIcaMin, 'ttSnipShift', -500, 'ttDuration', 2000, 'numIgnore', 0, 'combOpp', 0);
RunAnalysis('dataPath', dataPathsBarPair([1]), 'analysisFile', {'BarPairNewCompiledRoiAnalysis'}, 'figureName', 'Bar Pair Tm1', 'dataX', (1:6)/60, 'progRegSplit', true, 'plotIndividualROIs', true, 'plotIndividualFlies', plotIndividualFlies, 'roiExtractionFile','watershedRoiExtraction_v2','epochsForSelectivity', epochsForSelectivity, 'snipShift', -500, 'duration', 2000, 'forceRois', 0, 'roiSelectionFile', roiSelectionFile, 'plottingFunction', plottingFunction, 'figurePlotName', 'Unnormalized', 'polarityPosCheck', polarityPosCheck, 'calculateModelMatrix', calculateModelMatrix, 'plotResponsesOnly', plotResponsesOnly, 'roiSizeIcaMin', roiSizeIcaMin, 'ttSnipShift', -500, 'ttDuration', 2000, 'numIgnore', 0, 'combOpp', 0, 'ignoreNeighboringBars', true);

 RunAnalysis('dataPath', dataPathsBarPair([1:2 4:end]), 'analysisFile', {'PlotTimeTraces'}, 'figureName', 'Bar Pair Tm1', 'dataX', (1:6)/60, 'progRegSplit', true, 'plotIndividualROIs', plotIndividualROIs, 'plotIndividualFlies', plotIndividualFlies, 'roiExtractionFile','watershedRoiExtraction_v2','epochsForSelectivity', epochsForSelectivity, 'snipShift', -500, 'duration', 2000, 'forceRois', false, 'roiSelectionFile', roiSelectionFile, 'plottingFunction', plottingFunction, 'figurePlotName', 'Unnormalized', 'polarityPosCheck', polarityPosCheck, 'calculateModelMatrix', calculateModelMatrix, 'plotResponsesOnly', plotResponsesOnly, 'roiSizeIcaMin', roiSizeIcaMin, 'ttSnipShift', -500, 'ttDuration', 4500, 'numIgnore', 0, 'combOpp', 0, 'duration', 1000, 'PlotInd', 1, 'numEpochsToPlot', 2, 'plotTime', [0 1000 2000 3000 4000]);
%RunAnalysis('dataPath', dataPathsBarPair(1), 'analysisFile', {'PlotTwoPhotonTimeTraces', 'PlotRoisOnMask'}, 'figureName', 'Bar Pair Tm1', 'dataX', [], 'progRegSplit', true, 'plotIndividualROIs', plotIndividualROIs, 'plotIndividualFlies', plotIndividualFlies, 'roiExtractionFile','watershedRoiExtraction_v2','epochsForSelectivity', epochsForSelectivity, 'snipShift', -500, 'duration', 2000, 'forceRois', true, 'roiSelectionFile', roiSelectionFile, 'plottingFunction', plottingFunction, 'figurePlotName', 'Unnormalized', 'polarityPosCheck', polarityPosCheck, 'calculateModelMatrix', calculateModelMatrix, 'plotResponsesOnly', plotResponsesOnly, 'roiSizeIcaMin', roiSizeIcaMin, 'ttSnipShift', -500, 'ttDuration', 4000, 'numIgnore', 2, 'combOpp', 0, 'duration', 1000, 'PlotInd', 1);
%epochSelIndThresh = 0.4;
%overallCorrelationThresh = 0.4;
%corrToThirdThresh = 0.4;
%RunAnalysis('dataPath', dataPathsBarPair, 'analysisFile', {'BarPairNewCompiledRoiAnalysis', 'PlotRoisOnMask'}, 'figureName', 'Bar Pair Tm1', 'dataX', (1:6)/60, 'progRegSplit', true, 'plotIndividualROIs', plotIndividualROIs, 'plotIndividualFlies', plotIndividualFlies, 'roiExtractionFile','watershedRoiExtraction_v2','epochsForSelectivity', epochsForSelectivity, 'snipShift', -500, 'duration', 2000, 'forceRois', false, 'roiSelectionFile', roiSelectionFile, 'plottingFunction', plottingFunction, 'figurePlotName', 'Unnormalized', 'polarityPosCheck', polarityPosCheck, 'calculateModelMatrix', calculateModelMatrix, 'plotResponsesOnly', plotResponsesOnly, 'roiSizeIcaMin', roiSizeIcaMin, 'epochRespPercentThreshold', 50, 'epochSelIndThresh', 0.3, 'overallCorrelationThresh', 0.3, 'corrToThirdThresh', 0.3);