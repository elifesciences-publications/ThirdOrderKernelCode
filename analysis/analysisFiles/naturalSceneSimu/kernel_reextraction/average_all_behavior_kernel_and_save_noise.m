function average_all_behavior_kernel_and_save_noise(process_stim_flag, process_stim_FWHM, kernel_extraction_method,  noise_flag)

S = GetSystemConfiguration;
data_folder = S.datapath_behavior_kernel;
data_folder_relative_path = findkerneldata_relativepath(data_folder);
file_relative_path_all = cat(1, data_folder_relative_path{:});
file_full_path_all = cellfun(@(x) fullfile(data_folder, x), file_relative_path_all, 'UniformOutput', false);


%% get individual kernel
if noise_flag
    kernel_2_ind = [];
    kernel_3_xxy_ind = [];
    kernel_3_yyx_ind = [];
    tic
    kernel_2_ave         = Analysis_Function_Get_Mean_Behavior_Noise(file_full_path_all, process_stim_flag, process_stim_FWHM, kernel_extraction_method, 'second_noise');
    toc
    tic
    kernel_3_xxy_ave = Analysis_Function_Get_Mean_Behavior_Noise(file_full_path_all, process_stim_flag, process_stim_FWHM, kernel_extraction_method, 'third_0_1_noise');
    toc
    kernel_3_yyx_ave = Analysis_Function_Get_Mean_Behavior_Noise(file_full_path_all, process_stim_flag, process_stim_FWHM, kernel_extraction_method, 'third_0_n1_noise');
else
    [kernel_2_ind, kernel_2_ave]         = Analysis_Function_Get_Mean_Behavior(file_full_path_all, process_stim_flag, process_stim_FWHM, kernel_extraction_method, 'second');
    [kernel_3_xxy_ind, kernel_3_xxy_ave] = Analysis_Function_Get_Mean_Behavior(file_full_path_all, process_stim_flag, process_stim_FWHM, kernel_extraction_method, 'third_0_1');
    [kernel_3_yyx_ind, kernel_3_yyx_ave] = Analysis_Function_Get_Mean_Behavior(file_full_path_all, process_stim_flag, process_stim_FWHM, kernel_extraction_method, 'third_0_n1');
end
%% symmetrize kernel
maxTau = round(sqrt(length(kernel_2_ave)));
kernel_2_ave = reshape(kernel_2_ave, [maxTau, maxTau, size(kernel_2_ave,2)]);
k2_sym = zeros(size(kernel_2_ave));
for ii = 1:1:size(kernel_2_ave, 3)
    k2_sym(:,:,ii) = (kernel_2_ave(:, :, ii) - kernel_2_ave(:, :, ii)')/2;
end
k3_sym = (kernel_3_xxy_ave - kernel_3_yyx_ave)/2;
k3_sym = reshape(k3_sym, [maxTau, maxTau, maxTau,size(k3_sym,2)]);

% rescale the kernel. as well as individual kernels. 2 and 6 factor is done
% here...
k2_sym = k2_sym/2;
k3_sym = k3_sym/6;

if ~noise_flag
    % symmtrize individual kernels, as well as rescale them
    kernel_2_ind_sym = zeros(size(kernel_2_ind));
    for ii = 1:1:size(kernel_2_ind_sym, 2)
        k2_square = reshape(kernel_2_ind(:,ii), [maxTau, maxTau]);
        k2_square_sym = (k2_square - k2_square')/2;
        kernel_2_ind_sym(:,ii) = k2_square_sym(:);
    end
    kernel_2_ind_sym_rescale = kernel_2_ind_sym/2;
    
    % third order kernel, for individual? no need to symetrize . only scale
    kernel_3_xxy_ind_rescale = kernel_3_xxy_ind/6;
    kernel_3_yyx_ind_rescale = kernel_3_yyx_ind/6;
else
    kernel_2_ind_sym_rescale = [];
    kernel_3_xxy_ind_rescale = [];
    kernel_3_yyx_ind_rescale = [];
end

%% put most of the elements to be zero
k2_sym_cleaned = zeros(size(k2_sym));
k3_sym_cleaned = zeros(size(k3_sym));
for ii = 1:1:size(k2_sym, 3)
    k2_sym_this = k2_sym(:,:,ii);
    k3_sym_this = k3_sym(:,:,:,ii);
    k2_sym_cleaned_temp =  chop_kernel(k2_sym_this(:), 2); k2_sym_cleaned(:,:,ii) = reshape(k2_sym_cleaned_temp, [maxTau, maxTau]);
    k3_sym_cleaned_temp =  chop_kernel(k3_sym_this(:), 3); k3_sym_cleaned(:,:,:,ii) = reshape(k3_sym_cleaned_temp, [maxTau, maxTau, maxTau]);
end
%% organize
kernel.k2_ind = kernel_2_ind_sym_rescale;
kernel.k3_xxy_ind = kernel_3_xxy_ind_rescale;
kernel.k3_yyx_ind = kernel_3_yyx_ind_rescale;
kernel.k2_sym = k2_sym;
kernel.k3_sym = k3_sym;
kernel.k2_sym_cleaned = k2_sym_cleaned;
kernel.k3_sym_cleaned = k3_sym_cleaned;

%% save it.
if ~process_stim_flag
    kernel_file_starter = 'ori';
else
    kernel_file_starter = sprintf('FWHM%d', process_stim_FWHM);
end

if noise_flag
    kernel_file_ending = ['_noise'];
else
    kernel_file_ending = [];
end
kernel_file_name = [kernel_file_starter, '_', kernel_extraction_method,kernel_file_ending, '.mat'];
kernel_storage_folder = 'D:\Natural_Scene_Simu\parameterdata';
kernel_storage_fullpath = fullfile(kernel_storage_folder, kernel_file_name);

save(kernel_storage_fullpath, 'kernel');
end