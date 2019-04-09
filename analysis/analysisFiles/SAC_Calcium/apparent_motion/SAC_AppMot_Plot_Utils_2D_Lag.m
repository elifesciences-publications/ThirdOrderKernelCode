function SAC_AppMot_Plot_Utils_2D_Lag(resp, data_info, stim_info, epoch_ID)
%% SAC_AverageResponse_By works only if the resp has been reorganized.
color_bank = [[1,0,0];[0,0,1]];

%% data_info.epoch_index = [leadCont, ladCont, Direction, lagPos]
epoch_index = data_info.epoch_index;
stim_cont = stim_info.epoch_cont;
n_lag = size(data_info.epoch_index, 2);

%%
[~, resp_ave, resp_sem] = SAC_GetAverageResponse(resp);%% do averging
[resp_over_X, data_info_over_X, ~] = SAC_AverageResponse_By(resp, data_info, 'dirVal','sub',epoch_ID);
epoch_index_over_X = data_info_over_X.epoch_index;
[~, resp_over_X_ave, resp_over_X_sem] = SAC_GetAverageResponse(resp_over_X);

%% It is important that the for loop is the same as the
MakeFigure;
for ll = 1:1:n_lag
    %% determine the structure. should be consistent with function name.
    block_idx = ll; %% plot it somewhere.
    subplot_idx_diff_resp = block_idx * 3 ;
    subplot_idx_two_resp  = block_idx * 3 - 1;
    
    %% response averaged over X.
    epoch_over_X = epoch_index_over_X(ll);
    resp_ave_this = resp_over_X_ave(:, epoch_over_X);
    resp_sem_this = resp_over_X_sem(:, epoch_over_X);
    
    
    %% plot response averaged over X.
    subplot(n_lag * 3, 1, subplot_idx_diff_resp);
    SAC_AppMot_Plot_Utils_PlotTimeTraces(resp_ave_this, resp_sem_this, [0,0,0]);
    if (ll == n_lag)
        xlabel('time (sec)');
    end
    
    %% plot stimulus and response before averaging.
    for dd = 1:1:2
        epoch_this = epoch_index(dd, ll);
        
        epoch_ID_this = epoch_ID(epoch_this,:); % epoch_ID_this has two dimensions.
        epoch_ID_this_reshape = reshape( epoch_ID_this, 2, 2);

        resp_ave_this = resp_ave(:, epoch_this);
        resp_sem_this = resp_sem(:, epoch_this);
        color_use = color_bank(dd,:);
            subplot(n_lag * 3, 1,  subplot_idx_two_resp);
            SAC_AppMot_Plot_Utils_PlotTimeTraces(resp_ave_this, resp_sem_this, color_use);
        
        for cc_lead = 1:1:2
            for cc_lag = 1:1:2
                %% get the position of the subplot.
                block_idx_mega = (block_idx - 1) * 2 + dd;
                block_idx_tmp = (block_idx_mega - 1) * 2 + cc_lead;
                subplot_idx_stim  = floor((block_idx_tmp - 1)/ 4) * 16 + (block_idx_tmp - 1) * 2 + cc_lag; % read dd = 1, blue dd = 2;
                epoch_ID_one_epoch = epoch_ID_this_reshape(cc_lag,cc_lead);
                
                %% trial this would be two dimensionalll.
                subplot(n_lag * 3,8, subplot_idx_stim); % you also want to plot the
                stim = stim_cont(:,:,abs(epoch_ID_one_epoch));
                SAC_AppMot_Plot_Utils_PlotStimCont(stim, color_use)
                title(num2str(epoch_ID_one_epoch));
            end
        end
    end
end
end