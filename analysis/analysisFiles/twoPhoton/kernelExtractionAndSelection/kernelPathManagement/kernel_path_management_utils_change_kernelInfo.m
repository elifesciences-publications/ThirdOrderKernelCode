function kernel_info_array = kernel_path_management_utils_change_kernelInfo(filepath, kernel_identifier_cur, varargin)

% you need a constructor, to make sure you can set it.
%% kernel of interest. KOI
kernel_to_be_extracted = '';
mode = 'set';
KOI_path = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% if you force new kernels, and set new pathways here, you want to delete
% the old one before you set the new one.
if strcmp(mode, 'set')
    kernel_path_management_utils_change_kernelInfo(filepath, kernel_identifier_cur, 'kernel_to_be_extracted',kernel_to_be_extracted,'KOI_path',KOI_path, 'mode', 'delete');
end

kernel_inventory_folder = fullfile(filepath,'savedAnalysis');
kernel_inventory_file_name = 'kernel_inventory';
kernel_invertory_file_fullpath = fullfile(kernel_inventory_folder,kernel_inventory_file_name);
load(kernel_invertory_file_fullpath);

if isempty(kernel_info_array)
    kernel_info_this = kernel_identifier_cur;
    kernel_info_this.path.(kernel_to_be_extracted) = KOI_path;
    % ARMA and CVFlag;;;
    kernel_info_array = kernel_info_this;
    
else
    n_kernel_type  = length(kernel_info_array);
    for nn = 1:1:n_kernel_type
        %
        kernel_info_this = kernel_info_array(nn);
        kernel_identifier_this = rmfield(kernel_info_this,'path');
        
        switch kernel_identifier_cur.data_source
            case 'twoPhoton'
                exist_kernel_for_same_roi_identification = (strcmp(kernel_to_be_extracted, 'flick')...
                    || strcmp(kernel_to_be_extracted, 'arma_ols_first')...
                    || strcmp(kernel_to_be_extracted, 'roi_data_edge_only'))...
                    && strcmp( kernel_identifier_cur.ROI_indenfication_method, kernel_identifier_this.ROI_indenfication_method);
            case 'behavior'
                exist_kernel_for_same_roi_identification = (strcmp(kernel_to_be_extracted, 'flick')...
                    && isequal( kernel_identifier_cur.kernel_process_stim_flag, kernel_identifier_this.kernel_process_stim_flag)...
                    && isequal( kernel_identifier_cur.kernel_process_stim_FWHM, kernel_identifier_this.kernel_process_stim_FWHM));
        end
        kernel_identifier_exist_flag = isequal(kernel_identifier_cur,kernel_identifier_this);
        
        if  kernel_identifier_exist_flag || exist_kernel_for_same_roi_identification
            switch mode
                case 'set'
                    kernel_info_this.path.(kernel_to_be_extracted) = KOI_path;
                case 'delete'
                    % first, check whether this file exist.
                    
                    if isfield(kernel_info_this.path,kernel_to_be_extracted)
                        % delete the file
                        file_to_be_deleted_relative_path = kernel_info_this.path.(kernel_to_be_extracted);
                        S = GetSystemConfiguration;
                        switch kernel_info_this.data_source
                            case 'twoPhoton'
                                  kernel_folder  = S.kernelSavePath_twoPhoton;
                            case 'behavior'
                                  kernel_folder = S.kernelSavePath_behavior;
                        end
                        file_to_be_deleted_full_path = [kernel_folder, file_to_be_deleted_relative_path];
                        delete([file_to_be_deleted_full_path,'.mat'])
                        
                        % delete the dictionary.
                        kernel_info_this.path = rmfield(kernel_info_this.path,kernel_to_be_extracted);
                    end
            end
            kernel_info_array(nn) = kernel_info_this; % updated the path.
        end
    end
end
save(kernel_invertory_file_fullpath,'kernel_info_array');
