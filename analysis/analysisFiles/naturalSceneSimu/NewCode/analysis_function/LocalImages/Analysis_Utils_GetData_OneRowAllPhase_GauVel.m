function data = Analysis_Utils_GetData_OneRowAllPhase_GauVel(visual_stimulus_relative_path, which_kernel_type, varargin)
spatial_average_flag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

S = GetSystemConfiguration;
% path for the storage of the stimulus.
visual_stimulus_full_path = fullfile(S.natural_scene_simulation_path, which_kernel_type, 'visual_stimulus', visual_stimulus_relative_path);

% find all the data in it,
data_unit_info = dir(fullfile(visual_stimulus_full_path, '*.mat'));
v2 = []; % position, by velocity, by scene.
v_real = [];
for nn = 1:1:length(data_unit_info)
    data_unit = load(fullfile(visual_stimulus_full_path, data_unit_info(nn).name));
    if spatial_average_flag
        v2 = cat(2, v2, squeeze(mean(data_unit.v2, 1))); % 927 * 1000;
        if ndims(data_unit.v_real) == 3
            v_real = cat(2, v_real, squeeze(mean(data_unit.v_real, 1)));
        elseif ndims(data_unit.v_real) == 2
%             if isempty(v_real)
%                 v_real = data_unit.v_real;
%             else
                v_real = cat(2, v_real, data_unit.v_real);
%             end
        end
    else
        % if you do not average. you should
        v2 = cat(2, v2, [data_unit.v2]); % 927 * 1000;
        v_real = cat(2, v_real, [data_unit.v_real]);
    end
end
% symmetrize the velocities
data.v2 = v2;
data.v_real = v_real;


if isfield(data_unit, 'v3')
    % for real kernels, there will be third order kernel.
    v3 = [];
    for nn = 1:1:length(data_unit_info)
        data_unit = load(fullfile(visual_stimulus_full_path, data_unit_info(nn).name));
        if spatial_average_flag
            v3 = cat(2, v3, squeeze(mean(data_unit.v3, 1))); % 927 * 1000;
        else
            v3 = cat(2, v3, [data_unit.v3]); % 927 * 1000;
        end
    end
    data.v3 = v3;
end

end