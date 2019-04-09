function data_extreme_all_types = Analysis_Utils_GetData_FindExtremePoint_MatcheUp(image_process_info, velocity, spatial_range, which_kernel_type, varargin)
synthetic_flag_bank = false;
synthetic_type_bank = []; %
n_selected = 5;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

S = GetSystemConfiguration;
%% first, get the idea of which data point to use.
[data_extreme_ns, file_num, data_num] = Analysis_Utils_GetData_FindExtremePoint(image_process_info, velocity, spatial_range, which_kernel_type, ...
    'synthetic_flag',false, 'synthetic_type', [],'n_selected', n_selected);

data_extreme_all_types = cell(length(synthetic_flag_bank), 1);
%% second, matched it up.
for ii = 1:1:length(synthetic_flag_bank)
    synthetic_flag = synthetic_flag_bank(ii);
    synthetic_type = synthetic_type_bank{ii};
    visual_stimulus_relative_path = NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','visual_stimulus','synthetic_flag',synthetic_flag, 'synthetic_type',synthetic_type);
    visual_stimulus_full_path = fullfile(S.natural_scene_simulation_path, which_kernel_type, 'visual_stimulus', visual_stimulus_relative_path);

    
    data_unit_info = dir(fullfile(visual_stimulus_full_path, '*.mat'));
    
    % now load the data accordingly.
    data_extreme_all_types{ii} = repmat(struct('image_ID',[],'flip_flag',[],'row_pos',[],'column_pos',[],'v_real',[],'stim',[],'v_est',[],'synthetic_type',[]), n_selected, 1);
    for nn = 1:1:n_selected
        data_unit = load(fullfile(visual_stimulus_full_path, data_unit_info(file_num(nn)).name));
        
        if isfield(data_unit, 'data_storage_unit')
            data_point_this = data_unit.data_storage_unit(data_num(nn));
            
        elseif isfield(data_unit, 'data_storage_unit_sc')
            data_point_this = data_unit.data_storage_unit_sc(data_num(nn));
            
        elseif isfield(data_unit, 'data_storage_unit_spatial_corr')
            data_point_this = data_unit.data_storage_unit_spatial_corr(data_num(nn));
        end
        
        data_extreme_all_types{ii}(nn) = data_point_this;
    end
end