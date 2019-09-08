function optimal_glider = OptimalGlider_Calculation_Regresion_On_Selected_Predictor(X, v_real, predicting_variable)
n_predictors_total = size(X, 2);
optimal_glider = struct('beta', zeros(n_predictors_total, 1),'beta_ci',zeros(n_predictors_total, 2), 'r_square',[],'lambda',[]);
% coeff_v_real_v_hat = zeros(length(FWHM_bank), 1);
%     predicting_variable = B_record{ff}(:,fitinfo_record{ff}.Index1SE) ~= 0;

[b,bint,r,rint,stats] = regress(v_real, X(:,predicting_variable));
optimal_glider.beta(predicting_variable) = b;
optimal_glider.beta_ci(predicting_variable,:) = bint;
optimal_glider.r_square = stats(1);

end

