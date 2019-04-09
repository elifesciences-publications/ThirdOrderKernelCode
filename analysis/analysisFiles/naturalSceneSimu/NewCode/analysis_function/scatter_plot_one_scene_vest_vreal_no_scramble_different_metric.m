function corr_metric =  scatter_plot_one_scene_vest_vreal_no_scramble_different_metric(D, v_real, metric_mode, plot_flag)

v_2_this = squeeze(D(:,:,1));  
v_23_this = squeeze(D(:,:,3));  

switch metric_mode
    case 'std_ratio'
        std_v2  = std(v_2_this, 1,1);
        std_v23 = std(v_23_this, 1,1);
        corr_metric = std_v23./std_v2;

    case 'sig_noise_ratio'
        std_v2  = std(v_2_this, 1,1); mean_v2 = mean(v_2_this, 1);
        std_v23 = std(v_23_this, 1,1); mean_v3 = mean(v_23_this, 1);
        corr_metric = (std_v23./mean_v3)./(std_v2./mean_v2);

end

if plot_flag
    plot_scatter_plot_for_one_scene_vest_vreal_no_scramble(D, v_real, corr_metric)
end
