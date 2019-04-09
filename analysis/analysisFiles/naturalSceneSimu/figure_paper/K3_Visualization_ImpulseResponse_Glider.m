function K3_impulse = K3_Visualization_ImpulseResponse_Glider(K3,K3_individual, K3_noise, varargin)
% plot impulse response with the standard error of mean and shuffled
tMax = 64;
plot_flag = true;
hor_inches = 2;
dtxx_bank = 1:1:3;
dtxy_bank = -6:1:6;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% change the plot to the most recent tau.
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
p_thresh = 0.05;
p_thresh_strict = 0.01;

%% start plotting..

if plot_flag
    x_tick_value_half = 0:3:length(find(dtxy_bank > 0));
    x_value = [-x_tick_value_half(end:-1:2), x_tick_value_half];
    x_tick = find(ismember(dtxy_bank, x_value));
    
    x_tick_str_num = (dtxy_bank(x_tick)/60) * 1000;
    x_tick_str = strsplit(num2str(x_tick_str_num,3));
    y_tick = [0,16,31,46];
    y_tick_str = strsplit(num2str([0,0.25,0.5,0.75]));
    
    MakeFigure;
    subplot(3,3,1);
    subplot_num = {[1,4],[2,5],[3,6]};
    maxValue = max(abs(K3_impulse(:)));
    for ii = 1:1:length(dtxx_bank)
        subplot(3,3,subplot_num{ii})
        quickViewOneKernel(K3_impulse(:,:,ii), 1, 'labelFlag', false, 'set_clim_flag', true, 'clim', maxValue);
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
        set(gca, 'XTick',x_tick, 'XTickLabel', []);
        hold on
        tau3_tau1 = find(dtxy_bank == 0);
        plot([tau3_tau1,tau3_tau1], [0, tMax], 'k--')
        tau3_tau2 = find(dtxy_bank == dtxx_bank(ii));
        plot([tau3_tau2,tau3_tau2], [0, tMax], 'k--');
        tau1_tau2_middle = (dtxx_bank(ii)/2) + tau3_tau1;
        plot([tau1_tau2_middle,tau1_tau2_middle], [0, tMax], 'r--');
        title(['\tau3 - \tau1 = ', sprintf('%d',dtxx_bank(ii))]);
        set(gca,'BoxStyle','full'); box on
        % title, the middle line and the label.
        High_Corr_PaperFig_Utils_SmallFontSize;
        
    end
    
    maxVal = max(abs(K3_glider(:)))  * 1.5;
    for ii = 1:1:length(dtxx_bank)
        subplot(3,3,6 + ii);
        x_data = 1:length(dtxy_bank);
        PlotXvsY(x_data', K3_glider(:,ii), 'significance', p_two_tailed(:,ii), 'graphType', 'bar');
        PlotErrorBar_Juyue(x_data', K3_glider(:,ii), K3_individual_glider_sem(:,ii));
            set(gca, 'XTick',x_tick, 'XTickLabel', x_tick_str);
            xlabel('\tau2 - \tau1 [ms]')
        set(gca,'YLim',[-maxVal, maxVal]);
        set(gca,'XLim',[1 - 0.5,length(dtxy_bank) + 0.5]);
        %         colormap(gray)
        if ii == 1
            ylabel(sprintf('mean filter strength \n o/c^3/s^4'));
        else
            set(gca, 'YTick',[-maxVal, maxVal], 'YTickLabel', []);
        end
        set(gca,'XAxisLocation','origin','box', 'off');
        High_Corr_PaperFig_Utils_SmallFontSize;
    end
    
    
end
% plot the average over time.



end
