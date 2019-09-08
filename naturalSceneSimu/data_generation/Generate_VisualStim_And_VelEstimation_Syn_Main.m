function Generate_VisualStim_And_VelEstimation_Syn_Main(image_process_info,image,simulation_stim,velocity,time, kernel, varargin)

synthetic_flag_bank = false;
synthetic_type_bank = [];
force_new_image_selection_flag = true; %
which_file_to_use = [];
mean_subtraction_vstim_flag = 0;
mean_subtraction_onerow_flag = 0;
kernel_extraction_method = 'reverse_correlation';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
%% image path and result storage path.
S = GetSystemConfiguration;
% % path for the preprocessed image.
% image_source_relative_path =  NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','image_source', 'synthetic_flag',false);
% image_source_full_path = fullfile(S.natural_scene_simulation_path, 'image', image_source_relative_path);

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
    visual_stimulus_relative_path = NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','visual_stimulus','synthetic_flag',synthetic_flag,'synthetic_type',synthetic_type);
    visual_stimulus_full_path{ii} = fullfile(S.natural_scene_simulation_path, 'visual_stimulus', visual_stimulus_relative_path);
end

%% prepare filter
if strcmp('dynamic',image_process_info.contrast) || strcmp('dynamic_both_future_and_past',image_process_info.contrast)
    contrast_filter = VisualStimulusGeneration_Utils_GenerateTempFilter(image_process_info.tf_tau);
    for ii = 1:1:length(synthetic_type_bank)
        if synthetic_type_bank{ii} == 1
            error('for dynamic mode, you should not have synthetic scene');
            keyboard;
        end
    end
end

%% number of samples and storage organization.
n_total_sample_points = simulation_stim.n_samplepoints;
nSpS = simulation_stim.nSps;
data_struct = struct('image_ID', [],  'flip_flag', [], 'row_pos',[], 'column_pos', [], 'v_real', [], 'stim', [], 'v_est', [],'synthetic_type',[]);
data_storage_struct = repmat(data_struct, [nSpS, 1]);

%% choose image to use. only if individual images are needed.
if force_new_image_selection_flag
    data_sequence_image = Generate_VisStimVelEst_Utils_GenerateImageSequence(n_total_sample_points, 'seed_num', 0); % okay, you will never change it again.
    velocity_sequence = Generate_VisStimVelEst_Utils_GenerateVelocitySequence(n_total_sample_points, velocity, 'seed_num', 0);
else
    data_sequence_image = Generate_VisualStim_And_VelEstimation_Utils_LoadRandomSequence(0, 0,[], 'image', 'which_file_to_use', which_file_to_use);
    velocity_sequence = Generate_VisualStim_And_VelEstimation_Utils_LoadRandomSequence(0, 0,velocity, 'velocity', 'which_file_to_use', which_file_to_use);
end
image_sequence = data_sequence_image.image_sequence;
image_row_pos_sequence = data_sequence_image.image_row_pos_sequence;
image_column_pos_sequence = data_sequence_image.image_column_pos_sequence;
image_flip_flag_sequence = data_sequence_image.image_flip_flag_sequence;
nSpI = data_sequence_image.nSpI;


%% initialization.
% storage_unit_counter = 1; % storage_sample_unit_counter counts how many storage units data has been computed.
% all_sample_unit_counter = 1; % counter counts how many data unit has been calculated. the name of the data will be determined by the final number of counter.

storage_sample_unit_counter = 1; % storage_sample_unit_counter counts how many data has been collected for this storage unit, when it reaches nSpS, the data will be stored into file
data_storage_unit_all = cell(length(synthetic_type_bank), 1);
for ii = 1:1:length(synthetic_type_bank)
    data_storage_unit_all{ii} = data_storage_struct;
