function SupplementaryFigure_5_2G_FixedContrastRange_KernelPerformance()
synthetic_flag_bank = [1,1]; % natural scene are the first. from most negative to the most positive.
ns_num = 1;
x_tick_str = {'+var','+var +skew'};
x_value = [1, 2];

synthetic_type_bank = {'pixel_dist_ivar_sym_0mean_fixedlh25_512bin', 'pixel_dist_iskew_sym_0mean_fixedlh25_512bin'};
data = summary_of_different_manipulation_groups(synthetic_flag_bank, synthetic_type_bank, ns_num, x_tick_str, x_value);
[metric_all, improvement_all,  weight_ratio_all] = SynData_MultiSyn_SummaryPlot_Utils_FromDataToPlot(data, 'x_tick_str', x_tick_str, 'condition_discard', ns_num, 'x_value', x_value, 'plot_fig_flag', 0);

%% Plot the residual of the second with the third. 

%% Paper Quality Plot 
MakeFigure_Paper;
axes('Units', 'points', 'Position', [400, 500, 108, 108]);
SynData_MultiSyn_SummaryPlot_Utils_BarPlot_GroupedByCondition(metric_all, improvement_all, 'x_tick_str',x_tick_str, 'weight_ratio', weight_ratio_all,'order_to_plot', [1, 2, 3]);
ConfAxis('LineWidth', 0.5, 'fontSize', 9);
set(gca,'YLim', [-0.2, 0.5]);
set(gca,'YTick',[0,0.25,0.5]);
% MySaveFig_Juyue(gcf, 'SyntheticAcrossScene_fixedContrastRange','group_by_condition', 'nFigSave',2,'fileType',{'png','pdf'});
end
