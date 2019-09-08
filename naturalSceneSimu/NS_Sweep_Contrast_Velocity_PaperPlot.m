function NS_Sweep_Contrast_Velocity_PaperPlot(data, varargin)
x_label_str = '';
condition_discard= [];
n_conditions = length(data);
x_value = 1:n_conditions;
num_batches = 10;
metric = 'corr_improvement';
y_label_str = 'improvement added by third order kernel';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

metric_all= cell(length(data), 1);
improvement_all = cell(length(data), 1);
weight_ratio_all = cell(length(data), 1);
residual_r_all = cell(length(data), 1);
residual_slope_all = cell(length(data), 1);
for ss = 1:length(data)
    plot_flag = false;
    [metric_all{ss},  improvement_all{ss}, ~, weight_ratio_all{ss}, residual_r_all{ss}, residual_slope_all{ss}] = plot_scatter_plot_correlation_one_situation(data{ss}, 'ai_poster', 'plot_flag', plot_flag, 'metric', metric, 'y_label_str','correlation_with_image_velocity',...
        'num_batches', num_batches);
end


%% print out all second.
for ii = 1:1:length(metric_all)
    metric_all{ii}.mean(1);
    improvement_all{ii}.mean;
end
%% third, summarize the improvement together.
improvement_all_various_skew = improvement_all;
improvement_all_various_skew(condition_discard) = [];
x_tick_str_skew =  x_tick_str; x_tick_str_skew(condition_discard) = [];
improvement_struct = [improvement_all_various_skew{:}];
improvement_mean = [improvement_struct(:).mean];
improvement_sem = [improvement_struct(:).sem];

%% plot the individual one.
MakeFigure; 
subplot(2,3,1)
hold on
SynData_MultiSyn_SummaryPlot_Utils_LinePlot_GroupedByOrder(metric_all, 'x_tick_str',x_tick_str, 'weight_ratio', weight_ratio_all,...
    'ylabel_str','correlation with image velocity','xlabel_str',x_label_str)
ConfAxis
%% plot the line improvements.
subplot(2,3,2)
plot(x_value, improvement_mean,'k');
hold on
for ii = 1:1:length(x_value)
    plot([x_value(ii), x_value(ii)], [improvement_mean(ii) + improvement_sem(ii), improvement_mean(ii) - improvement_sem(ii)],'k');
end
set(gca, 'XTick', x_value, 'XTickLabel', x_tick_str_skew)
xlabel(x_label_str);
ylabel(y_label_str);
% set(gca, 'XScale','log')
ConfAxis

%%
subplot(2,3,3)
weight_ratio_mean = zeros(n_conditions, 1);
weight_ratio_sem = zeros(n_conditions, 1);
for ii = 1:1:n_conditions
    weight_ratio_mean(ii) = weight_ratio_all{ii}.mean;
    weight_ratio_sem(ii) = weight_ratio_all{ii}.sem;
end
plot(x_value, weight_ratio_mean,'k');
hold on
for ii = 1:1:length(x_value)
    plot([x_value(ii), x_value(ii)], [weight_ratio_mean(ii) + weight_ratio_sem(ii) , weight_ratio_mean(ii) - weight_ratio_sem(ii)],'k');
end
set(gca, 'XTick', x_value, 'XTickLabel', x_tick_str_skew)
xlabel(x_label_str);
ylabel('weighting ratio 3rd/2nd');
% set(gca, 'XScale','log')
ConfAxis
% MySaveFig_Juyue(gcf, 'Ensemble_Skewness_Fold_Change','one_curve', 'nFigSave',2,'fileType',{'png','fig'});

%% plot the noise cancelling...
subplot(2,3,4)
residual_r_mean = zeros(n_conditions, 1);
residual_r_sem = zeros(n_conditions, 1);
for ii = 1:1:n_conditions
    residual_r_mean(ii) = residual_r_all{ii}.mean;
    residual_r_sem(ii) = residual_r_all{ii}.sem;
end
plot(x_value,residual_r_mean,'k');
hold on
for ii = 1:1:length(x_value)
    plot([x_value(ii), x_value(ii)], [residual_r_mean(ii) + residual_r_sem(ii) , residual_r_mean(ii) - residual_r_sem(ii)],'k');
end
set(gca, 'XTick', x_value, 'XTickLabel', x_tick_str_skew)
xlabel(x_label_str);
ylabel('noise r');
% set(gca, 'XScale','log')
ConfAxis

subplot(2,3,5)
residual_slope_mean = zeros(n_conditions, 1);
residual_slope_sem = zeros(n_conditions, 1);
for ii = 1:1:n_conditions
    residual_slope_mean(ii) = residual_slope_all{ii}.mean;
    residual_slope_sem(ii) = residual_slope_all{ii}.sem;
end
plot(x_value,residual_slope_mean,'k');
hold on
for ii = 1:1:length(x_value)
    plot([x_value(ii), x_value(ii)], [residual_slope_mean(ii) + residual_slope_sem(ii) , residual_slope_mean(ii) - residual_slope_sem(ii)],'k');
end
set(gca, 'XTick', x_value, 'XTickLabel', x_tick_str_skew)
xlabel(x_label_str);
ylabel('noise slope');
% set(gca, 'XScale','log')
ConfAxis

end