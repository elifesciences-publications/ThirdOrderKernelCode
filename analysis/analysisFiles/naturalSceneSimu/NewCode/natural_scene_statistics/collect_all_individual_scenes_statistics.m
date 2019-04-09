function stim_statistics = collect_all_individual_scenes_statistics(varargin)
FWHM = 25;
raw_image_flag = 0;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

image_process_info.contrast = 'static';
image_process_info.he = 0;
image_process_info.FWHM = FWHM;
image_process_info.tf_tau = [];
velocity.distribution = 'binary';
velocity.range = 100;
synthetic_flag = false;
synthetic_type = [];
synthetic_image_source_relative_path = NS_Filema_Param_To_FolderName(velocity, image_process_info, [],...
    'folder_use','image_source', 'synthetic_flag',synthetic_flag, 'synthetic_type', synthetic_type, 'raw_image_flag', raw_image_flag);
S = GetSystemConfiguration;
synthetic_image_source_full_path =  fullfile(S.natural_scene_simulation_path, 'image', synthetic_image_source_relative_path);
n_scene = 421;
n_row = 251;
% load all possible
stim_skewness = zeros(n_row, n_scene);
stim_variance = zeros(n_row, n_scene);
stim_kurtosis = zeros(n_row, n_scene);
stim_mean = zeros(n_row, n_scene);
for ss = 1:1:n_scene
    I = Generate_VisualStim_And_VelEstimation_Utils_LoadImage...
        (ss,synthetic_image_source_full_path, synthetic_type);
    
    for rr = 1:1:size(I, 1)
        scene_this = I(rr, :);
        stim_mean(rr, ss) = mean(scene_this);
        stim_variance(rr, ss) = var(scene_this);
        stim_kurtosis(rr, ss) = kurtosis(scene_this);
        stim_skewness(rr, ss) = skewness(scene_this);
    end
end
stim_statistics.skewness = stim_skewness;
stim_statistics.variance = stim_variance;
stim_statistics.kurtosis = stim_kurtosis;
stim_statistics.mean = stim_mean;

end