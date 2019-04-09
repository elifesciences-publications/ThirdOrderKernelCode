function  [data_matrix,stim_info] = Analysis_Utils_GetAllData(distribution, spatial_range, which_kernel_type, FWHM_bank, temporal_filter_tau_bank, vel_range_bank, varargin)
contrast_form = 'static';
image_process_info.he = 0;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
image_process_info.contrast = contrast_form;
% choose a distribution and do the plotting. cool... you are making a lot
% of progress...
velocity.distribution = distribution;
data_struct = struct('v2', [], 'v3', [], 'v_real', [],'solved_flag',[], 'exit_flag', []);
data_matrix = repmat(data_struct, length(vel_range_bank), length(FWHM_bank));
stim_info = [];
for jj = 1:1:length(vel_range_bank)
    switch contrast_form
        case 'static'
            for kk = 1:1:length(FWHM_bank)
                velocity.range = vel_range_bank(jj);
                image_process_info.FWHM = FWHM_bank(kk);
                data_matrix(jj, kk) = Analysis_Utils_GetData(image_process_info, velocity, spatial_range, which_kernel_type, varargin{:});
                stim_info = Analysis_Utils_GetData_StimScene(image_process_info, velocity, which_kernel_type, varargin{:});
            end
        case 'dynamic'
            for kk = 1:1:length(temporal_filter_tau_bank)
                velocity.range = vel_range_bank(jj);
                image_process_info.FWHM = [];
                image_process_info.tf_tau = temporal_filter_tau_bank(kk);
                data_matrix(jj, kk) = Analysis_Utils_GetData(image_process_info, velocity, spatial_range, which_kernel_type, varargin{:});
            end
        case 'dynamic_both_future_and_past'
            for kk = 1:1:length(temporal_filter_tau_bank)
                velocity.range = vel_range_bank(jj);
                image_process_info.FWHM = [];
                image_process_info.tf_tau = temporal_filter_tau_bank(kk);
                data_matrix(jj, kk) = Analysis_Utils_GetData(image_process_info, velocity, spatial_range, which_kernel_type, varargin{:});
            end
    end
end