function K2_CovraianceMatrix_Visualization_AverageOverBars_colorPlot(cov_mat_mean,cov_mat_noise_mean, varargin)
barUse = {[7:14],[7:14],[8:15],[6:13]};
dx_plot_bank = [0,1,2,3];
n_average_over_bars_bank = [3,2];
nType_str = {'T4_Pro', 'T4_Reg', 'T5_Pro', 'T5_Reg'};
alpha = 0.05;
dt_bank = [-10:1:10];
dt = [-12:1:12];
% correlation between them.
n_noise = length(cov_mat_noise_mean);
saveFigFlag = true;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

for tt = 1:1:4
    x_bank_this_type = barUse{tt};
    cov_mat_mean_noise_this_type = cellfun(@(A)A{tt}, cov_mat_noise_mean,'UniformOutput', false);
    cov_mat_mean_this_type = cov_mat_mean{1}{tt};
    
    % get all diagnal points to be zero
    n_length_cov = size(cov_mat_mean_this_type,1);
    cov_mat_mean_this_type(eye(n_length_cov ) == 1) = 0;
    for nn = 1:1:n_noise
        cov_mat_mean_noise_this_type{nn}(eye(n_length_cov ) == 1) = 0;
    end
    
    [cov_mat_glider_aligned,  cov_mat_glider_aligned_noise] ...
        = K2_Visualization_Compute_Cov_Mat_Glider_Mean_MeanNoise(cov_mat_mean_this_type, cov_mat_mean_noise_this_type, varargin{:});
    
    %% color plot.
    MakeFigure;
    for ii = 1:1:length(dx_plot_bank)
        for jj = 1:1:length(n_average_over_bars_bank)
            
            [dt_x_dx_plot_average_over_bar,~, ~, p_val] = ...
                K2_Visualization_AverageOverBars_Computation(cov_mat_glider_aligned, cov_mat_glider_aligned_noise, ...
                'x_bank', x_bank_this_type, 'dx_plot',dx_plot_bank(ii),'n_average_over_bars',n_average_over_bars_bank(jj),'dt_bank',dt_bank ,'dt',dt);
            
            subplot(length(n_average_over_bars_bank),length(dx_plot_bank), (jj - 1) * length(dx_plot_bank) + ii)
            K2_Visualization_AverageOverBars_plot_dt_x_dx(dt_x_dx_plot_average_over_bar, ...
                'x_bank', x_bank_this_type, 'n_average_over_bars', n_average_over_bars_bank(jj), 'dx_plot',dx_plot_bank(ii),'dt_bank',dt_bank,'dt',dt)
            hold on
            K2_CovarianceMatrix_Visualization_Utils_Image_SigPoint(p_val < alpha);
        end
    end
    if saveFigFlag
        MySaveFig_Juyue(gcf,'K2_Vis_AverageOverBars_',nType_str{tt},'nFigSave',2,'fileType',{'png','fig'});
    end
    
end