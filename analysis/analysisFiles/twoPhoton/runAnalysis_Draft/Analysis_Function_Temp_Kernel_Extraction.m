% first, check flick is there.
function data = Analysis_Function_Temp_Kernel_Extraction(filepath, kernel_identifier, kernel_to_be_extracted_string_this, roiSelected)
S = GetSystemConfiguration;
kernel_folder = S.kernelSavePath;

if strcmp(kernel_identifier.kernel_extraction_method, 'ARMA_RC')
    arma_flag = true;
else
    arma_flag = false;
end

kernel_to_be_extracted_param_this =  kernel_path_management_utils_kernelstr_to_kernelparam({kernel_to_be_extracted_string_this});
order_this = kernel_to_be_extracted_param_this.order;
noise_this = kernel_to_be_extracted_param_this.noise;
maxTau_this  = kernel_to_be_extracted_param_this.maxTau; % change this in the future;


[~, flick_relative_path] = kernel_path_management_utils_get_kernelInfo(filepath, kernel_identifier, 'flick'); % do
flick_relative_path_full = [kernel_folder, flick_relative_path];
% load and get resp and stim.
load(flick_relative_path_full);
respData = flickSave.respData(roiSelected);
stimData = flickSave.stimData;
stimIndexes = flickSave.stimIndexed(roiSelected);

if arma_flag
    [~, arma_ols_relative_path] = kernel_path_management_utils_get_kernelInfo(filepath, kernel_identifier, 'arma_ols_first');
    arma_ols_path_full = [kernel_folder, arma_ols_relative_path];
    load(arma_ols_path_full);
    kr =  arma_ols_first.kr;
    kr = kr(roiSelected);
else
    kr = [];
end
data = Main_KernelExtraction_ReverseCorr(respData, stimData, stimIndexes, 'order', order_this, 'donoise', noise_this, 'maxTau', maxTau_this, 'arma_flag', arma_flag,'kr',kr);
end