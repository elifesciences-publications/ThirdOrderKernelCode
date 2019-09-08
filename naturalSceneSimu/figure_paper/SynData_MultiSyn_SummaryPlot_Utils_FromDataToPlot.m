function [metric_all, improvement_all,  weight_ratio_all] = SynData_MultiSyn_SummaryPlot_Utils_FromDataToPlot(data, varargin)
x_tick_str = {'natural scene ','-2','-1','-0.5','0','0.5','1','2'};
x_label_str = 'fold of individual skewness';
condition_discard = [];
x_value = 1:length(data);
num_batches = 10;
metric = 'corr_improvement';
y_label_str = 'improvement added by third order kernel';
image_title = [];
save_fig_flag = 0;
plot_fig_flag = 1;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

metric_all= cell(length(data), 1);
improvement_all = cell(length(data), 1);
weight_ratio_all = cell(length(data), 1);
for ss = 1:length(data)
    [metric_all{ss},  improvement_all{ss}, ~, weight_ratio_all{ss}] = plot_scatter_plot_correlation_one_situation(data{ss}, 'ai_poster', 'plot_flag', plot_fig_flag, 'metric', metric, 'y_label_str','correlation_with_image_velocity',...
        'num_batches', num_batches);
    %     MySaveFig_Juyue(gcf, 'Across_scene_corr_improvement',synthetic_name_fig_save{ss},'nFigSave',2,'fileType',{'png','fig'});
    %     title(synthetic_name_bank{ss})
end

if plot_fig_flag
    %% first, complex bar plot, correlation of each group are grouped together
    SynData_MultiSyn_SummaryPlot_Utils_BarPlot_GroupedByOrder(metric_all, improvement_all,'x_tick_str',x_tick_str, 'weight_ratio', weight_ratio_all);
    title(image_title);
    if save_fig_flag
        MySaveFig_Juyue(gcf, 'Across_scene_corr_improvement_grouped_by_order',image_title,'nFigSave',2,'fileType',{'png','fig'});
    end
    %% print out all second.
    for ii = 1:1:length(metric_all)
        metric_all{ii}.mean(1)
        improvement_all{ii}.mean
    end
    %% second, complex bar plot, correlation of each condition are grouped together
    MakeFigure;
    SynData_MultiSyn_SummaryPlot_Utils_BarPlot_GroupedByCondition(metric_all, improvement_all, 'x_tick_str',x_tick_str, 'weight_ratio', weight_ratio_all);
    
    MakeFigure;
    SynData_MultiSyn_SummaryPlot_Utils_BarPlot_GroupedByCondition(...
        metric_all, improvement_all, 'x_tick_str',x_tick_str, 'weight_ratio', weight_ratio_all,...
        'order_to_plot', [1, 2, 3]);
    title(image_title);
    if save_fig_flag
        MySaveFig_Juyue(gcf, 'Across_scene_corr_improvement+grouped_by_condition',image_title,'nFigSave',2,'fileType',{'png','fig'});
    end
end
% % %% third, summarize the improvement together.
% MakeFigure;
% subplot(2,2,1)
% improvement_all_various_skew = improvement_all;
% improvement_all_various_skew(condition_discard) = [];
% x_tick_str_skew =  x_tick_str; x_tick_str_skew(condition_discard) = [];
% SynData_MultiSyn_SummaryPlot_Utils_LinePlot_GroupedByCondition(improvement_all_various_skew, x_value, x_tick_str_skew);
% xlabel(x_label_str);
% ylabel(y_label_str)
% ConfAxis
% MySaveFig_Juyue(gcf, 'Ensemble_Skewness_Fold_Change','one_curve', 'nFigSave',2,'fileType',{'png','fig'});

end