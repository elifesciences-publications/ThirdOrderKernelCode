function evaluate_current_solution(n_highest_moments, solution_path, syn_path, data_set_str, ...
    image_statistics_flag, solution_statistics_flag, syn_image_statistics_flag,...
    plot_image_vs_solution_moments_flag, plot_image_vs_solution_moments_long_sample_flag,...
    plot_image_vs_syn_image_moments_flag,plot_image_vs_syn_image_correlations_flag,...
    symmetrize_flag, zero_mean_flag, lower_bound_flag, prefixed_discretization_flag,...
    syn_path_selective)
plot_image_vs_syn_image_used_moments_flag = 0;
n_points_in_scatter = 1000;
%%
if ~exist(data_set_str,'dir')
    mkdir(data_set_str);
    %% also, copy the image data into the folder.
    %     copyfile('image_moments_correlations.mat', fullfile(data_set_str, 'image_moments_correlations.mat'));
end
cd(data_set_str);
%%
N = 32;
K = 1;
%%
if image_statistics_flag
    image_path = 'statiche0';
    data_image = compute_statistics_moments_correlation_all(image_path,'image','N',N,...
        'symmetrize_flag',symmetrize_flag,...
        'zero_mean_flag',zero_mean_flag,...
        'lower_bound_flag',lower_bound_flag,...
        'prefixed_discretization_flag',prefixed_discretization_flag,...
        'solution_path',solution_path);
    save('image_moments_correlations','data_image');
    
    data_image_correlation = compute_statistics_moments_correlation_all(image_path,'pairwise_correlation','symmetrize_flag',symmetrize_flag,'zero_mean_flag', zero_mean_flag, 'lower_bound_flag',lower_bound_flag);
    save('image_correlations','data_image_correlation');
end

%%
% solution_path = 'statiche0syn_pixel_dist_ivar_solution';
if solution_statistics_flag
    data_solution = compute_statistics_moments_correlation_all(solution_path,'solution','n_highest_moments',n_highest_moments,'K', K);
    save('solution_moments_correlations','data_solution');
    
    %
    %     data_syn_image_long_sample = compute_statistics_moments_correlation_all(solution_path,'long_samples',...
    %         'symmetrize_flag',symmetrize_flag,'zero_mean_flag', zero_mean_flag,'lower_bound_flag',lower_bound_flag, ...
    %         'K', K,'n_highest_moments',n_highest_moments);
    %     save('syn_image_longSamples','data_syn_image_long_sample');
end
%%
% syn_path = 'statiche0syn_pixel_dist_ivar';
if syn_image_statistics_flag
    % it does not make much difference.  but it is a good confirmation for
    % me.
    data_syn_image_selective = compute_statistics_moments_correlation_all(syn_path_selective,'syn_image','solution_path',solution_path,...,
        'symmetrize_flag',symmetrize_flag,'zero_mean_flag', zero_mean_flag);
    save('syn_image_moments_correlations_downsampled_selective','data_syn_image_selective');
    
    data_syn_image = compute_statistics_moments_correlation_all(syn_path,'syn_image','solution_path',solution_path,...,
        'symmetrize_flag',symmetrize_flag,'zero_mean_flag', zero_mean_flag);
    save('syn_image_moments_correlations_downsampled','data_syn_image');
    
    %     % PARTII calculate the pairwise correlations.
    %     data_syn_image_correlation = compute_statistics_moments_correlation_all(syn_path,'pairwise_correlation',...
    %         'symmetrize_flag',symmetrize_flag,'zero_mean_flag', zero_mean_flag);
    %     save('syn_image_correlations','data_syn_image_correlation');
end

