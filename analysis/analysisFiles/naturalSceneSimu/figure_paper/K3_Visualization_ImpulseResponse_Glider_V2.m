function K3_impulse = K3_Visualization_ImpulseResponse_Glider_V2(K3, K3_individual, K3_noise, varargin)
% plot impulse response with the standard error of mean and shuffled
tMax = 64;
plot_flag = true;
dtxx_bank = 1:1:3;
dtxy_bank = -6:1:6;
n_dt_xy_plot_range = 5;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% first, compute. then plot  it. separate it.
[K3_impulse, K3_glider] = K3_Visualization_ImpulseResponse(K3, ...
    'tMax',tMax + 6,'tMaxShow', tMax,'dtxx_bank', dtxx_bank, 'dtxy_bank',dtxy_bank, 'plot_flag', false);
n_fly = size(K3_individual, 4);
K3_individual_glider = zeros([size(K3_glider), n_fly]);
for ff = 1:1:n_fly
    [~, K3_individual_glider(:,:,ff)] = K3_Visualization_ImpulseResponse(K3_individual(:,:,:,ff),...
        'tMax',tMax + 6,'tMaxShow', tMax, 'dtxx_bank', dtxx_bank, 'dtxy_bank',dtxy_bank, 'plot_flag', false);
end
% calculate the sem from individual flies
% K3_individual_glider_mean = mean(K3_individual_glider, 3);
K3_individual_glider_std = std(K3_individual_glider, 1,3);
K3_individual_glider_sem = K3_individual_glider_std./sqrt(n_fly);

% calculate the glider from the shifted kernel.
n_noise = size(K3_noise, 4);
K3_noise_glider = zeros([size(K3_glider), n_noise]);
for ii = 1:1:n_noise
    [~, K3_noise_glider(:,:,ii)] = K3_Visualization_ImpulseResponse(K3_noise(:,:,:,ii), ...
        'tMax',tMax + 6,'tMaxShow', tMax,'dtxx_bank', dtxx_bank, 'dtxy_bank',dtxy_bank, 'plot_flag', false);
end
K3_noise_glider_mean = mean(K3_noise_glider, 3);
K3_noise_glider_std = std(K3_noise_glider, 1, 3);
K3_mean_glider_z = (K3_glider - K3_noise_glider_mean)./K3_noise_glider_std;
% calculate
onetailed_p = 1 - normcdf(abs(K3_mean_glider_z));
p_two_tailed = 2 * onetailed_p;

%% start plotting..
% get the plotting function out.
if plot_flag
    % Change the whole plot process:
    n_page = length(dtxx_bank);
    tau_3_minus_tau_1_plot_value = cell(n_page, 1);
    tau_3_minus_tau_1_plot_index = cell(n_page, 1); % different number of thing.
    num_data_points = zeros(n_page, 1);
    x_tick_str = cell(n_page, 1);
    x_tick = cell(n_page, 1);
    page_title_str = cell(3, 1);
    for ii = 1:1:n_page
        tau_2_minus_tau_1_this = dtxx_bank(ii);
        if mod(tau_2_minus_tau_1_this, 2) == 1            % if odd number. you want the middle point think more..
            tau_3_minus_tau_1_plot_value{ii} = ...
                [bsxfun(@plus, (tau_2_minus_tau_1_this - 1)/2, -(n_dt_xy_plot_range - 1):1:0),...
                bsxfun(@plus, (tau_2_minus_tau_1_this + 1)/2, 0: n_dt_xy_plot_range - 1)];
        else
            tau_3_minus_tau_1_plot_value{ii} = ...
                [bsxfun(@plus, tau_2_minus_tau_1_this, -(n_dt_xy_plot_range):1:-1),...
                bsxfun(@plus, tau_2_minus_tau_1_this, 0: n_dt_xy_plot_range - 2)];
            
        end
        % from the value, you can get the index.
        num_data_points(ii) = length(tau_3_minus_tau_1_plot_value{ii});
        tau_3_minus_tau_1_plot_index{ii} = ismember(dtxy_bank, tau_3_minus_tau_1_plot_value{ii});
        
        x_tick_value = tau_3_minus_tau_1_plot_value{ii};
        x_tick{ii} = 1:1:length(tau_3_minus_tau_1_plot_value{ii});
        x_tick_str_num = (x_tick_value(x_tick{ii})/60) * 1000;
        x_tick_str{ii} = strsplit(num2str(x_tick_str_num,'%0-12.0f'));
        page_title_str{ii} = ['\tau2 - \tau1 = ', num2str(ii/60 * 1000, 3),'ms'];
        
    end
    
    %
    
    y_tick = [0,16,31,46];
    y_tick_str = strsplit(num2str([0,0.25,0.5,0.75]));
    
