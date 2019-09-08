function [x_solved, fval, exitflag, t_nonlinear_function] = MaxEntDis_ConsMoments_OneVaribleMar_Main( mu_true, n_highest_moments, gray_value, N)

function_tolerance = 1e-10; % 1e-11? is larger.
step_tolerance = 1e-7;
n_unknown = n_highest_moments + 1;

x_start_initial = rand(n_unknown, 1) * 0.01;
counter_max = 1;

[dFdp, DpDx_part1] = MaxEntDis_ConsMoments_OneVaribleMar_Utils_JacobPart(n_highest_moments, gray_value, N);
fun = @(x) MaxEntDis_ConsMoments_OneVaribleMar_Utils_NonLinear(x, mu_true, gray_value, N, dFdp, DpDx_part1);
options = optimoptions(@fsolve, 'Display', 'off', 'Algorithm', 'trust-region', 'SpecifyObjectiveGradient', true, 'PrecondBandWidth', 0,...
    'FunctionTolerance',function_tolerance, 'StepTolerance', step_tolerance, 'MaxIterations', 5000, 'MaxFunctionEvaluation', 5000);

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
end
%% look at the result.
