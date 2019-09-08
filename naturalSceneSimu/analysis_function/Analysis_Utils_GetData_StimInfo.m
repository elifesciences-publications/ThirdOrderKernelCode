function data = Analysis_Utils_GetData_StimInfo(image_process_info, velocity,  which_kernel_type, varargin)
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
image_ID = [];
row_pos = [];
for nn = 1:1:length(data_unit_info)
    data_unit = load(fullfile(visual_stimulus_full_path, data_unit_info(nn).name));
    image_ID  = cat(2, image_ID , [data_unit.data_storage_unit(:).image_ID]);
    row_pos = cat(2, row_pos, [data_unit.data_storage_unit(:).row_pos]);
end

data.image_ID = image_ID;
data.row_num = row_pos;
end