function D = Analysis_Utils_PlotVelR_Binary_OneFWHM_VelocityPlot(distribution, spatial_range, main_name, FWHM_bank, data_matrix, vel_range_bank, FWHM_bank_plot, color)
plot_flag = false;

velocity.distribution = distribution;
% v_real_plot = [-fliplr(vel_range_bank), vel_range_bank];

n_vel = size(data_matrix, 1);
kk = find(FWHM_bank == FWHM_bank_plot);
%% second, plot the mean/std
v2_mean = zeros(2, n_vel);
v3_mean = zeros(2,n_vel);
v2_median = zeros(2, n_vel);
v2_quarter = zeros(2, n_vel, 2); % 25 percetile and 75 percentile
v2_std = zeros(2,n_vel);
v3_std = zeros(2,n_vel);
v23_mean = zeros(2,n_vel);
v23_std = zeros(2,n_vel);
% v_residual_mean = zeros(2,n_vel);
% v_residual_std = zeros(2,n_vel);
v_real_range = zeros(2, n_vel);


for jj = 1:1:n_vel
    v2 = data_matrix(jj, kk).v2;
    v3 = data_matrix(jj,kk).v3;
    v_real = data_matrix(jj,kk).v_real;
    v23 = v2 + v3;
    %         v_residual = v_real - v2;
    sign_bank = [-1, 1];
    for pp = 1:1:2
        if pp == 1
            ind = find(v_real < 0);
        else
            ind = find(v_real > 0);
        end
        v_real_range(pp, jj) = v_real(ind(1));
        v2_mean(pp, jj) = mean(v2(ind));
        v2_median(pp,jj) = prctile(v2(ind), 50);
        v2_quarter(pp,jj,1) = prctile(v2(ind), 25);
        v2_quarter(pp,jj,2) = prctile(v2(ind), 75);
        v2_std(pp,jj) = std(v2(ind));
        v3_mean(pp,jj) = mean(v3(ind));
        v3_std(pp,jj) = std(v3(ind));
        v23_mean(pp,jj) = mean(v23(ind));
        v23_std(pp,jj) = std(v23(ind));
        %             v_residual_mean(pp,jj,kk) = mean(v_residual(ind));
        %             v_residual_std(pp,jj,kk) = std(v_residual(ind));
    end
end

D.v2_mean = v2_mean;
D.v2_median = v2_median;
D.v2_quarter = v2_quarter;
D.v3_mean = v3_mean;
D.v2_std = v2_std;
D.v3_std = v3_std;
D.v23_mean = v23_mean;
D.v23_std = v23_std ;
D.v2 = {data_matrix(:,kk).v2};
D.v_real = {data_matrix(:,kk).v_real};
% v_residual_mean = zeros(2,n_vel);
% v_residual_std = zeros(2,n_vel);
D.v_real_range = v_real_range;

if plot_flag
    MakeFigure;
    subplot(2,3,1);
    MyScatter_DoubleErrBars(v_real_range(:),v2_mean(:), [], v2_std(:), 'color',color);
    title(sprintf('FWHM %d', FWHM_bank(kk)));
    % set(gca, 'XTick',[]);
    box off
    
    ylabel('2nd');
    xlabel('image velocity');
    
    subplot(2,3,2);
    MyScatter_DoubleErrBars(v_real_range(:), v3_mean(:), [], v2_std(:), 'color',color)
    % set(gca, 'XTick',[]);
    box off
    ylabel('3rd');
    xlabel('image velocity')
    
    subplot(2,3,3);
    MyScatter_DoubleErrBars(v_real_range(:), v23_mean(:), [], v23_std(:), 'color',color);
    % set(gca, 'XTick',[]);
    box off
    ylabel('3rd + 2nd');
    xlabel('image velocity')
    
    special_name = sprintf('vel_mean_std_%s_ave%d', velocity.distribution,spatial_range);
    text_str = [main_name, ' ' special_name];
    uicontrol('Style', 'text',...
        'String', text_str,... %replace something with the text you want
        'Units','normalized',...
        'Position', [0 0.9 0.15 0.1],'FontSize', 15);
    
    % MySaveFig_Juyue(gcf,main_name, special_name, 'nFigSave',2,'fileType',{'png','fig'});
end
end

