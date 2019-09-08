function [behavior_kernel_ind, behavior_kernel_ave] = Analysis_Function_Get_Mean_Behavior(file_full_path_all, process_stim_flag, process_stim_FWHM, kernel_extraction_method, which_data)

kernel_identifier.kernel_process_stim_flag = process_stim_flag;
kernel_identifier.kernel_process_stim_FWHM = process_stim_FWHM;
kernel_identifier.kernel_extraction_method = kernel_extraction_method;
kernel_identifier.data_source = 'behavior';

if contains(which_data, 'third')
    order = 3;
elseif contains(which_data, 'second')
    order = 2;
elseif contains(which_data, 'first')
    order = 1;
end
% how to doyou make it first order compatible?
n_file = length(file_full_path_all);
nMultiBars_all = [];
kernel_all = [];
for ff = 1:1:n_file
    filepath = file_full_path_all{ff};
    data = Analysis_Function_Loading_Draft(filepath, kernel_identifier, 'which_data', which_data);
    kernel_all = cat(3,kernel_all, mat2cell(data{1}, size(data{1},1), size(data{1},2), ones(size(data{1}, 3), 1)));
    
    nMultiBars_this = decipher_nMulitbars_from_full_file_path(filepath);
    n_fly_this = size(data{1}, 3);
    nMultiBars_all =cat(1, nMultiBars_all, repmat( nMultiBars_this, [n_fly_this, 1]));
end

%% turn it into idea format.
% behavior_kernel = cat(3, behavior_kernel{:});

n_fly = size(kernel_all, 3);
behavior_kernel = cell(1, n_fly);
for nn = 1:1:n_fly
    % for each fly, knows it nMultiBars;
    nMultiBars_this = nMultiBars_all(nn);
    switch order
        case 1
            behavior_kernel_neaby_bars = mean(kernel_all{nn}, 2);
            behavior_kernel{nn} = Analysis_Function_Get_Mean_Behavior_Utils_RescaleKernel(behavior_kernel_neaby_bars, nMultiBars_this);
        case 2
            behavior_kernel_neaby_bars = ConvertCovMatToK2(kernel_all{nn}, nMultiBars_this);
            % get one more step. combine 3-bar multibar flicker and 4-bar
            % multibar flicker.
            behavior_kernel{nn} = Analysis_Function_Get_Mean_Behavior_Utils_RescaleKernel(behavior_kernel_neaby_bars, nMultiBars_this);
            behavior_kernel{nn} = behavior_kernel{nn}(:);
        case 3
            behavior_kernel_neaby_bars = mean(kernel_all{nn}(:,:),2);
            behavior_kernel{nn} = Analysis_Function_Get_Mean_Behavior_Utils_RescaleKernel(behavior_kernel_neaby_bars, nMultiBars_this);
            
    end
end
behavior_kernel_ind = cell2mat(behavior_kernel);
behavior_kernel_ave = mean(behavior_kernel_ind, 2);
% cat it in the
end

