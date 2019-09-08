function Analysis_Utils_PlotVelR(distribution, spatial_range, which_kernel_type, main_name, FWHM_bank)
image_process_info.contrast = 'static';
image_process_info.he = 0;

% choose a distribution and do the plotting. cool... you are making a lot
% of progress...
velocity.distribution = distribution;
if strcmp(distribution,'binary')
    vel_range_bank = [2, 4, 8,16,32, 64, 128, 256];
else
    vel_range_bank = [32, 64, 128, 256, 512];
end

data_struct = struct('v2', [], 'v3', [], 'v_real', []);
data_matrix = repmat(data_struct, length(vel_range_bank), length(FWHM_bank));
for jj = 1:1:length(vel_range_bank)
    for kk = 1:1:length(FWHM_bank)
        velocity.range = vel_range_bank(jj);
        image_process_info.FWHM = FWHM_bank(kk);
        data_matrix(jj, kk) = Analysis_Utils_GetData(image_process_info, velocity, spatial_range, which_kernel_type);
        
    end
end

if strcmp(distribution, 'binary')
    r2     = zeros(length(FWHM_bank),1);
    r3     = zeros(length(FWHM_bank),1);
    r23    = zeros(length(FWHM_bank),1);
    r_best = zeros(length(FWHM_bank),1);
    for kk = 1:1:length(FWHM_bank)
        v2 = [data_matrix(:,kk).v2]; v2 = v2(:);
        v3 = [data_matrix(:,kk).v3]; v3 = v3(:);
        v_real = [data_matrix(:,kk).v_real]; v_real = v_real(:);
        a = corrcoef(v2, v_real); r2(kk) = a(1,2);
        a =  corrcoef(v3, v_real);r3(kk) = a(1,2);
        a =  corrcoef(v2 + v3, v_real); r23(kk) = a(1,2);
        % also compute what is the best weighting and what is the best
        % correlation.
        w = [v2, v3]\ v_real;
        v_best = [v2, v3] * w;
        a = corrcoef(v_best, v_real); r_best(kk) = a(1, 2);
        
        subplot(3, length(FWHM_bank), kk );
        Utils_ScatterPlot_VReal_VEst(v_real, v2, velocity.distribution, FWHM_bank(kk));
        subplot(3, length(FWHM_bank), kk + length(FWHM_bank));
        Utils_ScatterPlot_VReal_VEst(v_real, v3, velocity.distribution, FWHM_bank(kk));
        subplot(3, length(FWHM_bank), kk + 2 * length(FWHM_bank));
        Utils_ScatterPlot_VReal_VEst(v_real, v3 + v2, velocity.distribution, FWHM_bank(kk));
        %         subplot(3, length(FWHM_bank), kk + 2 * length(FWHM_bank))
        %         Utils_ScatterPlot_VReal_VEst(v_real, v_best, velocity.distribution, FWHM_bank(kk));
        
    end
    MakeFigure;
    plot(FWHM_bank, r2);
    hold on;
    plot(FWHM_bank,r3);
    plot(FWHM_bank,r23);
    legend('k2', 'k3', 'k23');
    xlabel('FWHM');
    title(sprintf('%s', velocity.distribution));
    ConfAxis
    MySaveFig_Juyue(gcf, 'correlation', sprintf('vel_dis%s_ave%d', velocity.distribution, spatial_range), 'nFigSave',2,'fileType',{'png','fig'});
    
