function MaxEntDis_Utils_SolveNonLinear_Utils_PlotResult_FullCov(x_solved, gray_value_mean_subtracted, N,K)
%
gray_value = gray_value_mean_subtracted;
p_factor = MaxEntDis_AllMar_TwoCov_Utils_LambdaToP(x_solved, gray_value_mean_subtracted, N,K);
p_two_variable = repmat(struct('var',[],'card',[],'val',[]),K, K);
for ii = 1:1:K
    for jj = [1: ii - 1, ii + 1:1:K]
    % 1 with ii + 1
    var_marginalized = find(~ismember(1:K, [ii, jj]));
    p_two_variable(ii, jj) = FactorMarginalization(p_factor, var_marginalized);
    end
end
% get the one-variable marginal, every one-variable should be able to get
% several representation
p_one_variable = repmat(struct('var',[],'card',[],'val',[]),K, K);
for ii = 1:1:K
    for jj = [1: ii - 1, ii + 1:1:K]
        p_one_variable(ii,jj) = FactorMarginalization(p_two_variable(ii,jj), jj);
    end
end

%% 
covariance_matrix_solved = zeros(K, K);
for ii = 1:1:K
    for jj = 1: 1:K
        if ii == jj
            if ii == 1
             covariance_matrix_solved(ii,jj) = p_one_variable(ii, ii + 1).val' * (gray_value_mean_subtracted.^2);
            else
             covariance_matrix_solved(ii,jj) = p_one_variable(ii, ii - 1).val' * (gray_value_mean_subtracted.^2);
            end
        else
            covariance_matrix_solved(ii,jj) = gray_value_mean_subtracted' * reshape(p_two_variable(ii,jj).val, [N,N]) * gray_value_mean_subtracted;

        end
    end
end
%%
subplot(3,3,1);
bar(gray_value, [p_one_variable(:).val]);xlabel('contrast'); ylabel('probability'); title('solved - contrast distribution');
subplot(3,3,2); % covariance matrix.
quickViewOneKernel(covariance_matrix_solved, 1, 'labelFlag', false);
set(gca,'Clim',[0 max(covariance_matrix_solved(:))]);
title('solved - covariance matrix');

subplot(3,3, 3); % correlation matrix;
correlation_matrix_solved = covariance_matrix_solved./covariance_matrix_solved(1,1);
quickViewOneKernel(correlation_matrix_solved, 1, 'labelFlag', false);
set(gca,'Clim',[0 1]);
title('solved - correlation matrix');
% look at the marginal distribution.
for ii = 1:1:K - 1
    subplot(3,3,3 + ii)
    quickViewOneKernel(reshape(p_two_variable(ii, ii + 1).val, [N,N]), 1, 'labelFlag', false,'set_clim_flag', false);
    set(gca,'Clim',[0 max(p_two_variable(ii, ii + 1).val)]);
    
    xlabel(['x', num2str(p_two_variable(ii, ii + 1).var(1))]);
    ylabel(['x', num2str(p_two_variable(ii, ii + 1).var(2))]);
    title('solved- two-variable-prob')
end
lineStyles = brewermap(20,'Blues');
colormap(lineStyles);

%% 
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