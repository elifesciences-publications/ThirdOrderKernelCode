function Generate_VisualStim_And_VelEstimation_Syn_Main_WithinScene_Gau...
    (image_process_info,image, velocity,time, kernel, varargin)

synthetic_flag_bank = false;
synthetic_type_bank = [];
seed_num = 0;
space_range = 54;
% n_different_phases = 10;
n_total_image = 70;
n_total_velocity = 2000; % is it enough? might be.
data_sequence_image_input = [];
preselectimage_flag = false;
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
if preselectimage_flag
    %% you will have the correct format.
    data_sequence_image = data_sequence_image_input;
else
    data_sequence_image = Generate_VisStimVelEst_Utils_GenerateImageSequence(n_total_image, 'seed_num', seed_num);
    % you might load the image
end
image_sequence = data_sequence_image.image_sequence;
image_row_pos_sequence = data_sequence_image.image_row_pos_sequence;
image_flip_flag_sequence = data_sequence_image.image_flip_flag_sequence;
nSpI = data_sequence_image.nSpI;

%% you should generate random column position and velocity here. use that across all images.
[vel_sequence, col_pos_sequence] = Generate_VisStimVelEst_Utils_WithinScene_GenVel(n_total_velocity,  velocity, 'seed_num', seed_num);

%% initialization.
v_real_all = zeros(n_total_velocity, n_total_image);
v2_different_types = zeros(space_range - 1, n_total_velocity, n_total_image, length(synthetic_type_bank));
v3_different_types = zeros(space_range - 1, n_total_velocity, n_total_image, length(synthetic_type_bank));

sample_counter = 1;

%% everytime, decide where to start the simulation.
% do not do the scrambline...
%% start simulation
for m = 1:1:length(image_sequence) % the length of image_sequence might be smaller than nSpI
    tic
    imageID = image_sequence(m);
    if nSpI(imageID)~= 0
        ii = 1;
        synthetic_type = synthetic_type_bank{ii};
        synthetic_image_source_full_path_this = synthetic_image_source_full_path{ii};
        I = Generate_VisualStim_And_VelEstimation_Utils_LoadImage...
            (imageID,synthetic_image_source_full_path_this, synthetic_type);
    end
    
    for k = 1:1:nSpI(imageID)
        % stim is a xt plot.spatial resolution is .38degree/pixel
        flip_flag = image_flip_flag_sequence{imageID}(k);
        if flip_flag
            I = fliplr(I);
        end
        row_pos = image_row_pos_sequence{imageID}(k); % for different imageID, there was some predetermined value to use
        oneRow = I(row_pos,:);
        for ii = 1:1:length(synthetic_type_bank)
            if isempty(synthetic_type_bank{ii})
                oneRow_use = oneRow;
            else
                oneRow_use_cell = Generate_VisualStim_And_VelEstimation_Utils_ManipulateOneScene(oneRow,{'scramble_phase'});
                oneRow_use = oneRow_use_cell{1};
            end
            %% get image for this condition.
            tic
            for vv = 1:1:length(vel_sequence)
                v_real = vel_sequence(vv);
                stim_full = VisualStimulusGeneration_Utils_CreateXT(oneRow_use, v_real, time, image);
                column_pos_reference = col_pos_sequence(vv);
                column_pos = VelocityEstimation_SelectPos(column_pos_reference);
                
                
                stim = stim_full(:, column_pos);
                vest = VelocityEstimation_OneStim(stim, kernel);
                
                %                 plot_scatter_plot_correlation_one_situation(data_this , 'matlab_debug','plot_flag', true);
                v2_different_types(:, vv,sample_counter, ii)= vest.v2;
                v3_different_types(:, vv,sample_counter, ii)= vest.v3;
                v_real_all(vv, sample_counter) =  v_real;
                
            end
            toc
        end
        sample_counter = sample_counter + 1;
        
    end
    toc
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