end
%% simulation
tic
for m = 1:1:length(image_sequence) % the length of image_sequence might be smaller than nSpI
    % choose image
    imageID = image_sequence(m);
    
    % loading all manipulated image of this particular image.
    if nSpI(imageID)~= 0
        I = cell(length(synthetic_type_bank), 1);
        for ii = 1:1:length(synthetic_type_bank)
            synthetic_type = synthetic_type_bank{ii};
            synthetic_image_source_full_path_this = synthetic_image_source_full_path{ii};
            I{ii} = Generate_VisualStim_And_VelEstimation_Utils_LoadImage...
                (imageID,synthetic_image_source_full_path_this, synthetic_type);
        end
    end
    
    
    for k = 1:1:nSpI(imageID)
        % stim is a xt plot.spatial resolution is .38degree/pixel
        flip_flag = image_flip_flag_sequence{imageID}(k);
        v_real = velocity_sequence{imageID}(k); % determined by the contrast distribution, if it is binary value?
        row_pos = image_row_pos_sequence{imageID}(k); % for different imageID, there was some predetermined value to use.
        column_pos_reference = image_column_pos_sequence{imageID}(k);
        column_pos = VelocityEstimation_SelectPos(column_pos_reference);
        
        %% shared information across all types of simulation.
        data.image_ID = imageID;
        data.flip_flag = flip_flag;
        data.row_pos = row_pos;
        data.v_real = v_real;
        
        
        %% moving the scene.
        data_points_different_types = repmat(data, length(synthetic_type_bank), 1);
        for ii = 1:1:length(synthetic_type_bank)
            %% get image for this condition.
            I_this = I{ii};
            if flip_flag
                I_this = fliplr(I_this);
            end
            oneRow = I_this(row_pos,:);
            if mean_subtraction_onerow_flag
                oneRow = oneRow - mean(oneRow);
            end
            %% get stimulus. using
            switch image_process_info.contrast
                case 'static'
                    stim_full = VisualStimulusGeneration_Utils_CreateXT(oneRow, v_real, time, image);
                    stim = stim_full(:, column_pos);
                    
                case 'dynamic'
                    stim = VisualStimulusGeneration_Utils_CreateXT_Dyna_Con(oneRow, v_real, time, contrast_filter, column_pos);
                    
                case 'dynamic_both_future_and_past'
                    stim = VisualStimulusGeneration_Utils_CreateXT_Dyna_Con_BothSide(oneRow, v_real, time, contrast_filter, column_pos);
                    
                    %                 otherwise % otherwise would be dynamic.
                    %                     stim = VisualStimulusGeneration_Utils_CreateXT_Dyna_Con(oneRow, v_real, time, contrast_filter, column_pos);
            end
            
            %% do mean subtraction. how???
            %%
            if mean_subtraction_vstim_flag
                v_est = VelocityEstimation_OneStim_MeanSubtraction(stim, kernel);
            else
                switch kernel_extraction_method
                    case 'reverse_correlation'
                        v_est = VelocityEstimation_OneStim(stim, kernel);
                    case 'HRC'
                        v_2_hrc_this = VelocityEstimation_OneStim_HRC(stim, kernel);
                        v_est.v2 = v_2_hrc_this;
                end
            end
            data_points_different_types(ii).stim = stim;
            data_points_different_types(ii).v_est = v_est;
            data_points_different_types(ii).synthetic_type = synthetic_type_bank{ii};
            data_points_different_types(ii).column_pos = column_pos;
            data_storage_unit_all{ii}(storage_sample_unit_counter) = data_points_different_types(ii);
            
        end
        
        if storage_sample_unit_counter == nSpS
            % save current data into the folder.
            unit_name = sprintf('unit_%s', datestr(now,'mm_dd_HH_MM_SS'));
            %
            for ii = 1:1:length(synthetic_type_bank)
                storage_full_path = fullfile(visual_stimulus_full_path{ii}, unit_name);
                if ~exist(visual_stimulus_full_path{ii}, 'dir')
                    mkdir(visual_stimulus_full_path{ii})
                end
                data_storage_unit = data_storage_unit_all{ii};
                save(storage_full_path, 'data_storage_unit');
                clear data_storage_unit
            end
            data_storage_unit_all = cell(length(synthetic_type_bank), 1);
            for ii = 1:1:length(synthetic_type_bank)
                data_storage_unit_all{ii} = data_storage_struct;
            end
            
            storage_sample_unit_counter = 0;
        end
        
        storage_sample_unit_counter = storage_sample_unit_counter  + 1;
    end
end

end