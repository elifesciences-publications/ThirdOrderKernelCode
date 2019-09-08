function [r_plot, w_this, residual_r, slope] = performance_evaluation_utils_data_calculate_correlation(data, is_v3_flag)

% only useful
r2 = corr(data.v2, data.v_real);
if is_v3_flag
    w_this = [data.v2, data.v3]\ data.v_real;
    v_best = [data.v2, data.v3] * w_this;
    r_best = corr(v_best, data.v_real);
    r3 = corr(data.v3, data.v_real);
    r23 = corr(data.v_real, data.v3 + data.v2);
    r_plot = [r2, r3, r23, r_best];
    
    %% also get the coefficient.
    coef = data.v_real\data.v2; 
    residual_this = data.v2 - data.v_real * coef ;

    residual_r = corr(residual_this, data.v3);
    slope = [ones(length(data.v3), 1),residual_this]\data.v3;
else
    r_plot = r2;
    w_this = 1;
    residual_r = 0;
    slope = 0;
end
end