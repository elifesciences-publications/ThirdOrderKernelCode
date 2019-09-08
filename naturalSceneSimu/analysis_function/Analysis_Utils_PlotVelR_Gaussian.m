function Analysis_Utils_PlotVelR_Gaussian(distribution, main_name, contrast_form, mean_lum_scale, mean_lum_scale_plot, data_matrix, vel_range_bank)
% reorganize this function!!
color_bank = [[114, 206, 245]; [49, 168, 73]; [237, 26, 85]]/255;
color_bank = cat(1, color_bank, [0.5,0.5,0.5]);

alpha = 0.05;
image_process_info.contrast = contrast_form; % no capability.
switch contrast_form
    case 'static'
        variable_name = 'FWHM';
    case 'dynamic'
        variable_name = 'time contstant';
    case 'dynamic_both_future_and_past'
        variable_name = 'time contstant';
end
image_process_info.he = 0;
velocity.distribution = distribution;
%% first: scatter plot between real velocity and estimated velocity. binned.
n_vel = length(vel_range_bank);
n_scale = length(mean_lum_scale);
r2 = zeros(n_vel, n_scale);
r3 = zeros(n_vel, n_scale);
r23= zeros(n_vel, n_scale);
r_best = zeros(n_vel, n_scale);
n_sample = zeros(n_vel, n_scale);
rv = zeros(n_vel, n_scale);
w = zeros(2, n_vel, n_scale);
for jj = 1:1:n_vel
    for kk = 1:1:n_scale
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
    end
end
%%  find one velocity distribution. 128.
jj = find(vel_range_bank ==114);
% mean_lum_scale_plot = [10,25,75];
MakeFigure;
for ii = 1:1:length(mean_lum_scale_plot)
    kk = find(mean_lum_scale_plot(ii) == mean_lum_scale);
    v2 = [data_matrix(jj,kk).v2];
    v3 = [data_matrix(jj,kk).v3];
    v_real = [data_matrix(jj,kk).v_real];
    
    subplot(3, length(mean_lum_scale_plot), ii);
    scatter(v_real, v2,'r.');
    title(sprintf('%s%d ms', variable_name, mean_lum_scale_plot(ii) * 1000));
    ConfAxis
    %         Utils_ScatterPlot_VReal_VEst(v_real, v2, velocity.distribution, mean_lum_scale(kk));
    if ii == 1
        ylabel('K2');
    end
    subplot(3, length(mean_lum_scale_plot), ii + length(mean_lum_scale_plot));
    scatter(v_real, v3,'r.');
    ConfAxis
    %         Utils_ScatterPlot_VReal_VEst(v_real, v3, velocity.distribution, mean_lum_scale(kk));
    if ii == 1
        ylabel('K3');
    end
    subplot(3, length(mean_lum_scale_plot), ii + 2 * length(mean_lum_scale_plot));
    scatter(v_real, v2 + v3,'r.')
    xlabel('v_{real}');
    ConfAxis
    %         Utils_ScatterPlot_VReal_VEst(v_real, v3 + v2, velocity.distribution, mean_lum_scale(kk));
    if ii == 1
        ylabel('K3 + K2');
    end
end
% write some text tell about the velocity distribution.
special_name = sprintf('%d',vel_range_bank(jj));
text_str = [main_name, ' ' special_name];
uicontrol('Style', 'text',...
    'String', text_str,... %replace something with the text you want
    'Units','normalized',...
    'Position', [0 0.9 0.15 0.07],'FontSize', 15);
MySaveFig_Juyue(gcf, main_name, special_name, 'nFigSave',2,'fileType',{'png','fig'});

%% calculate the residual..
%
% for jj = 1:1:n_vel
%     for kk = 1:1:n_scale
%         v2 = [data_matrix(jj,kk).v2];
%         v3 = [data_matrix(jj,kk).v3];
%         v_real = [data_matrix(jj,kk).v_real];
%
%         fitvars_v2 = polyfit(v_real,v2, 1);
%         fitvars_v3 = polyfit(v_real,v3, 1);
%         fitvars_v23 = polyfit(v_real, v2+v3, 1);
%         v2_res =  Analysis_Utils_Calculate_Residual(v2,v_real);
%         v3_res = Analysis_Utils_Calculate_Residual(v3,v_real);
%         v23_res = Analysis_Utils_Calculate_Residual(v2 + v3, v_real);
%         scatter(v2_res, v3_res,'r.');
%
%         v_real_res_2 = Analysis_Utils_Calculate_Residual(v_real, v2);
%     end
% end




