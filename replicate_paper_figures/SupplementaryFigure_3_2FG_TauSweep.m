function SupplementaryFigure_3_2FG_TauSweep()
is_symmetrize_flag = false;
which_kernel_type = 'rc_kernel';
tf_tau_bank  = [10, 20, 50, 100, 200, 500] *  1e-3;

data = cell(length(tf_tau_bank), 1);
synthetic_flag = 0;
synthetic_type = '';
contrast_mode = 'dynamic';

for ii = 1:1:length(tf_tau_bank)
    tf_tau = tf_tau_bank(ii);
    data{ii} = Analysis_Utils_GetData_OneCondition_Symmetrize_NoStorage(which_kernel_type, synthetic_flag, synthetic_type,...
        'velocity_range', 114, 'is_symmetrize_flag', is_symmetrize_flag,...
        'temporal_filter_tau_bank',tf_tau, 'contrast_form', contrast_mode);
end
%%
x_tick_str = strsplit(num2str(tf_tau_bank));
x_value = tf_tau_bank;
NS_Sweep_Contrast_Velocity_PaperPlot(data, 'x_tick_str', x_tick_str, 'condition_discard', [], 'x_value', x_value,'x_label_str','FWHM');

end