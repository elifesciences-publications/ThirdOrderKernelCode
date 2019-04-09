function [x_solved_scale, gray_value_mean_subtracted_scale,solved_flag, fval,  exitflag_scale, t_nonlinear_function,...
    x_solved_scale_back, gray_value_mean_subtracted] = ...
    MaxEntDis_Utils_FindDist_To_MatchUp_GrayLevel_Correlation_FullC(gray_value, correlation, p_1_true, N, K, varargin)
plot_flag = false;
x_start_initial = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

mu_one_variable = p_1_true'* gray_value; %% mean value is probability * value, not mean(gray_value).
gray_value_mean_subtracted = gray_value - mu_one_variable;
var_one_variable = p_1_true'* (gray_value_mean_subtracted).^2;
correlation_matrix = zeros( (K^2 + K)/2, 1);
correlation_matrix(1:K) = 1;
for ii = 1:1:K
    for jj = ii + 1:1:K
        ind_this = Calculate_Jacobian_Utils_EveryMarginalCov_Cov_Sub2Ind(ii, jj);
        dist_ii_jj = jj - ii;
        correlation_matrix(K + ind_this) = correlation(dist_ii_jj);
    end
end

%% scaling
if var_one_variable > 0.5
    n_scaling = var_one_variable/0.5; % scaling the variable and K how many variables. s
else
    n_scaling  = 1;
end
% calculate the n_scaling......
gray_value_scale = gray_value/n_scaling; % from 1 to 5. could change in the future.

% a set of consistent values
mu_one_variable_scale = p_1_true'* gray_value_scale;
gray_value_mean_subtracted_scale = gray_value_scale - mu_one_variable_scale;
var_one_variable_scale = p_1_true' * (gray_value_mean_subtracted_scale).^2;


cov_true_scale = correlation_matrix * var_one_variable_scale;

%% solve the equation
[x_solved_scale, exitflag_scale,~,~,t_nonlinear_function, solved_flag, fval] = ...
    MaxEntDis_AllMar_TwoCovFull_Main(p_1_true, cov_true_scale, gray_value_mean_subtracted_scale,K, varargin{:});

x_solved_scale_back = x_solved_scale;
x_solved_scale_back(end - (K^2 + K)/2 + 1:end) = x_solved_scale_back(end - (K^2 + K)/2 + 1:end)./n_scaling^2;

%%
if plot_flag
%     MakeFigure;
%     MaxEntDis_Utils_FullCov_SolveNonLinear_Utils_PlotResult(x_solved_scale, gray_value_mean_subtracted_scale, N,K);
    MakeFigure;
    MaxEntDis_Utils_FullCov_SolveNonLinear_Utils_PlotResult(x_solved_scale_back, gray_value_mean_subtracted, N,K);
end
end

%%
% MakeFigure; plot(x_solved_scale_back); hold on; plot(x_solved);
%% look at wether you got the same solution..
% MakeFigure;
% MaxEntDis_Utils_SolveNonLinear_Utils_PlotResult(x_solved, gray_value_mean_subtracted, N,K);
% % MakeFigure;
% % MaxEntDis_Utils_SolveNonLinear_Utils_PlotResult(x_solved_scale, gray_value_mean_subtracted_scale, N,K);
% MakeFigure;
% MaxEntDis_Utils_SolveNonLinear_Utils_PlotResult(x_solved_scale_back, gray_value_mean_subtracted, N,K);
%
% n_sample = 10000;
% time_series_level_label = MaxEntDist_AllMar_TwoCov_Utils_GibbsSampling(x_solved, gray_value_mean_subtracted, N, K, n_sample);
% time_series = gray_value(time_series_level_label);
%
% time_series_level_label_scale = MaxEntDist_AllMar_TwoCov_Utils_GibbsSampling(x_solved_scale, gray_value_mean_subtracted_scale, N, K, n_sample);
% % time_series_scale = gray_value_scale(time_series_level_label_scale);
% time_series_scale_back = gray_value(time_series_level_label_scale);
%
% %%
% MaxEntDis_Utils_Gibbs_Utils_PlotOneTimeSeries(time_series, gray_value,N,K);
% MaxEntDis_Utils_Gibbs_Utils_PlotOneTimeSeries(time_series_scale_back, gray_value,N,K);
