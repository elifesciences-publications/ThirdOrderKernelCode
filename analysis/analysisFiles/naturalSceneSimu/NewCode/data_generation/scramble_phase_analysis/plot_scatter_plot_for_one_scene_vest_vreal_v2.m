function [std_ratio_scrambling_phase_v2_over_v2, std_ratio_v23_over_v2_ns, p_sig_std_ratio_v23_over_v2, std_ratio_v23_over_V2_scramble] = ...
    plot_scatter_plot_for_one_scene_vest_vreal_v2(D, v_real, n_noise, plot_flag)
which_velocity_bank = {'v2', 'v3', 'v23'};
scene_condition_str = {'natural scene','scramble phase'};
color_real = [[0,0,1];[0,1,0];[1,0,0]];
n_vel = length(v_real);
n_scene_condition = 2;
n_hor = size(D, 1);

%% quantify the improvement, reduction in the varaibility
%% you should set up a significance test, to test the the ratio of std...
std_ratio_v23_over_v2 = zeros(n_scene_condition, n_vel);
for jj = 1:1:n_scene_condition
    
    if jj == 1
        v_2_this = squeeze(D(:,:,1, jj));  std_v2  = std(v_2_this, 1,1);
        v_23_this = squeeze(D(:,:,3, jj));  std_v23 = std(v_23_this, 1,1);
        std_ratio_v23_over_v2(jj, :) = std_v23./std_v2;
    else
        v_2_this = squeeze(D(:,:,1, 2:end));
        % or you can calculate the distribution here.
        v_2_this = permute( v_2_this, [1, 3, 2]);
        v_2_this = reshape( v_2_this, [n_hor * n_noise, n_vel]);
        std_v2  = std(v_2_this, 1,1);
        
        v_23_this = squeeze(D(:,:,3, 2:end));
        v_23_this = permute( v_23_this, [1, 3, 2]);
        v_23_this = reshape( v_23_this, [n_hor * n_noise, n_vel]);
        std_v23  = std(v_23_this, 1,1);
        std_ratio_v23_over_v2(jj, :) = std_v23./std_v2;
        
    end
    std_ratio_v23_over_v2(jj, :) = std_v23./std_v2;
end
std_ratio_v23_over_v2_ns = std_ratio_v23_over_v2(1,:);
%% significance test.
std_ratio_v23_over_V2_scramble = zeros(n_noise, n_vel);
for nn = 1:1:n_noise
    v_2_this = squeeze(D(:,:,1, 1 + nn));  std_v2  = std(v_2_this, 1,1);
    v_23_this = squeeze(D(:,:,3, 1 + nn));  std_v23 = std(v_23_this, 1,1);
    std_ratio_v23_over_V2_scramble(nn, :) = std_v23./std_v2;
end

mean_std_ratio_v23_over_V2_scramble = mean(std_ratio_v23_over_V2_scramble, 1);
std_std_ratio_v23_over_V2_scramble = std(std_ratio_v23_over_V2_scramble, 1, 1); % assume it is true
normalized_std_ratio_v23_over_v2_ns = (std_ratio_v23_over_v2(1,:) - mean_std_ratio_v23_over_V2_scramble)./std_std_ratio_v23_over_V2_scramble;
p_sig_std_ratio_v23_over_v2 = zeros(1,  n_vel);


for vv = 1:1:n_vel
    [~, p_sig_std_ratio_v23_over_v2(vv)] = ztest(normalized_std_ratio_v23_over_v2_ns(vv), 0, 1);
end
%% scale test. how much could be improved by scrambling the phase.
std_scrambling_phase_v2_over_v2 = zeros(n_noise, n_vel);
std_v2_ns = zeros(1, n_vel);
for vv = 1:1:length(v_real)
    v2_ns = squeeze(D(:, vv, 1, 1));
    std_v2_ns(vv) = std(v2_ns);
    for nn = 1:1:n_noise
        v2_srambling_phase = squeeze(D(:,vv, 1, nn + 1));
        std_scrambling_phase_v2_over_v2(nn,vv) = std(v2_srambling_phase);
    end
end

std_ratio_scrambling_phase_v2_over_v2 = bsxfun(@rdivide, std_scrambling_phase_v2_over_v2, std_v2_ns);
mean_std_ratio_scrambling_phase_v2_over_v2 = mean(std_ratio_scrambling_phase_v2_over_v2, 1);

if plot_flag
    MakeFigure;
    %% whether v3 can improve v2 in both cases/
    v_real_ns = repmat(v_real, [n_hor, 1]);
    v_real_scramble = repmat(v_real, [n_hor, 1, n_noise]);
    for jj = 1:1:n_scene_condition % two scenes
        for ii = 1:1:3
            subplot(3,3,jj);
            if jj == 1
                v_est_this = squeeze(D(:,:,ii, jj));
                v_real_this = v_real_ns;
            else
                v_est_this = squeeze(D(:,:,ii, jj: end));
                v_real_this =  v_real_scramble;
            end
            
            scatter(v_real_this(:),v_est_this(:),10,'MarkerEdgeColor',color_real(ii,:),'MarkerFaceColor',color_real(ii,:),'LineWidth',1.5);
            hold on
            xlabel('image velocity'); ylabel('v');
            title(scene_condition_str{jj});
        end
        
        legend(which_velocity_bank)
        
        for ii = 1:1:3
            if jj == 1
                v_est_this = squeeze(D(:,:,ii, jj));
            else
                v_est_this = squeeze(D(:,:,ii, jj: end));v_est_this = permute(v_est_this, [1, 3, 2]);
                v_est_this = reshape(v_est_this, [n_hor * n_noise, n_vel]);
            end
            % mean and std.
            mean_v = mean(v_est_this, 1); std_v = std(v_est_this, 1, 1);
            MyScatter_DoubleErrBars(v_real + 10, mean_v, [], std_v , 'color',color_real(ii,:));
        end
        plot(get(gca, 'xLim'),[0,0],'k--');
    end
    
    %% plot the degree of decrement in noise.
    % v3 work on v2
    % scrambling work on v2
    % scrambing v3 as the control.
    color_bank = {[0,0,0],[1,0,0],[0.5,0.5,0.5]};
    std_ratio_v23_over_v2_all = cat(1,mean_std_ratio_scrambling_phase_v2_over_v2,std_ratio_v23_over_v2);
    
    subplot(3,3,3);
    plot_bar_std_ratio_v23_over_v2(v_real, std_ratio_v23_over_v2_all,p_sig_std_ratio_v23_over_v2, color_bank, scene_condition_str)
    
    %% plot the distribution of each.
    h_axes = repmat(struct('Units','normalized','Position', []), n_vel, 1);
    for vv = 1:1:n_vel
        axes_subplot = subplot(3, n_vel, n_vel + vv);
        h_axes(vv).Position= axes_subplot.Position;
    end
    plot_std_ratio_histogram(v_real, std_ratio_scrambling_phase_v2_over_v2, std_ratio_v23_over_V2_scramble, std_ratio_v23_over_v2(1, :),  color_bank, h_axes)
end
end