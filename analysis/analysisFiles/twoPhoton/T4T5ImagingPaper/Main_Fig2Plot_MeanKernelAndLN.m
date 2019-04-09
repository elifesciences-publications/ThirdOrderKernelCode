clear
clc

roiMethodType = 'ICA_NNMF';
stimulusType = '5B';
roiData5B = getData_Juyue('5B',roiMethodType);
roiData5T = getData_Juyue('5T',roiMethodType);
% roiData = [roiData5T;roiData5B];
roiData = [roiData5B];

%%

flyLargeMovement = {'I:\2pData\2p_microscope_data\2015_08_11\+;UASGC6f_+;T4T5_+ - 1\multiBarFlicker_20_60hz_-64.6down005'};
roiData = roiSelection_AllRoi(roiData,'method','fly','targetedfilepath',flyLargeMovement);
roiDataUse = roiSelection_AllRoi(roiData,'method','kernelType');
roiDataUseEdge = roiSelection_AllRoi(roiDataUse,'method','prob');
roiDataUseEdge = roiAnalysis_ChangeFilterDirection(roiDataUseEdge,'method','corChangeAndCentered');
for rr = 1:1:length(roiDataUseEdge)
    roiDataUseEdge{rr} = roiAnalysis_OneRoi_LN_OLS(roiDataUseEdge{rr});
end

saveFigFlag = true;
FigPlot_FK_MeanKernel(roiDataUseEdge,'aveBy','fly','kernelTypeUse',[1,3],'normRoiFlag',true,'MainName','1oKernel_Binary','saveFigFlag',saveFigFlag);
roiDataUseEdge = FigPlot2_LN(roiDataUseEdge,'saveFigFlag',saveFigFlag,'MainName','1oKernel_Binary');

