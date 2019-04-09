function [predictor_rank,B,fitinfo] = OptimalGlider_Calculate_Lasso_And_Predictor_Ranking(X, Y, varargin)
% direction selective signal.
% X = (stim_corr_data(:,:,1) - stim_corr_data(:,:,2))/2; Y = v_real;
[B, fitinfo] = lasso(X,Y, 'CV', 10, 'PredictorNames', corr_name);
lassoPlot(B, fitinfo,'PlotType','CV');
predictor_rank = OptimalGlider_Calculate_Predictor_Ranking(B);


%%
%% do not use indse . use
% IndSE = zeros(length(FWHM_bank), 3);
% for ii = 1:1:3
%     for ff = 1:1:length(FWHM_bank) - 1;
%         indmse = fitinfo_record{ff}.IndexMinMSE;
%         se2 = fitinfo_record{ff}.MSE(indmse) + fitinfo_record{ff}.SE(indmse) * ii;
%         se2_diff = fitinfo_record{ff}.MSE - se2;
%         [value,IndSE(ff,ii)] = min(abs(se2_diff));
%     end
% end
%% ranking. 1, 3, 5, how many regresser do you use.
