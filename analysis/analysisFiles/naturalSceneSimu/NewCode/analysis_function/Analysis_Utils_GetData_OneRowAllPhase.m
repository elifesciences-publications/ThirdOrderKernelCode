function data = Analysis_Utils_GetData_OneRowAllPhase(synthetic_type, which_kernel_type, varargin)
spatial_average_flag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

S = GetSystemConfiguration;
% path for the storage of the stimulus.

visual_stimulus_relative_path = synthetic_type;
visual_stimulus_full_path = fullfile(S.natural_scene_simulation_path, which_kernel_type, 'visual_stimulus', visual_stimulus_relative_path);

% find all the data in it,
data_unit_info = dir(fullfile(visual_stimulus_full_path, '*.mat'));
v2= []; % position, by velocity, by scene.
v_real = [];
for nn = 1:1:length(data_unit_info)
    data_unit = load(fullfile(visual_stimulus_full_path, data_unit_info(nn).name));
    if spatial_average_flag
        % average over space.
        v2_this = zeros(size(data_unit.v2));
        nhor = 927;
        column_pos = mod(bsxfun(@plus, (0:53) * 13 - 1, (1:nhor)') -1, nhor) + 1;
        for pp = 1:1:size(column_pos,1)
            v2_to_be_averaged = data_unit.v2(column_pos(pp,:),:,:);
            v2_this(pp,:,:) = mean(v2_to_be_averaged, 1);
        end
        % you have to append different v2 together... 
        v2 = cat(3, v2_this, v2); % 927 * 1000;
    else
        v2 = cat(2, v2, [data_unit.v2]); % 927 * 1000;
    end
    v_real = cat(3, v_real, [data_unit.v_real]);
    
end
% symmetrize the velocities
data.v2 = v2;
data.v_real = v_real;


if isfield(data_unit, 'v3');
    % for real kernels, there will be third order kernel.
    v3 = [];
    for nn = 1:1:length(data_unit_info)
        data_unit = load(fullfile(visual_stimulus_full_path, data_unit_info(nn).name));
        if spatial_average_flag
            % average over space.
            v3_this = zeros(size(data_unit.v3));
            nhor = 927;
            column_pos = mod(bsxfun(@plus, (0:53) * 13 - 1, (1:nhor)') -1, nhor) + 1;
            for pp = 1:1:size(column_pos,1)
                v3_to_be_averaged = data_unit.v3(column_pos(pp,:),:,:);
                v3_this(pp,:,:) = mean(v3_to_be_averaged, 1);
            end
            v3 = cat(3, v3, v3_this); % 927 * 1000;
        else
            v3 = cat(3, v3, v3_this); % 927 * 1000;
        end
    end
    data.v3 = v3;
end

end