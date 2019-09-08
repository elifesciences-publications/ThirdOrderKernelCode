function  [data,stim_info] = summary_of_different_manipulation_groups(synthetic_flag_bank, synthetic_type_bank, ns_num, x_tick_str, x_value, plot_fig_flag)

is_symmetrize_flag = false;

which_kernel_type = 'rc_kernel';
data = cell(length(synthetic_flag_bank), 1);
stim_info = cell(length(synthetic_flag_bank), 1);
for ii = 1:1:length(synthetic_flag_bank )
    synthetic_flag = synthetic_flag_bank(ii);
    synthetic_type = synthetic_type_bank{ii};
    % check out the exitflag.
    [data{ii}, stim_info{ii}] = Analysis_Utils_GetData_OneCondition_Symmetrize_NoStorage(which_kernel_type, synthetic_flag, synthetic_type,...
        'is_symmetrize_flag', is_symmetrize_flag);
end
% SynData_MultiSyn_SummaryPlot_Utils_FromDataToPlot(data, 'x_tick_str', x_tick_str, 'condition_discard', ns_num, 'x_value', x_value);

end