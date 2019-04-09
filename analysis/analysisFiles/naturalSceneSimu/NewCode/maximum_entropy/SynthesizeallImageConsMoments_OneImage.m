function SynthesizeallImageConsMoments_OneImage(solution_storage_full_path, I_syn_storage_full_path, ...
    set_spatial_correlation_flag, set_fixed_skewness_flag, sample_flag, skewness_fold, ...
    solving_method,moments_calculation_method, n_highest_moments, N, symmetrize_flag, image_id, K,...
    zero_mean_flag,skewness_prefiexed, lower_bound_flag,...
    prefixed_gray_value_flag, prefixed_gray_value)


S = GetSystemConfiguration;
image_source_full_path = fullfile(S.natural_scene_simulation_path, 'image','statiche0','FWHM25');

if set_spatial_correlation_flag
    mean_spatial_correlation_full_path = fullfile(S.natural_scene_simulation_path,'image','statiche0syn_','FWHM25','spatial_corr.mat');
end


if ~exist(solution_storage_full_path, 'dir')
    mkdir(solution_storage_full_path);
end
if ~exist(I_syn_storage_full_path,'dir')
    mkdir(I_syn_storage_full_path)
end

%% load mean autocorrelation.
if set_spatial_correlation_flag
    auto_thresh = 0.2;
    load(mean_spatial_correlation_full_path);
    [correlation_true_prefixed, resolution_n_pixel_prefixed]  = MaxEntDis_Utils_FindCorrTrue(spatial_corr_mean, auto_thresh, K);
else
    correlation_true_prefixed = [];
    resolution_n_pixel_prefixed = [];
end

if set_fixed_skewness_flag
    %     skewness_prefiexed = 1;
else
    skewness_prefiexed = [];
end

%% for this particular image.
imageDataInfo  = dir(fullfile(image_source_full_path, '*.mat'));
image_file_this = fullfile(image_source_full_path, imageDataInfo(image_id).name);
I_this = load(image_file_this);
%% calculate data for that image.
[med,~,I] = MED_FindSolutionForEachImage_ConsMoments(I_this.I, 'N', N,...
    'sample_flag', sample_flag,...
    'skewness_fold', skewness_fold,...
    'set_spatial_correlation_flag',set_spatial_correlation_flag,...
    'correlation_true_prefixed',correlation_true_prefixed,...
    'resolution_n_pixel_prefixed', resolution_n_pixel_prefixed,...
    'set_fixed_skewness_flag', set_fixed_skewness_flag,...
    'skewness_prefiexed',skewness_prefiexed,...
    'solving_method', solving_method,...
    'moments_calculation_method',moments_calculation_method,...
    'n_highest_moments', n_highest_moments,...,
    'symmetrize_flag',symmetrize_flag,...
    'lower_bound_flag',lower_bound_flag,...
    'K',K,...
    'zero_mean_flag',zero_mean_flag,...
    'prefixed_gray_value_flag',prefixed_gray_value_flag,...
    'prefixed_gray_value',prefixed_gray_value);

solved_file_this = fullfile(solution_storage_full_path, imageDataInfo(image_id).name);
save(solved_file_this,  'med');

if sample_flag
    synimage_file_this = fullfile( I_syn_storage_full_path, imageDataInfo(image_id).name);
    save(synimage_file_this,  'I');
end
