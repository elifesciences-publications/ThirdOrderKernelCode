function Figure3_KernelPerformance()
is_symmetrize_flag = false;
which_kernel_type = 'rc_kernel';
velocity_range_bank = [114];
data = cell(length(velocity_range_bank), 1);
synthetic_flag = 0;
synthetic_type = '';
for ii = 1:1:length(velocity_range_bank)
    velocity_range = velocity_range_bank(ii);
    data{ii} = Analysis_Utils_GetData_OneCondition_Symmetrize_NoStorage(which_kernel_type, synthetic_flag, synthetic_type,...
        'velocity_range', velocity_range, 'is_symmetrize_flag', is_symmetrize_flag);
end
%%
plot_scatter_plot_correlation_one_situation(data{1},'ai_publish','y_label_str','correlation with image velocity','downsample_point_flag', true);

end
%%