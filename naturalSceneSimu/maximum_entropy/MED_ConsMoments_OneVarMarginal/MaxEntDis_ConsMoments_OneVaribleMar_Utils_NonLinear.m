function [F, J] = MaxEntDis_ConsMoments_OneVaribleMar_Utils_NonLinear(lambda, mu, gray_level, N, dFdp, DpDx_part1)

%% you still have a lot of time doing this. N equations.
% you have three unknowns.
[mu_est, p] = MaxEntDis_ConsMoments_OneVaribleMar_Utils_FromXToMoments(lambda, gray_level, N);
F = mu_est - [1;mu];
%% finish calculating Jacobian.
% calculate Jacobian
dpdx = bsxfun(@times, DpDx_part1, p);
J = dFdp * dpdx;
end

%% calculating Jacobian
% first, dfdp, second dpdlambda