function SynthesizeallImageConsMoments_OneImage_OneRow(solution_storage_full_path, I_syn_storage_full_path, ...
    set_spatial_correlation_flag, set_fixed_skewness_flag, sample_flag, skewness_fold, ...
    solving_method,moments_calculation_method, n_highest_moments, N, symmetrize_flag, image_id, row_id)


K = 4;
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
    skewness_prefiexed = 0;
else
    skewness_prefiexed = [];
end

%% for this particular image.
imageDataInfo  = dir(fullfile(image_source_full_path, '*.mat'));
image_file_this = fullfile(image_source_full_path, imageDataInfo(image_id).name);
I_this = load(image_file_this);

x_start_initial = ran(K * n_highest_moments +  (K^2 - K)/2 + 1, 1) * 0.01;
one_row = I_this.I(row_id, :);
    [x_solved, f_val, solved_flag, time_for_each_row, gray_value, mu_true,  cov_true, correlation_true, resolution_n_pixel, ~]=...
        MaxEntDis_ConsMoments_Utils_FromSceneToScene(one_row, 'sample_flag', sample_flag, 'plot_flag', false, 'skewness_fold',skewness_fold,...
        'set_spatial_correlation_flag' ,set_spatial_correlation_flag,...
        'correlation_true_prefixed',correlation_true_prefixed,...
        'resolution_n_pixel_prefixed',resolution_n_pixel_prefixed,...
        'set_fixed_skewness_flag', set_fixed_skewness_flag,...
        'x_start_initial', x_start_initial,...
        'skewness_prefiexed',skewness_prefiexed,'solving_method',solving_method,'moments_calculation_method',moments_calculation_method,...
        'n_highest_moments',n_highest_moments,'symmetrize_flag', symmetrize_flag, 'N', N);
    
    %%
med.gray_value = gray_value;
med.resolution_n_pixel = resolution_n_pixel;
med.correlation_true = correlation_true;
med.cov_true = cov_true;
med.mu_true = mu_true;
med.x_solved = x_solved;
med.N = N;
med.K = K;
med.solved_flag = solved_flag;
med.f_val = f_val;
med.time = time_for_each_row;

%%
image_name = strsplit(imageDataInfo(image_id).name, '.'); 
image_folder_this = fullfile(solution_storage_full_path, image_name{1});
solved_file_this = fullfile(image_folder_this, ['row',num2str(row_id),'.mat']);
if ~exist(image_folder_this, 'dir')
    mkdir(image_folder_this);
end
save(solved_file_this,  'med');


