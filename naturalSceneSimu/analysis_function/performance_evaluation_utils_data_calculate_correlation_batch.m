function [metric_batches,  improvement_metric_batches_3rd, improvement_metric_batches_best,weight_ratio, residual_r, residual_slope] ...
    = performance_evaluation_utils_data_calculate_correlation_batch(data, performance_metric)
num_batches = length(data);
is_v3_flag = isfield(data{1},'v3');
if is_v3_flag
    r_all_batches = zeros(4, num_batches);
    w_all_batches = zeros(2, num_batches);
    residual_r_all_bathces = zeros(1, num_batches);
    residual_slope_all_bathces = zeros(2, num_batches);
else
    r_all_batches = zeros(1, num_batches);
    w_all_batches = zeros(1, num_batches);
end
for ii = 1:1:num_batches
    [r_all_batches(:, ii),w_all_batches(:,ii),residual_r_all_bathces(:,ii), residual_slope_all_bathces(:,ii)] ...
        = performance_evaluation_utils_data_calculate_correlation(data{ii}, is_v3_flag);
end
%% metric will control whether you output correlation and improvement of correlations
%% or unexplained varianc and reduction of error reduction.
switch performance_metric
    case 'corr_improvement'
        metric_all_batches = r_all_batches;
        if is_v3_flag
            improvement_metric_all_batches_3rd = (r_all_batches(3,:) - r_all_batches(1,:))./r_all_batches(1,:);
            improvement_metric_all_batches_best = (r_all_batches(4,:) - r_all_batches(1,:))./r_all_batches(1,:);
        else
            improvement_metric_all_batches_3rd = [];
            improvement_metric_all_batches_best = [];
        end
    case 'error_reduction'
        metric_all_batches = 1 - r_all_batches.^2;
        if is_v3_flag
            improvement_metric_all_batches_3rd = (metric_all_batches(1,:) - metric_all_batches(3,:))./metric_all_batches(1,:);
            improvement_metric_all_batches_best = (metric_all_batches(1,:) - metric_all_batches(4,:))./metric_all_batches(1,:);
        else
            improvement_metric_all_batches_3rd = [];
            improvement_metric_all_batches_best = [];
        end
end


metric_batches.mean = mean(metric_all_batches, 2);
if num_batches > 1
    metric_batches.std = std(metric_all_batches, 1, 2);
    metric_batches.sem =  metric_batches.std./sqrt(num_batches);
end

if is_v3_flag
    improvement_metric_batches_3rd.mean = mean(improvement_metric_all_batches_3rd, 2);
    improvement_metric_batches_best.mean = mean(improvement_metric_all_batches_best, 2);
    if num_batches > 1
        improvement_metric_batches_3rd.std = std(improvement_metric_all_batches_3rd, 1, 2);
        improvement_metric_batches_3rd.sem = improvement_metric_batches_3rd.std/sqrt(num_batches);
        
        improvement_metric_batches_best.std = std(improvement_metric_all_batches_best, 1, 2);
        improvement_metric_batches_best.sem = improvement_metric_batches_best.std/sqrt(num_batches);
        
    end
    weight_ratio_3rd_over_2nd = w_all_batches(2,:)./w_all_batches(1,:);
    weight_ratio.mean = mean( weight_ratio_3rd_over_2nd);
    weight_ratio.std = std(weight_ratio_3rd_over_2nd, 1);
    weight_ratio.sem = weight_ratio.std/sqrt(num_batches);
    
    residual_r.mean = mean(residual_r_all_bathces);
    residual_r.std = std(residual_r_all_bathces);
    residual_r.sem = residual_r.std/sqrt(num_batches);

    residual_slope.mean = mean(residual_slope_all_bathces(2,:));
    residual_slope.std = std(residual_slope_all_bathces(2,:));
    residual_slope.sem = residual_slope.std/sqrt(num_batches);
    
else
    improvement_metric_batches_3rd = [];
    improvement_metric_batches_best = [];
    weight_ratio = [];
    residual_r = [];
    residual_slope = [];
end

%% having a histogram for different batches...
% MakeFigure;
% if is_v3_flag
%     xlabel_str_bank = {'correlation between 2nd and image velocity',...
%         'correlation between 3rd and image velocity',...
%         'correlation between 2nd + 3rd and image velocity',...
%         'best correlation'};
% else
%     xlabel_str_bank = {'correlation between 2nd and image velocity'};
% end
% for ii = 1:1:size(r_all_batches, 1)
%     subplot(2,3,ii);
%     histogram(r_all_batches(ii, :), 'FaceColor', [0,0,0]);
%     xlabel(xlabel_str_bank{ii});
%     ylabel('count');
%     ConfAxis;
% end
end