else
    r2 = zeros(size(data_matrix));
    r3 = zeros(size(data_matrix));
    r23= zeros(size(data_matrix));
    r_best = zeros(size(data_matrix));
    rv = zeros(size(data_matrix));
    w = zeros([2,size(data_matrix)]);
    for jj = 1:1:length(vel_range_bank)
        MakeFigure;
        for kk = 1:1:length(FWHM_bank)
            v2 = [data_matrix(jj,kk).v2];
            v3 = [data_matrix(jj,kk).v3];
            v_real = [data_matrix(jj,kk).v_real];
            a = corrcoef(v2, v_real); r2(jj,kk) = a(1,2);
            a =  corrcoef(v3, v_real);r3(jj,kk) = a(1,2);
            a =  corrcoef(v2 + v3, v_real); r23(jj,kk) = a(1,2);
            
            w_this = [v2, v3]\ v_real;
            v_best = [v2, v3] * w_this;
            w(:,jj,kk) = w_this;
            a = corrcoef(v_best, v_real); r_best(jj,kk) = a(1, 2);
            
            a = corrcoef(v2, v3); rv(jj,kk) = a(1,2);
            subplot(3, length(FWHM_bank), kk );
            Utils_ScatterPlot_VReal_VEst(v_real, v2, velocity.distribution, FWHM_bank(kk));
            if kk == 1
                ylabel('K2');
            end
            subplot(3, length(FWHM_bank), kk + length(FWHM_bank));
            Utils_ScatterPlot_VReal_VEst(v_real, v3, velocity.distribution, FWHM_bank(kk));
            if kk == 1
                ylabel('K3');
            end
            subplot(3, length(FWHM_bank), kk + 2 * length(FWHM_bank));
            Utils_ScatterPlot_VReal_VEst(v_real, v3 + v2, velocity.distribution, FWHM_bank(kk));
            if kk == 1
                ylabel('K3 + K2');
            end
        end
        % write some text tell about the velocity distribution.
        text_str = sprintf('vel distribution:%s%d \n average over %d points', velocity.distribution, vel_range_bank(jj),spatial_range);
        uicontrol('Style', 'text',...
            'String', text_str,... %replace something with the text you want
            'Units','normalized',...
            'Position', [0 0.9 0.15 0.07],'FontSize', 15);
        special_name = sprintf('vel_dis%s%d_ave%d', velocity.distribution, vel_range_bank(jj),spatial_range);
        MySaveFig_Juyue(gcf, main_name, special_name, 'nFigSave',2,'fileType',{'png','fig'});
    end
    
    %% plot the correlation.
    MakeFigure;
    % correlation between estimated velocity and real velocity
    maxVal = max(r_best(:));
    minVal = min(r3(:)) * 1.5;
    for jj = 1:1:length(vel_range_bank)
        subplot(2,length(vel_range_bank),  jj);
        
        plot(FWHM_bank, r2(jj,:));
        hold on;
        plot(FWHM_bank,r3(jj,:));
        plot(FWHM_bank,r23(jj,:));
        plot(FWHM_bank,r_best(jj,:))
        set(gca, 'YLim', [minVal, maxVal]);
        if jj == length(vel_range_bank)
            legend('k2', 'k3', 'k23', 'best');
        end
        if jj == 1
            ylabel('corr: predicted vel vs real vel ')
        end
        title(sprintf('%s%d', velocity.distribution, vel_range_bank(jj)));
    end
    
    
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
        plot(FWHM_bank, w_v3./w_v2);
        hold on
        plot(FWHM_bank, ones(length(FWHM_bank), 1), 'k--')
        set(gca, 'YLim', [minVal_w, maxVal_w]);
        if jj == 1
            ylabel('weight v3/v2');
        end
        
        % correlation between two velocities.
        subplot(4,n_range, 3 * n_range + jj);
        plot(FWHM_bank, rv(jj,:));
        hold on
        plot(FWHM_bank, zeros(length(FWHM_bank), 1), 'k--')
        set(gca, 'YLim', [minVal_r, maxVal_r]);
        xlabel('FWHM');
        if jj == 1
            ylabel('corr: predicted v2 vs predicted v3');
        end
    end
        special_name = sprintf('correlation_vel_dis%s_ave%d', velocity.distribution,spatial_range);

    text_str = [main_name, ' ' special_name];
    uicontrol('Style', 'text',...
        'String', text_str,... %replace something with the text you want
        'Units','normalized',...
        'Position', [0 0.9 0.15 0.1],'FontSize', 15);
    
    MySaveFig_Juyue(gcf,main_name, special_name, 'nFigSave',2,'fileType',{'png','fig'});
    
end

close all
end


function Utils_ScatterPlot_VReal_VEst(v_real, v, distribution, FWHM)
switch distribution
    case 'gaussian'
        ScatterXYBinned(v_real, v, 15, 50, 'color','r','lineWidth',5,'markerType','o','setAxisLimFlag',1,'plotDashLineFlag',1, 'edge_distribution','histeq');
    case 'uniform'
        ScatterXYBinned(v_real, v, 15, 50, 'color','r','lineWidth',5,'markerType','o','setAxisLimFlag',1,'plotDashLineFlag',1, 'edge_distribution','linear');
    case 'binary'
        scatter(v_real, v, 'r.');
end
xlabel('real velocity'); ylabel('estimated velocity');
title(sprintf('FWHM%d', FWHM));

end