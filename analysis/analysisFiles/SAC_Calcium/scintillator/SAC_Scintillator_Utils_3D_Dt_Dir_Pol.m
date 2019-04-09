function SAC_Scintillator_Utils_3D_Dt_Dir_Pol(resp, data_info,stim_info, epoch_ID)

color_bank = [[1,0,0];[0,0,1]];

%%
epoch_index = data_info.epoch_index;
xt_cc = stim_info.epoch_crosscorr;

%%
n_time = 6;
n_dir = 2;
n_par = 2;

[~, resp_ave, resp_sem] = SAC_GetAverageResponse(resp);
[resp_over_X, data_info_over_X, ~] = SAC_AverageResponse_By(resp, data_info,'pol','sub',epoch_ID);
epoch_index_over_X = data_info_over_X.epoch_index;
[~, resp_over_X_ave, resp_over_X_sem] = SAC_GetAverageResponse(resp_over_X);
%%
MakeFigure;
for tt = 1:1:n_time
    for dd = 1:1:n_dir
        subplot_idx_two_resp  = (dd - 1)*18 + 6 + tt;
        subplot_idx_diff_resp = (dd - 1)*18 + 12 + tt;
        % get the direction subtracted resposne.
        epoch_over_X = epoch_index_over_X(tt, dd);
        resp_ave_this = resp_over_X_ave(:, epoch_over_X);
        resp_sem_this = resp_over_X_sem(:, epoch_over_X);
        
        % plot response.
        subplot(6, n_time, subplot_idx_diff_resp);
        SAC_SineWave_Plot_Utils_PlotTimeTraces(resp_ave_this, resp_sem_this, [0,0,0]);
        
        for pp = 1:1:n_par

            epoch_this = epoch_index(tt, dd, pp);
            epoch_ID_this = epoch_ID(epoch_this,:); % epoch_ID_this has two dimensions.
            resp_ave_this = resp_ave(:, epoch_this);
            resp_sem_this = resp_sem(:, epoch_this);
            color_use = color_bank(pp,:);
            
            %% plot response.
            subplot(6, n_time,  subplot_idx_two_resp);
            SAC_SineWave_Plot_Utils_PlotTimeTraces(resp_ave_this, resp_sem_this, color_use);
            
            
            %% plot stimulus
            subplot_idx_stim = (dd - 1)*36 + (tt - 1) * 2  + pp;
            epoch_ID_one_epoch = epoch_ID_this;
            stim_cross = xt_cc(:,:,epoch_ID_one_epoch);
            
            subplot(6, n_time * 2, subplot_idx_stim);
            SAC_Scintillator_Plot_Utils_PlotStimCont(stim_cross, color_use);
            title(num2str(epoch_ID_one_epoch));
        end
    end
end
end