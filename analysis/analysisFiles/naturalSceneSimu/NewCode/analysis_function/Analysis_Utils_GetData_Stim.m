function data = Analysis_Utils_GetData_Stim(image_process_info, velocity, spatial_range, which_kernel_type, varargin)
synthetic_flag = false;
synthetic_str = [];
which_data = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

S = GetSystemConfiguration;
% path for the storage of the stimulus.
visual_stimulus_relative_path = NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','visual_stimulus','synthetic_flag',synthetic_flag, 'synthetic_str',synthetic_str);
visual_stimulus_full_path = fullfile(S.natural_scene_simulation_path, which_kernel_type, 'visual_stimulus', visual_stimulus_relative_path);

% find all the data in it,
data_unit_info = dir(fullfile(visual_stimulus_full_path, '*.mat'));
contrast_all = [];
for nn = 1:1:length(data_unit_info)
    data_unit = load(fullfile(visual_stimulus_full_path, data_unit_info(nn).name));
    contrast_all = cat(2, contrast_all, {data_unit.data_storage_unit(:).stim});
end
contrast_first_line = cellfun(@(x) x(1,:), contrast_all, 'UniformOutput', false);
clear contrast_all;
data = cell2mat(contrast_first_line);

end