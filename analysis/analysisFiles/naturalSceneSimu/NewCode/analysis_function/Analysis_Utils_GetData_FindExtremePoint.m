function [data_extreme, file_num, data_num] = Analysis_Utils_GetData_FindExtremePoint(image_process_info, velocity, spatial_range, which_kernel_type, varargin)
synthetic_flag = false;
synthetic_type = [];
n_selected = 5;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

S = GetSystemConfiguration;
% path for the storage of the stimulus.
visual_stimulus_relative_path = NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','visual_stimulus','synthetic_flag',synthetic_flag, 'synthetic_type',synthetic_type);
visual_stimulus_full_path = fullfile(S.natural_scene_simulation_path, which_kernel_type, 'visual_stimulus', visual_stimulus_relative_path);

% find all the data in it,
data_unit_info = dir(fullfile(visual_stimulus_full_path, '*.mat'));
v_est = [];
v_real = [];
n_data_point_each_file = zeros(length(data_unit_info), 1);
for nn = 1:1:length(data_unit_info)
    data_unit = load(fullfile(visual_stimulus_full_path, data_unit_info(nn).name));
    if isfield(data_unit, 'data_storage_unit')
        v_est = cat(2, v_est, [data_unit.data_storage_unit(:).v_est]);
        v_real = cat(2, v_real, [data_unit.data_storage_unit(:).v_real]);
        n_data_point_each_file(nn) = length(data_unit.data_storage_unit);
    elseif isfield(data_unit, 'data_storage_unit_sc')
        v_est = cat(2, v_est, [data_unit.data_storage_unit_sc(:).v_est]);
        v_real = cat(2, v_real, [data_unit.data_storage_unit_sc(:).v_real]);
        n_data_point_each_file(nn) = length(data_unit.data_storage_unit_sc);
    elseif isfield(data_unit, 'data_storage_unit_spatial_corr')
        v_est = cat(2, v_est, [data_unit.data_storage_unit_spatial_corr(:).v_est]);
        v_real = cat(2, v_real, [data_unit.data_storage_unit_spatial_corr(:).v_real]);
        n_data_point_each_file(nn) = length(data_unit.data_storage_unit_spatial_corr);
        
    else
        keyboard
    end
end

% n_sample_points = length(v_real); % 54, 53 pair
n_space = size(v_est(1).v2, 1);

%% if spatial_range = 1;
n_extra = n_space - spatial_range + 1;
v2_individual = [v_est(:).v2];
v3_individual = [v_est(:).v3];

%% create a adding matrix.
c = zeros(n_space, 1); c(1:spatial_range) = 1;
r = zeros(n_extra, 1); r(1) = 1;
adding_matrix = toeplitz(c, r);

%% add across space
v2 = v2_individual' *  adding_matrix; v2 = v2(:, 1);
v3 = v3_individual' * adding_matrix; v3 = v3(:, 1);
v_real = v_real';

%% find the top 10 points.
% you should get the largest and smallest by absolute value.
[~, v2_sort_ind] = sort(abs(v2),'descend'); % top 5 values.
v2_sort_ind_selected = v2_sort_ind(1:n_selected);
% for each ind, code the index into file number
data_extreme = repmat(struct('image_ID',[],'flip_flag',[],'row_pos',[],'column_pos',[],'v_real',[],'stim',[],'v_est',[],'synthetic_type',[]), n_selected, 1);
file_num = zeros(n_selected, 1);
data_num = zeros(n_selected, 1);
for ii = 1:1:n_selected
    [file_num(ii), data_num(ii)] = find_extreme_estimation_from_gloabl_index_to_single_data_point(v2_sort_ind_selected(ii), n_data_point_each_file);
    % look at the data and see whether it is correct.
    data_unit_this_file = load(fullfile(visual_stimulus_full_path, data_unit_info(file_num(ii)).name));
    
    if isfield(data_unit, 'data_storage_unit')
        data_point_this = data_unit_this_file.data_storage_unit(data_num(ii));
        
    elseif isfield(data_unit, 'data_storage_unit_sc')
        data_point_this = data_unit_this_file.data_storage_unit_sc(data_num(ii));
        
    elseif isfield(data_unit, 'data_storage_unit_spatial_corr')
        data_point_this = data_unit_this_file.data_storage_unit_spatial_corr(data_num(ii));
    end
    
    % double check you are using the correct point.
    %     v_real_found = data_point_this.v_real
    %     v_real_this = v_real(v2_sort_ind_selected(ii))
    %
    %     v_est_v2_found = data_point_this.v_est.v2' * adding_matrix
    %     v_est_v2_abs_this = v2_sort_abs_value(ii)
    %     v2_est_v2_this = v2(v2_sort_ind_selected(ii))
    % store the informiaotn.
    data_extreme(ii) = data_point_this;
end
end


function [file_num, data_num] = find_extreme_estimation_from_gloabl_index_to_single_data_point(global_index, n_data_point_each_file)
% first, find which file it is in.
n_point_in_each_file_cumsum = [0;cumsum(n_data_point_each_file)];
file_num = find(global_index > n_point_in_each_file_cumsum(1: end - 1) & global_index <= n_point_in_each_file_cumsum(2: end));
data_num = global_index - n_point_in_each_file_cumsum(file_num);
end
