function resp_ave = Simu_Util_AveragePredictedSinewaveResp(resp, f_vals_bank, n_k)
plot_flag = false;

f_vals = repmat(f_vals_bank, [1, n_k, 2]);
n_epoch = length(f_vals(:));

[integrate_on_idx, integrate_off_idx, ~] = Simu_Util_AverageOverTime_CalOnOffIdx(1, f_vals);
resp_ave = zeros(n_epoch, 1);
for ee = 1:1:n_epoch
    resp_ave(ee) = mean(resp{ee}(integrate_on_idx(ee):integrate_off_idx(ee)));
end

if plot_flag
    MakeFigure;
    for ee = 1:1:10
        subplot(2,5,ee);
        plot(resp{ee});
        plot_utils_shade([integrate_on_idx(ee + 40),integrate_off_idx(ee + 40)], get(gca,'YLim')); hold on;
    end
end
end