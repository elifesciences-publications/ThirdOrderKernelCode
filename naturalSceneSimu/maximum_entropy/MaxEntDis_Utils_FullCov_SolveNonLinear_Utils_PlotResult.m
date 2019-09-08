function [p_ij, p_i, covariance_matrix_solved] = MaxEntDis_Utils_FullCov_SolveNonLinear_Utils_PlotResult(x_solved, gray_value_mean_subtracted, N,K, varargin)
plot_flag = true;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
%
gray_value = gray_value_mean_subtracted;
p_factor = MaxEntDis_AllMar_TwoCovFull_Utils_LambdaToP(x_solved, gray_value_mean_subtracted, N,K);
p_ij = repmat(struct('var', [],'card', [], 'val', []), (K^2-K)/2, 1);
for ii = 1:1:K
    for jj = ii + 1:1:K
        ind_this = Calculate_Jacobian_Utils_EveryMarginalCov_Cov_Sub2Ind(ii, jj );
        
        p_ij(ind_this)= FactorMarginalization(p_factor, find(~ismember(1:K, [ii, jj])));
    end
end
p_i =  repmat(struct('var', [],'card',[], 'val', []), K, 1);
for ii = 1:1:K
    p_i(ii) = FactorMarginalization(p_factor, find(~ismember(1:K, ii)));
end

F_variance = zeros(K, 1);
for ii = 1:1:K
    % calculate covariance.
    F_variance(ii) =  p_i(ii).val' * gray_value_mean_subtracted.^2;
end
%% covariance
F_covariance = zeros((K^2 - K)/2, 1);
for ii = 1:1:(K^2 - K)/2
    F_covariance(ii) = gray_value_mean_subtracted' * reshape(p_ij(ii).val, [N,N]) * gray_value_mean_subtracted;
end

%% make the matrix.
covariance_matrix_solved = zeros(K, K);
for kk = 1:1:K
    covariance_matrix_solved(kk, kk) = F_variance(kk);
end
for ii = 1:1:K
    for jj = ii + 1:1:K
        ind_this = Calculate_Jacobian_Utils_EveryMarginalCov_Cov_Sub2Ind(ii, jj);
        covariance_matrix_solved(ii, jj) = F_covariance(ind_this);
    end
end

%%
if plot_flag
    MakeFigure;
    subplot(3,3,1);
    bar(gray_value, [p_i(:).val]);xlabel('contrast'); ylabel('probability'); title('solved - contrast distribution');
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
    for ii = 1:1:min([(K^2 - K)/2, 6])
        subplot(3,3,3 + ii)
        quickViewOneKernel(reshape(p_ij(ii).val, [N,N]), 1, 'labelFlag', false,'set_clim_flag', false);
        set(gca,'Clim',[0 max(p_ij(ii).val)]);
        
        xlabel(['x', num2str(p_ij(ii).var(1))]);
        ylabel(['x', num2str(p_ij(ii).var(2))]);
        title('solved- two-variable-prob')
    end
    lineStyles = brewermap(20,'Blues');
    colormap(lineStyles);
end
end