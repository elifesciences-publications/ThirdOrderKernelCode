function [metric_2d, metric_skew, metric_var,data_subgroup_2d,data_subgroup_skew,data_subgroup_var  ] =  subensemble_analysis_organize_data(data, scene_stim,edges)

%% use all those tools to separate data. interesting...
scene_variance = var(scene_stim, 1, 2);
scene_skewness = skewness(scene_stim, 1, 2);
%%
X = [scene_variance, scene_skewness];

%% group data according to the
var_num = 1;
skew_num = 2;
n_bin_skew = length(edges{skew_num}) - 1;
n_bin_var = length(edges{var_num}) - 1;
% group the data using the edges and X. two d is not that hard. do it.
ind_2d = cell(n_bin_skew, n_bin_var);
for ii = 1:1:n_bin_skew
    for jj = 1:1:n_bin_var
        ind_2d{ii, jj} = find(X(:, skew_num) < edges{skew_num}(ii + 1) ...
            & X(:, skew_num) > edges{skew_num}(ii)...
            & X(:, var_num) < edges{var_num}(jj + 1)...
            & X(:, var_num) > edges{var_num}(jj));
    end
end
ind_skew = cell(n_bin_skew, 1);
for ii = 1:1:n_bin_skew
    ind_skew{ii} = find(X(:, skew_num) < edges{skew_num}(ii + 1) ...
        & X(:, skew_num) > edges{skew_num}(ii));
end
ind_var = cell(n_bin_var, 1);
for jj = 1:1:n_bin_var
    ind_var{jj} = find(X(:, var_num) < edges{var_num}(jj + 1)...
        & X(:, var_num) > edges{var_num}(jj));
end
%
data_subgroup_2d = cell(n_bin_skew, n_bin_var);
data_subgroup_skew = cell(n_bin_skew, 1);
data_subgroup_var = cell(n_bin_var, 1);
% group them together, and calculate the metric.
metric_2d = zeros(n_bin_skew, n_bin_var);
metric_skew = cell(n_bin_skew, 1);
metric_var = cell(n_bin_var, 1);
% group them together.
n_one_bin = 10;
% first, both group. 2d.
for ii = 1:1:n_bin_skew
    for jj = 1:1:n_bin_var
        data_subgroup_2d{ii, jj} = put_data_in_the_same_subgroup_together(data, ind_2d{ii, jj});
        if length(ind_2d{ii, jj}) > n_one_bin
            [~, metric,~,~] = plot_scatter_plot_correlation_one_situation...
                (data_subgroup_2d{ii, jj}, '','num_batches',1,'plot_flag', false);
            metric_2d(ii, jj) = metric.mean;
        else
            metric_2d(ii, jj) = NaN;
        end
        
    end
end

metric_2d = metric_2d';
% second. skew only.
for ii = 1:1:n_bin_skew
    data_subgroup_skew{ii} = put_data_in_the_same_subgroup_together(data, ind_skew{ii});
    if length(ind_skew{ii}) > n_one_bin
        [~, metric_skew{ii},~,~] = plot_scatter_plot_correlation_one_situation...
            (data_subgroup_skew{ii}, '','num_batches',5,'plot_flag', false);
    else
        metric_skew{ii} = NaN;
    end
end
% third. variance only
for ii = 1:1:n_bin_var
    data_subgroup_var{ii} = put_data_in_the_same_subgroup_together(data, ind_var{ii});
    if length(ind_var{ii}) > n_one_bin
        [~, metric_var{ii},~,~] = plot_scatter_plot_correlation_one_situation...
            (data_subgroup_var{ii}, '','num_batches',5,'plot_flag', false);
    else
        metric_var{ii} = NaN;
    end
end

end