%     MakeFigure;
    maxValue = max(abs(K3_impulse(:)));
    for ii = 1:1:length(dtxx_bank)
        axes('Units', h(1, ii).Units,'Position', h(1, ii).Position);
        
        quickViewOneKernel(K3_impulse(:,tau_3_minus_tau_1_plot_index{ii},ii), 1, 'labelFlag', false, 'set_clim_flag', true, 'clim', maxValue);
        colorbar('off');
        %         if ii == 3
        %             c = colorbar
        %             curr_loc = c.Position;   curr_loc(1) = curr_loc(1) + 0.075;
        %             c.Position =  curr_loc;
        %         end
        if ii == 1
            ylabel('time since most recent bar [s]');
            set(gca, 'YTick',y_tick, 'YTickLabel', y_tick_str);
        else
            set(gca, 'YTick',y_tick, 'YTickLabel', []);
        end
        set(gca, 'XTick',[]);
        hold on
        %         tau3_tau1 = find(dtxy_bank == 0);
        %         plot([tau3_tau1,tau3_tau1], [0, tMax], 'k--')
        %         tau3_tau2 = find(dtxy_bank == dtxx_bank(ii));
        %         plot([tau3_tau2,tau3_tau2], [0, tMax], 'k--');
        %         tau1_tau2_middle = (dtxx_bank(ii)/2) + tau3_tau1;
        
        % get rid of the red line, but plot the red line... interesting..
        %         plot([tau1_tau2_middle,tau1_tau2_middle], [0, tMax], 'r--');
        title(page_title_str{ii});
        set(gca,'BoxStyle','full'); box on
        middle_line_x_pos = num_data_points(ii)/2 + 0.5;
        plot([middle_line_x_pos, middle_line_x_pos], get(gca, 'YLim'),'k--')
        % title, the middle line and the label.
        %         High_Corr_PaperFig_Utils_SmallFontSize;
                High_Corr_PaperFig_Utils_SmallFontSize;

        
    end
    
    maxVal = max(abs(K3_glider(:)))  * 1.5;
    for ii = 1:1:length(dtxx_bank)
        axes('Units', h(2, ii).Units, 'Position', h(2, ii).Position);
        PlotXvsY(x_tick{ii}, K3_glider(tau_3_minus_tau_1_plot_index{ii},ii), 'significance', p_two_tailed(tau_3_minus_tau_1_plot_index{ii},ii), 'graphType', 'bar');
        PlotErrorBar_Juyue(x_tick{ii}, K3_glider(tau_3_minus_tau_1_plot_index{ii},ii), K3_individual_glider_sem(tau_3_minus_tau_1_plot_index{ii},ii));
        set(gca,'YLim',[-maxVal, maxVal]);
        set(gca,'XLim',[1 - 0.5,length(tau_3_minus_tau_1_plot_value{ii}) + 0.5]);
        %         colormap(gray)
        if ii == 1
            ylabel(sprintf('mean filter strength \n o/c^3/s^4'));
            ax = gca; ax.YAxis.Exponent = 2;
        else
            set(gca, 'YTick',[-maxVal, maxVal], 'YTickLabel', []);
        end
        set(gca, 'Xtick',[]);
        set(gca,'XAxisLocation','origin','box', 'off');
        % xlabel
        xl = xlabel('\tau2 - \tau1 [ms]');
        yLim = get(gca, 'YLim');
        xl.Position = [middle_line_x_pos, yLim(1) * 1.5];
        % xtick
        for xx = 1:1:length(x_tick_str{ii})
            text(xx, yLim(1), x_tick_str{ii}(xx),'Rotation',90,'HorizontalAlignment','center');
        end
        High_Corr_PaperFig_Utils_SmallFontSize;
        set(gcf, 'Clipping', 'off');
    end
end
% plot the average over time.



end
