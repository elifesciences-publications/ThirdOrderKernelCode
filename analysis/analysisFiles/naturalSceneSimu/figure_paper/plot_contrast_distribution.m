function plot_contrast_distribution(med_data, p_i_var, p_i_skew, natural_scene, symmetrize_flag, zero_mean_flag, plot_natural_scene_flag)
% second two. not four of them together...
%%
gray_value = med_data.gray_value;
N = med_data.N;
% K = med_data.K;
%%
medp_plot_matchup(gray_value, p_i_var(:,1), [0, 0,1],1,[0,0,1]);
medp_plot_matchup(gray_value, p_i_skew(:,1), [1, 0,0],1,[1, 0,0]);

if plot_natural_scene_flag
    natural_scene_histogram_temp(natural_scene, gray_value, [0,0,0],'n_gray', N,...
        'symmetrize_flag', symmetrize_flag,'zero_mean_flag', zero_mean_flag,...
        'plot_statistics_flag',0);
end
set(gca, 'XLim', [-3, 3]);
set(gca, 'YLim', [0, 0.2],'YScale','linear');
set(gca,'YTick',[0,0.1,0.2],'YTickLabel',{'0','0.1','0.2'});
ylabel('probability');
xlabel('contrast');
legend('+mean +var','+mean +var +skew','original');
end
