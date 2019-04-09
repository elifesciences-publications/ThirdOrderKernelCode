function SAC_Oppenency_Utils_PlotRaw_Resp(resp, data_info,stim_info, epoch_ID)
color_use_bank = [[1,0,0];[0,0,1];[0,0,0]];
%%
epoch_index = data_info.epoch_index;
n_phase = 8;
n_dir = 3;
[~, resp_ave, resp_sem] = SAC_GetAverageResponse(resp);
%% Timetraces..
MakeFigure;
for pp = 1:1:n_phase
    for dd = 1:1:n_dir
        color_use = color_use_bank(dd,:);
        % plot the stimulus, contrast, and response.
        subplot(2, 4, pp);
        SAC_SineWave_Plot_Utils_PlotTimeTraces(resp_ave(:, epoch_index(pp, dd)), ...
                                               resp_sem(:, epoch_index(pp, dd)), ...
                                               color_use,...
                                               'set_integrate_len',true,...
                                               'f_vals', 4);
        set(gca,'YLim',[-0.05, 0.2]);
    end
    legend('preferred','null','counterphase');
end

end
