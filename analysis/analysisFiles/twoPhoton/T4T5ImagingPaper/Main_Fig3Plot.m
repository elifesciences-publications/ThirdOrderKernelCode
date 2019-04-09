clear
clc

roiMethodType = 'ICA_NNMF';
stimulusType = '5B';
roiData5B = getData_Juyue('5B',roiMethodType);
roiData5T = getData_Juyue('5T',roiMethodType);
roiData = [roiData5T;roiData5B];


tic
roiData = roiAnalysis_ChangeFilterDirection(roiData,'method','corChangeAndCentered');
toc
flyLargeMovement = {'I:\2pData\2p_microscope_data\2015_08_11\+;UASGC6f_+;T4T5_+ - 1\multiBarFlicker_20_60hz_-64.6down005'};
roiData = roiSelection_AllRoi(roiData,'method','fly','targetedfilepath',flyLargeMovement);

%% for second order kernel, only select on DSI.
roiData = roiSelection_AllRoi(roiData,'method','prob');% this seems like a reasonable idea... also record the
roiDataLoose = roiAnalysis_SecondKernelSelection_SelectAll(roiData);
roiDataLoose = roiSelection_AllRoi(roiDataLoose,'method','kernelType');
roiDataLoose = roiAnalysis_ChangeFilterDirection(roiDataLoose,'method','corChangeAndCentered');

%
saveFigFlag = true;
Temp_roiAnalysis_DifferentRoi(roiDataLoose,'tMax',45,'dt',[-8:8],'normKernelFlag',false,'normRoiFlag',true,...
    'MainName','LooseOnlyDSI_T4T5Blend','saveFigFlag',saveFigFlag,'kernelTypeUse',[1,2,3],'MainName','Binary');
Temp_roiAnalysis_DifferentRoi(roiDataLoose,'tMax',45,'dt',[-15:15],'normKernelFlag',false,'normRoiFlag',true,...
    'MainName','LooseOnlyDSI_T4T5Blend','saveFigFlag',saveFigFlag,'kernelTypeUse',[1,2,3],'MainName','Binary');

%% for second order kernel, only select on DSI.
roiDataOnlyDSI = roiSelection_AllRoi(roiData,'method','probOnlyDSI');% this seems like a reasonable idea... also record the
roiDataLooseOnlyDSI = roiAnalysis_SecondKernelSelection_SelectAll(roiDataOnlyDSI);
roiDataLooseOnlyDSI = roiSelection_AllRoi(roiDataLooseOnlyDSI,'method','kernelType');

saveFigFlag = true ;
Temp_roiAnalysis_DifferentRoi(roiDataLooseOnlyDSI,'tMax',45,'dt',[-8:8],'normKernelFlag',false,'normRoiFlag',true,...
    'MainName','LooseOnlyDSI_T4T5Blend','saveFigFlag',saveFigFlag,'kernelTypeUse',[1,2,3]);
Temp_roiAnalysis_DifferentRoi(roiDataLooseOnlyDSI,'tMax',45,'dt',[-15:15],'normKernelFlag',false,'normRoiFlag',true,...
    'MainName','LooseOnlyDSI_T4T5Blend','saveFigFlag',saveFigFlag,'kernelTypeUse',[1,2,3]);

%%
roiDataUse = roiSelection_AllRoi(roiData,'method','kernelType');% this seems like a reasonable idea... also record the
roiDataUseEdge = roiSelection_AllRoi(roiDataUse,'method','prob');% this seems like a reasonable idea... also record the
roiDataUseEdge = roiAnalysis_ChangeFilterDirection(roiDataUseEdge,'method','corChangeAndCentered');

flyLargeMovement = {'I:\2pData\2p_microscope_data\2015_08_11\+;UASGC6f_+;T4T5_+ - 1\multiBarFlicker_20_60hz_-64.6down005'};
roiDataUseEdge = roiSelection_AllRoi(roiDataUseEdge ,'method','fly','targetedfilepath',flyLargeMovement);