%% image and solution
if plot_image_vs_solution_moments_flag
    load('image_moments_correlations');
    load('solution_moments_correlations');
    
    %%TO DO. For scatter plot, plot limited number of points in scatter_
    %%plot. 
    %% randomly choose 200 points.
    n_use = 200;
    n = size(data_image, 2) * size(data_image, 3);
    rng(0)
    tmp = randperm(n); plot_ind = tmp(1:n_use);
    
    scatter_plot(data_image, data_solution, 'MED', plot_ind);
    MySaveFig_Juyue(gcf, 'performance_of_current_model_solution_scatter_200',data_set_str, 'nFigSave',2,'fileType',{'eps','pdf'});
    %     MySaveFig_Juyue(gcf, 'performance_of_current_model_solution',data_set_str, 'nFigSave',2,'fileType',{'eps','fig'});
    density_plot(data_image, data_solution, 'med mode', []);
    MySaveFig_Juyue(gcf, 'performance_of_current_model_solution_density',data_set_str, 'nFigSave',2,'fileType',{'png','fig'});
end


%%
if plot_image_vs_solution_moments_long_sample_flag
    
    load('image_moments_correlations');
    load('syn_image_longSamples');
    
    statistics_str = {'mean','variance','skew','kurtosis'};
    MakeFigure;
    for ii = 1:1:4
        subplot(2,4,ii)
        pixel_statistics_image = data_image(ii, :, :);
        pixel_statistics_solution = data_syn_image_long_sample(ii, :, :);
        scatter(pixel_statistics_image(:), pixel_statistics_solution(:),'k.');
        xlabel('image');
        ylabel('long samples');
        title(statistics_str{ii});
        daspect([1, 1, 1]);
        axis tight
        ConfAxis
    end
    MySaveFig_Juyue(gcf, 'performance_of_current_model_solution_long_sample',data_set_str, 'nFigSave',2,'fileType',{'png','fig'});
    
end
%% also the syn image and image.
if plot_image_vs_syn_image_moments_flag
    % pixel statistics/
    load('image_moments_correlations');
    load('syn_image_moments_correlations_downsampled.mat');
    
    ylabel_str = 'synthetic image random';
    scatter_plot(data_image, data_syn_image, ylabel_str,[])
    MySaveFig_Juyue(gcf, 'performance_of_syn_image_moments_scatter',data_set_str, 'nFigSave',2,'fileType',{'png','fig'});
    density_plot(data_image, data_syn_image, ylabel_str, [])
    MySaveFig_Juyue(gcf, 'performance_of_syn_image_moments_density',data_set_str, 'nFigSave',2,'fileType',{'png','fig'});
    

    ylabel_str = 'synthetic image selective';
    load('syn_image_moments_correlations_downsampled_selective.mat');
    scatter_plot(data_image, data_syn_image_selective, ylabel_str,[])
    MySaveFig_Juyue(gcf, 'performance_of_syn_selective_image_moments_scatter',data_set_str, 'nFigSave',2,'fileType',{'png','fig'});
    density_plot(data_image, data_syn_image_selective, ylabel_str, [])
    MySaveFig_Juyue(gcf, 'performance_of_syn_selective_image_moments_density',data_set_str, 'nFigSave',2,'fileType',{'png','fig'});
    
end

if plot_image_vs_syn_image_used_moments_flag
    [image_sequence, row_sequence] = get_image_sequence_used_in_velocity_estimation();
%     load('D:\JuyueLog\2018_12_18_SelectiveNonSelectiveSamples\tmp.mat')
    plot_ind = sub2ind([251, 421], row_sequence,image_sequence);
    
    load('image_moments_correlations');
    load('syn_image_moments_correlations_downsampled.mat');
    ylabel_str = 'used synthetic image random';
    scatter_plot(data_image, data_syn_image, ylabel_str, plot_ind);
    MySaveFig_Juyue(gcf, 'performance_of_syn_image_moments_scatter_used',data_set_str, 'nFigSave',2,'fileType',{'png','fig'});
    density_plot(data_image, data_syn_image, ylabel_str, plot_ind);
    MySaveFig_Juyue(gcf, 'performance_of_syn_image_moments_density_used',data_set_str, 'nFigSave',2,'fileType',{'png','fig'});
    
    load('syn_image_moments_correlations_downsampled_selective.mat');
    ylabel_str = 'used synthetic image selective';
    scatter_plot(data_image, data_syn_image_selective, ylabel_str, plot_ind);
    MySaveFig_Juyue(gcf, 'performance_of_syn_selective_image_moments_scatter_used',data_set_str, 'nFigSave',2,'fileType',{'png','fig'});
    density_plot(data_image, data_syn_image_selective, ylabel_str, plot_ind);
    MySaveFig_Juyue(gcf, 'performance_of_syn_selective_image_moments_density_used',data_set_str, 'nFigSave',2,'fileType',{'png','fig'});
 
