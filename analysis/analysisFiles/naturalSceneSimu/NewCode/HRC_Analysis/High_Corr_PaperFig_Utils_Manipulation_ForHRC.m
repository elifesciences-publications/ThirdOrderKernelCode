function High_Corr_PaperFig_Utils_Manipulation_ForHRC(one_row_different, med_info, scene_str, varargin)
h_kde = 0.075;
mean_spatial_correlation_full_path = 'D:\Natural_Scene_Simu\image\statiche0syn_\FWHM25\spatial_corr.mat';
mean_powerspectrum_full_path = 'D:\Natural_Scene_Simu\image\statiche0syn_\FWHM25\power_spectrum.mat';
% how do you compute mean variance of a guassian?
n_autocorr= 100;
plot_matched_up_flag = true;
color_individual = [0,1,0];
color_ensemble = [0.5, 0.5, 0.5];
show_skew_flag = false;
skewness_ns = 0;
ns_scene = [];
mode = 'ai_publish';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

if plot_matched_up_flag
    mean_spatial_corr = load(mean_spatial_correlation_full_path);
    mean_power_spectrum = load(mean_powerspectrum_full_path);
    I_syn_temp = SyntheticScene_Utils_GenerateOneImage([], mean_power_spectrum,'m_sc_m_var');
    mean_std = mean(std( I_syn_temp(), 0,2));
    if strcmp(scene_str{1}, 'natural scene')
        individual_spatial_corr = autocorr(one_row_different{1}, n_autocorr);
        individual_std = std(one_row_different{1});
    end
end


%%
switch mode
    case 'matlab_debug'
        n_scene = length(one_row_different);
        h_axes = repmat(struct('Units', 'normalized','Position', []), n_scene, 3);
        for ii = 1:1:n_scene
            for jj = 1:1:3
                a = subplot(n_scene, 3, (ii - 1) * 3 + jj);
                h_axes(ii,jj).Position = a.Position;
                
            end
        end
    case 'ai_publish'
        n_scene = length(one_row_different);
        hor_position = [50, 250, 450];
        ver_position = [325, 250, 175, 100];
        hor_width = 150;
        ver_height = 50;
        h_axes = repmat(struct('Units', 'points','Position', []), n_scene, 3);
        for ii = 1:1:n_scene
            for jj = 1:1:3
                h_axes(ii,jj).Position = [hor_position(jj),ver_position(ii), hor_width, ver_height];
                
            end
        end
end
% for power spectrum.
% n_hor_pixels = 927; NFFT = 927;
% frequency = (0:1:(NFFT + 1)/4) * 1/NFFT * 927/360; % what is
% f_plot_ind = length(frequency);

n_hor_pixels = 927;
spatial_resolution = 360/n_hor_pixels;
x_plot = spatial_resolution:spatial_resolution:360;
%% constrast limit.
all_contrast = cell2mat(one_row_different);
contrast_max = max(all_contrast(:));


