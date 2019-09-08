function  kernel_to_be_extracted_string_prerequisite_fullfilled = kernel_path_management_uitils_check_pre_requisite(filepath, kernel_identifier, kernel_to_be_extracted_string,force_kernel,arma_flag)

kernel_to_be_extracted_string_prerequisite_fullfilled = kernel_to_be_extracted_string;
for kk = 1:1:length(kernel_to_be_extracted_string)
    
    kernel_to_be_extracted_string_this = kernel_to_be_extracted_string{kk}; % string to order, order to string.
    kernel_to_be_extracted_param_this =  kernel_path_management_utils_kernelstr_to_kernelparam({kernel_to_be_extracted_string_this});

    order_this = kernel_to_be_extracted_param_this.order;
%     noise_this = kernel_to_be_extracted_param_this.noise;
    
    % including force_kernel. if force kernel, everything should be
    [kernel_this_exist_flag, ~] = kernel_path_management_utils_get_kernelInfo(filepath, kernel_identifier, kernel_to_be_extracted_string_this); % do
    
    % if this kernel has been calculated, then delete it from the list
    if kernel_this_exist_flag && ~force_kernel
        % delete that guy from your list.
        kernel_to_be_extracted_string_prerequisite_fullfilled(strcmp(kernel_to_be_extracted_string_this, kernel_to_be_extracted_string_prerequisite_fullfilled)) = [];
    else
        % if you have to calculate this kernel. check whether the
        % prerequisite is fullfilled.
        if order_this > 0
            % check whether flick is available.
            [flick_exist_flag, ~] = kernel_path_management_utils_get_kernelInfo(filepath, kernel_identifier, 'flick'); % do
            if ~flick_exist_flag && sum(strcmp('flick', kernel_to_be_extracted_string_prerequisite_fullfilled)) == 0
                kernel_to_be_extracted_string_prerequisite_fullfilled = ['flick';kernel_to_be_extracted_string_prerequisite_fullfilled];
            end
            
            if arma_flag
                [kr_exist_flag, ~] = kernel_path_management_utils_get_kernelInfo(filepath, kernel_identifier, 'arma_ols_first');
                if ~kr_exist_flag && sum(strcmp('arma_ols_first', kernel_to_be_extracted_string_prerequisite_fullfilled)) == 0
                    kernel_to_be_extracted_string_prerequisite_fullfilled = ['arma_ols_first';kernel_to_be_extracted_string_prerequisite_fullfilled];
                end
            end
        end
    end
end
kernel_to_be_extracted_string_prerequisite_fullfilled = check_prerequisite_correct_kernel_extraction_sequence(kernel_to_be_extracted_string_prerequisite_fullfilled);

end
% make sure the sequence are the same.
function kernel_to_be_extracted_string_corrected = check_prerequisite_correct_kernel_extraction_sequence(kernel_to_be_extracted_string)
kernel_to_be_extracted_string_left = kernel_to_be_extracted_string;
ind_flick = strcmp('flick',kernel_to_be_extracted_string); exist_flick = sum( ind_flick) > 0;kernel_to_be_extracted_string_left(ind_flick == 1) = [];
ind_arma_ols_first = strcmp('arma_ols_first',kernel_to_be_extracted_string); exist_arma_ols_first = sum(ind_arma_ols_first) > 0;kernel_to_be_extracted_string_left(ind_arma_ols_first) = [];

if exist_arma_ols_first && exist_flick
    kernel_to_be_extracted_string_corrected = ['flick'; 'arma_ols_first';kernel_to_be_extracted_string_left];
elseif ~exist_arma_ols_first && exist_flick
    kernel_to_be_extracted_string_corrected = ['flick'; kernel_to_be_extracted_string_left];
elseif exist_arma_ols_first && ~exist_flick
    kernel_to_be_extracted_string_corrected = ['arma_ols_first';kernel_to_be_extracted_string_left];
else
    kernel_to_be_extracted_string_corrected = kernel_to_be_extracted_string_left;
end
end