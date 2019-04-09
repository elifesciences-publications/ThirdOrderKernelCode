dataPathsLinescan3 = GetPathsFromDatabase('Mi1', 'alternatingContrastFullField_p2_p9_60Hz', 'ArcLD');

% 
% Fly 18 is dirty, not sure why
%36
%28
roiSelectionFile = '';
sizeMin = 0;
epochsForSelectivity = {'Off', 'On'};
for k = 28
    currentFly = dataPathsLinescan3(k);
    paramPath = fullfile(currentFly,'stimulusData','chosenparams.mat');
    paramsHere = load(paramPath{1});
    paramsHere = paramsHere.params;
    numEpochs = length(paramsHere);
    epochDurations = {paramsHere.duration};
    epochDurations = epochDurations{1};
    if numEpochs == 4 && epochDurations == 15
%         try
        Mi1analysis{k} = RunAnalysis('dataPath', currentFly, 'analysisFile', {'PlotTimeTraces'}, 'progRegSplit', false, 'roiExtractionFile','manualRoiExtraction_linescan','epochsForSelectivity', '', 'forceRois', 1, 'roiSelectionFile', '', 'ttDuration', 1000, 'ttSnipShift', 0, 'combOpp', 0, 'numIgnore', 0, 'linescan', 1, 'filterMovie', 0, 'noTrueInterleave', 0, 'roiSelectionFile', roiSelectionFile, 'epochsForSelectivity', epochsForSelectivity, 'sizeMin', 0,'backgroundSubtractMovie',0);
%         catch
%             continue;
%         end
    end
end

% allTraces = [];
% j = 1;
% for k = 24:length(Mi1analysis)
%     if ~isempty(Mi1analysis{k}) && ismember(k, [28, 29, 31, 32, 33, 34])
%         subplot(2, 3, j)
%         plot(linspace(0, 1, length(Mi1analysis{end}.analysis{1}.respMatPlot(:, 2))), Mi1analysis{k}.analysis{1}.respMatPlot(:, 2))
%         ax = gca;
%         ax.XTick = [0, 0.25, 0.5, 0.75];
%         ax.XTickLabel = {'Off', 'On', 'Off', 'On'};
%         ax.YTick = [];
%         allTraces = [allTraces; (Mi1analysis{k}.analysis{1}.respMatPlot(:, 2))'];
%         j = j+1;
%     end
% end
% figure;plot(mean(allTraces));