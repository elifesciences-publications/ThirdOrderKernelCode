function SAC_Oppenency_Utils_PlotRaw_Resp_IndividualCell(resp, data_info,stim_info, epoch_ID)
color_use_bank = [[1,0,0];[0,0,1];[0,0,0]];
%%
epoch_index = data_info.epoch_index;
n_phase = 8;
n_dir = 3;
n_cell = length(resp);
% [~, resp_ave, resp_sem] = SAC_GetAverageResponse(resp);
%% Timetraces..
for cc = 1:1:n_cell
    MakeFigure;
    resp_over_roi = mean(resp{cc}, 4);
    resp_ave = squeeze(mean(resp_over_roi, 2));
    resp_std = squeeze(std(resp_over_roi, 1, 2));
    resp_sem = resp_std/sqrt(3);
    %     for pp = 1:1:n_phase
    %         for dd = 1:1:n_dir
    %             color_use = color_use_bank(dd,:);
    %             % plot the stimulus, contrast, and response.
    %             subplot(2, 4, pp);
    %             SAC_SineWave_Plot_Utils_PlotTimeTraces(resp_ave(:, epoch_index(pp, dd)), ...
    %                 resp_sem(:, epoch_index(pp, dd)), ...
    %                 color_use,...
    %                 'set_integrate_len',true,...
    %                 'f_vals', 4);
    % %             set(gca,'YLim',[-0.05, 0.2]);
    %         end
    %         legend('preferred','null','counterphase');
    %     end
    color_use = brewermap(24, 'Accent');
    for ee = 1:1:24
        SAC_SineWave_Plot_Utils_PlotTimeTraces(resp_ave(:, ee), ...
            resp_sem(:, ee), ...
             color_use(ee, :),...
            'set_integrate_len',true,...
            'f_vals', 4);
%                     set(gca,'YLim',[-0.05, 0.2]);
    end
end
end
