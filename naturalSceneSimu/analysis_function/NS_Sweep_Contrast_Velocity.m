function NS_Sweep_Contrast_Velocity(data, varargin)
x_label_str = '';
condition_discard= [];
n_conditions = length(data);
x_value = 1:n_conditions;
num_batches = 10;
metric = 'corr_improvement';
y_label_str = 'improvement added by third order kernel';
paper_plot_flag = 0;
x_tick =[];

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
if ~paper_plot_flag
    fontSize = 15;
    LineWidth = 2;
else
    fontSize = 8;
    LineWidth = 0.5;
    plot_size = [128,88];
end

if isempty(x_tick)
    % use empty
    x_tick = x_value;
else 
    if isempty(condition_discard)
        x_tick_str = x_tick_str(x_tick);
        x_tick = x_value(x_tick);
    else
        error('Should not use "condition_discard" and customized "x_tick" together.')
    end
end
    
%% Calculating Data.
% Collect Data.
metric_all= cell(length(data), 1);
improvement_all = cell(length(data), 1);
weight_ratio_all = cell(length(data), 1);
residual_r_all = cell(length(data), 1);
residual_slope_all = cell(length(data), 1);
for ss = 1:length(data)
    plot_flag = false;
    [metric_all{ss},  improvement_all{ss}, ~, weight_ratio_all{ss}, residual_r_all{ss}, residual_slope_all{ss}] = plot_scatter_plot_correlation_one_situation(data{ss}, 'ai_poster', 'plot_flag', plot_flag, 'metric', metric, 'y_label_str','correlation_with_image_velocity',...
        'num_batches', num_batches);
    %     MySaveFig_Juyue(gcf, 'Across_scene_corr_improvement',synthetic_name_fig_save{ss},'nFigSave',2,'fileType',{'png','fig'});
    %     title(synthetic_name_bank{ss})
end

% print out all second.
for ii = 1:1:length(metric_all)
    metric_all{ii}.mean(1);
    improvement_all{ii}.mean;
end
% summarize the improvement together.
improvement_all_various_skew = improvement_all;
improvement_all_various_skew(condition_discard) = [];
x_tick_str_skew =  x_tick_str; x_tick_str_skew(condition_discard) = [];
improvement_struct = [improvement_all_various_skew{:}];
improvement_mean = [improvement_struct(:).mean];
improvement_sem = [improvement_struct(:).sem];

%% Individual 2nd, 3rd. 2+3
if ~paper_plot_flag
    MakeFigure;
    subplot(2,3,1)
else
    MakeFigure_Paper;
    axes('Units','Points','Position', [36, 500, plot_size(1), plot_size(2)]);
end
hold on
SynData_MultiSyn_SummaryPlot_Utils_LinePlot_GroupedByOrder(metric_all,'x_value',x_value, 'x_tick',x_tick, 'x_tick_str',x_tick_str, 'weight_ratio', weight_ratio_all,...
    'ylabel_str','correlation with image velocity','xlabel_str',x_label_str);
plot(get(gca, 'XLim'),[0,0],'k--');
plot(zeros(2,1),get(gca, 'YLim'),'k--');
ConfAxis('fontSize', fontSize, 'LineWidth', LineWidth);

%% plot the line improvements.
if ~paper_plot_flag
    subplot(2,3,2)
else
   axes('Units','Points','Position', [220, 500, plot_size(1), plot_size(2)]);
end

plot(x_value, improvement_mean,'k.-');
set(gca,'YLim', [-0.15, 0.15], 'YTick',[-0.1, 0, 0.1]);
hold on
for ii = 1:1:length(x_value)
    plot([x_value(ii), x_value(ii)], [improvement_mean(ii) + improvement_sem(ii), improvement_mean(ii) - improvement_sem(ii)],'k');
