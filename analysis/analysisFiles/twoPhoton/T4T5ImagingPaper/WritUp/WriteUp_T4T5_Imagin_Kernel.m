% do you want to give it a try?
clear
clc
filepathAllNonRep = GetPathsFromDatabase('T4T5', 'multiBarFlicker_20_60hz', 'GC6f', '','','date', '>', '2015-06-01');
filepathAllRep = GetPathsFromDatabase('T4T5', 'multiBarFlicker_20_repBlock_60hz', 'GC6f', '','','date','<','2016-06-18');
filepathAllRepNewest = GetPathsFromDatabase('T4T5', 'multiBarFlicker_20_repBlock_60hz', 'GC6f', '','','date','>=','2016-06-18','date','<','2016-06-19'); % 
filepathAll = [filepathAllRep;filepathAllNonRep;filepathAllRepNewest];

% the data does not match...
data_processed_default = 'ICA_DFOVERF_T4T5_BT_EdgeCorrected_With2oNoisy';
data_raw_default = 'ICA_DFOVERF_T4T5_BT_EdgeCorrected';
% data_roiMask_default = '';
% you should have a folder to do it? this might be hard, but worth trying.
roiMethod_forBackground_default = 'RoiIsBackGround';
roiMethod_forTwoPhotonMaster_default = 'ICA_DFOVERF'; 
roiMethod_forRunAnalysis_default = 'IcaRoiExtraction';

force_new_roi = true; 
force_new_kernel = true;
% before you do this, do you want to keep a snap shot of your ICA mask?
if force_new_roi && force_new_kernel
    % This will generate a different ICA roimask, and everything will be
    % changed, but the old data is preserved. 
    data_folder_name = 'new_roi_new_kernel';
    roiMethod_forTwoPhotonMaster = 'WriteUp_T4T5_NewRoiMask_ICA';
    roiMethod_forBackGround = 'WriteUp_T4T5_RoiIsBackgound';
    roiMethod_forRunAnalysis = 'WriteUp_T4T5_IcaRoiExtraction';
    WriteUp_T4T5_Paper_ROIExtraction(filepathAll, roiMethod_forRunAnalysis);
    force_new_roi = true;
    WriteUp_T4T5_Paper_KernelExtraction(filepathAll, data_folder_name,roiMethod_forTwoPhotonMaster,roiMethod_forBackGround, force_new_roi);
    WriteUp_T4T5_1oD_2oNoisyKernel(filepathAll, data_folder_name,roiMethod_forTwoPhotonMaster,roiMethod_forBackground);
    % if they force new Roi and RoiMask. That would be nasty.
elseif ~force_new_kernel && ~force_new_roi
    data_folder_name = data_processed_default;
    roiMethod_forTwoPhotonMaster = roiMethod_forTwoPhotonMaster_default;
    roiMethod_forBackGround = roiMethod_forBackground_default;
end
WriteUp_T4T5_AnalyzeData(data_folder_name);
