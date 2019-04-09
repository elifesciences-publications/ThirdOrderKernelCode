function SAC_Oppenency_Utils_SumPreferredNull_WithCounterPhase(resp, data_info,stim_info, epoch_ID)
color_use_bank = [[1,0,0];[0,0,1];[0,0,0]];
color_sum = [1,0,1];


%%
epoch_index = data_info.epoch_index;
if length(data_info.param_name) == 1
    n_phase = 1;
    epoch_index = epoch_index';
else
    n_phase = 8;
end
n_dir = 3;
[~, resp_ave, resp_sem] = SAC_GetAverageResponse(resp);
%% add the preferred and null.
n_cell = length(resp);
resp_pref_plus_null = cell(n_cell, 1);
for ii = 1:1:n_cell
    %% response.
    r_s = size(resp{ii});
    resp_reshape_this = reshape(resp{ii}, [r_s(1), r_s(2), [n_phase, 3], r_s(4)]);
    resp_sum_this = resp_reshape_this(:,:,:,1,:) + resp_reshape_this(:,:,:,2,:); % two directions...
    
    resp_sum_this = reshape(resp_sum_this, [r_s(1), r_s(2), n_phase, r_s(4)]);
    resp_pref_plus_null{ii} = resp_sum_this;
end
[~, resp_ave_pref_plus_null, resp_sem_pref_plus_null] = SAC_GetAverageResponse(resp_pref_plus_null);

%% Timetraces..
MakeFigure;
for pp = 1:1:n_phase
    for dd = 1:1:n_dir
        color_use = color_use_bank(dd,:);
        % plot the stimulus, contrast, and response.
        subplot(2, ceil(n_phase/2), pp);
        SAC_SineWave_Plot_Utils_PlotTimeTraces(resp_ave(:, epoch_index(pp, dd)), resp_sem(:, epoch_index(pp, dd)), color_use,...
            'set_integrate_len',true,'f_vals', 4);
    end
    subplot(2, ceil(n_phase/2), pp);
    SAC_SineWave_Plot_Utils_PlotTimeTraces(resp_ave_pref_plus_null(:,pp), resp_sem_pref_plus_null(:, pp), color_sum, 'set_integrate_len',true,'f_vals', 4);
    set(gca,'YLim',[-0.05, 0.25]);
    xlabel('time (t)');
    legend('preferred','null','counterphase', 'pref+null');
end
end
