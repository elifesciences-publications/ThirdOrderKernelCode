function High_Corr_PaperFig_Utils_GliderVSKernel(glider_data, kernel_data, h)
axes('Units',h.Units, 'Position', h.Position);
%% combine the negative and positive together.
glider_resp_3o_mean_positive = (glider_data.mean(:,1) - glider_data.mean(:,2))/2; % averaged value.
glider_resp_3o_sem_positive = sqrt((glider_data.std(:,1).^2./glider_data.n(:,1) + glider_data.std(:,2).^2./glider_data.n(:,2))/4);
%% plot
MyScatter_DoubleErrBars(-kernel_data.mean, -glider_resp_3o_mean_positive, kernel_data.sem, glider_resp_3o_sem_positive);
xlim = get(gca, 'XLim');
ylim = get(gca, 'YLim');
lim_max = max([xlim(2), ylim(2)]);
lim_min = min([xlim(1), ylim(1)]);
lim = [lim_min, lim_max];
set(gca, 'XLim', lim , 'YLim', lim );
% fit...
[Err, P] = fit_2D_data(-kernel_data.mean, -glider_resp_3o_mean_positive, 'no');
lim_for_fit = 0.6 * lim;
yfit = lim_for_fit * P(1) + 0;
% yfit = xlim;
hold on
plot(lim_for_fit, yfit, 'k--');
set(gca, 'XAxisLocation', 'origin', 'YAxisLocation', 'origin');

% do a liniear fitting, take the errors into consideration.
xl = xlabel('Kernel Predicted Response (deg/s)'); xl.Position = [mean(lim), lim(1) * 1.5];
yl = ylabel('Measured Glider Response (deg/s)'); yl.Position = [lim(1)* 1.5, mean(lim)]; 
% title('Glider responses: Kernel Predictions versus Measured');
High_Corr_PaperFig_Utils_SmallFontSize;
% corr_kernel_behavior = corr(k3_resp_mean(:), glider_resp_3o_mean(:));
% text(xlim, ylim * 1.1, sprintf('corr %f', corr_kernel_behavior));
corr_kernel_behavior_positive = corr(kernel_data.mean(:), glider_resp_3o_mean_positive(:));
text(xlim(2) * 0.9, ylim (2) * 0.9, sprintf('r = %.2f', corr_kernel_behavior_positive));
end