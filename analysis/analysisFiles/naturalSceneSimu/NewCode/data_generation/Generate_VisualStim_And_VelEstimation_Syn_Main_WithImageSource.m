function Generate_VisualStim_And_VelEstimation_Syn_Main_WithImageSource...
    (image_process_info,image,simulation_stim,velocity,time, kernel, vel_range_bank, varargin)

synthetic_flag_bank = false;
synthetic_type_bank = [];
which_kernel_type = [];
% n_different_phases = 10;
n_total_sample_points = 70;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
%% image path and result storage path.
S = GetSystemConfiguration;
visual_stimulus_full_path = cell(length(synthetic_type_bank), 1);
synthetic_image_source_full_path = cell(length(synthetic_type_bank), 1);

for ii = 1:1:length(synthetic_type_bank)
    % synthetic_type
    synthetic_type = synthetic_type_bank{ii};
    synthetic_flag = synthetic_flag_bank(ii);
    
    % path for the precalculated synthetic scene
    synthetic_image_source_relative_path = NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','image_source', 'synthetic_flag',synthetic_flag, 'synthetic_type', synthetic_type);
    synthetic_image_source_full_path{ii} =  fullfile(S.natural_scene_simulation_path, 'image', synthetic_image_source_relative_path);
    
    % path for storage.
    if isempty(synthetic_type)
        visual_stimulus_relative_path = 'ns';
    else
        visual_stimulus_relative_path = synthetic_type;
    end
    %     visual_stimulus_relative_path = NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','visual_stimulus','synthetic_flag',synthetic_flag,'synthetic_type',synthetic_type);
    visual_stimulus_full_path{ii} = fullfile(S.natural_scene_simulation_path, 'visual_stimulus', visual_stimulus_relative_path);
end

%% initialization.
n_hor = 927;
n_vel = length(vel_range_bank);

sample_counter = 1;
%% just load all image.
load(fullfile(synthetic_image_source_full_path{1}, 'Image1.mat')); % 
n_total_sample_points = size(I, 1); % should be scenes only.

v_real_all = zeros(n_hor, n_vel, n_total_sample_points);
v2_different_types = zeros(n_hor, n_vel, n_total_sample_points, length(synthetic_type_bank));
v3_different_types = zeros(n_hor, n_vel, n_total_sample_points, length(synthetic_type_bank));


%% start simulation
for m = 1:1:n_total_sample_points % the length of image_sequence might be smaller than nSpI
    oneRow_use = I(m, :);
    %% get image for this condition.
    
    parfor vv = 1:1:length(vel_range_bank)
        v_real = vel_range_bank(vv);
        stim_full = VisualStimulusGeneration_Utils_CreateXT(oneRow_use, v_real, time, image);
        [v2_one_velocity, v3_one_velocity] = VelocityEstimation_OneStim_InputIsOneRow_AllKernel(stim_full, kernel, 'which_kernel_type',which_kernel_type);
        
        v2_different_types(:,vv,sample_counter, ii)= v2_one_velocity;
        v3_different_types(:,vv,sample_counter, ii)= v3_one_velocity;
        v_real_all(:,vv, sample_counter) = v_real;
    end
    sample_counter = sample_counter + 1;
end

%% after you finish compuatation, store all of them together.
unit_name = sprintf('unit_%s', datestr(now,'mm_dd_HH_MM_SS'));
for ii = 1:1:length(synthetic_type_bank)
    storage_full_path = fullfile(visual_stimulus_full_path{ii}, unit_name);
    if ~exist(visual_stimulus_full_path{ii}, 'dir')
        mkdir(visual_stimulus_full_path{ii})
    end
    v2 = squeeze(v2_different_types(:,:,:,ii));
    v3 = squeeze(v3_different_types(:,:,:,ii));
    v_real = v_real_all;
    save(storage_full_path, 'v2','v3','v_real'); clear v2 v3
end

end

