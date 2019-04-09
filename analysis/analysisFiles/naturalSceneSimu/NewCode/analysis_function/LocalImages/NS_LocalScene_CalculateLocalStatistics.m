function statistics_I = NS_LocalScene_CalculateLocalStatistics()
n_image = 421;
image_process_info.contrast = 'static';
image_process_info.he = 0;
image_process_info.FWHM = 25;
image_process_info.tf_tau = [];
velocity.distribution = 'binary';
velocity.range = 100;
synthetic_flag = false;
synthetic_type = [];

synthetic_image_source_relative_path = NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','image_source', 'synthetic_flag',synthetic_flag, 'synthetic_type', synthetic_type);
S = GetSystemConfiguration;
synthetic_image_source_full_path =  fullfile(S.natural_scene_simulation_path, 'image', synthetic_image_source_relative_path);
%%
statistics_I = repmat(struct('mean', [], 'variance',[], 'skewness',[], 'kurtosis',[], 'imageID' ,[], 'row_pos', []), n_image, 1);
% do you want to store the data somewhere? no...
tic
for ii = 1:1:n_image
    image_ID = ii;
    I = Generate_VisualStim_And_VelEstimation_Utils_LoadImage...
        (image_ID,synthetic_image_source_full_path, synthetic_type);
    statistics_I(ii).mean = mean(I, 2);
    statistics_I(ii).variance = var(I, 1, 2);
    statistics_I(ii).skewness = skewness(I, 1, 2);
    statistics_I(ii).kurtosis = kurtosis(I, 1, 2);
    statistics_I(ii).imageID = ones(size(I, 1), 1) * ii;
    statistics_I(ii).row_pos = 1:size(I, 1);
end
toc
end