function K2_impulse = K2_Visualization_ImpulseResponse_Glider(K2,K2_individual, K2_noise, varargin)
% plot impulse response with the standard error of mean and shuffled
tMax = 64;
plot_flag = true;
hor_inches = 2;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% change the plot to the most recent tau.
[K2_impulse, K2_glider] = K2_Visualization_ImpulseResponse(K2,'tMax',tMax + 6,'tMaxShow', tMax, 'dtxy_bank',dtxy_bank);
n_fly = size(K2_individual, 3);
K2_individual_glider = zeros([size(K2_glider), n_fly]);
for ff = 1:1:n_fly
    [~, K2_individual_glider(:,:,ff)] = K2_Visualization_ImpulseResponse(K2_individual(:,:,ff),'tMax',tMax + 6,'tMaxShow', tMax, 'dtxy_bank',dtxy_bank);
end
% calculate the sem from individual flies
% K2_individual_glider_mean = mean(K2_individual_glider, 3);
K2_individual_glider_std = std(K2_individual_glider, 1,3);
K2_individual_glider_sem = K2_individual_glider_std./sqrt(n_fly);

% calculate the glider from the shifted kernel.
n_noise = size(K2_noise, 3);
K2_noise_glider = zeros([size(K2_glider), n_noise]);
for ii = 1:1:n_noise
    [~, K2_noise_glider(:,:,ii)] = K2_Visualization_ImpulseResponse(K2_noise(:,:,ii),'tMax',tMax + 6,'tMaxShow', tMax,'dtxy_bank',dtxy_bank);
end
K2_noise_glider_mean = mean(K2_noise_glider, 3);
K2_noise_glider_std = std(K2_noise_glider, 1, 3);
K2_mean_glider_z = (K2_glider - K2_noise_glider_mean)./K2_noise_glider_std;
% calculate
onetailed_p = 1 - normcdf(abs(K2_mean_glider_z));
p_two_tailed = 2 * onetailed_p;
p_thresh = 0.05;
p_thresh_strict = 0.01;

%% start plotting..

if plot_flag
    % needs to
    x_tick_value_half = 0:3:length(find(dtxy_bank > 0));
    x_value = [-x_tick_value_half(end:-1:2), x_tick_value_half];
    x_tick = find(ismember(dtxy_bank, x_value));
    x_tick_str_num = (dtxy_bank(x_tick)/60);
    x_tick_str = strsplit(num2str(x_tick_str_num,3));
    y_tick = [0,16,31,46];
    y_tick_str = strsplit(num2str([0,0.25,0.5,0.75]));
    
    MakeFigure;
    subplot(3,3,1);
    subplot_num = {[1,4],[2,5],[3,6]};
    maxValue = max(abs(K2_impulse(:)));
    for ii = 1:1:1
        subplot(3,3,subplot_num{ii})
        quickViewOneKernel(K2_impulse, 1, 'labelFlag', false, 'set_clim_flag', true, 'clim', maxValue);
        colorbar('off');
        if ii == 3
            colorbar
            c = colorbar;
            curr_loc = c.Position;   curr_loc(1) = curr_loc(1) + 0.075;
            c.Position =  curr_loc;
        end
        if ii == 1
            ylabel('time since most recent bar [s]');
            set(gca, 'YTick',y_tick, 'YTickLabel', y_tick_str);
        else
            set(gca, 'YTick',y_tick, 'YTickLabel', []);
        end
        set(gca, 'XTick',x_tick, 'XTickLabel', []);
        hold on
        tau1_tau2_middle = length(dtxy_bank)/2 +0.5;
        plot([tau1_tau2_middle,tau1_tau2_middle], [0, tMax], 'k--');
        set(gca,'BoxStyle','full'); box on
        % title, the middle line and the label.
    end
    
    ax = gca;
    ax.Units = 'inches';
    currPos = ax.Position;
    ax.Position = [currPos(1), currPos(2), hor_inches , 1.25 * hor_inches];
    High_Corr_PaperFig_Utils_SmallFontSize;
    
    maxVal = max(abs(K2_glider(:)))  * 1.5;
    for ii = 1:1:1
        subplot(3,3,6 + ii);
        x_data = 1:length(dtxy_bank);
        PlotXvsY(x_data', K2_glider, 'significance', p_two_tailed(:,ii), 'graphType', 'bar');
        PlotErrorBar_Juyue(x_data', K2_glider, K2_individual_glider_sem);
        set(gca, 'XTick',x_tick, 'XTickLabel', x_tick_str,'YLim',[-maxVal, maxVal],'XLim',[1 - 0.5,length(dtxy_bank) + 0.5],...
            'Units','inches');
        xlabel('\tau2 - \tau1 [s]')
        if ii == 1
            ylabel(sprintf('mean filter strength \n o/c^2/s^3'));
        else
            set(gca, 'YTick',[-maxVal, maxVal], 'YTickLabel', []);
        end
    end
    
    ax = gca;
    currPos = ax.Position;
    ax.Position = [currPos(1), currPos(2), hor_inches , 0.68 * hor_inches ];
    set(gca,'XAxisLocation','origin','box', 'off');
    High_Corr_PaperFig_Utils_SmallFontSize;
end
end
