function plot_scatter_plot_correlation_several_situations(data_all, condition_str, condition_str_short, mode)
% RGB.
n_condition = length(data_all);

color_bank = [[114, 206, 245]; [49, 168, 73]; [237, 26, 85]]/255;
color_bank = cat(1, color_bank, [0.5,0.5,0.5]);
switch mode
    case 'ai_publish'
        fontsize_tau = 4;
        fontsize_label = 6;
        position_bank = {[1/2,1,1,1],[7/4,1,1,1],[3,1,1,1],[19/4,1,1.5,1],}; %plot first and scale them
        h = repmat(struct('Position',[],'Units', 'inches'), 5,1);
        for ii = 1:1:4
            h(ii).Position = position_bank{ii};
        end
        h(5).Position = [1/4,3/4,nan,nan];
    case 'matlab_debug'
        fontsize_tau = 10;
        fontsize_label = 10;
        n_subplot_h = 4;
        n_subplot_v = n_condition;
        h = repmat(struct('Position',[],'Units', 'normalized'), n_condition, 3); % 5 condition, 4 plot.
        for ii = 1:1:n_subplot_h - 1
            for jj = 1:1:n_subplot_v
                a = subplot(n_subplot_h, n_subplot_v, (ii - 1) * n_subplot_v  + jj);
                h(jj, ii).Position = a.Position;
            end
        end
        h_bar = struct('Position',[],'Units', 'normalized');
        a = subplot(n_subplot_h, n_subplot_v, (4 - 1) * n_subplot_v  + (1:n_subplot_v));
        h_bar.Position =a.Position;
        %         color_bank = {[0,1,0],[1,0,0],[0,0,1]};
        
        %         fig_info.h = h;
        %         fig_info.fontsize.fontsize_tau = fontsize_tau;
        %         fig_info.fontsize.fontsize_label = fontsize_label;
        %         fig_info.color_bank = color_bank;
        %
        %         fileType = {'png'};
        %         nFigSave = 1;
end

MakeFigure;
r_all = zeros(length(data_all), 4);
for jj = 1:1:n_condition
    data = data_all{jj};
    % try to associate a color with each .
    w_this = [data.v2, data.v3]\ data.v_real;
    v_best = [data.v2, data.v3] * w_this;
    r_best = corr(v_best, data.v_real);
    r2 = corr(data.v2, data.v_real);
    r3 = corr(data.v3, data.v_real);
    r23 = corr(data.v_real, data.v3 + data.v2);
    % get the confidence interval.
    % find the largest limit. between such that they are in the same range.
    % coloring certain points. % top 5. different colors.
    ylim_max = max([max(data.v2(:)), max(data.v3(:)), max(data.v2(:) + data.v3(:))]);
    ylim_scatter = [-ylim_max, ylim_max];
    
    %%
    axes('Units', h(jj, 1).Units, 'Position', h(jj, 1).Position);
    scatter(data.v_real, data.v2, 'MarkerEdgeColor', color_bank(1,:), 'MarkerFaceColor', color_bank(1,:), 'Marker','.');
    Velocity_ScatterPlot_Utils('image velocity', '2nd order response','y_lim_flag', true, 'ylim', ylim_scatter );
    High_Corr_PaperFig_Utils_SmallFontSize();
    title(condition_str{jj})
    
    axes('Units', h(jj, 2).Units, 'Position', h(jj, 2).Position);
    scatter(data.v_real, data.v3, 'MarkerEdgeColor', color_bank(2,:), 'MarkerFaceColor', color_bank(2,:), 'Marker','.');
    Velocity_ScatterPlot_Utils('image velocity', '3rd order response','y_lim_flag', true, 'ylim', ylim_scatter );
    High_Corr_PaperFig_Utils_SmallFontSize();
    
    
    axes('Units', h(jj, 3).Units, 'Position', h(jj, 3).Position);
    scatter(data.v_real, data.v3 + data.v2, 'MarkerEdgeColor', color_bank(3,:), 'MarkerFaceColor', color_bank(3,:), 'Marker','.');
    Velocity_ScatterPlot_Utils('image velocity', 'full(2nd + 3rd) response','y_lim_flag', true, 'ylim', ylim_scatter);
    High_Corr_PaperFig_Utils_SmallFontSize();
    
    r_all(jj,:) = [r2, r3, r23, r_best];
end

axes('Units', h_bar.Units, 'Position', h_bar.Position);
% make up a value.
xaxis_value = bsxfun(@plus, (0:3) * 10, (1:n_condition)');

% one color by another?
for ii = 1:1:4
    hold on
    bar(xaxis_value(:,ii), r_all(:, ii),'FaceColor',color_bank(ii, :),'EdgeColor',[0 0 0])
end


box off
yLim = get(gca, 'YLim');
xLim = get(gca, 'XLim');
set(gca, 'XAxisLocation','origin');
set(gca, 'XTick',[]);
% instead using xtick, use text.
x_block_str = {'2nd ','3rd','2nd + 3rd','weighted 2nd and 3rd'};
% four conditions.
for ii = 1:1:length(x_block_str)
    text(xaxis_value(3, ii), yLim(2) * 1.1, x_block_str{ii},'Rotation',0,'HorizontalAlignment','center','FontSize',fontsize_label);
end
yl = ylabel('correlation with image velocity','FontSize',fontsize_label);
hold on

for jj = 1:1:n_condition
    for ii = 1:1:4
        text(xaxis_value(jj, ii), yLim(1), condition_str_short{jj}, 'Rotation',45,'HorizontalAlignment','center','FontSize',fontsize_label)
    end
end

%% plot the r_improve and second
for jj = 1:1:n_condition
    hold on
    plot(get(gca, 'XLim'),[r_all(jj, 1),r_all(jj, 1)], 'k--')
end

%% on the natural scene and third, plot the increment.
r_improve_all = (r_all(:,3) - r_all(:,1))./r_all(:,1) * 100;
r_improve_all_str  = cell(n_condition, 1);
for jj = 1:1:n_condition
r_improve_all_str{jj} = [sprintf('%.0f%', r_improve_all(jj)),'%'];
end
for jj = [1,4, 6, 7]
    text(xaxis_value(jj, 3), yLim(2),r_improve_all_str{jj},'Rotation',45,'HorizontalAlignment','center')
end
% High_Corr_PaperFig_Utils_SmallFontSize();

end