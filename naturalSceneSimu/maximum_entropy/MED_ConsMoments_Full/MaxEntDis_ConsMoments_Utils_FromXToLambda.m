function [lambda0, lambda_one_variable, lambda_two_variable] = MaxEntDis_ConsMoments_Utils_FromXToLambda(x,n_highest_moments, N, K)
lambda0 = x(1); % all of them shared on
lambda_one_variable = zeros(n_highest_moments - 1, K);
%     lambda_two_variable = zeros((K^2 - K)/2, 1);

for ii = 1:1:n_highest_moments
    lambda_one_variable(ii, :) = x(1 + (ii - 1) * K + 1: 1 + ii * K + 1); %
end
% 1 + K * (n_highest_moments - 1) is number of lambda for one variable
% distribution.
lambda_two_variable =  x(1 + K * (n_highest_moments - 1) + 1:end);
end