MakeFigure;
for ii = 1:1:n_scene
    color_distribution = color_individual;
    color_mean = color_individual;
    color_correlation = color_individual;
    color_scene = color_individual;
    color_skew = color_ensemble;
    if ~strcmp(scene_str{ii},'ns')
        color_scene = color_individual * 0.5;
    end
    if strcmp(scene_str{ii}, 'm_sc_i_var')|| strcmp(scene_str{ii}, 'm_sc_m_var')
        color_correlation = color_ensemble;
    end
    if strcmp(scene_str{ii}, 'm_var_i_sc')|| strcmp(scene_str{ii}, 'm_sc_m_var')
        color_mean = color_ensemble;
    end
    if strcmp(scene_str{ii}, 'm_var_i_sc')|| strcmp(scene_str{ii}, 'm_sc_m_var') ...
            || strcmp(scene_str{ii}, 'm_sc_i_var') || strcmp(scene_str{ii}, 'i_sc_i_var')...
            || strcmp(scene_str{ii}, 'med_i_sc_iskew')
        color_distribution = color_ensemble;
    end
    if strcmp(scene_str{ii}, 'med_i_sc_iskew') || strcmp(scene_str{ii}, 'ns') || strcmp(scene_str{ii}, 'i_sc_i_cd_fullcov')
        color_skew = color_individual;
    end
    %% scene
    axes('Units', h_axes(ii,1).Units, 'Position', h_axes(ii,1).Position);
    one_row_this = one_row_different{ii};
    % by degree
    plot(x_plot, one_row_this,'color', color_scene);
    if ii ~= n_scene
        %         set(gca, 'XTick', [],'YTick',[]);
        set(gca, 'XTick',[],'XAxisLocation','origin');
    else
        set(gca, 'XTick', [90, 180, 270, 360])
    end
    if ii == n_scene
        ylabel('contrast');
        xlabel('spatial position [degree]')
        
    end
    if ii == 1
        title('example scene');
    end
    if ii ~= 1
        set(gca, 'YTick', [])
        
    end
    %     ylabel(scene_str{ii})
    set(gca, 'YLim', [-contrast_max,contrast_max]);
    hold on
    plot(get(gca, 'XLim'),[0,0],'k-');
    set(gca, 'XLim', [0,361]);
    ConfAxis
    %     title(scene_str(ii),'Interpreter', 'none');
    %% autocorrelation
    % also plot the one needs to be matched with? color?
    axes('Units', h_axes(ii,2).Units, 'Position', h_axes(ii,2).Position);
    if strcmp(scene_str(ii) ,'m_sc_i_var')...
            || strcmp(scene_str(ii) ,'m_sc_m_var')
        [autocorrelation_this,lags] = autocorr(one_row_this, n_autocorr);
    else
        [autocorrelation_this,lags] = autocorr(ns_scene, n_autocorr);
        
    end
    spatial_resolution = 360/n_hor_pixels;
    plot(lags *  spatial_resolution, autocorrelation_this, 'color', color_correlation);
    set(gca, 'YLim', [-1, 1]);
    if ~ (ii == n_scene)
        set(gca, 'XTick',[],'XAxisLocation','origin');
    end
    hold on; plot(get(gca, 'XLim'), [0,0],'k-');
    if ii == n_scene
        %         xlabel('\delta x [degree]');
        xlabel('spatial offset [deg]')
        ylabel('correlation')
    end
    if ii == 1
        title('spatial correlation');
    end
    if ii ~= 1
        set(gca, 'YTick', [])
        
    end
    
    %% also plot the correlation needs to be matched up.
    if plot_matched_up_flag
        if strcmp(scene_str(ii) ,'m_sc_i_var')...
                ||strcmp(scene_str(ii) ,'m_sc_m_var')
            plot(lags *  spatial_resolution, mean_spatial_corr.spatial_corr_mean, 'color', color_correlation_matched);
        elseif  strcmp(scene_str(ii) ,'i_sc_i_var')...
                || strcmp(scene_str(ii) ,'m_var_i_sc')
            plot(lags *  spatial_resolution, individual_spatial_corr, 'color', color_correlation_matched);
        elseif  strcmp(scene_str(ii) ,'m_sc_i_cd') ...
                || strcmp(scene_str(ii) ,'i_sc_i_cd') ...
                || strcmp(scene_str(ii) ,'m_sc_i_cd_fullcov')...
                || strcmp(scene_str(ii) ,'i_sc_i_cd_fullcov')
            K = 4; N = 8;
            resolution_n_pixel = med_info{ii}.resolution_n_pixel;
            lag_ind = find(ismember(lags,resolution_n_pixel:resolution_n_pixel: resolution_n_pixel * (K - 1)));
            for kk = 1:1:K - 1
                scatter(lags(lag_ind(kk)) * spatial_resolution, med_info{ii}.correlation_true(kk), 'filled','MarkerFaceColor',color_correlation_matched);
            end
        end
        
    end
    ConfAxis
    %% histogram
    %
    axes('Units', h_axes(ii,3).Units, 'Position', h_axes(ii,3).Position);
    
    if strcmp(scene_str(ii) ,'m_sc_i_cd') ...
            || strcmp(scene_str(ii) ,'i_sc_i_cd') ...
            || strcmp(scene_str(ii) ,'m_sc_i_cd_fullcov')...
            %             || strcmp(scene_str(ii) ,'i_sc_i_cd_fullcov')
        gray_value_edge = med_info{ii}.gray_value_edge;
        % turn histogram into log scale so that people can see.
        h_hist_value = histcounts(one_row_this, gray_value_edge, 'Normalization', 'probability');
        %         h_hist = bar((gray_value_edge(1:end - 1) + gray_value_edge(2:end))/2, h_hist_value);
    elseif strcmp(scene_str(ii) ,'med_i_sc_iskew')
        gray_value = med_solu.gray_value;
        h_hist_value = med_solu.p_i;
    elseif strcmp(scene_str(ii) ,'ns') 
        % you need to bin it to 8.
        N = 50;
        gray_value = linspace(-contrast_max, contrast_max, N + 1); % That is a great idea actuall... you should do 11 levels.
        h_hist_value = kde_juyue_contrast_plotting(one_row_this , gray_value, h_kde);
        h_hist_value = h_hist_value./sum(h_hist_value);
    elseif  strcmp(scene_str(ii) ,'i_sc_i_cd_fullcov')
        N = 50;
        gray_value = linspace(-contrast_max, contrast_max, N + 1); % That is a great idea actuall... you should do 11 levels.
        h_hist_value = kde_juyue_contrast_plotting(ns_scene , gray_value, h_kde);
        h_hist_value = h_hist_value./sum(h_hist_value);
        
    else
        %% use a gaussian to fit the data.
        N = 50;
        
        gray_value = linspace(-contrast_max, contrast_max, N);
        var_this = var(one_row_this);
        h_hist_value = exp(-1/2 * gray_value.^2/var_this);
        h_hist_value = h_hist_value./sum(h_hist_value);
    end
    semilogy(gray_value, h_hist_value, 'color', color_distribution); hold on;
    set(gca, 'XLim', [-contrast_max,contrast_max]);
    if ii ~= n_scene
        set(gca,'XTick', []);
        
    end
    set(gca, 'YLim',[1e-4,1]);
    if ii == 1
        title('contrast distribution');
    end
    
    mean_contrast = mean(one_row_this);
    std_contrast = std(one_row_this);
    ylim  = get(gca, 'YLim');
    
    plot([mean_contrast, mean_contrast],ylim, 'color',color_mean);
    plot([mean_contrast - std_contrast, mean_contrast + std_contrast], [sqrt(ylim(2)/ylim(1)),sqrt(ylim(2)/ylim(1))] * ylim(1), 'color',color_mean);
    if ii == n_scene
        xlabel('contrast');
        ylabel('probability')
    end
    if ii ~= 1
        set(gca, 'YTick', [])
        
    end
    ConfAxis
    
    %% write down the skewness
    if show_skew_flag
        % calculate skewness
        if strcmp(scene_str(ii) ,'ns') || strcmp(scene_str(ii) ,'med_i_sc_iskew') || strcmp(scene_str(ii) ,'i_sc_i_cd_fullcov')
            skewness_this = skewness_ns;
            skew_text = text(contrast_max * 0.6, 1, sprintf('skewness = %0.2f', skewness_this),'color', color_skew, 'FontSize', 20);
        else
            skewness_this = 0;
            skew_text = text(contrast_max * 0.6, 1, sprintf('skewness = %0.0f', skewness_this),'color', color_skew, 'FontSize', 20);
        end
        skew_text.Color = color_skew; skew_text.FontSize = 15;
    end
    %% also plot the scene to be matched up.
    if plot_matched_up_flag
        if strcmp(scene_str(ii) ,'m_sc_m_var')...
                ||strcmp(scene_str(ii) ,'m_var_i_sc')
            plot([mean_contrast - mean_std, mean_contrast + mean_std], [sqrt(ylim(2)/ylim(1)),sqrt(ylim(2)/ylim(1))] * ylim(1), 'color', color_correlation_matched);
        elseif  strcmp(scene_str(ii) ,'i_sc_i_var')...
                || strcmp(scene_str(ii) ,'m_sc_i_var')
            plot([mean_contrast - individual_std, mean_contrast + individual_std], [sqrt(ylim(2)/ylim(1)),sqrt(ylim(2)/ylim(1))] * ylim(1), 'color', color_correlation_matched);
        elseif  strcmp(scene_str(ii) ,'m_sc_i_cd') ...
                || strcmp(scene_str(ii) ,'i_sc_i_cd') ...
                || strcmp(scene_str(ii) ,'m_sc_i_cd_fullcov')...
                || strcmp(scene_str(ii) ,'i_sc_i_cd_fullcov')
            gray_value_edge = med_info{ii}.gray_value_edge;
            p_1_true = med_info{ii}.p_1_true;
            semilogy((gray_value_edge(1:end - 1) + gray_value_edge(2:end))/2, p_1_true, 'color', color_correlation_matched); hold on;
        end
    end
    ConfAxis
end
end