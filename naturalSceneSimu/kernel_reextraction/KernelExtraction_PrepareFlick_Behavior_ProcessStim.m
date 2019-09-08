function flickSave = KernelExtraction_PrepareFlick_Behavior_ProcessStim(filepath, process_stim_flag, process_stim_FWHM)
if ~ process_stim_flag
    error('You should be not here/')
else
    % first, find the oriflick
    kernel_identifier.kernel_process_stim_flag = 0;
    kernel_identifier.kernel_process_stim_FWHM = [];
    kernel_identifier.data_source = 'behavior';
    kernel_identifier.kernel_extraction_method = 'reverse_correlation';
    [~, flick_relative_path] = kernel_path_management_utils_get_kernelInfo(filepath, kernel_identifier, 'flick'); % do
    S = GetSystemConfiguration;
    kernel_folder = S.kernelSavePath_behavior;
    flick_relative_path_full = fullfile(kernel_folder, flick_relative_path);
    load(flick_relative_path_full);
    stimData = flickSave.stimData;
    % process it
    flickSave.stimData =  NS_KernelWithFilteredStim_Utils_PreProcess_Stim(process_stim_FWHM,stimData);
    
    % store it
    
end
end