function NS_Statistics_MeanStatistics(FWHM)

velocity.distribution = [];
velocity.range = [];

image_process_info.contrast = 'static';
image_process_info.he = 0;
image_process_info.FWHM = FWHM;
image_process_info.tf_tau = [];

S = GetSystemConfiguration;

% information for image data set.
synthetic_type = [];
synthetic_flag = false;
image_source_relative_path =  NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','image_source', 'synthetic_flag',synthetic_flag);
image_source_full_path = fullfile(S.natural_scene_simulation_path, 'image', image_source_relative_path);
imageDataInfo  = dir(fullfile(image_source_full_path, '*.mat'));
imageIDBank = 1:1:length(imageDataInfo);
n_image = length(imageIDBank);

% information for image mean information.
synthetic_type = [];
synthetic_flag = true;
synthetic_image_source_relative_path  =  NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','image_source', 'synthetic_flag',synthetic_flag);
synthetic_image_source_full_path  = fullfile(S.natural_scene_simulation_path, 'image', synthetic_image_source_relative_path);

%% start calculating contrast distributino, spatial_correlation and power spectrum. for contrast distribution...

spatial_corr_all = cell(n_image, 1);
power_spectrum_all = cell(n_image, 1);
contrast_distribution_all = cell(n_image, 1);
num_row = zeros(n_image, 1);
bin_edges = -1:0.05:10; % very large accu
n_autocorr = 100;
tic
parfor nn = 1:1:n_image
    image_file_this = fullfile(image_source_full_path, imageDataInfo(nn).name);
    I_this = load(image_file_this);
    [contrast_distribution_all{nn}, spatial_corr_all{nn} , power_spectrum_all{nn}] ...
        = calculate_statistics_of_one_image(I_this.I, bin_edges, n_autocorr);
end
toc

%% do the average.
contrast_distribution_mean = mean(cat(1, contrast_distribution_all{:}), 1);
spatial_corr_mean = mean(cat(1, spatial_corr_all{:}), 1);
power_spectrum_mean = mean(cat(1, power_spectrum_all{:}), 1);
%% store it.
cd_filename = 'contrast_distribution';
save(fullfile(synthetic_image_source_full_path, cd_filename),'contrast_distribution_mean','bin_edges');
sc_filename = 'spatial_corr';
save(fullfile(synthetic_image_source_full_path, sc_filename),'spatial_corr_mean');
fft_filename = 'power_spectrum';
save(fullfile(synthetic_image_source_full_path, fft_filename),'power_spectrum_mean');
end