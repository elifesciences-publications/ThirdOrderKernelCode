function [kernel_this_exist_flag, kernel_this_relative_path] = kernel_path_management_utils_get_kernelInfo(filepath, kernel_identifier_cur, kernel_to_be_extracted)


%% kernel of interest. KOI
kernel_this_relative_path = [];
kernel_this_exist_flag = false;
kernel_identifier_exist_flag = false;
kernel_identifier_ever_exist_flag = false;
kernel_inventory_folder = [filepath,'/savedAnalysis'];
kernel_inventory_file_name = 'kernel_inventory.mat';
kernel_invertory_file_fullpath = [kernel_inventory_folder,'/',kernel_inventory_file_name];

if ~exist(kernel_invertory_file_fullpath, 'file')
    % if the inventory does not exist, create one.
    kernel_info_array = [];
    % check whether the folder exist
    if ~exist(kernel_inventory_folder, 'dir')
        mkdir(kernel_inventory_folder);
    end
    save(kernel_invertory_file_fullpath,'kernel_info_array'); % This kernel_info_array will be empty.
else
    load(kernel_invertory_file_fullpath);
    n_kernel_type  = length(kernel_info_array);
    
    for nn = 1:1:n_kernel_type
        kernel_info_this = kernel_info_array(nn);
        kernel_identifier_this = rmfield(kernel_info_this,'path');
        
        % update the path.
        % path for kernel and path for roiData.
        path_this = kernel_info_this.path;
        % check whether it is the same kernel extraction condition.
        % exception: flick and arma_ols_first is shared as long as the roiIdentifications are
        % the same. arma
        switch kernel_identifier_cur.data_source
            case 'twoPhoton'
                exist_kernel_for_same_roi_identification = (strcmp(kernel_to_be_extracted, 'flick')...
                    || strcmp(kernel_to_be_extracted, 'arma_ols_first')...
                    || strcmp(kernel_to_be_extracted, 'roi_data_edge_only'))...
                    && strcmp( kernel_identifier_cur.ROI_indenfication_method, kernel_identifier_this.ROI_indenfication_method);
            case 'behavior'
                exist_kernel_for_same_roi_identification = (strcmp(kernel_to_be_extracted, 'flick')...
                    && isequal(kernel_identifier_cur.kernel_process_stim_flag, kernel_identifier_this.kernel_process_stim_flag)...
                    && isequal( kernel_identifier_cur.kernel_process_stim_FWHM, kernel_identifier_this.kernel_process_stim_FWHM));
        end
        kernel_identifier_exist_flag = isequal(kernel_identifier_cur,kernel_identifier_this);
        if ~kernel_identifier_ever_exist_flag
            kernel_identifier_ever_exist_flag = isequal(kernel_identifier_cur,kernel_identifier_this);
        end
        % if you can find the same kernel_identifier,
        % if you can find the same roi_identification_method for flick and
        % arma_ols
        if kernel_identifier_exist_flag || exist_kernel_for_same_roi_identification
            if isfield(path_this,kernel_to_be_extracted)
                kernel_this_exist_flag = true;
                kernel_this_relative_path = path_this.(kernel_to_be_extracted); % relative path.
            end
        end
        
    end
    % you will overwrite existing kernels. you should always updating
    if ~kernel_identifier_ever_exist_flag % it is possible that
        % create this identifier
        kernel_info_this = kernel_identifier_cur;
        kernel_info_this.path = [];
        kernel_info_array = [kernel_info_array;kernel_info_this];
        save(kernel_invertory_file_fullpath,'kernel_info_array');
    end
    
end

end