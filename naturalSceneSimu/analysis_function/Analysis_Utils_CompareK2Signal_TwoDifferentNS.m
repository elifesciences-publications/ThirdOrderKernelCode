function Analysis_Utils_CompareK2Signal_TwoDifferentNS(which_kernel_type, spatial_average_flag)
distribution = 'binary';
synthetic_type_bank = {'ns_all_phase','sc_scramble_phase'};
vel_plot = 128;
% spatial_average_flag = false;
spatial_average_str = num2str(spatial_average_flag);
D = cell(2, 1);
for ii = 1:1:2
    synthetic_type = synthetic_type_bank{ii};
    % you can determine whether to average over space here.
    data = Analysis_Utils_GetData_OneRowAllPhase(synthetic_type, which_kernel_type,'spatial_average_flag', spatial_average_flag);
    D{ii} = Analysis_Utils_PlotVelR_Binary_OneRowAllPhase( data );
end
%%
n_scene = D{1}.n_scenes;
n_vel = size(D{1}.v2_mean,1);
v_real_range = D{1}.v_real_range(:,1);
% plot the mean response for different scene
MakeFigure;
color_bank = brewermap(n_vel, 'Spectral');
vel_plot_bank =[32, 128, 512, 1024];
std_ratio = zeros(length(vel_plot_bank), n_scene);
for vv = 1:1:length(vel_plot_bank)
    vel_plot_this = vel_plot_bank(vv);
    jj = find(vel_plot_this == v_real_range);
    v2_std = zeros(n_scene, 2);
    for ii = 1:1:2
        v2_std(:,ii) = D{ii}.v2_std(jj, :);
    end
    subplot(2,5,vv)
    std_ratio(vv,:) = v2_std(:,1)./v2_std(:,2);
    scatter(v2_std(:,2), v2_std(:, 1),'MarkerFaceColor', [0,0,0],'MarkerEdgeColor',  [0,0,0]);
    hold on
    ylabel('natural scene');xlabel('scrambled natural scene');
    title('std of estimated velocity ');
    maxVal = max(v2_std(:));
    plot([0,maxVal],[0,maxVal],'k--');
    %     set(gca, 'XLim',[0,1], 'YLim',[0,1])
    legend(sprintf('vel = %d', vel_plot_this))
    subplot(4, 5, 10 + vv);
    histogram(std_ratio(vv,:));
    xlabel('ratio ns/scramble')
    ratio_meaned = mean(std_ratio(vv,:));
    hold on
    plot([ratio_meaned, ratio_meaned],get(gca, 'YLim'),'r');
    title(sprintf('vel = %d', vel_plot_this))
end
std_ratio = zeros(n_vel, n_scene);
ratio_meaned = zeros(n_vel, 1);
ratio_std = zeros(n_vel, 1);
for jj = 1:1:n_vel
    v2_std = zeros(n_scene, 2);
    for ii = 1:1:2
        v2_std(:,ii) = D{ii}.v2_std(jj, :);
    end
    std_ratio(jj,:) = v2_std(:,1)./v2_std(:,2);
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
MySaveFig_Juyue(gcf,'Std_Ratio',[which_kernel_type, spatial_average_str], 'nFigSave',2,'fileType',{'png','fig'});

%%
MakeFigure;

for ss = 1:1:10 % plot the first 5 images...
    v_real_range = D{ii}.v_real_range(:,ss);
    v2_mean = D{ii}.v2_mean(:,ss);
    v2_mean_norm = v2_mean/max(v2_mean);
    subplot(2,1,1)
    plot(v_real_range, v2_mean,'color', [0.5,0.5,0.5]); hold on
    title(sprintf('%s mean response across different scenes', which_kernel_type));
    xlabel('image velocity');
    ylabel('mean signal across all phases [927 phases]');
    subplot(2,1,2)
    plot(v_real_range, v2_mean_norm,'color', [0.5,0.5,0.5]); hold on
    title(sprintf('%s mean response across different scenes - max signal is normalized', which_kernel_type));
    xlabel('image velocity');
    ylabel('mean signal across all phases [927 phases]');
end
MySaveFig_Juyue(gcf,'IndiviualImages_Mean',[which_kernel_type, spatial_average_str], 'nFigSave',1,'fileType',{'png'});

%%
MakeFigure;
color_bank = {[0,0,0],[1,0,0]};
% find the largest diferences
vel_plot = 128;
jj = find(vel_plot== v_real_range);
v2_std = zeros(n_scene, 2);
for ii = 1:1:2
    v2_std(:,ii) = D{ii}.v2_std(jj, :);
end
% got the largest 4?
ratio = v2_std(:,1)./v2_std(:,2);
[~, ss_sort] = sort(ratio,'descend');
for vv = 1:1:4
    subplot(2,2,vv);
    ss = ss_sort(vv);
    for ii = 1:1:2
        v_real_range = D{ii}.v_real_range(:,ss);
        v2_mean = D{ii}.v2_mean(:,ss);
        v2_std = D{ii}.v2_std(:,ss);
        hold on
        MyScatter_DoubleErrBars(v_real_range, v2_mean, [], v2_std , 'color',color_bank{ii});
        title('mean value and standard deviation from a scene');
        xlabel('image velocity');
        box off
    end
    ConfAxis
end
MySaveFig_Juyue(gcf,'IndiviualImages_MeanAndStd',[which_kernel_type, spatial_average_str], 'nFigSave',1,'fileType',{'png'});

% mean value is smaller. not symmetric. very interesting.
