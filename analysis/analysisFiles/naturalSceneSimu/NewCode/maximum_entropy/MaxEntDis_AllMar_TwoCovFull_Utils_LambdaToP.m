function p_factor = MaxEntDis_AllMar_TwoCovFull_Utils_LambdaToP(x,gray_value_mean_subtracted, N,K)

% decompose unknowns into meaningful lambda.
lambda_0 = x(1);
lambda_1 = x(2:N *  K + 1); % N is gray level for K variables.
lambda_2 = x(N * K + 2:end); % The first K in lambda_2 are the variance term. The K + 1 to end  are the covariance term

%% calculate all terms
[~, sum_two_variable, sum_one_variable] = ...
    MaxEntDis_AllMar_TwoCovFull_Utils_LambdaToSum(1:K, lambda_1, lambda_2, gray_value_mean_subtracted, N, K);
p_val = exp(-1 + lambda_0 + sum_two_variable + sum_one_variable);
p_factor = struct('var', 1:K, 'card', ones(K, 1) * N, 'val', p_val);
end