function SAC_AppMot_Plot_Utils_4D_Lag_Dir_LeadC_LagC(resp, data_info, stim_info, epoch_ID)

%% SAC_AverageResponse_By works only if the resp has been reorganized.
%% plotting parameters/
color_bank = [[1,0,0];[0,0,1]];

%% data_info.epoch_index = [leadCont, ladCont, Direction, lagPos]
epoch_index = data_info.epoch_index;
stim_cont = stim_info.epoch_cont;
n_lag = size(data_info.epoch_index, 4);

%% average response.
[~, resp_ave, resp_sem] = SAC_GetAverageResponse(resp); 
[resp_over_X, data_info_over_X, ~] = SAC_AverageResponse_By(resp, data_info,'lagCont','sub',epoch_ID);
epoch_index_over_X = data_info_over_X.epoch_index;
[~, resp_over_X_ave, resp_over_X_sem] = SAC_GetAverageResponse(resp_over_X);


%% It is important that the for loop is the same as the 
MakeFigure;
for cc_lead = 1:1:2 %  Lef and Right Pannel.
    for ll = 1:1:n_lag
        for dd = 1:1:2
            
            %% organize the the index. (see slides in log.)
            block_row = ll;
            block_mega_col = dd;
            block_smaller_col = cc_lead; % direction...
            %%
            block_idx = (block_row - 1) * 4 + (block_mega_col - 1) * 2 + block_smaller_col; %% plot it somewhere.
            subplot_idx_diff_resp = floor((block_idx - 1) / 4) * 8 + 8 + block_idx;
            subplot_idx_two_resp  = floor((block_idx - 1) / 4) * 8 + 4 + block_idx ;
            
            %%
             epoch_over_X = epoch_index_over_X(cc_lead, dd, ll);
             resp_ave_this = resp_over_X_ave(:, epoch_over_X);
             resp_sem_this = resp_over_X_sem(:, epoch_over_X);
        
        
            %% the diff has been calculated across rois.
            subplot(n_lag * 3, 4, subplot_idx_diff_resp);
            SAC_AppMot_Plot_Utils_PlotTimeTraces(resp_ave_this, resp_sem_this, [0,0,0]);
            if (ll == n_lag)
                xlabel('time (sec)');
            end
            
            for cc_lag = 1:1:2
               epoch_this = epoch_index(cc_lead, cc_lag, dd, ll);
               epoch_ID_this = epoch_ID(epoch_this,:); % epoch_ID_this has two dimensions. 
               resp_ave_this = resp_ave(:, epoch_this);
               resp_sem_this = resp_sem(:, epoch_this);
               color_use = color_bank(cc_lag,:);
               
               %% plot response.
               subplot(n_lag * 3, 4,  subplot_idx_two_resp);
               SAC_AppMot_Plot_Utils_PlotTimeTraces(resp_ave_this, resp_sem_this, color_use);
               set(gca,'YLim', [-0.1,0.25]);
               
               %% plot stimulus
               subplot_idx_stim  = floor((block_idx - 1)/ 4) * 16 + (block_idx - 1) * 2 + cc_lag; % read dd = 1, blue dd = 2;
               subplot(n_lag * 3,8, subplot_idx_stim); % you also want to plot the
               epoch_ID_one_epoch = epoch_ID_this;
                
               subplot(n_lag * 3,8, subplot_idx_stim); % you also want to plot the
               stim = stim_cont(:,:,abs(epoch_ID_one_epoch));
               SAC_AppMot_Plot_Utils_PlotStimCont(stim, color_use)
               title(num2str(epoch_ID_one_epoch));
             end
        end
    end
end