function data = Analysis_Utils_GetData(image_process_info, velocity, spatial_range, which_kernel_type, varargin)
synthetic_flag = false;
synthetic_type = [];
% whether exclude data. If the exitflag is less than 0, exclude those.
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

S = GetSystemConfiguration;
% path for the storage of the stimulus.
visual_stimulus_relative_path = NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','visual_stimulus','synthetic_flag',synthetic_flag, 'synthetic_type',synthetic_type);
visual_stimulus_full_path = fullfile(S.natural_scene_simulation_path, which_kernel_type, 'visual_stimulus', visual_stimulus_relative_path);

%% if it is mde, find the folder for solution as well.

% find all the data in it,
data_unit_info = dir(fullfile(visual_stimulus_full_path, '*.mat'));
v_est = [];
v_real = [];

for nn = 1:1:length(data_unit_info)
    data_unit = load(fullfile(visual_stimulus_full_path, data_unit_info(nn).name));
    
    if isfield(data_unit, 'data_storage_unit')
        v_est = cat(2, v_est, [data_unit.data_storage_unit(:).v_est]);
        v_real = cat(2, v_real, [data_unit.data_storage_unit(:).v_real]);
    elseif isfield(data_unit, 'data_storage_unit_sc') % you will get rid of all these after a while.
        v_est = cat(2, v_est, [data_unit.data_storage_unit_sc(:).v_est]);
        v_real = cat(2, v_real, [data_unit.data_storage_unit_sc(:).v_real]);
    elseif isfield(data_unit, 'data_storage_unit_spatial_corr')
        v_est = cat(2, v_est, [data_unit.data_storage_unit_spatial_corr(:).v_est]);
        v_real = cat(2, v_real, [data_unit.data_storage_unit_spatial_corr(:).v_real]);
    else
        keyboard
    end
    % you will decide whether to exclude some of the data.
    
end

% n_sample_points = length(v_real); % 54, 53 pair
n_space = size(v_est(1).v2, 1);

%% if spatial_range = 1;
n_extra = n_space - spatial_range + 1;
v2_individual = [v_est(:).v2];
if isfield(v_est, 'v3')
    v3_individual = [v_est(:).v3];
end
%% create a adding matrix.
c = zeros(n_space, 1); c(1:spatial_range) = 1;
r = zeros(n_extra, 1); r(1) = 1;
adding_matrix = toeplitz(c, r);

% randomly choose one column instead of all of them?

% v2 = v2_individual' *  adding_matrix; v2 = v2'; v2 = v2(:);
% v3 = v3_individual' * adding_matrix; v3 = v3'; v3 = v3(:);
% v_real = repmat(v_real, [1, n_extra]); v_real = v_real'; v_real = v_real(:);

v2 = v2_individual' *  adding_matrix; v2 = v2(:, 1);
if isfield(v_est, 'v3')
    v3 = v3_individual' * adding_matrix; v3 = v3(:, 1);
end
v_real = v_real';
data.v2 = v2;
if isfield(v_est, 'v3')
    data.v3 = v3;
else
    data.v3 = [];
end
data.v_real = v_real;
%% This is a completely new part.
n_data_point = length(v2);
if strcmp( synthetic_type ,'m_sc_i_cd') || strcmp( synthetic_type ,'i_sc_i_cd') || strcmp( synthetic_type ,'m_sc_i_cd_fullcov') || strcmp( synthetic_type ,'i_sc_i_cd_fullcov')
    image_ID = [] ;
    row_pos = [];
    for nn = 1:1:length(data_unit_info)
        data_unit = load(fullfile(visual_stimulus_full_path, data_unit_info(nn).name));
        image_ID = cat(2, image_ID, [data_unit.data_storage_unit(:).image_ID]);
        row_pos = cat(2, row_pos, [data_unit.data_storage_unit(:).row_pos]);
    end
    
    solved_flag = zeros(n_data_point, 1);
    exit_flag = zeros(n_data_point, 1);
    [synthetic_image_individual_info_full_path, ~, ~, ~] = Generate_SynImages_Utils_GetInfoPath(velocity, image_process_info, synthetic_flag, synthetic_type);
    imageDataInfo  = dir(fullfile(synthetic_image_individual_info_full_path, '*.mat'));
    n_image = length(imageDataInfo);
    for nn = 1:1:n_image
        % do this image by image.
        ind_for_this_image = find(nn == image_ID);
        row_pos_for_this_image = row_pos(ind_for_this_image);
        med_info_this_image = load(fullfile(synthetic_image_individual_info_full_path,  imageDataInfo(nn).name));
        %
        solved_flag(ind_for_this_image) = [med_info_this_image.med(row_pos_for_this_image).solved_flag];
        exit_flag(ind_for_this_image) = [med_info_this_image.med(row_pos_for_this_image).exitflag];
    end
else    
    solved_flag = ones(n_data_point, 1);
    exit_flag = ones(n_data_point, 1);
end
data.solved_flag = solved_flag;
data.exit_flag = exit_flag;
end