end
%%
if plot_image_vs_syn_image_correlations_flag
    
    load('image_correlations.mat');
    load('syn_image_correlations');
    statistics_str = {'spatial correlation'};
    MakeFigure;
    subplot(2,2,1);
    pixel_statistics_image = data_image_correlation(:);
    pixel_statistics_solution = data_syn_image_correlation(:);
    scatter(pixel_statistics_image(:), pixel_statistics_solution(:),'k.');
    xlabel('image');
    ylabel('synthetic image');
    title(statistics_str{1});
    
    xlim = get(gca,'XLim'); ylim = get(gca, 'YLim');
    lim_max = max([xlim(2), ylim(2)]); lim_min = min([xlim(1), ylim(1)]);
    hold on
    plot([lim_min, lim_max],[lim_min, lim_max],'k--');
    daspect([1, 1, 1]);
    ConfAxis
    MySaveFig_Juyue(gcf, 'performance_of_syn_image_correlation',data_set_str, 'nFigSave',2,'fileType',{'png','fig'});
end

cd ..
end
%% What is wrong with those images???? That is a harder problem... accept what it is...
%% get outof the folder.
function Y = get_percentile_edge(X, N)
Y = zeros(N, 1);
p = linspace(0,100,N);
for ii = 1:1:N
    Y(ii) = prctile(X, p(ii));
end
end

function [image_sequence, row_sequence] = get_image_sequence_used_in_velocity_estimation()
which_file_to_use_bank = [1, 2, 3, 4];
n = 2000 * length(which_file_to_use_bank );
image_sequence = zeros(n, 1);
row_sequence = zeros(n, 1);

count = 1;
for ii = 1:1:length(which_file_to_use_bank)
    which_file_to_use = which_file_to_use_bank(ii);
    data_sequence_image = Generate_VisualStim_And_VelEstimation_Utils_LoadRandomSequence(...
        0, 0,[], 'image', ...
        'which_file_to_use', which_file_to_use);
    
    for jj = 1:1:421
        image_ID = data_sequence_image.image_sequence(jj);
        m = length(data_sequence_image.image_row_pos_sequence{image_ID});
        
        image_sequence(count:count + m - 1) = image_ID;
        row_sequence(count:count + m - 1) = data_sequence_image.image_row_pos_sequence{image_ID};
        count = count + m;
    end
end

end
function density_plot(data_image, data_solution, ylabel_str, plot_ind)

