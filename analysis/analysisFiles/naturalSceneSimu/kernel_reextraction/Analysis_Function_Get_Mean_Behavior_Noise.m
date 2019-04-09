function [behavior_kernel_ave] = Analysis_Function_Get_Mean_Behavior_Noise(file_full_path_all, process_stim_flag, process_stim_FWHM, kernel_extraction_method, which_data)
n_noise = 100;

kernel_identifier.kernel_process_stim_flag = process_stim_flag;
kernel_identifier.kernel_process_stim_FWHM = process_stim_FWHM;
kernel_identifier.kernel_extraction_method = kernel_extraction_method;
kernel_identifier.data_source = 'behavior';

if strfind(which_data, 'third');
    order = 3;
elseif strfind(which_data, 'second')
    order = 2;
end
n_file = length(file_full_path_all);
n_fly_count_prev = 0;
n_fly_count_curr = 0;
behavior_kernel_average_prev = 0;
behavior_kernel_average_curr = 0;

for ff = 1:1:n_file
    filepath = file_full_path_all{ff};
    nMultiBars_this = decipher_nMulitbars_from_full_file_path(filepath);
    data = Analysis_Function_Loading_Draft(filepath, kernel_identifier, 'which_data', which_data);
    switch order
        case 2
            len_kernel = round((size(data{1},1)/nMultiBars_this)^2);
        case 3
            len_kernel = size(data{1},1);
    end
    n_fly_this = size(data{1}, 3);
    behavior_kernel_this = zeros(len_kernel, n_noise, n_fly_this);
    
    % ask how many flies.
    for nn = 1:1:n_noise
        for ffly = 1:1:n_fly_this
            switch order
                case 2
                    square_kernel_temp = ConvertCovMatToK2(data{nn}(:,:,ffly), nMultiBars_this);
                    % also take the nMultiBars into consideration.
                    square_kernel_temp = Analysis_Function_Get_Mean_Behavior_Utils_RescaleKernel(square_kernel_temp, nMultiBars_this);
                    behavior_kernel_this(:,nn,ffly) = square_kernel_temp(:);
                case 3
                    behavior_kernel_neaby_bars =  mean(data{nn}(:,:,ffly),2);
                    behavior_kernel_this(:,nn,ffly) = Analysis_Function_Get_Mean_Behavior_Utils_RescaleKernel(behavior_kernel_neaby_bars, nMultiBars_this);
            end
        end
    end
    
    n_fly_count_curr = n_fly_count_prev + n_fly_this;
    % behavior_kernel_average_current = (behavior_kernel_average_previous *
    % n_fly_count_previous +
    % sum(behavior_kernel_this(:,:,:),3)))/n_fly_count_curr;
    behavior_kernel_average_curr = (behavior_kernel_average_prev * n_fly_count_prev + sum(behavior_kernel_this(:,:,:),3))...
        /n_fly_count_curr;
    n_fly_count_prev = n_fly_count_curr;
    behavior_kernel_average_prev = behavior_kernel_average_curr;
end

behavior_kernel_ave = behavior_kernel_average_curr;
% cat it in the
% do not save the individual...
end


