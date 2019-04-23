function Figure5E_Supplementary_5_3AB_kernelPerformance()
%% Notes
% Figure 1 -> Supplementary_5_3A
% Figure 2 -> Supplementary_5_3B
% Figure 3 -> Figure5E


%% four datasets together.
synthetic_flag_bank = [1,1]; % natural scene are the first. from most negative to the most positive.
ns_num = 1;
x_tick_str = {'+var','+var +skew'};
x_value = [1, 2];

synthetic_type_bank = {'pixel_dist_ivar_mean', 'pixel_dist_iskew_mean'};
data = summary_of_different_manipulation_groups(synthetic_flag_bank, synthetic_type_bank, ns_num, x_tick_str, x_value);
[metric_all, improvement_all,  weight_ratio_all] = SynData_MultiSyn_SummaryPlot_Utils_FromDataToPlot(data, 'x_tick_str', x_tick_str, 'condition_discard', ns_num, 'x_value', x_value, 'plot_fig_flag', 0);

%% Supplementary Figure
plot_scatter_plot_correlation_one_situation(data{1},'ai_publish','y_label_str','correlation with image velocity','downsample_point_flag', true);
title('Supplementary_Figure5_3A')

% MySaveFig_Juyue(gcf,'SyntheticAcrossScene_HeterogenousContrastRange_var','scatter_plot','nFigSave',2,'fileType',{'eps','fig'});

plot_scatter_plot_correlation_one_situation(data{2},'ai_publish','y_label_str','correlation with image velocity','downsample_point_flag', true);
title('Supplementary_Figure5_3B')

% MySaveFig_Juyue(gcf,'SyntheticAcrossScene_HeterogenousContrastRange_skew','scatter_plot','nFigSave',2,'fileType',{'eps','fig'});

%% Paper Quality Data.
MakeFigure_Paper;
axes('Units', 'points', 'Position', [400, 500, 108, 108]);
SynData_MultiSyn_SummaryPlot_Utils_BarPlot_GroupedByCondition(metric_all, improvement_all, 'x_tick_str',x_tick_str, 'weight_ratio', weight_ratio_all,'order_to_plot', [1, 2, 3]);
ConfAxis('LineWidth', 0.5, 'fontSize', 9);
set(gca,'YLim', [-0.2, 0.5]);
set(gca,'YTick',[0,0.25,0.5]);
title('Figure5E')
% MySaveFig_Juyue(gcf, 'SyntheticAcrossScene_HeterogenousContrastRange','barplot', 'nFigSave',2,'fileType',{'png','pdf'});

end