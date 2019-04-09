function [x_solved, exitflag,dP2dp, dP1dP2, t_nonlinear_function, solved_flag, fval] = MaxEntDis_AllMar_TwoCov_Main(p_1_true, cov_true, gray_value_mean_subtracted, varargin)

N = length(p_1_true);
K = length(cov_true);
n_unknows = N * K + K + 1;
counter_max = 2; % solve 5 different initial values.
function_tolerance = 1e-9; % 1e-10 is larger.
x_start_initial = randn(n_unknows,1) * 0.01;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

N = length(p_1_true);
K = length(cov_true);
n_unknows = N * K + K + 1;
p_1_true = repmat(p_1_true, K, 1);

%% first, solve the lambda
% Jacobian matrix -- chain rule.
[DpDx_part1, dFdp, dP2dp, dP1dP2] = Calculate_Jacobian_Utils_CommonCoefficient_EveryMarginal(N, K, gray_value_mean_subtracted);

% structure of the function
fun = @(x) MaxEntDis_AllMar_TwoCov_Utils_NonLinear(x, p_1_true, cov_true, gray_value_mean_subtracted, DpDx_part1, dFdp, dP2dp, dP1dP2, N, K);
options = optimoptions(@fsolve, 'Display', 'off', 'Algorithm', 'trust-region', 'SpecifyObjectiveGradient', true, 'PrecondBandWidth', 0,...
    'FunctionTolerance',function_tolerance, 'MaxIterations', 2000);

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
    x_start = randn(n_unknows,1) * 0.01; % start over if the provided initial value does not work.
end
% x_solved = cell(100,1);
% exitflag = zeros(100,1);
% fval = cell(1000,1); % you do not know what is the fval actually.
% for ii = 1:1:100
%     x_start = randn(n_unknows,1) * 0.01;
%     [x_solved{ii}, fval{ii}, exitflag(ii), output] = fsolve(fun, x_start, options);
%     plot_result(x_solved{ii}, gray_value_mean_subtracted, N,K)
% end
end

