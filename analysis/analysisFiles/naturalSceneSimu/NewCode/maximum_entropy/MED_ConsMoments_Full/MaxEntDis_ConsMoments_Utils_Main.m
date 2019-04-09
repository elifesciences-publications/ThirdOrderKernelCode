function [x_solved, fval, solved_flag, t_nonlinear_function] = MaxEntDis_ConsMoments_Utils_Main(mu_true, cov_true, gray_value, N, K, varargin)
plot_flag = false;
function_tolerance = 1e-14; % 1e-11? is larger.
step_tolerance = 1e-10;
OptimalityTolerance = 1e-10;
MaxFunctionEvaluations = 3000;
n_highest_moments = 3;
counter_max = 1;
MaxIterations = 3000;
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
%% do transfermation here? no!

%% you have everything, tested it out.
[DpDx_part1, dFdp, dP2dp, dP1dp] = MaxEntDis_ConsMomements_Utils_Jacobian_Const(N, K, gray_value, n_highest_moments);

fun = @(x) MaxEntDis_ConsMoments_Utils_NonLinear(x,  mu_true_full, gray_value, cov_true, dFdp, DpDx_part1, dP2dp, dP1dp,n_highest_moments, N, K);
options = optimoptions(@fsolve, 'Display', 'iter', 'Algorithm', 'trust-region', 'SpecifyObjectiveGradient', true, 'PrecondBandWidth', 0,...
    'FunctionTolerance',function_tolerance, 'StepTolerance', step_tolerance, 'MaxIterations', MaxIterations,'OptimalityTolerance', OptimalityTolerance, 'MaxFunctionEvaluations', MaxFunctionEvaluations );

t_nonlinear_function = [];
solved_flag = false;
counter = 1;
x_start = x_start_initial;
while ~solved_flag && counter <= counter_max
    tic
    [x_solved, fval, exitflag, output] = fsolve(fun, x_start, options);
    elapsedTime = toc;
    t_nonlinear_function = [t_nonlinear_function, elapsedTime];
    if exitflag > 0
        solved_flag = true;
    end
    counter = counter + 1;
    x_start = rand(n_unknown,1) * 0.01; % start over if the provided initial value does not work.
end
%%
if plot_flag
    MaxEntDis_ConsMoments_Utils_PlotResult(x_solved, gray_value, mu_true , cov_true, n_highest_moments, N, K);
%     MaxEntDis_ConsMoments_Utils_PlotResult(x_start_initial, gray_value, mu_true , cov_true, n_highest_moments, N, K);
end
end