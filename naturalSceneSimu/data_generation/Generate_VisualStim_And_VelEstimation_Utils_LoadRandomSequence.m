function data_sequence = Generate_VisualStim_And_VelEstimation_Utils_LoadRandomSequence...
    (force_new_data_sequence_flag, save_new_data_sequence_flag, velocity, mode, varargin)
%%
n_total_sample_points = 100000;
num_files = 50;
which_file_to_use = []; % you have to make the decision here? or somewhere else? here?
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% path for save image sequence information
S = GetSystemConfiguration;
switch mode
    case 'velocity'
        vel_folder  = sprintf('%s%d', velocity.distribution, velocity.range);
        file_path_for_data_sequence = fullfile(S.natural_scene_simulation_path, 'image', 'vel_sequence',vel_folder);
    case 'image'
        file_path_for_data_sequence = fullfile(S.natural_scene_simulation_path, 'image', 'image_sequence');
        
end

if force_new_data_sequence_flag
    %% generate image sequence for all potential future situations
    n_sample_points_in_one_file = floor(n_total_sample_points/num_files);
    for ii = 1:1:num_files
        switch mode
            case 'velocity'
                data_sequence = Generate_VisStimVelEst_Utils_GenerateVelocitySequence(n_sample_points_in_one_file, velocity, 'seed_num', ii); % okay, you will never change it again.
            case 'image'
                data_sequence = Generate_VisStimVelEst_Utils_GenerateImageSequence(n_sample_points_in_one_file, 'seed_num', ii); % okay, you will never change it again.
        end
        file_name_for_data_sequence = fullfile(file_path_for_data_sequence, ['data_sequence_predetermined_', num2str(ii),'.mat']);
        if save_new_data_sequence_flag
            if ~ exist(file_path_for_data_sequence, 'file')
                mkdir(file_path_for_data_sequence)
            end
            save(file_name_for_data_sequence, 'data_sequence');
        end
    end
else
    %% load image sequence
    if isempty(which_file_to_use)
        error('you have to decide which file to use'); % do not use default. what if you want to change? thus use date to do it?
        keyboard;
    end
    file_name_for_data_sequence = fullfile(file_path_for_data_sequence, ['data_sequence_predetermined_', num2str(which_file_to_use) ,'.mat']);
    load(file_name_for_data_sequence);
end

%

end