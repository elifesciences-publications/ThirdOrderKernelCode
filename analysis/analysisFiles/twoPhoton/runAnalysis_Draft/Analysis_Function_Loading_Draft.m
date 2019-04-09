function data = Analysis_Function_Loading_Draft(filepath, kernel_identifier, varargin)
S = GetSystemConfiguration;
kernel_folder = S.kernelSavePath;
% after this, everything should be arranged in roi basis...
which_data = 'roi_data_edge_only';
first_order_format = 'new';

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% this would be changed dramatically.
[exist_data,data_relative_path] = kernel_path_management_utils_get_kernelInfo(filepath, kernel_identifier,  which_data);
if ~isempty(strfind(which_data , 'first')) || ~isempty(strfind(which_data , 'second')) || ~isempty(strfind(which_data , 'third'))
    
    data_type = 'kernel';
else
    data_type = which_data;
end
if exist_data
    load([kernel_folder,data_relative_path]);
    %% load second order kernel
    switch data_type
        case 'roi_data_edge_only'
            data = roiData;
            % for the first and first_noise, you have to reorganize data
            % should all be new format.
        case 'kernel'
            data = saveKernels.kernels;
            %             if strcmp(first_order_format,'old')
            %                 data = saveKernels.kernels;
            %             else
            %                 data = {saveKernels.kernels};
            %             end
            %         case 'first_noise' % there should be two format...
            %             data = saveKernels.kernels;
            %         case 'second'
            %             data = saveKernels.kernels;
            %             % if it is second order noise, extract that on the moment.
            %         case 'second_noise'
            %             data = saveKernels.kernels;
            %             %%% change the third order kernel structure in the future.
            %         case 'third_0_1'
            %             data = saveKernels.kernels;
            %         case 'third_0_n1'
            %             data = saveKernels.kernels;
            %         case 'third_1_2'
            %             data = saveKernels.kernels;
            %         case 'third_n1_n2'
            %             data = saveKernels.kernels;
        case 'flick'
            data = flickSave;
        otherwise
            error('this kernel has not been pre-extracted');
    end
else
    error([which_data,' does not exist for file ',filepath]);
end
end