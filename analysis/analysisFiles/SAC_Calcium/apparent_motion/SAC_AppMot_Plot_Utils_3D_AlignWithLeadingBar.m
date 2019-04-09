function SAC_AppMot_Plot_Utils_3D_AlignWithLeadingBar(resp, data_info, stim_info, trial_ID)

%% SAC_AverageResponse_By works only if the resp has been reorganized.
f_resp = 15.625;
f_stim = 60;
resp_time = (1:40)'/f_resp ;

stim_time = 60/f_stim;
stim_onset = 60/f_stim;

%% data_info.epoch_index = [leadCont, ladCont, Direction, lagPos]
epoch_index = data_info.epoch_index;
stim_cont = stim_info.epoch_cont;

n_dir = 2;
n_lag = size(data_info.epoch_index, 3);
color_bank = [[1,0,0];[0,0,1]];
%%
[~, resp_ave, resp_sem] = SAC_GetAverageResponse(resp);%% do averging
[resp_over_dir, data_info_over_dir, ~] = SAC_AverageResponse_By(resp, data_info, 'dirVal','sub',trial_ID);
epoch_index_over_dirVal = data_info_over_dir.epoch_index;
[~, resp_over_dir_ave, resp_over_dir_sem] = SAC_GetAverageResponse(resp_over_dir);
%% The leading and laging contrast are the same
%% It is important that the for loop is the same as the
MakeFigure;
for cc_lead = 1:1:2 %  Lef and Right Pannel.
    for ll = 1:1:n_lag
        %% put the direction down...
        %% organize the the index. (see slides in log.)
        block_row = ll;
        block_mega_col = cc_lead;
        block_idx = (block_row - 1) * 2 + block_mega_col; %% plot it somewhere.
        subplot_idx_diff_resp = floor((block_idx - 1) / 2) * 6 + 4 + mod(block_idx + 1, 2) + 1;
        subplot_idx_two_resp  = floor((block_idx - 1) / 2) * 6 + 2 + mod(block_idx + 1, 2) + 1;
        
        %% the diff has been calculated across rois.
        subplot(n_lag * 3, 2, subplot_idx_diff_resp);
        resp_ave_this = resp_over_dir_ave(:, epoch_index_over_dirVal(cc_lead, ll));
        resp_sem_this = resp_over_dir_sem(:, epoch_index_over_dirVal(cc_lead, ll));
        PlotXY_Juyue(resp_time,resp_ave_this,'errorBarFlag',1,'sem',resp_sem_this,...
            'colorMean', [0,0,0], 'colorError',[0,0,0]);
        plot_utils_shade([stim_onset,stim_onset + stim_time], get(gca,'YLim')); hold on;
        plot([1.25, 1.25], get(gca, 'YLim'), 'k--'); % onset of the second bar.
        ylabel('\Delta F/F');
        hold on;
        ConfAxis('fontSize',10);
        if (ll == n_lag)
            xlabel('time (sec)');
        end
        
        for dd = 1:1:n_dir
            trial_this = trial_ID(epoch_index(cc_lead,dd, ll),:); % trial_this has two dimensions. 
            for cc_lag = 1:1:2
                block_idx_tmp = (block_idx - 1) * 2 + dd;
                subplot_idx_stim  = floor((block_idx_tmp - 1)/ 4) * 16 + (block_idx_tmp - 1) * 2 + cc_lag; % read dd = 1, blue dd = 2;
                subplot(n_lag * 3,8, subplot_idx_stim); % you also want to plot the
                %% trial this would be two dimensionalll.
                imagesc(stim_cont(:,:,abs(trial_this(cc_lag)))'); colormap(gray);
                set(gca, 'XTick',[], 'YTick', [], 'clim',[-1,1],'YDir','normal');
                ConfAxis('fontSize',10);
                set(gca, 'XColor', color_bank(dd,:),'YColor', color_bank(dd,:));
                box on
                ylabel('space','Color', [0,0,0]);
                xlabel('time', 'Color', [0,0,0]);
                title(num2str(trial_this(cc_lag)));
            end
            
            % plot response of individual traces.
            subplot(n_lag * 3, 2,  subplot_idx_two_resp);
            resp_this_mean = resp_ave(:, epoch_index(cc_lead, dd,ll));
            resp_this_std = resp_sem(:, epoch_index(cc_lead, dd,ll));
            
            PlotXY_Juyue(resp_time,resp_this_mean,'errorBarFlag',1,'sem',resp_this_std,...
                'colorMean', color_bank(dd,:), 'colorError', color_bank(dd,:));
            plot_utils_shade([stim_onset,stim_onset + stim_time], [-0.1, 0.6]); hold on;
            plot([1.25, 1.25], get(gca, 'YLim'), 'k--'); % onset of the second bar.
            set(gca,'YLim', [-0.1,0.25]);
            ylabel('\Delta F/F');
            hold on;
            %         plot([1,1],get(gca,'YLim'), 'k--');
            ConfAxis('fontSize',10);
        end
        %% plot differences..
    end
end
end