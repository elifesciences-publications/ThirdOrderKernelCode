% WriteUp_T4T5_Expression_Figure;
function WriteUp_T4T5_Expression_Figure()
filepath =  GetPathsFromDatabase('T4T5', 'multiBarFlicker_20_repBlock_60hz', 'GC6f', '','','date','>','2016-06-16','date','<','2016-06-17'); % do not have 06_19
filepath = filepath{3};
flyEye = GetEyeFromDatabase(filepath);
clear Z
Z = twoPhotonMaster('filename',filepath,...
    'ROImethod','ICA_DFOVERF','edgeTypes',{'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge'},'roiStashName','roiCorrNew','squareCounts',0,'roiMinPixNum',10,'force_new_ROIs',false);
roiSelected = RoiSelectionBySize(Z.ROI.roiMasks(:,:,1:end-1),5);
FigPlot1(Z,flyEye,'roiSelectionFlag',true,'roiSelected',roiSelected,'fig1_b_Flag',false,'fig1_c_Flag',true,'fig1_trace_Flag',true, 'fig1_DSIESI_flag',true,'saveFigFlag',false,'metaAnalysis_flag',false);
end