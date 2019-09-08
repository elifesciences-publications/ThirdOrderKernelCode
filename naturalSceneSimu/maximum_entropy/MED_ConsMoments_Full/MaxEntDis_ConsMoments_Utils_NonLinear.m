function [F, J] = MaxEntDis_ConsMoments_Utils_NonLinear(lambda, mu_true, gray_value, cov_true, dFdp, DpDx_part1, dP2dp, dP1dp,n_highest_moments, N, K)
%%
% p_joint = MaxEntDis_ConsMoments_Utils_FromLambdaToP(lambda, gray_value, N, K);

% from lambda and gray_level to calculate the F
[p_joint, F_est] = MaxEntDis_ConsMoments_Utils_FromLambdaToPF(lambda, gray_value, dP2dp, dP1dp, n_highest_moments, N, K);

F_true = [1; mu_true; cov_true];
%% set all of them to be one.
% cost_scaling_factor = 1./ F_true;
% F = F_est .* cost_scaling_factor - ones(length(F_true), 1); 
F = F_est  - F_true; 

%% Change the Cost Function. To be tested!!

%% Jacobian should not be very hard. Friday, finish this.
% input. initial lambda value.
dpdx = bsxfun(@times, DpDx_part1, p_joint);
% J = (cost_scaling_factor .* dFdp) * dpdx;
J =  dFdp * dpdx;

end



