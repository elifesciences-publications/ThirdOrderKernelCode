function MaxEntDis_Utils_SolveNonLinear_Utils_PlotResult(x_solved, gray_value_mean_subtracted, N,K)
%
gray_value = gray_value_mean_subtracted;
p_factor = MaxEntDis_AllMar_TwoCov_Utils_LambdaToP(x_solved, gray_value_mean_subtracted, N,K);
p_two_variable = repmat(struct('var',[],'card',[],'val',[]),K - 1, 1);
for ii = 1:1:K - 1
    % 1 with ii + 1
    var_marginalized = find(~ismember(1:K, [1, ii + 1]));
    p_two_variable(ii) = FactorMarginalization(p_factor, var_marginalized);
end
% get the one-variable marginal
p_one_variable = repmat(struct('var',[],'card',[],'val',[]),K, 1);
p_one_variable(1) = FactorMarginalization(p_two_variable(1), 2);
for ii = 2:1:K
    p_one_variable(ii) = FactorMarginalization(p_two_variable(ii - 1), 1);
end
C_11 = p_one_variable(1).val' * (gray_value_mean_subtracted.^2);
cov_between_variables = zeros(K - 1, 1);
for ii = 1:1:K - 1
    cov_between_variables(ii) = gray_value_mean_subtracted' * reshape(p_two_variable(ii).val, [N,N]) * gray_value_mean_subtracted;
end
cov_solved = [C_11;cov_between_variables];
%%
subplot(3,3,1);
bar(gray_value, [p_one_variable(:).val]);xlabel('contrast'); ylabel('probability'); title('solved - contrast distribution');
subplot(3,3,2); % covariance matrix.
cov_mat_value_ind_in_lambda_two_variable = covariance_index_transition_mat_to_vector(1:K^2, K);
covariance_matrix_solved = reshape(cov_solved(cov_mat_value_ind_in_lambda_two_variable), K, K);
quickViewOneKernel(covariance_matrix_solved, 1, 'labelFlag', false);
set(gca,'Clim',[0 max(covariance_matrix_solved(:))]);
title('solved - covariance matrix');

subplot(3,3, 3); % correlation matrix;
correlation_matrix_solved = covariance_matrix_solved./C_11;
quickViewOneKernel(correlation_matrix_solved, 1, 'labelFlag', false);
set(gca,'Clim',[0 1]);
title('solved - correlation matrix');
% look at the marginal distribution.
for ii = 1:1:K - 1
    subplot(3,3,3 + ii)
    quickViewOneKernel(reshape(p_two_variable(ii).val, [N,N]), 1, 'labelFlag', false,'set_clim_flag', false);
    set(gca,'Clim',[0 max(p_two_variable(ii).val)]);
    
    xlabel(['x', num2str(p_two_variable(ii).var(1))]);
    ylabel(['x', num2str(p_two_variable(ii).var(2))]);
    title('solved- two-variable-prob')
end
lineStyles = brewermap(20,'Blues');
colormap(lineStyles);

%% soooo ungly...
MakeFigure;  % you could have another plot
subplot(3,3,1);
bar(gray_value, [p_one_variable(:).val]);xlabel('contrast'); ylabel('probability'); title('solved - contrast distribution');
ConfAxis

subplot(3,3,2); % covariance matrix.
cov_mat_value_ind_in_lambda_two_variable = covariance_index_transition_mat_to_vector(1:K^2, K);
covariance_matrix_solved = reshape(cov_solved(cov_mat_value_ind_in_lambda_two_variable), K, K);
quickViewOneKernel(covariance_matrix_solved, 1, 'labelFlag', false);
set(gca,'Clim',[0 max(covariance_matrix_solved(:))]);
title('solved - covariance matrix');
ConfAxis

subplot(3,3,3);
correlation_matrix_solved = covariance_matrix_solved./C_11;
scatter(1:K, correlation_matrix_solved(1:4),'k','filled');
set(gca,'Clim',[0 1]);
title('solved - correlation matrix');
lineStyles = brewermap(20,'Blues');
colormap(lineStyles);
ConfAxis
end