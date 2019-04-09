function [metric_batches,  improvement_metric_batches_3rd, improvement_metric_all_batches_best, weight_ratio_3rd_over_2nd, residual_r, residual_slope] =...
    plot_scatter_plot_correlation_one_situation(data, mode, varargin)
plot_flag = true;
metric = 'corr_improvement';
num_batches = 10;
y_label_str = [];
color_bank = [[114, 206, 245]; [49, 168, 73]; [237, 26, 85]]/255;
downsample_point_flag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% RGB.
color_bank = cat(1, color_bank, [0.5,0.5,0.5]);
switch mode
%     case 'ai_publish'
%         textFontSize = 10;
%         axesFontSize = 9;
%         axesLineWidth = 2;
%         lineWidth = 2;
%         
%         fontsize_tau = 4;
%         fontsize_label = 6;
%         position_bank = {[1/2,1,1,1],[7/4,1,1,1],[3,1,1,1],[19/4,1,1.5,1],}; %plot first and scale them
%         h = repmat(struct('Position',[],'Units', 'inches'), 5,1);
%         for ii = 1:1:4
%             h(ii).Position = position_bank{ii};
%         end
%         h(5).Position = [1/4,3/4,nan,nan];

    case 'ai_publish'
        textFontSize = 10;
        axesFontSize = 9;
        axesLineWidth = 0.5;
        lineWidth = 1;
        axes('Units', 'points', 'Position', [400, 500, 108, 108]);
        
        fontsize_label = 9;
        position_bank = {[100,500,108,108],[300,500,108,108],[100,300,108,108],[300,300, 108,108], [100,100, 120,120]}; %plot first and scale them
        h = repmat(struct('Units', 'points','Position',[]), 5,1);
        for ii = 1:1:5
            h(ii).Position = position_bank{ii};
        end

        
    case 'ai_poster'
        fontsize_label = 15;
        position_bank = {[50,200,100, 100],[200,200,100, 100],[350,200,100, 100],[500,200,200,100]}; %plot first and scale them
        h = repmat(struct('Position',[],'Units', 'points'), 5,1);
        for ii = 1:1:4
            h(ii).Position = position_bank{ii};
        end
    case 'matlab_debug'
        textFontSize = 20;
        axesFontSize = 14;
        axesLineWidth = 2;
        lineWidth = 2;
        
        fontsize_tau = 15;
        fontsize_label = 15;
        n_subplot_v = 4;
        n_subplot_h = 3;
        h = repmat(struct('Position',[],'Units', 'normalized'), 5,1);
        for ii = 1:1:4
            a = subplot(n_subplot_h, n_subplot_v, ii); h(ii).Position = a.Position;
        end
        h(5).Position = [h(1).Position(1) - 0.05, h(1).Position(2) - 0.05,nan,nan];
end
%% ATTENTION!! you should not symmetrize your data before hand. data segmentation would symmetrize it for you.
%% Symmetrization before hand would decrease the standard deviation of your data!!!
data_batches = performance_evaluation_utils_data_segmentation(data, num_batches);
[metric_batches,  improvement_metric_batches_3rd, improvement_metric_all_batches_best, weight_ratio_3rd_over_2nd, residual_r, residual_slope] =...
    performance_evaluation_utils_data_calculate_correlation_batch(data_batches, metric);

%% you need to compute the correlation as well.
%% before plotting. downsample your data point to 200.
if downsample_point_flag
    % instead of resample it uniformly. you should delete point near the
    % origin. based on the second order estimates.
    % or chose point for every percentile. too much work? it is okay....
    n_sample = 1000;
    idx = utils_resample_data(data.v2, n_sample);
    
    coef = data.v_real\data.v2; 
    residual_this = data.v2 - data.v_real * coef;
    
    data.v2 = data.v2(idx);
    data.v3 = data.v3(idx);
    data.v_real = data.v_real(idx);
    v2_residual = residual_this(idx);
end
if plot_flag
    % get the confidence interval.
    % find the largest limit. between such that they are in the same range.
    % coloring certain points. % top 5. different colors.
    ylim_max = max([max(data.v2(:)), max(data.v3(:)), max(data.v2(:) + data.v3(:))]);
    ylim_scatter = [-ylim_max, ylim_max];
    
    if strcmp(mode, 'ai_publish')
        MakeFigure_Paper;
    else
       MakeFigure;
    end
    %%
    axes('Units', h(1).Units, 'Position', h(1).Position);
    scatter(data.v_real, data.v2, 'Marker','.', 'MarkerEdgeColor', color_bank(1,:), 'MarkerFaceColor', color_bank(1,:));
%     Velocity_ScatterPlot_Utils('', '2^{nd}order output','y_lim_flag', true, 'ylim', ylim_scatter, 'xLim', [-600, 600] );
    Velocity_ScatterPlot_Utils('', '','y_lim_flag', true, 'ylim', ylim_scatter, 'xLim', [-600, 600] );

    r_str = sprintf('%.2f +/- %.2f', metric_batches.mean(1), metric_batches.sem(1));
    text(500,  max(get(gca, 'YLim')),   ['\rho = ', r_str],'FontSize', textFontSize);
    figure_to_illustrator_utils_set_axes('fontSize', textFontSize, 'axesfontSize', axesFontSize, 'axesLineWidth', axesLineWidth,'lineWidth', lineWidth)
    
    if strcmp(mode, 'ai_publish')
        %         High_Corr_PaperFig_Utils_SmallFontSize();
    else
        ConfAxis;
    end
    
    axes('Units', h(2).Units, 'Position', h(2).Position);
    scatter(data.v_real, data.v3, 'Marker','.','MarkerEdgeColor', color_bank(2,:), 'MarkerFaceColor', color_bank(2,:));