statistics_str = {'mean','variance','skew','kurtosis', 'correlation_1','correlation_2','correlation_3'};
N = 30;
anchor_point = {[-0.1,0,0.1], [0.1,0.2,0.3], [-1, 0, 1, 2], [3,6,9, 12, 15]};
MakeFigure;
for ii = 1:1:4
    subplot(2,4,ii)
    pixel_statistics_image = data_image(ii, :, :);
    pixel_statistics_solution = data_solution(ii, :, :);
    
    if ~isempty(plot_ind)
        pixel_statistics_image =  pixel_statistics_image(plot_ind);
        pixel_statistics_solution = pixel_statistics_solution(plot_ind);
    end
    % calculate density
    %         edges = get_percentile_edge([pixel_statistics_image(:);pixel_statistics_solution(:)], N);
    %         edges_image = get_percentile_edge([pixel_statistics_image(:)], N);
    %         edges_med = get_percentile_edge([pixel_statistics_solution(:)], N);
    %         edges_image = [min(pixel_statistics_image(:)), linspace(prctile(pixel_statistics_image(:), 1),prctile(pixel_statistics_image(:), 99), N), max(pixel_statistics_image(:))];
    %         edges_med = [min(pixel_statistics_solution(:)), linspace(prctile(pixel_statistics_solution(:), 1),prctile(pixel_statistics_solution(:), 99), N), max(pixel_statistics_solution(:))];
    min_value = min([pixel_statistics_image(:); pixel_statistics_solution(:)]);
    max_value = max([pixel_statistics_image(:); pixel_statistics_solution(:)]);
    low_1     = prctile([pixel_statistics_image(:); pixel_statistics_solution(:)], 1);
    high_1    = prctile([pixel_statistics_image(:); pixel_statistics_solution(:)], 99);
    edges = [min_value, linspace(low_1, high_1, N), max_value];
    [prob_value,x_edges,~] = histcounts2(pixel_statistics_image, pixel_statistics_solution,...
        edges,edges, 'Normalization', 'Probability');
    
    %% plot the log scale.
    X = prob_value';
    imAlpha = ones(size(X));
    imAlpha(isnan(X))=0;
    imagesc(log(X),'AlphaData',imAlpha);
    
    % X label
    vq = interp1(edges, 0:length(x_edges) - 1,anchor_point{ii});
    set(gca, 'XTick', vq, 'XTickLabel',num2str(anchor_point{ii}', 3));
    set(gca, 'YTick', vq, 'YTickLabel',num2str(anchor_point{ii}', 3));
    x_lim =  get(gca, 'XLim');
    set(gca, 'YLim', x_lim);
    
    % color. use another one?
    mymap = brewermap(100, 'RdPu');
    mymap(1,:) = [1,1,1];
    colormap(mymap); %%
    
    clim = [-max(X(:)), max(X(:))];
    set(gca, 'CLim', [-inf,log(clim(2))]);
    
    % reverse
    set(gca, 'Ydir','normal');
    colorbar;
    ConfAxis
    box on
    axis tight
    axis equal
    title(statistics_str{ii})
    if ii == 1
        ylabel(ylabel_str);
    end
    
    % correlation and slop
    text(x_lim(end), x_lim(end)* 1.2, ['c:' num2str(corr(pixel_statistics_image(:), pixel_statistics_solution(:)),3)], 'fontSize', 15);
    slope = [ones(length(pixel_statistics_image(:)),1),pixel_statistics_image(:)]\pixel_statistics_solution(:);
    text(x_lim(end), x_lim(end) * 1.3, ['s:', num2str(slope(2),3)], 'fontSize', 15);
    
end
end

function scatter_plot(data_image, data_syn_image, ylabel_str, plot_ind)

statistics_str = {'mean','variance','skew','kurtosis', 'correlation_1','correlation_2','correlation_3'};
MakeFigure;
for ii = 1:1:4
    subplot(2,4,ii)
    
    pixel_statistics_image = data_image(ii, :, :);
    pixel_statistics_solution = data_syn_image(ii, :, :);
    
    if isempty(plot_ind)
        scatter(pixel_statistics_image(:), pixel_statistics_solution(:),'k.');
    else
        scatter(pixel_statistics_image(plot_ind), pixel_statistics_solution(plot_ind),'k.');
    end
    
    xlabel('image');
    ylabel(ylabel_str);
    title(statistics_str{ii});
    
    xlim = get(gca,'XLim'); ylim = get(gca, 'YLim');
    lim_max = max([xlim(2), ylim(2)]); lim_min = min([xlim(1), ylim(1)]);
    
    daspect([1, 1, 1]);
    ConfAxis
    
    axis tight
    x_lim = get(gca, 'XLim');
    set(gca, 'XLim', x_lim, 'YLim', x_lim);
    hold on
    plot(x_lim,x_lim,'k--');
    
    text(x_lim(end), x_lim(end), ['c:',num2str(corr(pixel_statistics_image(:), pixel_statistics_solution(:)),3)]);
    slope = [ones(length(pixel_statistics_image(:)),1),pixel_statistics_image(:)]\pixel_statistics_solution(:);
    text(x_lim(end), x_lim(end) * 0.8, ['s:' ,num2str(slope(2),3)]);
    daspect([1, 1, 1]);
    
end
end