function SupplementaryFigure_3_2DE_FWHMSweep()
is_symmetrize_flag = false;
which_kernel_type = 'rc_kernel';
FWHM_bank = [10:5:75];
data = cell(length(FWHM_bank), 1);
synthetic_flag = 0;
synthetic_type = '';
for ii = 1:1:length(FWHM_bank)
    FWHM = FWHM_bank(ii);
    data{ii} = Analysis_Utils_GetData_OneCondition_Symmetrize_NoStorage(which_kernel_type, synthetic_flag, synthetic_type,...
        'FWHM', FWHM, 'is_symmetrize_flag', is_symmetrize_flag);
end
%%
x_tick_str = strsplit(num2str(FWHM_bank));
x_value = FWHM_bank;
NS_Sweep_Contrast_Velocity_PaperPlot(data, 'x_tick_str', x_tick_str, 'condition_discard', [], 'x_value', x_value,'x_label_str','FWHM');

end