function Analysis_Utils_PlotVel_Gaussian_OneFWHM(distribution, spatial_range, main_name, FWHM_bank, data_matrix, vel_range_bank, FWHM_plot, velocity_plot)
image_process_info.contrast = 'static';
image_process_info.he = 0;
alpha = 0.05;
% choose a distribution and do the plotting. cool... you are making a lot
% of progress...
velocity.distribution = distribution;
%% first: scatter plot between real velocity and estimated velocity. binned.
n_vel = length(vel_range_bank);
n_FWHM = length(FWHM_bank);
r2 = zeros(n_vel, n_FWHM);
r3 = zeros(n_vel, n_FWHM);
r23= zeros(n_vel, n_FWHM);
r_best = zeros(n_vel, n_FWHM);
n_sample = zeros(n_vel, n_FWHM);
rv = zeros(n_vel, n_FWHM);
w = zeros(2, n_vel, n_FWHM);

%% get data from this velocity and this FWHM
jj = find(velocity_plot == vel_range_bank);
kk = find(FWHM_plot == FWHM_bank);
v2 = [data_matrix(jj,kk).v2];
v3 = [data_matrix(jj,kk).v3];
v_real = [data_matrix(jj,kk).v_real];
n_sample(jj,kk) = length(v2);

r2(jj,kk) = corr(v2, v_real);
r3(jj,kk) =  corr(v3, v_real);
r23(jj,kk) =  corr(v2 + v3, v_real);

w_this = [v2, v3]\ v_real;
v_best = [v2, v3] * w_this;
w(:,jj,kk) = w_this;
r_best(jj,kk) = corr(v_best, v_real);
rv(jj,kk) = corr(v2, v3);


%%  find one velocity distribution.
MakeFigure;
subplot(3, 2, 1);
scatter(v_real, v2,'r.');
title(sprintf('FWHM%d', FWHM_plot));
ConfAxis
ylabel('K2');

subplot(3, 2, 2);
Utils_ScatterPlot_VReal_VEst(v_real, v2, velocity.distribution, FWHM_bank(kk));
title(sprintf('FWHM%d', FWHM_plot));
ConfAxis
%         
subplot(3, 2, 3);
scatter(v_real, v3,'r.');
ConfAxis
ylabel('K3');

subplot(3, 2, 4);
Utils_ScatterPlot_VReal_VEst(v_real, v3, velocity.distribution, FWHM_bank(kk));
ConfAxis
%         
subplot(3, 2, 5);
scatter(v_real, v2 + v3,'r.')
xlabel('v_{real}');
ConfAxis
ylabel('K3 + K2');

subplot(3, 2, 6);
Utils_ScatterPlot_VReal_VEst(v_real, v3 + v2, velocity.distribution, FWHM_bank(kk));
xlabel('v_{real}');
ConfAxis
ylabel('estimated velocity')
% after scatter plot, get the mean value
% write some text tell about the velocity distribution.
special_name = sprintf('FWHM%d_vel%d',FWHM_plot,velocity_plot);
text_str = [main_name, ' ' special_name];
uicontrol('Style', 'text',...
    'String', text_str,... %replace something with the text you want
    'Units','normalized',...
    'Position', [0 0.9 0.15 0.07],'FontSize', 15);
MySaveFig_Juyue(gcf, main_name, special_name, 'nFigSave',2,'fileType',{'png','fig'});
% close all
end


function Utils_ScatterPlot_VReal_VEst(v_real, v, distribution, FWHM)
switch distribution
    case 'gaussian'
        ScatterXYBinned(v_real, v, 25, 50, 'color','r','lineWidth',5,'markerType','o','setAxisLimFlag',1,'plotDashLineFlag',1, 'edge_distribution','histeq');
    case 'uniform'
        ScatterXYBinned(v_real, v, 25, 50, 'color','r','lineWidth',5,'markerType','o','setAxisLimFlag',1,'plotDashLineFlag',1, 'edge_distribution','linear');
    case 'binary'
        scatter(v_real, v, 'r.');
end
% xlabel('real velocity'); ylabel('estimated velocity');
% title(sprintf('FWHM%d', FWHM));

end

function  Utils_Correlation_ColorPlot(r_value, clim, vel_range_bank, FWHM_bank, title_str,zlevs)
n_FWHM = length(FWHM_bank);
n_vel = length(vel_range_bank);
imagesc(r_value);colorbar; % plot countour plot. smooth the image.
set(gca,'Clim', clim);
set(gca, 'YTick',1:n_vel,'YTickLabel', strsplit(num2str(vel_range_bank)))
set(gca, 'XTick', 1:n_FWHM, 'XTickLabel', strsplit(num2str(FWHM_bank)));
ylabel('velocity range');
xlabel('FWHM');
title(title_str);     ConfAxis

%% countour plot
hold on
[x_grid_countour,y_grid_countour] = ndgrid(1:n_FWHM, 1:n_vel);
z_grid_countour = r_value';
contour(x_grid_countour,y_grid_countour, z_grid_countour ,zlevs,'LineColor','k','LineWidth', 1, 'ShowText','on');

end