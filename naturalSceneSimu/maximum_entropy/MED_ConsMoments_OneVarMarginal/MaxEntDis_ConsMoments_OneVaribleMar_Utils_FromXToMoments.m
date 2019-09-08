function [mu_est, p] = MaxEntDis_ConsMoments_OneVaribleMar_Utils_FromXToMoments(lambda, gray_value, N)
    p = MaxEntDis_ConsMoments_OneVaribleMar_Utils_FromXToP(lambda, gray_value, N);
    n_highest_moments = length(lambda) - 1;
    mu_est = zeros(n_highest_moments + 1, 1);
    for ii = 1:1: n_highest_moments + 1
        order = ii - 1;
        mu_est(ii) = moment_computing(p, gray_value, order);
    end
end
