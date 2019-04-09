Z.params.force_new_ROIs = false;
Z.params.force_new_ROIs = false; 
Z.params.channelDesired = 1;
Z.params.runPDAnalysis = 'Yes';
Z.params.filterTraces = 1;
Z.params.align = true;
Z.params.linescan = false;
Z.params.edgeTypes = { 'Left Light Edge','Left Dark Edge','Right Light Edge', ...
        'Right Dark Edge' };   % used in edgeTypeRois
Z.params.epochsForSelectivity = {'Square Right', 'Square Left'; 'Square Left' 'Square Right'}; % default to right selective ROIs, used in E's t-test script
Z.params.combinationMethod = 'any';
% Z.params.differentialEpochs = {'Square Right', 'Square Left'};
Z.params.low_frequency = .01;
Z.params.high_frequency = 1000;
Z.params.baseline_lowpass_filter_frequency = .01;
Z.params.ROImethod = 'differentialWatershed';
Z.params.stimulusDataCols = [];
% Z.params.epochForKernel = 1;
Z.params.saveROIdata = true; % A little complicated. This defaults to save ROI data
                             % IF IT HAS NOT ALREADY BEEN SAVED. If it is saved, this will be
                             % set to false. You can override it with
                             % force_new_ROIs
% Z.params.diffEpAnalysis = false;
Z.params.alignOnly = false;
Z.params.grabRoi = true;
Z.params.mapsToRoiData = true;
Z.params.filterRoiTraces = true;
Z.params.alignOnly = false;
Z.params.controlFigs = false;
Z.params.stashROIdata = true;
Z.params.roiStashName = [];
Z.params.loadDifferentROIs = false;
Z.params.controlFigs = false;
Z.params.viewROIs = false;
Z.params.cullRoiTraces = true;
Z.params.oldestAllowedRoiFile = '01_01_13';
Z.params.minRoiSize = 20;