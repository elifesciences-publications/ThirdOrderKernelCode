function SAC_AppMot_Plot_Utils_PlotTimeTraces(resp_ave, resp_sem, color_use)
%% experimental parameter.
f_resp = 15.625;
f_stim = 60;
resp_time = (1:40)'/f_resp ;

stim_time = 60/f_stim;
stim_onset = 60/f_stim;

second_bar_onset = stim_onset + 15/f_stim;

%%
PlotXY_Juyue(resp_time,resp_ave,'errorBarFlag',1,'sem',resp_sem,...
    'colorMean', color_use, 'colorError',color_use);
plot_utils_shade([stim_onset,stim_onset + stim_time], get(gca,'YLim')); hold on;
plot([second_bar_onset, second_bar_onset], get(gca, 'YLim'), 'k--'); % onset of the second bar.
ylabel('\Delta F/F');
hold on;
ConfAxis('fontSize',10);
end