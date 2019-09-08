function moments_value = varskew2moments(mean_value, var_value, skewness_value)
    % moments
    moments_value = zeros(3, 1);
    moments_value(1) = mean_value;
    moments_value(2) = var_value + mean_value.^2;
    moments_value(3) = skewness_value * var_value.^(3/2) + mean_value.^3 + 3 * mean_value * var_value;
end