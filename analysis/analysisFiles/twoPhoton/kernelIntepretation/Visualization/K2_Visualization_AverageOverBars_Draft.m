% correlation between them.
function [dt_x_dx_plot_average_over_bar, noise_std_val, p_val ]= K2_Visualization_AverageOverBars_Computation(cov_mat_glider_aligned, cov_mat_glider_aligned_noise, varargin)

x_bank = [7:14];
dx_plot = 0;
n_average_over_bars = 3; 
alpha = 0.05;
dt_bank = [-12:12];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
dt_x_dx_plot_average_over_bar = K2_Visualization_AverageOverBars_Compute_dt_x_dx(cov_mat_glider_aligned, ...
    'x_bank', x_bank, 'n_average_over_bars', n_average_over_bars , 'dx_plot',dx_plot, 'dt_bank', dt_bank);

n_noise = size(cov_mat_glider_aligned_noise,4);
dt_x_dx_plot_average_over_bar_noise = zeros([size(dt_x_dx_plot_average_over_bar), n_noise]);
%% corresponding noise

for nn = 1:1:n_noise
    dt_x_dx_plot_average_over_bar_noise(:,:,nn) = ...
        K2_Visualization_AverageOverBars_Compute_dt_x_dx(squeeze(cov_mat_glider_aligned_noise(:,:,:,nn)), ...
        'x_bank', x_bank, 'n_average_over_bars', n_average_over_bars , 'dx_plot',dx_plot, 'dt_bank', dt_bank );
end

% compute the significant point.
noise_mean_val = mean(dt_x_dx_plot_average_over_bar_noise,3);
noise_std_val = std(dt_x_dx_plot_average_over_bar_noise,1,3);

z_val =  (dt_x_dx_plot_average_over_bar - noise_mean_val)./noise_std_val;
p_val = 2 * normcdf(-abs(z_val),0,1);
p_val(isnan(p_val)) = 1;

end

