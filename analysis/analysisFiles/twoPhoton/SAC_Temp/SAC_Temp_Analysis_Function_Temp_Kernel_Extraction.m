% first, check flick is there.
function data = SAC_Temp_Analysis_Function_Temp_Kernel_Extraction(filepath, kernel_identifier, kernel_to_be_extracted_string_this)

bin_stim_flag = kernel_identifier.bin_stim_flag;
down_sample_response_flag = kernel_identifier.down_sample_response_flag;

[resp, stim, f] = SAC_Temp_Preprocessing_Stim_Resp(filepath, bin_stim_flag, down_sample_response_flag);
kernel_to_be_extracted_param_this =  SAC_Temp_kernel_path_management_utils_kernelstr_to_kernelparam({kernel_to_be_extracted_string_this} ,'f', f);
order_this = kernel_to_be_extracted_param_this.order;
noise_this = kernel_to_be_extracted_param_this.noise;
maxTau  = kernel_to_be_extracted_param_this.maxTau; % change this in the future;

data = Main_KernelExtraction_ReverseCorr({resp}, stim, {1:length(resp)}, ...
    'order', order_this, 'donoise', noise_this, 'maxTau', maxTau,'arma_flag', false,'kr',false);
end