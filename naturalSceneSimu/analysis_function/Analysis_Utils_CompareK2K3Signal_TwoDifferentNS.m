function Analysis_Utils_CompareK2K3Signal_TwoDifferentNS(which_kernel_type, spatial_average_flag, varargin)
distribution = 'binary';
synthetic_type_bank = {'ns_all_phase','sc_scramble_phase'};
vel_plot = 128;
% vel_plot_bank =[32, 128, 512, 1024];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% spatial_average_flag = false;
spatial_average_str = num2str(spatial_average_flag);
D = cell(2, 1);
for ii = 1:1:2
    synthetic_type = synthetic_type_bank{ii};
    % you can determine whether to average over space here.
    data = Analysis_Utils_GetData_OneRowAllPhase(synthetic_type, which_kernel_type,'spatial_average_flag', spatial_average_flag);
    D{ii} = Analysis_Utils_PlotVelR_Binary_OneRowAllPhase( data );
end
%% look at individual scene. Whether third order kernel improves velocity estimation in natural scene and scrabled natural scene
ss_bank = [10,100,200, 225];
for xx = 1:1:length(ss_bank)
    ss = ss_bank(xx);
    plot_scatter_plot_for_one_scene_vest_vreal(D, ss)
    MySaveFig_Juyue(gcf,'v2_v23_ns_scramble',['scene#', num2str(ss), 'ave', num2str(spatial_average_str)], 'nFigSave',2,'fileType',{'png','fig'});
end
plot_std_ratio_v23_v2_across_scenes(D);
MySaveFig_Juyue(gcf,'v2_v23_ns_scramble',['across_scenes','ave', num2str(spatial_average_str)], 'nFigSave',2,'fileType',{'png','fig'});

%% quantify stadard deviation across different scenes.

%% find quantify the ratio...for one sceme..
% plot_scatter_plot_std_ratio(D, vel_plot_bank, 'v2')
% plot_scatter_plot_std_ratio(D, vel_plot_bank, 'v3')
% plot_scatter_plot_std_ratio(D, vel_plot_bank, 'v23')


end
function plot_std_ratio_v23_v2_across_scenes(D)
scene_condition_str = {'natural scene','scramble phase'};
n_vel = size(D{1}.v_real, 2);
n_scene = size(D{1}.v_real, 3);
n_scene_condition = 2;
std_radio_v23_over_v2 = zeros(n_vel, n_scene, n_scene_condition);
for jj = 1:1:n_scene_condition
    for ss = 1:1:n_scene
        v_2_this = squeeze(D{jj}.v2(:,:,ss));  std_v2  = std(v_2_this, 1,1);
        v_23_this = squeeze(D{jj}.v23(:,:,ss));  std_v23 = std(v_23_this, 1,1);
        std_radio_v23_over_v2(:,ss,jj) = std_v23./std_v2;
    end
end

improvement_in_ratio = 1 - std_radio_v23_over_v2;


%% first, plot the scatter plot, ns vs scramble across different velocities. similar and highly correlated
v_real_range = squeeze(D{1}.v_real(1,:,1));
MakeFigure;
for vv = 1:1:n_vel
    subplot(3,4,vv)
    scatter(improvement_in_ratio(vv,:,2), improvement_in_ratio(vv,:,1), 'k.');
    set(gca, 'XAxisLocation', 'origin', 'YAxisLocation', 'origin','XLim', [-1 1], 'YLim', [-1, 1]);
    title(sprintf('image velocity %d', v_real_range(vv)));
    text(0,-1,'improvement in scrambled scene', 'HorizontalAlignment', 'center');
    text(-1,-0.5,'improvement in natural scene', 'Rotation', 90,'VerticalAlignment', 'bottom');
end

