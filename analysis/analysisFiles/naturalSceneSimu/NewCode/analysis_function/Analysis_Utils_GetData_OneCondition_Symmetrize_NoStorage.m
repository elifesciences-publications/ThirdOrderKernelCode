function [data_sym, stim_info] = Analysis_Utils_GetData_OneCondition_Symmetrize_NoStorage(which_kernel_type, synthetic_flag, synthetic_type, varargin)
is_symmetrize_flag = true;
velocity_range = 114;
FWHM = 25;
contrast_form = 'static';
temporal_filter_tau_bank = [];

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

FWHM_bank = FWHM;
distribution = 'gaussian';
vel_range_bank = velocity_range;
spatial_range = 53;

%%
[data_matrix, stim_info] = Analysis_Utils_GetAllData(distribution, spatial_range, which_kernel_type, FWHM_bank, temporal_filter_tau_bank, vel_range_bank,...
    'synthetic_flag', synthetic_flag,'synthetic_type',synthetic_type,'contrast_form',contrast_form);

if is_symmetrize_flag
    data_sym = Analysis_Utils_GetAllData_EnforceSymmetry(data_matrix);
else
    data_sym = data_matrix;
end