function SAC_AppMot_Plot_Utils_1D_AlignWithLeadingBar(resp, data_info, stim_info, trial_ID)

%% SAC_AverageResponse_By works only if the resp has been reorganized.
f_resp = 15.625;
f_stim = 60;
resp_time = (1:40)'/f_resp ;

stim_time = 60/f_stim;
stim_onset = 60/f_stim;

%% data_info.epoch_index = [leadCont, ladCont, Direction, lagPos]
epoch_index = data_info.epoch_index;
stim_cont = stim_info.epoch_cont;
color_bank = [[1,0,0];[0,0,1]];
%%
[~, resp_ave, resp_sem] = SAC_GetAverageResponse(resp);%% do averging
[resp_over_lagPos, data_info_over_lagPos, ~] = SAC_AverageResponse_By(resp, data_info, 'lagPos','sum',trial_ID);
[~, resp_over_lagPos_ave, resp_over_lagPos_sem] = SAC_GetAverageResponse(resp_over_lagPos);

MakeFigure;
subplot_idx_diff_resp = 4 ;
subplot_idx_two_resp  = 3;

%% the diff has been calculated across rois.
subplot(4, 1, subplot_idx_diff_resp);
resp_ave_this = resp_over_lagPos_ave(:);
resp_sem_this = resp_over_lagPos_sem(:);
PlotXY_Juyue(resp_time,resp_ave_this,'errorBarFlag',1,'sem',resp_sem_this,...
    'colorMean', [0,0,0], 'colorError',[0,0,0]);
plot_utils_shade([stim_onset,stim_onset + stim_time], get(gca,'YLim')); hold on;
plot([1.25, 1.25], get(gca, 'YLim'), 'k--'); % onset of the second bar.
ylabel('\Delta F/F');
hold on;
ConfAxis('fontSize',10);
xlabel('time (sec)');

for ll = 1:1:2
    trial_this = trial_ID(epoch_index(ll),:); % trial_this has two dimensions.
    for ss = 1:length(trial_this)
                subplot(4,8, (ll - 1) * 8 + ss); % you also want to plot the
                %% trial this would be two dimensionalll.
                imagesc(stim_cont(:,:,abs(trial_this(ss)))'); colormap(gray);
                set(gca, 'XTick',[], 'YTick', [], 'clim',[-1,1],'YDir','normal');
                ConfAxis('fontSize',10);
                set(gca, 'XColor', color_bank(ll,:),'YColor', color_bank(ll,:));
                box on
                ylabel('space','Color', [0,0,0]);
                xlabel('time', 'Color', [0,0,0]);
                title(num2str(trial_this(ss)));        
    end
    % plot response of individual traces.
    subplot(4, 1,  subplot_idx_two_resp);
    resp_this_mean = resp_ave(:, epoch_index(ll));
    resp_this_std = resp_sem(:, epoch_index(ll));
    
    PlotXY_Juyue(resp_time,resp_this_mean,'errorBarFlag',1,'sem',resp_this_std,...
        'colorMean', color_bank(ll,:), 'colorError', color_bank(ll,:));
    plot_utils_shade([stim_onset,stim_onset + stim_time], [-0.1, 0.6]); hold on;
    plot([1.25, 1.25], get(gca, 'YLim'), 'k--'); % onset of the second bar.
    set(gca,'YLim', [-0.05,0.15]);
    ylabel('\Delta F/F');
    hold on;
    %         plot([1,1],get(gca,'YLim'), 'k--');
    ConfAxis('fontSize',10);
end
end