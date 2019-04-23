function kernel = Load_Kernel_For_NS(process_stim_flag , process_stim_FWHM, kernel_extraction_method, varargin)
full_kernel_flag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
if ~process_stim_flag
    kernel_file_starter = 'ori';
else
    kernel_file_starter = sprintf('FWHM%d', process_stim_FWHM);
end
kernel_file_name = [kernel_file_starter, '_', kernel_extraction_method,'.mat'];
S = GetSystemConfiguration;
kernel_storage_folder =  fullfile(S.natural_scene_simulation_path, '\parameterdata');
kernel_storage_fullpath = fullfile(kernel_storage_folder, kernel_file_name);

if strcmp(kernel_extraction_method, 'Holly_OLS')
    load('D:\Natural_Scene_Simu\parameterdata\OLS_2o_nonorm.mat');
    kernel.k2_sym = Z.kernels.meanKernels.k2_sym;
    load('D:\Natural_Scene_Simu\parameterdata\OLS_3o_nonorm.mat')
    kernel.k3_sym = Z.kernels.meanKernels.k3_sym; % put the last to be zeros..
elseif strcmp(kernel_extraction_method, 'HRC')
    kernel = VelocityEstimation_Utils_GenerateHRC();
elseif strcmp(kernel_extraction_method, 'STE') % spatial temporal energy model
    kernel = VelocityEstimation_Utils_GenerateSTE();
elseif strcmp(kernel_extraction_method, 'reverse_correlation_first')
    kernel_load = load(kernel_storage_fullpath);
    kernel.k1 = kernel_load.kernel.k1_ave;
  
else
    kernel_load = load(kernel_storage_fullpath);
    if full_kernel_flag
        kernel.k2_sym = kernel_load.kernel.k2_sym;
        kernel.k3_sym = kernel_load.kernel.k3_sym;
    else
        kernel.k2_sym = kernel_load.kernel.k2_sym_cleaned;
        kernel.k3_sym = kernel_load.kernel.k3_sym_cleaned;
    end
    %     kernel.k3_sym = kernel_load.kernel.k3_sym;
    
end

end