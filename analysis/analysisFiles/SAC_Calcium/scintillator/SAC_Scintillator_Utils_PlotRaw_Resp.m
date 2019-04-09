function SAC_Scintillator_Utils_PlotRaw_Resp(resp, data_info,stim_info, epoch_ID)
epoch_index = data_info.epoch_index;
%%
n_time = 6;
n_dir = 2;
n_par = 2;

xt_cc = stim_info.epoch_crosscorr;
[~, resp_ave, resp_sem] = SAC_GetAverageResponse(resp);

%%
MakeFigure;
for pp = 1:1:n_par
    for dd = 1:1:n_dir
        for tt = 1:1:n_time
            block_idx = (pp - 1) * 2 + dd;
            subplot_stim = (block_idx - 1) *  12 + (tt - 1)* 2 + 1;
            subplot_resp = (block_idx - 1) * 12 + (tt - 1)* 2 + 2;
            
            resp_ave_this = resp_ave(:, epoch_index(tt, dd, pp));
            resp_sem_this = resp_sem(:, epoch_index(tt, dd, pp));
            stim_cross = xt_cc(:,:,epoch_ID(epoch_index(tt, dd, pp)));
            % plot the stimulus, contrast, and response.
            subplot(4, n_time * 2, subplot_stim);
            SAC_Scintillator_Plot_Utils_PlotStimCont(stim_cross, [0,0,0]);
            title(num2str(epoch_ID(epoch_index(tt, dd, pp))));
            subplot(4, n_time * 2, subplot_resp)
            SAC_Scintillator20190326_Plot_Utils_PlotTimeTraces(resp_ave_this, resp_sem_this, [0,0,0]);
%             SAC_SineWave_Plot_Utils_PlotTimeTraces(resp_ave_this, resp_sem_this, [0,0,0]);
%             set(gca, 'YLim', [-0.05, 0.3]);
        end
    end
end
end