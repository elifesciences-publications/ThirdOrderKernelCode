function ci_r = Analysis_Utils_CalculateRInterval(r, n, alpha)
% http://onlinestatbook.com/2/estimation/correlation_ci.html provide a
% useful explainantion of estimating the confidence interval of pearson
% correlations.

% Sampling Distribution of Pearson'r is skewed. Transform it into a normal
% distribution z' with standard deviation 1/sqrt(N - 3);
% first, transform into z'
    normalized_std = norminv(1 - alpha/2); % 2 tail test.
   
    mean_z_prime = 0.5 * log((1 + r)/(1-r));
    std_z_prime = 1/sqrt(n - 3);
    ci_z = [mean_z_prime' - std_z_prime' * normalized_std, mean_z_prime' + std_z_prime' * normalized_std];
    
    % turns it back to r
    ci_r = (exp(2 .* ci_z) - 1)./(exp(2 .* ci_z) + 1);
    
end