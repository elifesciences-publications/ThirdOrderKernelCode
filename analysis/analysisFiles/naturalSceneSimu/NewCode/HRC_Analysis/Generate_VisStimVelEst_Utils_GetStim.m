function scene_stim = Generate_VisStimVelEst_Utils_GetStim(image_process_info, varargin)

synthetic_flag_bank = false;
synthetic_type_bank = [];
seed_num = 0;
n_total_image = 1000;
preselectimage_flag = false;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

S = GetSystemConfiguration;
synthetic_image_source_full_path = cell(length(synthetic_type_bank), 1);
for ii = 1:1:length(synthetic_type_bank)
    % synthetic_type
    synthetic_type = synthetic_type_bank{ii};
    synthetic_flag = synthetic_flag_bank(ii);
    
    % path for the precalculated synthetic scene
    synthetic_image_source_relative_path = NS_Filema_Param_To_FolderName([], image_process_info, [],'folder_use','image_source', 'synthetic_flag',synthetic_flag, 'synthetic_type', synthetic_type);
    synthetic_image_source_full_path{ii} =  fullfile(S.natural_scene_simulation_path, 'image', synthetic_image_source_relative_path);
end

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

scene_stim = cell(n_total_image, length(synthetic_type_bank));
sample_counter = 1;
for m = 1:1:length(image_sequence) % the length of image_sequence might be smaller than nSpI
    imageID = image_sequence(m);
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
        row_pos = image_row_pos_sequence{imageID}(k); % for different imageID, there was some predetermined value to use
        for ii = 1:1:length(synthetic_type_bank)
            I_this = I{ii};
            if flip_flag
                I_this = fliplr(I_this);
            end
            oneRow = I_this(row_pos,:);
            scene_stim{sample_counter, ii} = oneRow;
        end
        sample_counter = sample_counter + 1;
    end
end
end