end
plot(get(gca, 'XLim'),[0,0],'k--');
plot(zeros(2,1),get(gca, 'YLim'),'k--');
set(gca, 'XTick', x_tick, 'XTickLabel', x_tick_str_skew)
xlabel(x_label_str);
ylabel(y_label_str);
% set(gca, 'XScale','log')
ConfAxis('fontSize', fontSize, 'LineWidth', LineWidth);

%%
if ~paper_plot_flag
    subplot(2,3,2)
else
    axes('Units','Points','Position', [400, 500,  plot_size(1), plot_size(2)]);
end


weight_ratio_mean = zeros(n_conditions, 1);
weight_ratio_sem = zeros(n_conditions, 1);
for ii = 1:1:n_conditions
    weight_ratio_mean(ii) = weight_ratio_all{ii}.mean;
    weight_ratio_sem(ii) = weight_ratio_all{ii}.sem;
end
plot(x_value, weight_ratio_mean,'k.-');
hold on
for ii = 1:1:length(x_value)
    plot([x_value(ii), x_value(ii)], [weight_ratio_mean(ii) + weight_ratio_sem(ii) , weight_ratio_mean(ii) - weight_ratio_sem(ii)],'k');
end
plot(get(gca, 'XLim'),[0,0],'k--');
plot(zeros(2,1),get(gca, 'YLim'),'k--');
set(gca, 'XTick', x_tick, 'XTickLabel', x_tick_str_skew)
xlabel(x_label_str);
ylabel('weighting ratio 3rd/2nd');
ConfAxis('fontSize', fontSize, 'LineWidth', LineWidth);

%% plot the noise cancelling...
if ~paper_plot_flag
    subplot(2,3,2)
else
    axes('Units','Points','Position', [36, 300, plot_size(1), plot_size(2)]);
end


residual_r_mean = zeros(n_conditions, 1);
residual_r_sem = zeros(n_conditions, 1);
for ii = 1:1:n_conditions
    residual_r_mean(ii) = residual_r_all{ii}.mean;
    residual_r_sem(ii) = residual_r_all{ii}.sem;
end
plot(x_value,residual_r_mean,'k.-');
hold on
for ii = 1:1:length(x_value)
    plot([x_value(ii), x_value(ii)], [residual_r_mean(ii) + residual_r_sem(ii) , residual_r_mean(ii) - residual_r_sem(ii)],'k');
end
plot(get(gca, 'XLim'),[0,0],'k--');
plot(zeros(2,1),get(gca, 'YLim'),'k--');
set(gca, 'XTick', x_tick, 'XTickLabel', x_tick_str_skew)
xlabel(x_label_str);
ylabel('noise r');
% set(gca, 'XScale','log')
ConfAxis('fontSize', fontSize, 'LineWidth', LineWidth);

%%
if ~paper_plot_flag
    subplot(2,3,2)
else
    axes('Units','Points','Position', [220, 300, plot_size(1), plot_size(2)]);
end
residual_slope_mean = zeros(n_conditions, 1);
residual_slope_sem = zeros(n_conditions, 1);
for ii = 1:1:n_conditions
    residual_slope_mean(ii) = residual_slope_all{ii}.mean;
    residual_slope_sem(ii) = residual_slope_all{ii}.sem;
end
plot(x_value,residual_slope_mean,'k.-');
hold on
for ii = 1:1:length(x_value)
    plot([x_value(ii), x_value(ii)], [residual_slope_mean(ii) + residual_slope_sem(ii) , residual_slope_mean(ii) - residual_slope_sem(ii)],'k');
end
plot(get(gca, 'XLim'),[0,0],'k--');
plot(zeros(2,1),get(gca, 'YLim'),'k--');
set(gca, 'XTick', x_tick, 'XTickLabel', x_tick_str_skew)
xlabel(x_label_str);
ylabel('noise slope');
% set(gca, 'XScale','log')
ConfAxis('fontSize', fontSize, 'LineWidth', LineWidth);

end