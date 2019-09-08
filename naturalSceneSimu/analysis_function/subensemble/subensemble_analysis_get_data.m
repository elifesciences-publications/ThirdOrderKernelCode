function [data, scene_stim] = subensemble_analysis_get_data()

is_symmetrize_flag = false;
which_kernel_type = 'rc_match_up_iskew';
synthetic_flag = 0;
synthetic_type = '';
velocity_range = 114;
[data, stim_info] = Analysis_Utils_GetData_OneCondition_Symmetrize_NoStorage(which_kernel_type, synthetic_flag, synthetic_type,...
    'velocity_range', velocity_range, 'is_symmetrize_flag', is_symmetrize_flag);
%% load image from current information. interesting...
data_sequence_input.image_sequence = stim_info.image_ID;
data_sequence_input.image_row_pos_sequence = stim_info.row_pos;
data_sequence_input.image_flip_flag_sequence = zeros(length(stim_info.row_pos));
scene_stim = reload_images_used_for_scramble_phase_analysis([], false, [], 25, [], ...
    'preselect_data_sequence_image', true, 'data_sequence_image', data_sequence_input);
end