function [stim_corr_data_sym_full,v_real_sym_full] = Analysis_Utils_GetData_Stim_Corr(image_process_info, velocity, spatial_range, which_kernel_type, varargin)
synthetic_flag = false;
synthetic_type = [];
corr_name = {'Two Point DT 1','Two Point DT 2', 'Two Point DT 3','Two Point DT 4',...
    'Diverging DT 1','Diverging DT 2','Diverging DT 3','Diverging DT 4',...
    'Converging DT 1','Converging DT 2', 'Converging DT 3','Converging DT 4',...
    'Elbow','Late Knight','Early Knight','Elbow Late Break','Elbow Early Break'};
visual_stimulus_relative_path_flag = 0;
visual_stimulus_relative_path = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

S = GetSystemConfiguration;
% path for the storage of the stimulus.
if ~ visual_stimulus_relative_path_flag
    visual_stimulus_relative_path = NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','visual_stimulus','synthetic_flag',synthetic_flag, 'synthetic_type',synthetic_type);
end
visual_stimulus_full_path = fullfile(S.natural_scene_simulation_path, which_kernel_type, 'visual_stimulus', visual_stimulus_relative_path);
% find all the data in it,
data_unit_info = dir(fullfile(visual_stimulus_full_path, '*.mat'));

stim_corr = [];
v_real  = [];
for nn = 1:1:length(data_unit_info)
    data_unit = load(fullfile(visual_stimulus_full_path, data_unit_info(nn).name));
    stim_corr_this = arrayfun(@(x)NS_Statistics_Calculate_Corr_From_Data(x, 'corr_name', corr_name), data_unit.data_storage_unit, 'UniformOutput', false);
    stim_corr  = cat(1, stim_corr , stim_corr_this);
    v_real = cat(2, v_real, [data_unit.data_storage_unit(:).v_real]);
end

% n_sample_points = length(v_real); % 54, 53 pair
n_space = size(stim_corr{1}, 1);
n_extra = n_space - spatial_range + 1;

%% create a adding matrix.
c = zeros(n_space, 1); c(1:spatial_range) = 1;
r = zeros(n_extra, 1); r(1) = 1;
adding_matrix = toeplitz(c, r);

%% reorganize the data and calculate the spatial average
A = cat(4, stim_corr{:});
B = permute(A,[4,1,2,3]);
n_corr = length(corr_name);
stim_corr_data = zeros(size(B,1), size(B,3), size(B,4));
for ii = 1:1:n_corr
    for jj = 1:1:2
        C_temp = squeeze(B(:,:,ii,jj)) * adding_matrix;
        stim_corr_data(:,ii,jj) = C_temp(:,1);
    end
end

%% symmetrize it.
v_real_anti_sym = - v_real;
stim_corr_data_anti_sym = zeros(size(stim_corr_data));
stim_corr_data_anti_sym(:,:,1) = stim_corr_data(:,:,2);
stim_corr_data_anti_sym(:,:,2) = stim_corr_data(:,:,1);

v_real_sym_full = [v_real, v_real_anti_sym];
stim_corr_data_sym_full = cat(1, stim_corr_data, stim_corr_data_anti_sym);
end