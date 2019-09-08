function plot_scatter_plot_for_all_scene_vest_vreal_v2(D, v_real, n_noise)
which_velocity_bank = {'v2', 'v3', 'v23'};
scene_condition_str = {'natural scene','scramble phase'};
color_real = [[0,0,1];[0,1,0];[1,0,0]];
n_vel = length(v_real);
n_scene_condition = 2;
n_scene = size(D, 3);
MakeFigure;
%% whether v3 can improve v2 in both cases/
n_hor = size(D, 1);
for ss = 1:1:n_scene
    for jj = 1:1:n_scene_condition % two scenes
        for ii = 1:1:3
            if jj == 1
                v_est_this = squeeze(D(:,:,ss, ii, jj));
            else
                v_est_this = squeeze(D(:,:,ss, ii, jj: end));v_est_this = permute(v_est_this, [1, 3, 2]);
                v_est_this = reshape(v_est_this, [n_hor * n_noise, n_vel]);
            end
            % mean and std.
            mean_v = mean(v_est_this, 1); std_v = std(v_est_this, 1, 1);
            MyScatter_DoubleErrBars(v_real, mean_v, [], std_v , 'color',color_real(ii,:));
            plot(v_real, mean_v, 'color',color_real(ii,:));
        end
        plot(get(gca, 'xLim'),[0,0],'k--'); 
    end
end

end