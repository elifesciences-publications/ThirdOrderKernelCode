function Generate_VisualStim_And_VelEstimation_SynImages(FWHM, synthetic_type, synthetic_flag)
velocity.distribution = [];
velocity.range = [];

image_process_info.contrast = 'static';
image_process_info.he = 0;
image_process_info.FWHM = FWHM;
image_process_info.tf_tau = [];

S = GetSystemConfiguration;

%% 
switch synthetic_type
    case 'm_sc_i_var' % no need to generate beforehand. you can also do it anyways, not neccessay.
        synthetic_info_type_mean = 'power_spectrum';
        synthetic_info_type_individual = [];
        synthetic_info_flag_individual = false; % might be false.
    case 'm_var_i_sc'
        synthetic_info_type_mean = 'power_spectrum';
        synthetic_info_type_individual = [];
        synthetic_info_flag_individual = false; % might be false.
    case 'i_sc_i_var'
        synthetic_info_type_mean = []; % do not use mean value at all
        synthetic_info_type_individual = [];
        synthetic_info_flag_individual = false; % might be false.
    case 'm_sc_i_cd'
        synthetic_info_type_mean = [];
        synthetic_info_type_individual = 'med_mean_sc_cond_solution';
        synthetic_info_flag_individual = true; % might be false.
    case 'i_sc_i_cd'
        synthetic_info_type_mean = [];
        synthetic_info_type_individual = 'med_sc_cond_solution';
        synthetic_info_flag_individual = true; % might be false.
    otherwise
        synthetic_info_type_mean = [];
        synthetic_info_type_individual = [];
        synthetic_info_flag_individual = []; % might be false. does not matter, those are calculated on the spot.
end
% image data set.
synthetic_image_individual_info_relative_path =  NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','image_source',...
    'synthetic_flag',synthetic_info_flag_individual, 'synthetic_type', synthetic_info_type_individual);
synthetic_image_individual_info_full_path = fullfile(S.natural_scene_simulation_path, 'image', synthetic_image_individual_info_relative_path);

% mean image information.
if ~isempty(synthetic_info_type_mean)
    synthetic_image_mean_info_relative_path =  NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','image_source',...
        'synthetic_flag',true);
    synthetic_image_mean_info_full_path = fullfile(S.natural_scene_simulation_path, 'image', synthetic_image_mean_info_relative_path, [synthetic_info_type_mean,'.mat']);
    image_mean_info = load(synthetic_image_mean_info_full_path);
else
    synthetic_image_mean_info_full_path = [];
    image_mean_info = [];
    
end
% storage
synthetic_image_source_relative_path  =  NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','image_source',...
    'synthetic_flag',synthetic_flag,'synthetic_type',synthetic_type);
synthetic_image_source_full_path  = fullfile(S.natural_scene_simulation_path, 'image', synthetic_image_source_relative_path);

%% different individual match up.
imageDataInfo  = dir(fullfile(synthetic_image_individual_info_full_path, '*.mat'));
imageIDBank = 1:1:length(imageDataInfo);
n_image = length(imageIDBank);

%% do simulation on individual images.
% Make it into batch processing.



for nn = 376
    image_this = load(fullfile(synthetic_image_individual_info_full_path,  imageDataInfo(nn).name));
    % start generating image. have a function here.
    I = SyntheticScene_Utils_GenerateOneImage(image_this, image_mean_info,synthetic_type);
    
    % store it somewhere.
    if ~exist(synthetic_image_source_full_path, 'dir')
        mkdir(synthetic_image_source_full_path);
    end
    save(fullfile(synthetic_image_source_full_path, imageDataInfo(nn).name), 'I');
end
end