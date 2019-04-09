function High_Corr_PaperFig_OptimalKernel_Utils_Plot(kernel_glider_format,kernel_extraction_method_str,corr_type_str_2o,corr_type_str_3o, h)
n_corr_2o = length(corr_type_str_2o);
n_corr_3o = length(corr_type_str_3o);

fontSize = 10;
n_model = length(kernel_glider_format);
kernel_glider_format_mat = cell2mat(kernel_glider_format');
% set up the ylim for both. such that the second is in the midlle, but the
% scale bar is different. should have one dt timed in?
kernel_glider_format_mat_second = kernel_glider_format_mat(1:n_corr_2o, :);
kernel_glider_format_mat_third = kernel_glider_format_mat(n_corr_2o + 1:end,:);
ylim_max_second = max(abs(kernel_glider_format_mat_second(:)));
ylim_max_third = max(abs(kernel_glider_format_mat_third(:)));


gray_level = [0,0.8,0.6,0.4,0.2];
%% second order
axes('Units',h(1).Units, 'Position', h(1).Position);
bar_plot_second = bar(kernel_glider_format_mat_second); % second order direction is not correct...
set(gca,'YLim',[-ylim_max_second, ylim_max_second],'XAxisLocation','origin','XTick',[]);
set(gca, 'YTick',[-1,0,1]);
box off
ylabel('2^{nd} kernel strength (a.u.)');
High_Corr_PaperFig_Utils_SmallFontSize;

%% third order
axes('Units',h(2).Units, 'Position', h(2).Position);
bar_plot_third = bar(kernel_glider_format_mat_third); % second order direction is not correct...
set(gca, 'YLim',[-ylim_max_third,ylim_max_third],'XAxisLocation','origin','XTick',[]);
box off
set(gca, 'YTick',[-5, 0, 5]);
ylabel('3^{rd} kernel strength (a.u.)');

High_Corr_PaperFig_Utils_SmallFontSize;
legend_pos  = [h(2).Position(1) + h(2).Position(3) * 7/8,h(2).Position(2)+ h(2).Position(4)* 3/4, h(2).Position(3) * 1/8, h(2).Position(4) * 1/16]; 
legend(kernel_extraction_method_str,'FontSize', fontSize , 'Units', h(2).Units, 'Position', legend_pos);
% colormap(gray)
for ii = 1:1:n_model
    bar_plot_second(ii).FaceColor = [1,1,1] * gray_level(ii);
    bar_plot_third(ii).FaceColor = [1,1,1] * gray_level(ii);
    bar_plot_second(ii).BarWidth = 0.5;
    bar_plot_third(ii).BarWidth = 0.5;
    
end
bar_plot_second(1).EdgeColor = [1,0,0];
bar_plot_third(1).EdgeColor = [1,0,0];

end