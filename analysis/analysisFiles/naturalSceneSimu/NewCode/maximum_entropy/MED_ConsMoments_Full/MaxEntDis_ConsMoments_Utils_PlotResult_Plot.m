function MaxEntDis_ConsMoments_Utils_PlotResult_Plot(gray_value, p_i, p_ij, mu_true, mu_est, cov_true, cov_est, covariance_matrix_solved, n_highest_moments, N, K)
%% plotting function shared by two methods.

MakeFigure;
subplot(3,5,1);
bar(gray_value, p_i);xlabel('contrast'); ylabel('probability'); title('solved - contrast distribution');
% also plot moments.
subplot(3,5,2);
plot(1:n_highest_moments, mu_true(1:end), 'k'); hold on;
for kk = 1:1:K
    plot(1:n_highest_moments, mu_est(kk,:), 'r');
end
legend('true', 'solved'); xlabel('moments');


subplot(3,5,3); % covariance matrix.
quickViewOneKernel(covariance_matrix_solved, 1, 'labelFlag', false);
set(gca,'Clim',[0 max(covariance_matrix_solved(:))]);
title('solved - covariance matrix');
subplot(3,5,4); % correlation matrix;
correlation_matrix_solved = covariance_matrix_solved./covariance_matrix_solved(1,1);
quickViewOneKernel(correlation_matrix_solved, 1, 'labelFlag', false);
set(gca,'Clim',[0 1]);
title('solved - correlation matrix');
subplot(3,5,5); % correlation matrix;
plot(cov_true,'k'); hold on;
plot(cov_est, 'r');
legend('true', 'solved'); xlabel('covariance matrix');


% look at the marginal distribution.
%% change this!!!
for ii = 1:1:min([(K^2 - K)/2, 6])
    subplot(3,3,3 + ii)
    quickViewOneKernel(reshape(p_ij(:, ii), [N,N]), 1, 'labelFlag', false,'set_clim_flag', false);
    set(gca,'Clim',[0 max(p_ij(:, ii))]);
    
    [x1, x2] = Calculate_Jacobian_Utils_EveryMarginalCov_Cov_Ind2Sub(ii);
    xlabel(['x', num2str(x1)]);
    ylabel(['x', num2str(x2)]);
    title('solved- two-variable-prob')
end
lineStyles = brewermap(20,'Blues');
colormap(lineStyles);


end