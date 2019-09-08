function Generate_VisualStim_And_VelEstimation_Syn_Main_ScramblePhase...
    (image_process_info,image,simulation_stim,velocity,time, kernel, vel_range_bank, varargin)

synthetic_flag_bank = false;
synthetic_type_bank = [];
which_kernel_type = [];
seed_num = 0;
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
        visual_stimulus_relative_path = ['ns','FWHM', num2str(image_process_info.FWHM)];
    else
        visual_stimulus_relative_path = synthetic_type;
    end
%     visual_stimulus_relative_path = NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','visual_stimulus','synthetic_flag',synthetic_flag,'synthetic_type',synthetic_type);
    visual_stimulus_full_path{ii} = fullfile(S.natural_scene_simulation_path, 'visual_stimulus', visual_stimulus_relative_path);
end

%% number of samples and storage organization.
% n_total_sample_points = simulation_stim.n_samplepoints;
%% choose image to use. only if individual images are needed.
% this result is not very very interesting. actually, but you probably have
% to do it many times?
data_sequence_image = Generate_VisStimVelEst_Utils_GenerateImageSequence(n_total_sample_points, 'seed_num', seed_num);
% you might load the image 
image_sequence = data_sequence_image.image_sequence;
image_row_pos_sequence = data_sequence_image.image_row_pos_sequence;
image_flip_flag_sequence = data_sequence_image.image_flip_flag_sequence;
nSpI = data_sequence_image.nSpI;


%% initialization.
n_hor = 927;
n_vel = length(vel_range_bank);
v_real_all = zeros(n_hor, n_vel, n_total_sample_points);
v2_different_types = zeros(n_hor, n_vel, n_total_sample_points, length(synthetic_type_bank));
v3_different_types = zeros(n_hor, n_vel, n_total_sample_points, length(synthetic_type_bank));

sample_counter = 1;

%% everytime, decide where to start the simulation.
% do not do the scrambline...
%% start simulation
for m = 1:1:length(image_sequence) % the length of image_sequence might be smaller than nSpI
    imageID = image_sequence(m);
    if nSpI(imageID)~= 0
        ii = 1;
        synthetic_type = synthetic_type_bank{ii};
        synthetic_image_source_full_path_this = synthetic_image_source_full_path{ii};
        I = Generate_VisualStim_And_VelEstimation_Utils_LoadImage...
            (imageID,synthetic_image_source_full_path_this, synthetic_type);
    end
    
    for k = 1:1:nSpI(imageID);
        % stim is a xt plot.spatial resolution is .38degree/pixel
        flip_flag = image_flip_flag_sequence{imageID}(k);
        if flip_flag
            I = fliplr(I);
        end
        row_pos = image_row_pos_sequence{imageID}(k); % for different imageID, there was some predetermined value to use
        oneRow = I(row_pos,:);
        rng(0); % for e
        for ii = 1:1:length(synthetic_type_bank)
            if isempty(synthetic_type_bank{ii})
                oneRow_use = oneRow;
            else
                oneRow_use_cell = Generate_VisualStim_And_VelEstimation_Utils_ManipulateOneScene(oneRow,{'scramble_phase'});
                oneRow_use = oneRow_use_cell{1};
            end
            %% get image for this condition.
            
            parfor vv = 1:1:length(vel_range_bank)
                v_real = vel_range_bank(vv);
                stim_full = VisualStimulusGeneration_Utils_CreateXT(oneRow_use, v_real, time, image);
                [v2_one_velocity, v3_one_velocity] = VelocityEstimation_OneStim_InputIsOneRow_AllKernel(stim_full, kernel, 'which_kernel_type',which_kernel_type);
                
                v2_different_types(:,vv,sample_counter, ii)= v2_one_velocity;
                v3_different_types(:,vv,sample_counter, ii)= v3_one_velocity;
                v_real_all(:,vv, sample_counter) = v_real;
            end
        end
        sample_counter = sample_counter + 1;
        
    end
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

