%% analyze the final result.
function WriteUp_T4T5_AnalyzeData(roiMethodType)
% roiMethodType = ['ICA_DFOVERF_T4T5_BT_EdgeCorrected_With2oNoisy'];
stimulusType = '5B';
roiData = getData_Juyue(stimulusType,roiMethodType);

roiData = roiAnalysis_ChangeFilterDirection(roiData,'method','corChangeAndCentered');
nRoi = length(roiData);
for rr = 1:1:nRoi
    roiData{rr} = roiAnalysis_OneRoi_SecondDt(roiData{rr},'normKernelFlag',false,'normRoiFlag',false);
end
for rr = 1:1:nRoi
    roiData{rr} = roiAnalysis_OneRoi_1oPred2oAndGlider(roiData{rr});
end
for rr = 1:1:length(roiData)
    roiData{rr} = roiAnalysis_OneRoi_KernelSelection_MD_Utils_DistRank(roiData{rr});
end
toc
%%
DSI = cellfun(@(roi) roi.typeInfo.DSI_Edge,roiData);
ESI = cellfun(@(roi) roi.typeInfo.ESI,roiData);
edgeType = cellfun(@(roi) roi.typeInfo.edgeType,roiData);
ccWholeTrace = cellfun(@(roi) roi.repeatability.value,roiData);
% first order kernel.
zFirst = cellfun(@(roi)roi.filterInfo.firstKernel.ZTest.z,roiData);
pFirst = cellfun(@(roi)roi.filterInfo.firstKernel.ZTest.p,roiData);
firstRank = cellfun(@(roi) roi.filterInfo.firstKernel.ZTest.nlessAndEqual,roiData);

%%saveFigureFlag = false;
threshESIT4 = 0.3;
threshESIT5 = 0.4;
threshDSI = 0.4;
roiSelectedByDSI = abs(DSI) > threshDSI;
% roiSelectedByESI = abs(ESI) > threshESI;
roiSelectedByESI = ESI < - threshESIT5| ESI > threshESIT4;
roiSelectedByEdge =  roiSelectedByDSI & roiSelectedByESI;
repeatabilityThresh = 0.4;
roiSelectedByTrace = ccWholeTrace > repeatabilityThresh;
roiSelected = roiSelectedByEdge & roiSelectedByTrace & firstRank > 9990;

alpha = 0.01;
FigPlot_Fig3_Supp_SVD(roiData(roiSelected),['ICA_DFOVERF_T403T504R_rank_9990_BT_EdgeCorrected'],saveFigureFlag,'smoothFlag',true)
FigPlot_Fig3_Supp_1oPred2o(roiData(roiSelected),['ICA_DFOVERF_T403T504R_rank_9990_BT_EdgeCorrected'],saveFigureFlag,'smoothFlag',true);
FigPlot_Fig3_Supp_2oSVD(roiData(roiSelected),['ICA_DFOVERF_T403T504R_rank_9990_BT_EdgeCorrected'],saveFigureFlag,'smoothFlag',true);
% fit your SVD component on some curve? babo
FigPlot_Fig3_PaperRevision(roiData(roiSelected),['ICA_DFOVERF_T403T504R_rank_9990_BT_EdgeCorrected'],saveFigureFlag,'smoothFlag',true,'limPreSetFlag',false,...
    'barUseBank',{[9,10,11],[8,9,10],[9,10,11],[8,9,10]},'MainName',['1o_2o_Mean_091011_080910'],'dx',1,'alpha',alpha);
FigPlot_Fig3_PaperRevision(roiData(roiSelected),['ICA_DFOVERF_T403T504R_rank_9990_BT_EdgeCorrected'],saveFigureFlag,'smoothFlag',true,'limPreSetFlag',false,...
    'barUseBank',{[9,10,11],[8,9,10],[9,10,11],[8,9,10]},'MainName',['1o_2o_Mean_091011_080910'],'dx',2,'alpha',alpha);
FigPlot_SecondOrderKernel_ImpulseResponse(roiData(roiSelected),['ICA_DFOVERF_T403T504R_rank_9990_BT_EdgeCorrected'],saveFigureFlag,'smoothFlag',true,'limPreSetFlag',false,...
    'barUseBank',{[9,10,11],[8,9,10],[9,10,11],[8,9,10]},'MainName',['2o_Mean_091011_080910_Impulse'],'dx',1);
