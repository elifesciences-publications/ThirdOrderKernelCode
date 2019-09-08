function [x_solve_nonlinear_equation_format, fval, solved_flag, t_nonlinear_function] = MaxEntDis_ConsMoments_MinimizePotential_Utils_Main(mu_true, cov_true, gray_value, N, K, varargin)
plot_flag = false;
function_tolerance = 1e-8; 
step_tolerance = 1e-11;
OptimalityTolerance = 1e-8;
MaxFunctionEvaluations = 2000;
n_highest_moments = 3;
counter_max = 1;
MaxIterations = 2000;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
n_unknown = 1 + K * n_highest_moments + (K^2 - K)/2;
x_start_initial =  randn(n_unknown, 1) * 0.01;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

mu_true_full = repmat(mu_true, [1, K])';
mu_true_full = mu_true_full(:);
%% rescale each lambda by x, x^2, x^3. x^3... shared by many things...
DpDx_part1 = MaxEntDis_ConsMoments_MinimizePotential_Utils_Jacobian_Const(N, K, gray_value, mu_true_full, cov_true, n_highest_moments);

fun = @(x) MaxEntDis_ConsMoments_Utils_CalculatePotential(x,  mu_true_full, gray_value, cov_true, n_highest_moments, N, K, DpDx_part1);
options = optimoptions('fminunc', 'Display', 'off', 'Algorithm', 'trust-region', 'SpecifyObjectiveGradient', true, 'PrecondBandWidth', 0,...
    'FunctionTolerance',function_tolerance, 'StepTolerance', step_tolerance, 'MaxIterations', MaxIterations,'OptimalityTolerance', OptimalityTolerance, 'MaxFunctionEvaluations', MaxFunctionEvaluations );

t_nonlinear_function = [];
solved_flag = false;
counter = 1;
x_start = x_start_initial;
while ~solved_flag && counter <= counter_max
    tic
    [x_solved, fval, exitflag, output] = fminunc(fun, x_start(2:end), options);
    elapsedTime = toc;
    t_nonlinear_function = [t_nonlinear_function, elapsedTime];
    if exitflag > 0
        solved_flag = true;
    end
    counter = counter + 1;
    x_start = rand(n_unknown,1) * 0.01; % start over if the provided initial value does not work.
end
% MaxEntDis_ConsMoments_Utils_CalculatePotential(x_solved,  mu_true_full, gray_value, cov_true, n_highest_moments, N, K,DpDx_part1);

%% x_solved does not have lambda_0.
% calculate the lambda0 for x_solved.
x_solve_nonlinear_equation_format = MaxEntDis_ConsMoments_MinimizePotential_Utils_Calq0(x_solved, K, N, n_highest_moments, mu_true, cov_true, gray_value);

if plot_flag
    MaxEntDis_ConsMoments_Utils_PlotResult(x_solve_nonlinear_equation_format , gray_value, mu_true, cov_true, n_highest_moments, N, K);
%    MaxEntDis_ConsMoments_Utils_PlotResult(x_start_initial , gray_value, mu_true, cov_true, n_highest_moments, N, K);
end
end