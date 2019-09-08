function [p_joint, p_ij, p_i, correlation_solved ] = MaxEntDis_ConsMoments_Utils_PlotResult(lambda, gray_value, mu_true, cov_true, n_highest_moments, N, K, varargin)
plot_flag = 1;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% first, calculate the marginal p one variable, and p two variable. The existence of this. you also interested in those
% you could compute p_joint first.
p_joint = MaxEntDis_ConsMoments_Utils_FromLambdaToP(lambda, gray_value, N, K,'n_highest_moments',n_highest_moments);
p_factor = struct('var', 1:K, 'card', ones(K, 1) * N, 'val', p_joint);
p_ij_struct = repmat(struct('var', [],'card', [], 'val', []), (K^2-K)/2, 1);
p_ij = zeros(N^2, (K^2-K)/2);

for ii = 1:1:K
    for jj = ii + 1:1:K
        ind_this = Calculate_Jacobian_Utils_EveryMarginalCov_Cov_Sub2Ind(ii, jj );
        
        p_ij_struct(ind_this)= FactorMarginalization(p_factor, find(~ismember(1:K, [ii, jj])));
        p_ij(:, ind_this) = p_ij_struct(ind_this).val;
    end
end
p_i_struct =  repmat(struct('var', [],'card',[], 'val', []), K, 1);
p_i = zeros(N, K);
for ii = 1:1:K
    p_i_struct(ii) = FactorMarginalization(p_factor, find(~ismember(1:K, ii)));
    p_i(:, ii) = p_i_struct(ii).val;
end
%%
F = MaxEntDis_ConsMoments_Utils_FromMargiPtoF(p_ij, p_i, gray_value, n_highest_moments, N, K);
F(1) = [];
mu_est = reshape(F(1: n_highest_moments*K), K, n_highest_moments); F(1: n_highest_moments*K) = [];
variance_est = mu_est(:, 2) - mu_est(:, 1).^2;
cov_est = F;

%% make the matrix.
covariance_matrix_solved = zeros(K, K);
for kk = 1:1:K
    covariance_matrix_solved(kk, kk) = variance_est(kk); % you can also calculate this to verify the equation.
end
correlation_solved_matrix = zeros(K, K);
for ii = 1:1:K
    for jj = ii + 1:1:K
        ind_this = Calculate_Jacobian_Utils_EveryMarginalCov_Cov_Sub2Ind(ii, jj);
        covariance_matrix_solved(ii, jj) = cov_est(ind_this) - mu_est(ii,1) * mu_est(jj,1);
        correlation_solved_matrix(ii, jj)  = covariance_matrix_solved(ii, jj)./(sqrt(covariance_matrix_solved(ii,ii)) * sqrt(covariance_matrix_solved(jj,jj)));
    end
end
correlation_solved = zeros(K - 1, 1);
for ii = 1:1:K - 1
    correlation_solved(ii) = mean(correlation_solved_matrix(triu(ones(K),ii) & tril(ones(K),ii)));
end
if plot_flag
    MaxEntDis_ConsMoments_Utils_PlotResult_Plot(gray_value, p_i,p_ij, mu_true, mu_est, cov_true, cov_est, covariance_matrix_solved, n_highest_moments, N, K)
end
% MakeFigure;
% subplot(3,5,1);
% bar(gray_value, p_i);xlabel('contrast'); ylabel('probability'); title('solved - contrast distribution');
% % also plot moments.
% subplot(3,5,2);
% plot(1:n_highest_moments, mu_true(1:K:end), 'k'); hold on;
% for kk = 1:1:K
%     plot(1:n_highest_moments, mu_est(ii,:), 'r');
% end
% legend('true', 'solved'); xlabel('moments');
%
%
% subplot(3,5,3); % covariance matrix.
% quickViewOneKernel(covariance_matrix_solved, 1, 'labelFlag', false);
% set(gca,'Clim',[0 max(covariance_matrix_solved(:))]);
% title('solved - covariance matrix');
% subplot(3,5,4); % correlation matrix;
% correlation_matrix_solved = covariance_matrix_solved./covariance_matrix_solved(1,1);
% quickViewOneKernel(correlation_matrix_solved, 1, 'labelFlag', false);
% set(gca,'Clim',[0 1]);
% title('solved - correlation matrix');
% subplot(3,5,5); % correlation matrix;
% plot(cov_true,'k'); hold on;
% plot(cov_est, 'r');
% legend('true', 'solved'); xlabel('covariance matrix');
%
%
% % look at the marginal distribution.
% for ii = 1:1:min([(K^2 - K)/2, 6])
%     subplot(3,3,3 + ii)
%     quickViewOneKernel(reshape(p_ij_struct(ii).val, [N,N]), 1, 'labelFlag', false,'set_clim_flag', false);
%     set(gca,'Clim',[0 max(p_ij_struct(ii).val)]);
%
%     xlabel(['x', num2str(p_ij_struct(ii).var(1))]);
%     ylabel(['x', num2str(p_ij_struct(ii).var(2))]);
%     title('solved- two-variable-prob')
% end
% lineStyles = brewermap(20,'Blues');
% colormap(lineStyles);

end
