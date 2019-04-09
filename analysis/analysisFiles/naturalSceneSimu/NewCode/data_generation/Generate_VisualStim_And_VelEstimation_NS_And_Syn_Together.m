function Generate_VisualStim_And_VelEstimation_NS_And_Syn_Together(image_process_info,image,simulation_stim,velocity,time, kernel, varargin)

synthetic_flag_bank = false;
synthetic_type_bank = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
%% image path and result storage path.
S = GetSystemConfiguration;
% path for the preprocessed image.
image_source_relative_path =  NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','image_source', 'synthetic_flag',false);
image_source_full_path = fullfile(S.natural_scene_simulation_path, 'image', image_source_relative_path);

visual_stimulus_full_path = cell(length(synthetic_type_bank), 1);
for ii = 1:1:length(synthetic_type_bank)
    % synthetic_type can
    synthetic_type = synthetic_type_bank{ii};
    synthetic_flag = synthetic_flag_bank(ii);
    visual_stimulus_relative_path = NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','visual_stimulus','synthetic_flag',synthetic_flag,'synthetic_type',synthetic_type);
    visual_stimulus_full_path{ii} = fullfile(S.natural_scene_simulation_path, 'visual_stimulus', visual_stimulus_relative_path);
end

%% prepare filter
if strcmp('dynamic',image_process_info.contrast) || strcmp('dynamic_both_future_and_past',image_process_info.contrast)
    contrast_filter = VisualStimulusGeneration_Utils_GenerateTempFilter(image_process_info.tf_tau);
end

%% number of samples and storage organization.
n_total_sample_points = simulation_stim.n_samplepoints;
nSpS = simulation_stim.nSps;
data_struct = struct('image_ID', [],  'flip_flag', [], 'row_pos',[], 'column_pos', [], 'v_real', [], 'stim', [], 'v_est', [],'synthetic_type',[]);
data_storage_struct = repmat(data_struct, [nSpS, 1]);

%% randomly choose image to use.
imageDataInfo  = dir(fullfile(image_source_full_path, '*.mat'));
nVerPixel = image.param.ver.nPixel;
imageIDBank = 1:1:length(imageDataInfo);
% imageIDBank(imageOutlier) = [];
nImage = length(imageIDBank);
nSpI = ChoseImage(nImage,n_total_sample_points); % every image has particular number of stimulus. uniformly sample from different images.
imageSequence = randperm(nImage);

%% initialization.
storage_unit_counter = 1; % storage_sample_unit_counter counts how many storage units data has been computed.
storage_sample_unit_counter = 1; % storage_sample_unit_counter counts how many data has been collected for this storage unit, when it reaches nSpS, the data will be stored into file
all_sample_unit_counter = 1; % counter counts how many data unit has been calculated. the name of the data will be determined by the final number of counter.
data_storage_unit_all = cell(length(synthetic_type_bank), 1);
for ii = 1:1:length(synthetic_type_bank)
    data_storage_unit_all{ii} = data_storage_struct;
end
%% simulation
for m = 1:1:nImage
    % choose image
    
    imageID = imageSequence(m);
    I = LoadProcessedImage(imageID,imageDataInfo,image_source_full_path);
    for k = 1:1:nSpI(imageID);
        % determine whether to flip the picture, balance the left and right.
        % posRow is the position of a randomly choosed row.
        % vel is a random velocity drawn from targeted distribution.
        % stim is a xt plot.spatial resolution is .38degree/pixel
        flip_flag = rand > 0.5;
        
        if flip_flag
            I = fliplr(I);
        end
        
        solved_flag = false;
        while ~solved_flag
            row_pos = randi(nVerPixel);
            oneRow = I(row_pos,:);
            [one_row_different_types, solved_flag_all]  = Generate_VisualStim_And_VelEstimation_Utils_ManipulateOneScene(oneRow, synthetic_type_bank);
            solved_flag = prod(solved_flag_all);
        end
        v_real = VisualStimulusGeneration_Utils_SampleOneV(velocity);
        %% shared information across all types of simulation.
        data.image_ID = imageID;
        data.flip_flag = flip_flag;
        data.row_pos = row_pos;
        data.v_real = v_real;
        
        
        %% natural scene stim and corresponding manipulation.
        
        
        
        %% moving the scene.
        data_points_different_types = repmat(data, length(synthetic_type_bank), 1);
        for ii = 1:1:length(synthetic_type_bank)
            %% get stimulus. using
            switch image_process_info.contrast
                case 'static'
                    stim_full = VisualStimulusGeneration_Utils_CreateXT(one_row_different_types{ii}, v_real, time, image);
                    column_pos = VelocityEstimation_SelectPos('synthetic_flag', synthetic_flag_bank(ii));
                    stim = stim_full(:, column_pos);
                case 'dynamic'
                    [stim, column_pos] = VisualStimulusGeneration_Utils_CreateXT_Dyna_Con(one_row_different_types{ii}, v_real, time, contrast_filter, 'synthetic_flag', synthetic_flag_bank(ii));
                    
                case 'dynamic_both_future_and_past'
                    [stim, column_pos] = VisualStimulusGeneration_Utils_CreateXT_Dyna_Con_BothSide(one_row_different_types{ii}, v_real, time, contrast_filter,'synthetic_flag', synthetic_flag_bank(ii));
                    
            end
            
            %%
            v_est = VelocityEstimation_OneStim(stim, kernel);
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
            storage_unit_counter = storage_unit_counter + 1;
        end
        
        storage_sample_unit_counter = storage_sample_unit_counter  + 1;
        all_sample_unit_counter = all_sample_unit_counter + 1;
    end
end
end