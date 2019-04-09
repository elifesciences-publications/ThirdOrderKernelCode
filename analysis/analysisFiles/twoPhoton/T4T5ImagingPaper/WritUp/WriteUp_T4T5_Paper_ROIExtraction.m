%% ROI Extraction. using run analysis.
function WriteUp_T4T5_Paper_ROIExtraction(filepathAll, roiMethod_forRunAnalysis)
% filepathAllNonRep = GetPathsFromDatabase('T4T5', 'multiBarFlicker_20_60hz', 'GC6f', '','','date', '>', '2015-06-01');
% filepathAllRep = GetPathsFromDatabase('T4T5', 'multiBarFlicker_20_repBlock_60hz', 'GC6f', '','','date','<','2016-06-18');
% filepathAllRepNewest = GetPathsFromDatabase('T4T5', 'multiBarFlicker_20_repBlock_60hz', 'GC6f', '','','date','>=','2016-06-18','date','<','2016-06-19'); % 
% filepathAll = [filepathAllRep;filepathAllNonRep;filepathAllRepNewest];


nfile = length(filepathAll);
flyEyeAll = cell(nfile,1);
for ff = 1:1:nfile
    flyEyeAll{ff} = GetEyeFromDatabase(filepathAll{ff});
end

prefNullCombo = 'bothPos';
switch prefNullCombo
    case 'bothPos'
        labelXNum = ([0:6 12 14])/60*1000;
        roundLabel = round(labelXNum(1:end-1), 1);
        labelXCell = [strsplit(num2str(roundLabel)), '\infty'];
    case 'prefPosNullNeg'
        labelXNum = ([-12 -6:6 12 14])/60*1000;
        roundLabel = round(labelXNum(1:end-1), 1);
        labelXCell = [strsplit(num2str(roundLabel)), '\infty'];
end


plotNameAppend = ' plot higher thresh';
esiThreshCell = {0.3, 0.3, 0.4, 0.4};
epochsForSelection = {'~Left Light Edge', 'Left Dark Edge', 'Right Light Edge', 'Right Dark Edge';'~Right Light Edge', 'Right Dark Edge', 'Left Light Edge', 'Left Dark Edge';'~Left Dark Edge', 'Left Light Edge', 'Right Dark Edge', 'Right Light Edge';'~Right Dark Edge', 'Right Light Edge', 'Left Dark Edge', 'Left Light Edge'};
epochsForIdentification =  {'Square Left', 'Square Right', 'Square Up', 'Square Down', 'Left Light Edge', 'Left Dark Edge','Right Light Edge', 'Right Dark Edge'};
multibarAnalysis = RunAnalysis('dataPath', filepathAll, 'analysisFile', 'PlotTimeTraces', 'calcDFOverFByRoi', true, 'progRegSplit', true, 'prefNullCombo', prefNullCombo, 'esiThresh', esiThreshCell, 'roiExtractionFile',roiMethod_forRunAnalysis,'epochsForIdentification',epochsForIdentification,'epochsForSelectivity',  epochsForSelection, 'forceRois', false, 'roiSelectionFile', '', 'filterMovie', false, 'stimulusResponseAlignment', false);
end
