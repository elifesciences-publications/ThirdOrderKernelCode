function MaxEntDis_Utils_Gibbs_Utils_PlotOneTimeSeries(time_series, gray_value,N,K)
MakeFigure;
subplot(4,1,1)
plot(time_series);

subplot(3,3,4);
gray_vale_edges = [gray_value(1) - 1e-5;gray_value + 1e-5];
h = histogram(time_series ,gray_vale_edges,'Visible', 'off','Normalization', 'probability');
bar(gray_value, h.Values); xlabel('contrast'); ylabel('probability'); title('sampled - contrast distribution');
ConfAxis

subplot(3,3,5);
C_11_sampled = var(time_series);
cov_between_variables_solved = zeros(K - 1, 1);
for ii = 1:1:K - 1
    a = cov(time_series(1:end - ii), time_series(ii + 1: end));
    cov_between_variables_solved(ii) = a(1,2);
end
cov_sampled = [C_11_sampled; cov_between_variables_solved];
cov_mat_value_ind_in_lambda_two_variable = covariance_index_transition_mat_to_vector(1:K^2, K);
covariance_matrix_sampled = reshape(cov_sampled(cov_mat_value_ind_in_lambda_two_variable), K, K);
quickViewOneKernel(covariance_matrix_sampled, 1, 'labelFlag', false);
title('sampled - covariance matrix');
set(gca,'Clim',[0 max(covariance_matrix_sampled(:))]);
ConfAxis

subplot(3,3,6);
correlation_matrix_sampled = covariance_matrix_sampled./C_11_sampled;
scatter(1:K, correlation_matrix_sampled(1,1:K),'k','filled');
title('sampled - correlation matrix');
set(gca,'Clim',[0 1]);
ConfAxis
lineStyles = brewermap(20,'Blues');
colormap(lineStyles);
%% 
%% plot the marginal distribution.
% for ii = 1:1:3
%     subplot(3,3,6 + ii)
%     grid_approximation_show([time_series(1:end - K),time_series(1 + ii : end - K + ii)],'edges',[{gray_value},{gray_value}]);
% end
end