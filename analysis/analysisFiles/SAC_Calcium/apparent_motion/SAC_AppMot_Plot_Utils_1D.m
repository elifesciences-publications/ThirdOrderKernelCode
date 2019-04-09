function SAC_AppMot_Plot_Utils_1D(resp, data_info, stim_info, epoch_ID)
%% SAC_AverageResponse_By works only if the resp has been reorganized.
color_bank = [[1,0,0];[0,0,1]];

%% data_info.epoch_index = [leadCont, ladCont, Direction, lagPos]
epoch_index = data_info.epoch_index;
stim_cont = stim_info.epoch_cont;
n_lag = size(data_info.epoch_index, 1);

%%
[~, resp_ave, resp_sem] = SAC_GetAverageResponse(resp);%% do averging
[resp_over_X, ~, ~] = SAC_AverageResponse_By(resp, data_info, 'lagPos','sum',epoch_ID);
[~, resp_over_X_ave, resp_over_X_sem] = SAC_GetAverageResponse(resp_over_X);

%% It is important that the for loop is the same as the

MakeFigure;
subplot_idx_diff_resp = 4 ;
subplot_idx_two_resp  = 3;
subplot(4, 1, subplot_idx_diff_resp);
SAC_AppMot_Plot_Utils_PlotTimeTraces(resp_over_X_ave, resp_over_X_sem, [0,0,0]);
xlabel('time (sec)');

for ll = 1:1:n_lag
    epoch_this = epoch_index(ll);
    epoch_ID_this = epoch_ID(epoch_this,:); % epoch_ID_this has two dimensions.
    color_use = color_bank(ll,:);
    subplot(4, 1,  subplot_idx_two_resp);
    SAC_AppMot_Plot_Utils_PlotTimeTraces(resp_ave(:, epoch_this), resp_sem(:, epoch_this), color_use);
    
    for ss = 1:length(epoch_ID_this)
        subplot(4, 8, (ll - 1) * 8 + ss)
        epoch_ID_one_epoch = epoch_ID_this(ss);
        stim = stim_cont(:,:,abs(epoch_ID_one_epoch));
        SAC_AppMot_Plot_Utils_PlotStimCont(stim, color_use)
        title(num2str(epoch_ID_one_epoch));
    end
end
end