%% second, correlation varies with FWHM and velocity distribution.
% first, calculate the variance.
r2_ci = zeros(2, n_vel, n_scale);
r3_ci = zeros(2, n_vel, n_scale);
r23_ci = zeros(2, n_vel, n_scale);
r_best_ci = zeros(2, n_vel, n_scale);
for jj = 1:1:n_vel
    for kk = 1:1:n_scale
        r2_ci(:,jj,kk) = Analysis_Utils_CalculateRInterval(r2(jj,kk), n_sample(jj,kk), alpha);
        r3_ci(:,jj,kk) = Analysis_Utils_CalculateRInterval(r3(jj,kk), n_sample(jj,kk), alpha);
        r23_ci(:,jj,kk) = Analysis_Utils_CalculateRInterval(r23(jj,kk), n_sample(jj,kk), alpha);
        r_best_ci(:,jj,kk) = Analysis_Utils_CalculateRInterval(r_best(jj,kk), n_sample(jj,kk), alpha);
        
    end
end

%%
% make the plot.
MakeFigure;
maxVal = max(r_best(:)) * 1.5;
minVal = min([min(r3(:)) * 1.5,0]);
for jj = 1:1:length(vel_range_bank)
    subplot(2,length(vel_range_bank),  jj);
    
    % PlotXY_Juyue(x,y,'errofBarFlag',true,'sem',sem)
    %     ci_r = Analysis_Utils_CalculateRInterval(r, n, alpha)
    %      PlotXY_Juyue(x, y, errorBarFlag, 'tru', 'sem', sem, 'asym_sem_flag', true)
    mean_lum_scale_plot = repmat(mean_lum_scale',[1,4]);
    r_plot = [r2(jj,:)', r3(jj,:)', r23(jj,:)', r_best(jj,:)'];
    A = cat(3,squeeze(r2_ci(:,jj,:)), squeeze(r3_ci(:,jj,:)), squeeze(r23_ci(:,jj,:)), squeeze(r_best_ci(:,jj,:)));
    A = permute(A,[2,3,1]);
    error_plot =  bsxfun(@minus,r_plot,A);
    %     PlotXvsY(mean_lum_scale_plot,r_plot,'error', error_plot);
    p1 = PlotXY_Juyue(mean_lum_scale', r2(jj,:)', 'errorBarFlag',true,'sem',squeeze(r2_ci(:,jj,:)), 'asym_sem_flag', true,'colorError',color_bank(1,:),'colorMean',color_bank(1,:));
    hold on;
    p2 = PlotXY_Juyue(mean_lum_scale', r3(jj,:)', 'errorBarFlag',true,'sem',squeeze(r3_ci(:,jj,:)), 'asym_sem_flag', true, 'colorError',color_bank(2,:),'colorMean',color_bank(2,:));
    hold on;
    
    p3 = PlotXY_Juyue(mean_lum_scale', r23(jj,:)', 'errorBarFlag',true,'sem',squeeze(r23_ci(:,jj,:)), 'asym_sem_flag', true, 'colorError',color_bank(3,:),'colorMean',color_bank(3,:));
    hold on;
    
    p4 = PlotXY_Juyue(mean_lum_scale', r_best(jj,:)', 'errorBarFlag',true,'sem',squeeze(r_best_ci(:,jj,:)), 'asym_sem_flag', true, 'colorError',color_bank(4,:),'colorMean',color_bank(4,:));
    %
    %
    set(gca, 'YLim', [minVal, maxVal]);
    if jj == length(vel_range_bank)
        legend([p1, p2, p3, p4],'2^{nd}', '3^{rd}', '2^{nd} + 3^{rd}', 'weighted');
    end
    if jj == 1
        ylabel('corr: predicted vel vs real vel ')
    end
    title(sprintf('%s%d', velocity.distribution, vel_range_bank(jj)));
    xlabel('FWHM of local mean luminance filter');
    ConfAxis
end

%%
ratio_w = w(2, :, :)./w(1, :, :);
maxVal_w = max(ratio_w(:));
minVal_w = min(ratio_w(:));

maxVal_r = max(max(rv(:)), 1);
minVal_r = min(min(rv(:)), -1);
n_range = length(vel_range_bank);
for jj = 1:1:length(vel_range_bank)
    % weighting of the K3 K2 which results best correlation.
    subplot(4,n_range, 2 * n_range + jj);
    w_v2 = squeeze(w(1, jj, :));
    w_v3 = squeeze(w(2, jj, :));
    plot(mean_lum_scale, w_v3./w_v2,'k');
    hold on
    plot(mean_lum_scale, ones(length(mean_lum_scale), 1), 'k--');
    plot(mean_lum_scale, zeros(length(mean_lum_scale), 1), 'k--');
    set(gca, 'YLim', [minVal_w, maxVal_w]);
    if jj == 1
        ylabel('weight v3/v2');
    end
    xlabel('FWHM of local mean luminance filter');
     ConfAxis
    % correlation between two velocities.
    subplot(4,n_range, 3 * n_range + jj);
    plot(mean_lum_scale, rv(jj,:),'k');
    hold on
    plot(mean_lum_scale, zeros(length(mean_lum_scale), 1), 'k--');
    
    set(gca, 'YLim', [minVal_r, maxVal_r]);
%     xlabel('FWHM of local mean luminance filter');
    if jj == 1
        ylabel('corr: predicted v2 vs predicted v3');
    end
     ConfAxis
end
special_name = sprintf('correlation');

text_str = [main_name, ' ' special_name];
uicontrol('Style', 'text',...
    'String', text_str,... %replace something with the text you want
    'Units','normalized',...
    'Position', [0 0.9 0.15 0.1],'FontSize', 15);

MySaveFig_Juyue(gcf,main_name, special_name, 'nFigSave',2,'fileType',{'png','fig'});
MySaveFig_Juyue(gcf,main_name, special_name, 'nFigSave',2,'fileType',{'eps','svg'});

%% improvement of pearson correlation of k23 on k2.
%%
MakeFigure;
colormap_gen;
colormap(mymap);
subplot(2,3,1)
maxValue = max(max(abs(r2(:))),max(abs(r23(:)))); clim = [-maxValue, maxValue];
zlevs = linspace(-maxValue, maxValue, 10);
Utils_Correlation_ColorPlot(r2, clim, vel_range_bank, mean_lum_scale, ['K2'],zlevs);
subplot(2,3,2)
Utils_Correlation_ColorPlot(r3, clim, vel_range_bank, mean_lum_scale, ['K3'],zlevs);
subplot(2,3,3)
Utils_Correlation_ColorPlot(r23, clim, vel_range_bank, mean_lum_scale, ['K23'],zlevs)
subplot(2,3,4)
improvement = r23 - r2; maxValue = max(abs(improvement(:))); clim = [-maxValue, maxValue];
zlevs = linspace(-maxValue, maxValue, 10);
Utils_Correlation_ColorPlot(improvement, clim, vel_range_bank, mean_lum_scale, ['improvement'],zlevs)
subplot(2,3,5)
improvement_ratio = improvement./r2; maxValue = max(abs(improvement_ratio(:))); clim = [-maxValue, maxValue];
zlevs = linspace(-maxValue, maxValue, 10);
Utils_Correlation_ColorPlot(improvement_ratio, clim, vel_range_bank, mean_lum_scale, ['improvement ratio'],zlevs)

special_name = sprintf('correlation_colorplot');
text_str = [main_name, ' ' special_name];
uicontrol('Style', 'text',...
    'String', text_str,... %replace something with the text you want
    'Units','normalized',...
    'Position', [0 0.9 0.15 0.1],'FontSize', 15);

MySaveFig_Juyue(gcf,main_name, special_name, 'nFigSave',2,'fileType',{'png','fig'});

close all
end


function Utils_ScatterPlot_VReal_VEst(v_real, v, distribution, scale_value)
switch distribution
    case 'gaussian'
        ScatterXYBinned(v_real, v, 25, 50, 'color','r','lineWidth',5,'markerType','o','setAxisLimFlag',1,'plotDashLineFlag',1, 'edge_distribution','histeq');
    case 'uniform'
        ScatterXYBinned(v_real, v, 25, 50, 'color','r','lineWidth',5,'markerType','o','setAxisLimFlag',1,'plotDashLineFlag',1, 'edge_distribution','linear');
    case 'binary'
        scatter(v_real, v, 'r.');
end
xlabel('real velocity'); ylabel('estimated velocity');
title(sprintf('%s%d', variable_name, scale_value));

end

function  Utils_Correlation_ColorPlot(r_value, clim, vel_range_bank, mean_lum_scale, title_str,zlevs)
n_scale = length(mean_lum_scale);
n_vel = length(vel_range_bank);
imagesc(r_value);colorbar; % plot countour plot. smooth the image.
set(gca,'Clim', clim);
set(gca, 'YTick',1:n_vel,'YTickLabel', strsplit(num2str(vel_range_bank)))
set(gca, 'XTick', 1:n_scale, 'XTickLabel', strsplit(num2str(mean_lum_scale)));
ylabel('velocity range');
xlabel('FWHM');
title(title_str);     ConfAxis

%% countour plot
hold on
[x_grid_countour,y_grid_countour] = ndgrid(1:n_scale, 1:n_vel);
z_grid_countour = r_value';
contour(x_grid_countour,y_grid_countour, z_grid_countour ,zlevs,'LineColor','k','LineWidth', 1, 'ShowText','on');

end