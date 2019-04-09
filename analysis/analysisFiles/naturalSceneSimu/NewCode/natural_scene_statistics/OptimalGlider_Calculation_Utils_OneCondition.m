function [optimal_glider,predictor_rank] = OptimalGlider_Calculation_Utils_OneCondition(image_process_info, velocity, spatial_range, which_kernel_type,varargin)
synthetic_flag = false;
synthetic_type = [];
main_name = [];
save_fig_flag = false;
corr_name = {'Two Point DT 1','Two Point DT 2', 'Two Point DT 3','Two Point DT 4',...
    'Diverging DT 1','Diverging DT 2','Diverging DT 3','Diverging DT 4',...
    'Converging DT 1','Converging DT 2', 'Convering DT 3','Converging DT 4',...
    'Elbow','Late Knight','Early Knight','Elbow Late Break','Elbow Early Break'};

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% also the FWHM and
% tau or FWHM
switch image_process_info.contrast
    case 'static'
        contrast_variable_str = 'FWHM';
        contrast_variable_value = num2str(image_process_info.FWHM);
    case 'dynamic'
        contrast_variable_str = 'TAU';
        contrast_variable_value = num2str(image_process_info.tf_tau * 1000);
end
main_name = sprintf('%s_%s%s_syn%d_%s_%s%d_%s%d',image_process_info.contrast, contrast_variable_str, contrast_variable_value, ...
    synthetic_flag, synthetic_type, velocity.distribution, velocity.range, which_kernel_type, spatial_range);


[stim_corr_data,v_real] = Analysis_Utils_GetData_Stim_Corr(image_process_info, velocity, spatial_range, which_kernel_type,'synthetic_flag',synthetic_flag,'synthetic_type',synthetic_type,...
                                                           'corr_name',corr_name);
v_real = v_real';
% CorrelationInMovingNS_Utils_Plot_Main_Temp(stim_corr_data, v_real, 'main_name',main_name, 'save_fig_flag', false);
%     CorrelationInMovingNS_Utils_Plot_Main_Temp(stim_corr_data, v_real, 'main_name',main_name, 'save_fig_flag', save_fig_flag);
X = (stim_corr_data(:,:,1) - stim_corr_data(:,:,2))/2; Y = v_real;
tic
[B, fit_info] = lasso(X,Y, 'CV', 10, 'PredictorNames', corr_name);
toc
[predictor_rank, lambda_bank] = OptimalGlider_Calculate_Predictor_Ranking(B,  fit_info);

%% do use n predictors to do regression.
n_predictor_use_bank = 1:size(B,1);
optimal_glider_template = struct('beta', zeros(length(corr_name), 1),'beta_ci',zeros(length(corr_name), 2), 'r_square',[],'lambda',[]);
optimal_glider = repmat(optimal_glider_template, length(n_predictor_use_bank), 1);

for nn = 1:1:length(n_predictor_use_bank)
    predictors_at_rank_nn = find(predictor_rank == nn);
    predicting_variable_below_rank_n = find(predictor_rank < nn);
    
    for ii  = 1:1:length(predictors_at_rank_nn)
        predicting_variable = [predicting_variable_below_rank_n; predictors_at_rank_nn(ii)];
        optimal_glider(nn + ii - 1) = OptimalGlider_Calculation_Regresion_On_Selected_Predictor(X, Y, predicting_variable);
        optimal_glider(nn + ii - 1).lambda = lambda_bank(nn);
    end
end

predictor_num_bank = [1,2,3,4,5,6,7, 8,9];
OptimalGlider_Plot_Utils_PlotOneCondition(optimal_glider, predictor_num_bank, predictor_rank,...
                                          'main_name', main_name, 'save_fig_flag', save_fig_flag, 'corr_name', corr_name);