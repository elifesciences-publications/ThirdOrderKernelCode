function time_series_level_label = ...
    MaxEntDist_ConsMoments_Utils_Sampling_TimeSeriesLevel(x_solved, gray_value, N, K, n_sample,varargin)
n_highest_moments = 3;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
p_joint = MaxEntDis_ConsMoments_Utils_FromLambdaToP(x_solved, gray_value, N, K,'n_highest_moments',n_highest_moments);
if k
p_factor = struct('var', [1:K]', 'card', ones(K, 1)* N, 'val', p_joint);
p_marginal = FactorMarginalization(p_factor, [2:K]);
p_conditional_probability = cell(K - 1, 1);
for kk = 2:1:K
    p_conditional_probability{kk - 1} = MaxEntDis_Utils_Calculate_ConditionalProbability(p_factor, kk, [1:kk - 1]');
end
%% 
time_series_level_label = zeros(n_sample, 1);
time_series_level_label(1) = GibbsSampling_Utils_OD_Sample(p_marginal.val, 1);
% time_series_level_label(1) = N - 2;
for ii = 2:1:K - 1
    p_conditional_in_use = p_conditional_probability{ii - 1};
    previous_condition_assignment = time_series_level_label(ii - (ii - 1):ii - 1);
    previous_condition_index = AssignmentToIndex(previous_condition_assignment, ones(ii - 1, 1) * N);
    p_this = p_conditional_in_use(:, previous_condition_index);
    time_series_level_label(ii) = GibbsSampling_Utils_OD_Sample(p_this, 1);
end

p_conditional_in_use = p_conditional_probability{K - 1};
for ii = K:1:n_sample
    previous_condition_assignment = time_series_level_label(ii - (K - 1):ii - 1);
    previous_condition_index = AssignmentToIndex(previous_condition_assignment, ones(K - 1, 1) * N);
    p_this = p_conditional_in_use(:, previous_condition_index);
    time_series_level_label(ii) = GibbsSampling_Utils_OD_Sample(p_this, 1);
end
% higher than thought. Why is that? not sure...
% MaxEntDis_Utils_Gibbs_Utils_PlotOneTimeSeries(gray_value(time_series_level_label(end - 1000:end)), gray_value,N,K);

end
