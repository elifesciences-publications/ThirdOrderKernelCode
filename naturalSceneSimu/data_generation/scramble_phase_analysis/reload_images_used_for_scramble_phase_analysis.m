function scene_stim = reload_images_used_for_scramble_phase_analysis(n_total_sample_points, synthetic_flag, synthetic_type, FWHM, seed_num, varargin)
preselect_image = false;
data_sequence_image_421_input = [];
data_sequence_image = [];
preselect_data_sequence_image = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% n_total_sample_points = 70;
if  ~preselect_data_sequence_image
    
    if preselect_image
        data_sequence_image_421 = data_sequence_image_421_input;
        data_sequence_image = tansfer_data_sequence_421_to_vector(data_sequence_image_421); % or do you want to just load the image and take a look?
        
    else
        n_scene = n_total_sample_points;
        data_sequence_image_421 = Generate_VisStimVelEst_Utils_GenerateImageSequence(n_total_sample_points, 'seed_num', seed_num);
        data_sequence_image = tansfer_data_sequence_421_to_vector(data_sequence_image_421); % or do you want to just load the image and take a look?
    end
end
n_scene = length(data_sequence_image.image_sequence);
n_hor = 927;


image_process_info.contrast = 'static';
image_process_info.he = 0;
image_process_info.FWHM = FWHM;
image_process_info.tf_tau = [];
velocity.distribution = 'binary';
velocity.range = 100;
% synthetic_flag = false;
% synthetic_type = [];
synthetic_image_source_relative_path = NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','image_source', 'synthetic_flag',synthetic_flag, 'synthetic_type', synthetic_type);
S = GetSystemConfiguration;
synthetic_image_source_full_path =  fullfile(S.natural_scene_simulation_path, 'image', synthetic_image_source_relative_path);

% load all possible
scene_stim = zeros(n_scene, n_hor);
for ss = 1:1:n_scene
    image_ID = data_sequence_image.image_sequence(ss);
    row_pos = data_sequence_image.image_row_pos_sequence(ss);
    flip_flag = data_sequence_image.image_flip_flag_sequence(ss);
    I = Generate_VisualStim_And_VelEstimation_Utils_LoadImage...
        (image_ID,synthetic_image_source_full_path, synthetic_type);
    if flip_flag
        I = fliplr(I);
    end
    scene_stim(ss, :) = I(row_pos, :);
end
end