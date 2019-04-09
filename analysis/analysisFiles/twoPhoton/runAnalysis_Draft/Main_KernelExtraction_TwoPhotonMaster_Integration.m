function Main_KernelExtraction_TwoPhotonMaster_Integration(file_path_all,varargin)
data_source = 'twoPhoton';
kernel_extraction_method = 'reverse_correlation'; % you should think about it.
RoiIdentificationMethod = 'HHCA';
roiMethod_forBackground = 'RoiIsBackGround';

% if behavior
process_stim_flag = false;
process_stim_FWHM = [];
kernel_to_be_extracted_string_preset = [];
cross_validation_flag = false;
order = [];
donoise = [];
dx_bank = [];
force_kernel = false;
save_kernel_flag = true;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
if strcmp(kernel_extraction_method, 'ARMA_RC')
    arma_flag = true;
else
    arma_flag = false;
end
%% kernel info
kernel_param = struct('order', num2cell(order), 'donoise',num2cell(donoise),'dx', dx_bank);
kernel_to_be_extracted_string_before_check = kernel_path_management_utils_kernelparam_to_kernelstr(kernel_param);
kernel_to_be_extracted_string_before_check = [kernel_to_be_extracted_string_before_check;kernel_to_be_extracted_string_preset];

%% name of the kernel for saving.
switch data_source
    case 'twoPhoton'
        kernel_name_full = [RoiIdentificationMethod, '_',kernel_extraction_method,'_', 'CV', num2str(cross_validation_flag)];
        kernel_name_only_roiIdentificationMethod_or_only_process = RoiIdentificationMethod;
    case 'behavior'
        kernel_name_starter = behavior_kernel_extraction_pathmanagement_utils_namestarter(process_stim_flag, process_stim_FWHM);
        kernel_name_full = [kernel_name_starter, '_',kernel_extraction_method,'_'];
        kernel_name_only_roiIdentificationMethod_or_only_process = kernel_name_starter;
end

%% kernel identifier.
switch data_source
    case 'twoPhoton'
        kernel_identifier.ROI_indenfication_method = RoiIdentificationMethod;
        kernel_identifier.cross_validation_flag    = cross_validation_flag;
        
    case 'behavior'
        % several identifiers.
        kernel_identifier.kernel_process_stim_flag = process_stim_flag;
        kernel_identifier.kernel_process_stim_FWHM = process_stim_FWHM;
        
end
kernel_identifier.kernel_extraction_method = kernel_extraction_method;
kernel_identifier.data_source = data_source;


%% folder info
S = GetSystemConfiguration;
switch data_source
    case 'twoPhoton'
        kernel_folder = S.kernelSavePath_twoPhoton;
        data_folder= S.twoPhotonDataPathLocal;
    case 'behavior'
        kernel_folder = S.kernelSavePath_behavior;
        data_folder= S.datapath_behavior_kernel;
end

%% start extracting kernels.
for ff = 1:1:length(file_path_all)
    filepath = file_path_all{ff};
    file_relative_path =  KernelPathManage_DeleteAbsolutePath(filepath,data_folder);
    % build kernel_identifier_cur
    % check for this fly, which kernel should be extracted.
    kernel_to_be_extracted_string = kernel_path_management_uitils_check_pre_requisite(filepath, kernel_identifier, kernel_to_be_extracted_string_before_check,force_kernel,arma_flag);
    try
        for kk = 1:1:length(kernel_to_be_extracted_string)
            kernel_to_be_extracted_string_this =  kernel_to_be_extracted_string{kk};
            kernel_to_be_extracted_param_this =  kernel_path_management_utils_kernelstr_to_kernelparam({kernel_to_be_extracted_string_this});
            order_this = kernel_to_be_extracted_param_this.order;
            noise_this = kernel_to_be_extracted_param_this.noise;
            maxTau_this  = kernel_to_be_extracted_param_this.maxTau; % change this in the future;
            dx_this = kernel_to_be_extracted_param_this.dx;
            
            %% calculate kernel
            if strcmp(kernel_to_be_extracted_string_this,'flick')% because you did not
                switch data_source
                    case 'twoPhoton'
                        data = KernelExtraction_PrepareFlick_TwoPhotonMaster_Version(filepath, roiMethod_forBackground, RoiIdentificationMethod);
                    case 'behavior'
                        data = KernelExtraction_PrepareFlick_Behavior_ProcessStim(filepath, process_stim_flag, process_stim_FWHM);
                end
                kernel_name = kernel_name_only_roiIdentificationMethod_or_only_process;
            elseif strcmp(kernel_to_be_extracted_string_this,'roi_data_edge_only')
                data = RoiData_Creation_TwoPhotonMaster_Version(filepath, RoiIdentificationMethod);
                kernel_name = kernel_name_only_roiIdentificationMethod_or_only_process;
            else
                % first, check flick is there.
                [~, flick_relative_path] = kernel_path_management_utils_get_kernelInfo(filepath, kernel_identifier, 'flick'); % do
                flick_relative_path_full = [kernel_folder, flick_relative_path];
                % load and get resp and stim.
                load(flick_relative_path_full);
                respData = flickSave.respData;
                stimData = flickSave.stimData;
                stimIndexes = flickSave.stimIndexed;
                
                if strcmp(kernel_to_be_extracted_string_this,'arma_ols_first')
                    [ks, kr] = kernel_extraction_ARMA_OLS(respData,stimData,stimIndexes,'order', order_this, 'maxTau',32,'kernel_by_bar_flag', false); % 32 might be too large.
                    data.ks = ks; data.kr = kr;
                    kernel_name = kernel_name_only_roiIdentificationMethod_or_only_process;
                else
                    if arma_flag
                        [~, arma_ols_relative_path] = kernel_path_management_utils_get_kernelInfo(filepath, kernel_identifier, 'arma_ols_first');
                        arma_ols_path_full = fullfile(kernel_folder, arma_ols_relative_path);
                        load(arma_ols_path_full);
                        kr =  arma_ols_first.kr;
                    else
                        kr = [];
                    end
                    tic
                    % this dx thing will still be existing...
                    tic
                    data = Main_KernelExtraction_twoPhotonOrBehavior(respData, stimData, stimIndexes, ...
                        order_this, noise_this, maxTau_this, arma_flag, kr, dx_this, process_stim_flag, data_source);
                    toc
                    kernel_name = kernel_name_full;
                    
                end
            end
            %% save the kernel.
            if save_kernel_flag % you have to save it?
                kernel_absolute_path = tp_saveKernels(file_relative_path, data, kernel_name, kernel_to_be_extracted_string_this , data_source); % no special name...
                %% update kernel inventory
                kernel_relative_path = KernelPathManage_DeleteAbsolutePath(kernel_absolute_path,kernel_folder);
                kernel_path_management_utils_change_kernelInfo(filepath,  kernel_identifier, 'mode','set','kernel_to_be_extracted',kernel_to_be_extracted_string_this,'KOI_path',kernel_relative_path);
                clear data kernel_absolute_path kernel_relative_path kernel_to_be_extracted_string_this
            end
            
        end
    catch err
        % you have to have a mark on the file, to see that there is an
        % error
                 keyboard;
    end
    
end

end
