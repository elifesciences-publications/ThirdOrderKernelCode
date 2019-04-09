% do some thing... first, plot the covariance matrix.


% write one function, and plot it.

function K2_CovarianceMatrix_Visualization_SigTest_Draft(cov_mat_aligned, cov_mat_noise_aligned, varargin)
barUse = 7:14; % 8:13;
alpha = 0.005;
saveFigFlag = false;
MainName = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

nbars = length(barUse);
x_plot = barUse(nbars/2 - 1 : nbars/2  + 2);

n_noise = length(cov_mat_noise_aligned); % cov_mat_noise will be a cell array.
cov_mat_glider_aligned = K2_CovarianceMatrix_Visualization_Compute_GliderRespPred(cov_mat_aligned, varargin{:});
cov_mat_glider_aligned_noise = zeros([size(cov_mat_glider_aligned),n_noise]);

% this one takes some time.
for nn = 1:1:n_noise
    cov_mat_glider_aligned_noise(:,:,:,nn) = K2_CovarianceMatrix_Visualization_Compute_GliderRespPred(cov_mat_noise_aligned{nn}, varargin{:});
end
% compute the standard deviation and 
cov_mat_glider_noise_mean = squeeze(mean(cov_mat_glider_aligned_noise,4));
cov_mat_glider_noise_std = squeeze(std(cov_mat_glider_aligned_noise,0,4));

%% this is the general format...
%% the visulization can be all kinds, the important thing is the 
% test significant value.
cov_mat_glider_z = ((cov_mat_glider_aligned - cov_mat_glider_noise_mean)./cov_mat_glider_noise_std);
cov_mat_glider_p =  2 * normcdf(-abs(cov_mat_glider_z),0,1);

% tonight, a lot of drawing..
max_value = max(abs(cov_mat_glider_aligned(:)));
subplot_n_x = 2;
subplot_n_y = 4;
subplot_number = [1,2,3,4,5,6,7,8];
MakeFigure;
subplot(subplot_n_x,subplot_n_y,subplot_number(1));
K2_CovarianceMatrix_Visualization_One_Plot(cov_mat_glider_aligned, 'dt_x_dx','dx_plot', 0, 'x_bank', barUse,'plot_significant_point_flag', true, 'gliderRespPred_sig',cov_mat_glider_p < alpha,'set_color_scale_flag', true, 'max_value', max_value, varargin{:});

subplot(subplot_n_x,subplot_n_y,subplot_number(2));
K2_CovarianceMatrix_Visualization_One_Plot(cov_mat_glider_aligned, 'dt_x_dx','dx_plot', 1, 'x_bank', barUse,'plot_significant_point_flag', true, 'gliderRespPred_sig',cov_mat_glider_p < alpha,'set_color_scale_flag', true, 'max_value', max_value, varargin{:});
subplot(subplot_n_x,subplot_n_y,subplot_number(3));
K2_CovarianceMatrix_Visualization_One_Plot(cov_mat_glider_aligned, 'dt_x_dx','dx_plot', 2,'x_bank', barUse, 'plot_significant_point_flag', true, 'gliderRespPred_sig',cov_mat_glider_p < alpha,'set_color_scale_flag', true, 'max_value', max_value, varargin{:});
subplot(subplot_n_x,subplot_n_y,subplot_number(4));
K2_CovarianceMatrix_Visualization_One_Plot(cov_mat_glider_aligned, 'dt_x_dx','dx_plot', 3,'x_bank', barUse, 'plot_significant_point_flag', true, 'gliderRespPred_sig',cov_mat_glider_p < alpha,'set_color_scale_flag', true, 'max_value', max_value, varargin{:});

% subplot(subplot_n_x,subplot_n_y,subplot_number(5));
% K2_CovarianceMatrix_Visualization_One_Plot(cov_mat_glider_aligned, 'dt_dx_x', 'x_plot', x_plot(1),'plot_significant_point_flag', true, 'gliderRespPred_sig',cov_mat_glider_p < alpha,'set_color_scale_flag', true, 'max_value', max_value, varargin{:});
% subplot(subplot_n_x,subplot_n_y,subplot_number(6));
% K2_CovarianceMatrix_Visualization_One_Plot(cov_mat_glider_aligned, 'dt_dx_x', 'x_plot', x_plot(2),'plot_significant_point_flag', true, 'gliderRespPred_sig',cov_mat_glider_p < alpha,'set_color_scale_flag', true, 'max_value', max_value, varargin{:});
% subplot(subplot_n_x,subplot_n_y,subplot_number(7));
% K2_CovarianceMatrix_Visualization_One_Plot(cov_mat_glider_aligned, 'dt_dx_x', 'x_plot',x_plot(3),'plot_significant_point_flag', true, 'gliderRespPred_sig',cov_mat_glider_p < alpha,'set_color_scale_flag', true, 'max_value', max_value, varargin{:});
% subplot(subplot_n_x,subplot_n_y,subplot_number(8));
% K2_CovarianceMatrix_Visualization_One_Plot(cov_mat_glider_aligned, 'dt_dx_x', 'x_plot',x_plot(4),'plot_significant_point_flag', true, 'gliderRespPred_sig',cov_mat_glider_p < alpha,'set_color_scale_flag', true, 'max_value', max_value, varargin{:});

if saveFigFlag 
   MySaveFig_Juyue(gcf,MainName,'K2_Visulization_1','nFigSave',2,'fileType',{'png','fig'});
end
% MakeFigure; 
% subplot_n_x = 3;
% subplot_n_y = 3;
% subplot_number = [1,2,3,4,5,6,7,8,9];
% for ii = 1:1:9
% subplot(subplot_n_x,subplot_n_y,subplot_number(ii));
% K2_CovarianceMatrix_Visualization_One_Plot(cov_mat_glider_aligned, 'x_x_dt',' dt_plot', ii - 1, 'x_bank', barUse,'plot_significant_point_flag', true, 'gliderRespPred_sig',cov_mat_glider_p < alpha,'set_color_scale_flag', true, 'max_value', max_value);
% end
% if saveFigFlag 
%    MySaveFig_Juyue(gcf,MainName,'K2_Visulization_2','nFigSave',2,'fileType',{'png','fig'});
% end

%% add one more figure...
end