function SAC_SineWave_Plot_Utils_PlotTimeTraces(resp_ave, resp_sem, color_use, varargin)
%% experimental parameter.
f_resp = 15.625;
f_stim = 60;
resp_time = (1:size(resp_ave, 1))'/f_resp ;
stim_onset = 60/f_stim;
stim_dur = 300/f_stim;
%% plotting parameter.
set_integrate_len = false;
f_vals = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% get the integration onidx and offidx. use the same function in actual averaging.
[integrate_on_idx, integrate_off_idx, ~] = SAC_SineWave_Utils_AverageOverTime_CalOnOffIdx(set_integrate_len, f_vals);

%% plotting.
PlotXY_Juyue(resp_time,resp_ave,'errorBarFlag',1,'sem',resp_sem,...
    'colorMean', color_use, 'colorError',color_use); hold on;
% plot_utils_shade([resp_time(integrate_on_idx),resp_time(integrate_off_idx)], get(gca,'YLim')); hold on;
h1 = plot([stim_onset, stim_onset], get(gca,'YLim'), 'k--');  h1.Annotation.LegendInformation.IconDisplayStyle = 'off';
h2 = plot([stim_onset + stim_dur, stim_onset + stim_dur], get(gca,'YLim'), 'k--');h2.Annotation.LegendInformation.IconDisplayStyle = 'off';
ylabel('\Delta F/F');
hold on;
ConfAxis('fontSize',10);
end