%% second, Whether within scene improvement is always positive.
subplot(3,4,5)
averaged_improvement_accross_scenes = squeeze(mean(improvement_in_ratio, 2)); % averaged across different scenes
std_improvement_accross_scenes = squeeze(std(improvement_in_ratio, 0,2));
b = bar(v_real_range, averaged_improvement_accross_scenes); % whether this is larger on 1?
b(1).FaceColor = [0,0,0];
b(2).FaceColor = 'y';
ylabel('averaged improvement');
xlabel('image velocity');
set(gca, 'XTick', v_real_range, 'XTickLabel', strsplit(num2str(v_real_range)));
legend(scene_condition_str);
hold on;
% errorbar(repmat(v_real_range',1,2) , std_improvement_accross_scenes);

%% third, quantify the differencesss overall v23 improves more. Why there are so many negative values? not sure...
difference_in_improvement = improvement_in_ratio(:,:, 1) - improvement_in_ratio(:,:, 2);
mean_diff = mean(difference_in_improvement, 2);
std_diff = std(difference_in_improvement, 0, 2);
    
subplot(3,4,6)
for vv = 1:1:n_vel
    hold on
    scatter(v_real_range(vv) * ones(n_scene, 1), difference_in_improvement(vv, :),'k.');
end
title(' natural scene - scrambled scene');
ylabel('differences in improvement');
xlabel('image velocity');
set(gca, 'XTick', v_real_range, 'XTickLabel', strsplit(num2str(v_real_range)));


subplot(3,4,7)
MyScatter_DoubleErrBars(v_real_range,mean_diff, [], std_diff,'type','bar');
set(gca, 'XTick', v_real_range, 'XTickLabel', strsplit(num2str(v_real_range)));
title('natural scene - scrambled scene');
ylabel('averaged differences in improvement [1 - v23/v2]');
end
function plot_scatter_plot_for_one_scene_vest_vreal(D, ss)
which_velocity_bank = {'v2', 'v3', 'v23'};
scene_condition_str = {'natural scene','scramble phase'};
color_real = [[0,0,1];[0,1,0];[1,0,0]];
n_vel = size(D{1}.v_real, 2);
n_scene_condition = 2;

MakeFigure;
%% whether v3 can improve v2 in both cases/
for jj = 1:1:n_scene_condition % two scenes
    for ii = 1:1:3
        subplot(3,3,jj);
        v_real_this = D{jj}.v_real(:,:,ss); v_est_this = squeeze(D{jj}.(which_velocity_bank{ii})(:,:,ss));
        scatter(v_real_this(:),v_est_this(:),10,'MarkerEdgeColor',color_real(ii,:),'MarkerFaceColor',color_real(ii,:),'LineWidth',1.5);
        hold on
        xlabel('image velocity'); ylabel('v');
        title(scene_condition_str{jj});
    end
    legend(which_velocity_bank)
    for ii = 1:1:3
        v_real_this = D{jj}.v_real(:,:,ss); v_est_this = squeeze(D{jj}.(which_velocity_bank{ii})(:,:,ss));
        % mean and std.
        mean_v = mean(v_est_this, 1); std_v = std(v_est_this, 1, 1);
        MyScatter_DoubleErrBars(v_real_this(1, :) + 15, mean_v, [], std_v , 'color',color_real(ii,:));
    end
    plot(get(gca, 'xLim'),[0,0],'k--');
end
%% quantify the improvement, reduction in the varaibility


std_radio_v23_over_v2 = zeros(n_scene_condition, n_vel);
for jj = 1:1:n_scene_condition
    % calculate the ratio of standard deviation
    v_2_this = squeeze(D{jj}.v2(:,:,ss));  std_v2  = std(v_2_this, 1,1);
    v_23_this = squeeze(D{jj}.v23(:,:,ss));  std_v23 = std(v_23_this, 1,1);
    std_radio_v23_over_v2(jj, :) = std_v23./std_v2;
end
subplot(3,3,3)
b = bar(D{1}.v_real(1,:,1), std_radio_v23_over_v2');
b(1).FaceColor = [0,0,0];
b(2).FaceColor= 'y';
title('std ratio v23/v2');
legend(scene_condition_str);
hold on
plot(get(gca, 'XLim'),[1,1],'k--');

for ii = 1:1:3
    subplot(3,3,ii + 3);
    v_real_this = D{1}.v_real(:,:,ss); v_est_this = squeeze(D{1}.(which_velocity_bank{ii})(:,:,ss));
    scatter(v_real_this(:),v_est_this(:),10,'MarkerEdgeColor',color_real(ii,:),'MarkerFaceColor',color_real(ii,:),'LineWidth',1.5);
    xlabel('image velocity'); ylabel(which_velocity_bank{ii});
    v_real_this = D{2}.v_real(:,:,ss); v_est_this = squeeze(D{2}.(which_velocity_bank{ii})(:,:,ss));
    hold on
    scatter(v_real_this(:), v_est_this(:),'y.');
    xlabel('image velocity'); ylabel(which_velocity_bank{ii});
    legend(scene_condition_str)
end
% summarize the decrease of standard deviation. two scene condition


end
function plot_scatter_plot_std_ratio(D, vel_plot_bank, which_velocity)
n_scene = D{1}.n_scenes;
n_vel = size(D{1}.v2_mean,1);
v_real_range = D{1}.v_real_range(:,1);
% plot the mean response for different scene
MakeFigure;
color_bank = brewermap(n_vel, 'Spectral');
std_ratio = zeros(length(vel_plot_bank), n_scene);
for kk = 1:1:length(vel_plot_bank)
    vel_plot_this = vel_plot_bank(kk);
    jj = find(vel_plot_this == v_real_range);
    v_std = zeros(n_scene, 2);
    for ii = 1:1:2
        v_std(:,ii) = D{ii}.(sprintf('%s_std',which_velocity))(jj, :);
    end
    subplot(2,5,kk)
    std_ratio(kk,:) = v_std(:,1)./v_std(:,2);
    scatter(v_std(:,2), v_std(:, 1),'MarkerFaceColor', [0,0,0],'MarkerEdgeColor',  [0,0,0]);
    hold on
    ylabel('natural scene');xlabel('scrambled natural scene');
    title('std of estimated velocity ');
    maxVal = max(v_std(:));
    plot([0,maxVal],[0,maxVal],'k--');
    %     set(gca, 'XLim',[0,1], 'YLim',[0,1])
    legend(sprintf('vel = %d', vel_plot_this))
    subplot(4, 5, 10 + kk);
    histogram(std_ratio(kk,:));
    xlabel('ratio ns/scramble')
    ratio_meaned = mean(std_ratio(kk,:));
    hold on
    plot([ratio_meaned, ratio_meaned],get(gca, 'YLim'),'r');
    title(sprintf('vel = %d', vel_plot_this))
end
std_ratio = zeros(n_vel, n_scene);
ratio_meaned = zeros(n_vel, 1);
ratio_std = zeros(n_vel, 1);
for jj = 1:1:n_vel
    v_std = zeros(n_scene, 2);
    for ii = 1:1:2
        v_std(:,ii) = D{ii}.(sprintf('%s_std',which_velocity))(jj, :);
    end
    std_ratio(jj,:) = v_std(:,1)./v_std(:,2);
    ratio_meaned(jj) = mean(std_ratio(jj,:));
    ratio_std(jj) = std(std_ratio(jj,:));
end
subplot(4, 5, 15); % do you want to do all this across different velocity?
histogram(std_ratio(:)); % get it for four different velocities. all together...
xlabel('ratio ns/scramble'); title('all velocity');
subplot(4,5,[16:17]);
% plot the mean ratio over different velocity.
% scatter(v_real_range, ratio_meaned,'filled');
MyScatter_DoubleErrBars(v_real_range, ratio_meaned, [], ratio_std , 'color',[0,0,0]);
xlabel('image velocity');
ylabel('mean ratio ns/scramble');
ylim = get(gca, 'YLim');
set(gca, 'YLim',[0,ylim(2)]);
end