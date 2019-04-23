
function SupplementaryFigure_3_1_VelocitySweep()
is_symmetrize_flag = false;
which_kernel_type = 'rc_kernel';
velocity_range_bank = [32, 64, 128, 256, 512];
data = cell(length(velocity_range_bank), 1);
synthetic_flag = 0;
synthetic_type = '';
for ii = 1:1:length(velocity_range_bank)
    velocity_range = velocity_range_bank(ii);
    data{ii} = Analysis_Utils_GetData_OneCondition_Symmetrize_NoStorage(which_kernel_type, synthetic_flag, synthetic_type,...
        'velocity_range', velocity_range, 'is_symmetrize_flag', is_symmetrize_flag);
end
%%
x_tick_str = strsplit(num2str(velocity_range_bank));
x_value = velocity_range_bank;
NS_Sweep_Contrast_Velocity_PaperPlot(data, 'x_tick_str', x_tick_str, 'condition_discard', [], 'x_value', x_value,'x_label_str','stadard deviation of velocity distribution [\circ/s]');

end