%     Velocity_ScatterPlot_Utils('image velocity [\circ/s]', '3^{rd} order output','y_lim_flag', true, 'ylim', ylim_scatter, 'xLim', [-600, 600] );
    Velocity_ScatterPlot_Utils('', '','y_lim_flag', true, 'ylim', ylim_scatter, 'xLim', [-600, 600] );
    r_str = sprintf('%.2f +/- %.2f', metric_batches.mean(2), metric_batches.sem(2));
    text(500,  max(get(gca, 'YLim')),   ['\rho = ', r_str],'FontSize', textFontSize);
    figure_to_illustrator_utils_set_axes('fontSize', textFontSize, 'axesfontSize', axesFontSize, 'axesLineWidth', axesLineWidth,'lineWidth', lineWidth)
    
    %     set(gca,'XTick',[-500, 500], 'XTickLabel',strsplit(num2str([-500, 500])));
    
    if strcmp(mode, 'ai_publish')
        %         High_Corr_PaperFig_Utils_SmallFontSize();
    else
        ConfAxis;
    end
    
    
    axes('Units', h(3).Units, 'Position', h(3).Position);
    scatter(data.v_real, data.v3 + data.v2, 'Marker','.','MarkerEdgeColor', color_bank(3,:), 'MarkerFaceColor', color_bank(3,:));
%     Velocity_ScatterPlot_Utils('', '2^{md} + 3^{rd} order output','y_lim_flag', true, 'ylim', ylim_scatter, 'xLim', [-600, 600] );
    Velocity_ScatterPlot_Utils('', '','y_lim_flag', true, 'ylim', ylim_scatter, 'xLim', [-600, 600] );
    r_str = sprintf('%.2f +/- %.2f', metric_batches.mean(3), metric_batches.sem(3));
    text(500,  max(get(gca, 'YLim')),   ['\rho = ', r_str],'FontSize', textFontSize);
    figure_to_illustrator_utils_set_axes('fontSize', textFontSize, 'axesfontSize', axesFontSize, 'axesLineWidth', axesLineWidth,'lineWidth', lineWidth)
    
    if strcmp(mode, 'ai_publish')
        %         High_Corr_PaperFig_Utils_SmallFontSize();
    else
        ConfAxis;
    end
    
    axes('Units', h(4).Units, 'Position', h(4).Position);

    scatter(v2_residual, data.v3, 'Marker','.','MarkerEdgeColor', [0,0,0], 'MarkerFaceColor', [0,0,0]);
    Velocity_ScatterPlot_Utils('', '','y_lim_flag', false, 'ylim', ylim_scatter, 'xLim', [-200,200]);
    r_str = sprintf('%.2f +/- %.2f', residual_r.mean, residual_r.std);
    set(gca, 'YLim', [-150, 150]);
    text(200,  max(get(gca, 'YLim')),   ['\rho = ', r_str],'FontSize', textFontSize);
    figure_to_illustrator_utils_set_axes('fontSize', textFontSize, 'axesfontSize', axesFontSize, 'axesLineWidth', axesLineWidth,'lineWidth', lineWidth)
    
    if strcmp(mode, 'ai_publish')
        %         High_Corr_PaperFig_Utils_SmallFontSize();
    else
        ConfAxis;
    end    
    %% correlation bar plot
    axes('Units', h(5).Units, 'Position', h(5).Position);
    High_Corr_Paper_Utils_PerformanceBarPlot(metric_batches,  improvement_metric_batches_3rd, color_bank, fontsize_label, y_label_str, 'weight_ratio', weight_ratio_3rd_over_2nd);
    figure_to_illustrator_utils_set_axes('fontSize', textFontSize, 'axesfontSize', axesFontSize, 'axesLineWidth', axesLineWidth,'lineWidth', lineWidth)
    
end
end


%     %% plot the scale bar. do not plot.
%     xlim = get(gca, 'XLim');
%     scale_bar_image_velocity = 200;
%     scale_bar_kernel_velocity = 50;
%     length_of_scale_bar = [(xlim(2) - xlim(1))/scale_bar_image_velocity, (ylim_max * 2)/scale_bar_kernel_velocity];
%     % the length of vertical line will be determined.
%     h(5).Position(3:4) = h(1).Position(3:4)./length_of_scale_bar;
%     if strcmp(mode, 'ai_publish')
%         %         High_Corr_PaperFig_Utils_SmallFontSize();
%     else
%         ConfAxis
%     end
    
%     axes('Units', h(5).Units, 'Position', h(5).Position);
%     % nomatter how long
%     plot([0,0],[0,50],'k');plot([0,200],[0,0],'k');
%     box off
%     set(gca, 'XAxisLocation','origin','YAxisLocation','origin','Xlim',[0,scale_bar_image_velocity],'YLim', [0,scale_bar_kernel_velocity]);
%     set(gca, 'XTick',[], 'YTick',[])
%     xlabel(sprintf('%d \n degree/second',scale_bar_image_velocity),'FontSize',fontsize_label);
%     ylabel(sprintf('%d \n degree/second',scale_bar_kernel_velocity),'FontSize',fontsize_label);
%     % the length of x y dependens strongly on the
