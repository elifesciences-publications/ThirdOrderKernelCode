function SAC_AppMot_Plot_Utils_4D(resp, data_info, stim_info, trial_ID)
f_resp = 15.625;
f_stim = 60;
resp_time = (1:40)'/f_resp ;

stim_time = 60/f_stim;
stim_onset = 60/f_stim;
second_bar_onset = stim_onset + 15/f_stim;

%% how about not plotting the four 4D? not necessary. just along the dimesion.

epoch_index = data_info.epoch_index;
stim_cont = stim_info.epoch_cont;

n_lag = size(data_info.epoch_index, 4);
color_bank = [[1,0,0];[0,0,1]];
[~, resp_ave, resp_sem] = SAC_GetAverageResponse(resp);%% do averging 

%% The leading and laging contrast are the same
MakeFigure;
for cc_lead = 1:1:2
    for cc_lag = 1:1:2
        for dd = 1:1:2
            for ll = 1:1:n_lag
                
                % plot the stimulus.
                subplot(n_lag * 2,8,  (ll - 1)*8*2 + ((cc_lead-1)*2+cc_lag - 1)*2 + dd);
                trial_this = trial_ID(epoch_index(cc_lead, cc_lag, dd,ll));
                imagesc(stim_cont(:,:,trial_this)'); colormap(gray);
                set(gca, 'XTick',[], 'YTick', [], 'clim',[-1,1],'YDir','normal');
                ConfAxis('fontSize',10);
                set(gca, 'XColor', color_bank(dd,:),'YColor', color_bank(dd,:));
                box on
                ylabel('space' ,'Color', [0,0,0]);
                xlabel('time' ,'Color', [0,0,0]);
                title(num2str(trial_this));
                
                % plot response
                subplot(n_lag * 2, 4,  (ll - 1)*4*2 +4+ (cc_lead-1)*2+cc_lag);
                resp_this_mean = resp_ave(:, epoch_index(cc_lead, cc_lag, dd,ll));
                resp_this_std = resp_sem(:, epoch_index(cc_lead, cc_lag, dd,ll));
                PlotXY_Juyue(resp_time,resp_this_mean,'errorBarFlag',1,'sem',resp_this_std,...
                    'colorMean', color_bank(dd,:), 'colorError', color_bank(dd,:));
                plot_utils_shade([stim_onset,stim_onset + stim_time], [-0.1, 0.25]);
                set(gca,'YLim', [-0.1, 0.25]); hold on;
                plot([second_bar_onset, second_bar_onset], get(gca, 'YLim'), 'k--'); % onset of the second bar.
                xlabel('time (s)');
                ylabel('\Delta F/F');
                hold on;
                %         plot([1,1],get(gca,'YLim'), 'k--');
                ConfAxis('fontSize',10);
            end
        end
    end
end