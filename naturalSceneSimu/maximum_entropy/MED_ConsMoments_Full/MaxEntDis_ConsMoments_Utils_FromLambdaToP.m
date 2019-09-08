function p = MaxEntDis_ConsMoments_Utils_FromLambdaToP(lambda, gray_value, N, K,varargin)
n_highest_moments = 3;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
%% write a function to parse this.
% not very useful here.
% [lambda0, lambda_one_variable, lambda_two_variable] = ...
%     MaxEntDis_ConsMoments_Utils_FromXToLambda(lambda,n_highest_moments, N, K);
assignment = IndexToAssignment(1:N^K,ones(K, 1) * N);
%% first, arrange a large thing.
one_variable_x = zeros(N^K, K * n_highest_moments);
for order = 1:1:n_highest_moments
    one_variable_x(:, (order - 1) * K + 1: order * K) = gray_value(assignment).^order;
end

two_variable_x = zeros(N^K, (K^2 - K)/2);
for jj = 2:1:K
    for ii = 1:jj - 1
        ind = Calculate_Jacobian_Utils_EveryMarginalCov_Cov_Sub2Ind(ii, jj);
        two_variable_x(:, ind) = gray_value(assignment(:, ii)) .* gray_value(assignment(:, jj));
    end
end

X = [-ones(N^K, 1), ones(N^K, 1), one_variable_x, two_variable_x];
f = X * [1;lambda];
p = exp(f);
end