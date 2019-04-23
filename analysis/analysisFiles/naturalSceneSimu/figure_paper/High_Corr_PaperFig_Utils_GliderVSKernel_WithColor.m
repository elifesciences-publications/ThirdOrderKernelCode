function High_Corr_PaperFig_Utils_GliderVSKernel_WithColor(glider_data, kernel_data, h)
sig_thresh = 0.05/13;
axes('Units',h.Units, 'Position', h.Position);
%% combine the negative and positive together.
glider_resp_3o_mean_positive = (glider_data.mean(:,1) - glider_data.mean(:,2))/2; % averaged value.
glider_resp_3o_sem_positive = sqrt((glider_data.std(:,1).^2./glider_data.n(:,1) + glider_data.std(:,2).^2./glider_data.n(:,2))/4);
%% plot
%% one plot a time..
%% 
% colorbank = {[1,0,0], [0,1,0], [0,0,1],[0,0,0]};
colorbank = {[0,0,0],[0,0,0],[0,0,0],[0,0,0]};
for ii = 1:1:length(kernel_data.mean)
    glider_sig = (glider_data.p(ii,1) < sig_thresh) | (glider_data.p(ii,2) < sig_thresh);
    kernel_sig = kernel_data.p(ii) < sig_thresh;
    if glider_sig && kernel_sig
        color_this = colorbank{1};
    elseif glider_sig 
        color_this = colorbank{2};
    elseif kernel_sig
        color_this = colorbank{3};
    else
        color_this = colorbank{4};
    end
    MyScatter_DoubleErrBars(-kernel_data.mean(ii), -glider_resp_3o_mean_positive(ii), kernel_data.sem(ii), glider_resp_3o_sem_positive(ii),'color', color_this);
    hold on
end
%%
xlim = get(gca, 'XLim');
ylim = get(gca, 'YLim');
lim_max = max([xlim(2), ylim(2)]);
lim_min = min([xlim(1), ylim(1)]);
lim = [lim_min, lim_max];
set(gca, 'XLim', lim , 'YLim', lim );
% The data is flipped here. when illustrator, do not foget to flip them
% back.

[Err, P] = fit_2D_data(-kernel_data.mean, -glider_resp_3o_mean_positive, 'no');
lim_for_fit = lim;

% yfit = lim_for_fit * P(1) + 0;
yfit_unity = lim_for_fit; % unity line??
yfit_fitting =  lim_for_fit * P(1) + P(2);
hold on
plot(lim_for_fit, yfit_unity, 'k--');
plot(lim_for_fit, yfit_fitting, 'k--');
set(gca, 'XAxisLocation', 'origin', 'YAxisLocation', 'origin');
set(gca, 'XLim', [-5, 20]);
set(gca, 'YLim', [-5, 20]);
% do a liniear fitting, take the errors into consideration.
xl = xlabel('Kernel Predicted Response [\circ/s]'); xl.Position = [mean(lim) * 3, lim(1) * 1.5];
yl = ylabel('Measured Glider Response [\circ/s]'); yl.Position = [lim(1)-5, -5]; set(yl,'Rotation',90)
% title('Glider responses: Kernel Predictions versus Measured');
% High_Corr_PaperFig_Utils_SmallFontSize;
% corr_kernel_behavior = corr(k3_resp_mean(:), glider_resp_3o_mean(:));
% text(xlim, ylim * 1.1, sprintf('corr %f', corr_kernel_behavior));
corr_kernel_behavior_positive = corr(kernel_data.mean(:), glider_resp_3o_mean_positive(:));
text(xlim(2) * 0.9, ylim (2) * 0.9, sprintf('r = %.2f', corr_kernel_behavior_positive));
end