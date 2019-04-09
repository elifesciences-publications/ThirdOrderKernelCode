function SAC_Scintillator_Utils_AverageOverTimeFirst(resp, data_info, epoch_ID)
%% averaged over time.
f_resp = 15.625;
on_set = ceil(f_resp);
off_set = floor(f_resp * 9 + on_set);
[resp_over_time] = SAC_AverageResponseOverTime(resp, on_set, off_set);

%% use this resp_over time to do analysis... plot the individual fly... get omer's code? interesting...
[resp_over_dir, data_info_over_dir, epoch_ID_over_dir] = ...
    SAC_AverageResponse_By(resp_over_time, data_info,'dir','sub',epoch_ID);
% [resp_over_dir_pol, data_info_over_dir_pol, epoch_ID_over_dir_pol] = ...
%     SAC_AverageResponse_By(resp_over_dir, data_info_over_dir,'pol','sub', epoch_ID_over_dir);

[resp_over_dir_dt,  ~, ~] =  ...
    SAC_AverageResponse_By(resp_over_dir, data_info_over_dir,'dt','mean', epoch_ID_over_dir);
% [resp_over_dir_pol_dt, data_info_over_dir_pol_dt, epoch_ID_over_dir_pol_dt] = ...
%     SAC_AverageResponse_By(resp_over_dir_pol, data_info_over_dir_pol,'dt','mean', epoch_ID_over_dir_pol);

%%
n_time = 6;
n_dir = 2;
n_par = 2;
epoch_index = data_info.epoch_index;
[~, resp_ave, resp_sem] = SAC_GetAverageResponse(resp_over_time);
color_bank = [[1,0,0];[0,0,1]]; % for positive and negative.
lineStyle_bank = {':','-.'}; % for prefered and null

title_str = {'Positive', 'Negative'};
MakeFigure;
for pp = 1:1:n_par
    % two directions.
    subplot(2, 4, pp);
    color_use = color_bank(pp,:);
    for dd = 1:1:n_dir
        epoch_this = epoch_index(:, dd, pp);
        resp_ave_this = resp_ave(epoch_this);
        resp_sem_this = resp_sem(epoch_this);
        lineStyle_use = lineStyle_bank{dd};
        
        PlotXY_Juyue((1:n_time)'-1,resp_ave_this,'errorBarFlag',1,'sem',resp_sem_this,...
            'colorMean', color_use, 'colorError',color_use, 'lineStyle', lineStyle_use); hold on;
        set(gca,'YLim',[0,0.2]);
    end
    xlabel('\Delta t (frame)');
    ylabel('\DeltaF /F');
    title(title_str{pp});
    legend('null', 'preferred');
    ConfAxis('fontSize', 12);
end

%% next, averaged the polarity first.
epoch_index = data_info_over_dir.epoch_index;
[~, resp_ave, resp_sem] = SAC_GetAverageResponse(resp_over_dir);
subplot(2, 4,3);

for pp = 1:1:n_par
    color_use = color_bank(pp,:);
    epoch_this = epoch_index (:,pp);
    resp_ave_this = resp_ave(epoch_this);
    resp_sem_this = resp_sem(epoch_this);
    PlotXY_Juyue((1:n_time)'-1,resp_ave_this,'errorBarFlag',1,'sem',resp_sem_this,...
        'colorMean', color_use, 'colorError',color_use); hold on;
end
xlabel('\Delta t (frame)');
ylabel('\DeltaF /F');
legend('positive', 'negative');
title('null - preferred');
ConfAxis('fontSize', 12);
set(gca, 'YLim', [-0.1, 0.1]);


%% over all dt as well...
[resp_ind_cell_mat, resp_ave, resp_sem] = SAC_GetAverageResponse(resp_over_dir_dt);
subplot(2, 4, 4);
resp_ind_cell_mat_plot = squeeze(resp_ind_cell_mat)';
bar_scatter_plot_Juyue(resp_ave, resp_sem, resp_ind_cell_mat_plot, color_bank);
set(gca, 'YLim', [-0.02, 0.02]);
legend('positive', 'negative');
title('null - preferred (average over \Delta t)');
ylabel('\DeltaF /F');
ConfAxis('fontSize', 12);
end