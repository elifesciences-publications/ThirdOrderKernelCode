function SAC_Scintillator_Utils_1D_Dt(resp, data_info,stim_info, epoch_ID)

color_bank = brewermap(6, 'Reds');

%%
epoch_index = data_info.epoch_index;
xt_cc = stim_info.epoch_crosscorr;

%%
n_time = 6;
n_dir = 2;
n_par = 2;

[~, resp_ave, resp_sem] = SAC_GetAverageResponse(resp);
[resp_over_X, data_info_over_X, ~] = SAC_AverageResponse_By(resp, data_info,'dt','mean',epoch_ID);
[~, resp_over_X_ave, resp_over_X_sem] = SAC_GetAverageResponse(resp_over_X);
%%
MakeFigure;

subplot_idx_diff_resp = 4;

% plot response.
subplot(4, 1, subplot_idx_diff_resp);
SAC_SineWave_Plot_Utils_PlotTimeTraces(resp_over_X_ave, resp_over_X_sem, [0,0,0]);
set(gca, 'YLim', [-0.05, 0.05]);
title('average over \Delta t');
xlabel('time (s)');

%%
for tt = 1:1:n_time
    subplot_idx_two_resp  = 12 + tt;
    epoch_this = epoch_index(tt);
    epoch_ID_this = epoch_ID(epoch_this,:); % epoch_ID_this has two dimensions.
    resp_ave_this = resp_ave(:, epoch_this);
    resp_sem_this = resp_sem(:, epoch_this);
    color_use = color_bank(tt,:);
    
    %% plot response.
    subplot(4, n_time,  subplot_idx_two_resp);
    SAC_SineWave_Plot_Utils_PlotTimeTraces(resp_ave_this, resp_sem_this, color_use);
    set(gca, 'YLim', [-0.15, 0.2]);
    
    epoch_ID_this_reshape = reshape(epoch_ID_this, [n_par, n_dir]);
    for dd = 1:1:n_par
        for pp = 1:1:n_dir
            %% plot stimulus
            subplot_idx_stim = (dd - 1)*12 + (tt - 1) * 2  + pp;
            epoch_ID_one_epoch = epoch_ID_this_reshape(pp, dd);
            stim_cross = xt_cc(:,:,abs(epoch_ID_one_epoch));
            
            subplot(4, n_time * 2, subplot_idx_stim);
            SAC_Scintillator_Plot_Utils_PlotStimCont(stim_cross, color_use);
            title(num2str(epoch_ID_one_epoch));
        end
    end
end
end