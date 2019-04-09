function High_Corr_PaperFig_Utils_Manipulation_Summary(one_row_different, med_info, scene_str, varargin)

mean_spatial_correlation_full_path = 'D:\Natural_Scene_Simu\image\statiche0syn_\FWHM25\spatial_corr.mat';
mean_powerspectrum_full_path = 'D:\Natural_Scene_Simu\image\statiche0syn_\FWHM25\power_spectrum.mat';
% how do you compute mean variance of a guassian?
n_autocorr= 100;
plot_matched_up_flag = true;
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




MakeFigure;
%%
n_scene = length(one_row_different);
h_axes = repmat(struct('Units', 'normalized','Position', []), n_scene, 3);
for ii = 1:1:n_scene
    for jj = 1:1:3
        a = subplot(n_scene, 3, (ii - 1) * 3 + jj);
        h_axes(ii,jj).Position = a.Position;
        
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
    
    color_correlation_matched = [1,0,0];
    if strcmp(scene_str{ii},'natural scene') || strcmp(scene_str{ii},'med_sc_cd') || strcmp(scene_str{ii},'sc mean var');
        color_mean = [0,0,0];
    else
        color_mean = [0,0,0];
    end
    if strcmp(scene_str{ii},'natural scene') || strcmp(scene_str{ii},'med_sc_cd')
        color_distribution = [0,0,0];
    else
        color_distribution = [0,0,0];
    end
    if ~(strcmp(scene_str{ii},'mean sc'))
        color_correlation = [0,0,0];
    else
        color_correlation = [0,0,0];
    end
    
    %% scene
    axes('Units', h_axes(ii,1).Units, 'Position', h_axes(ii,1).Position);
    one_row_this = one_row_different{ii};
    % by degree
    plot(x_plot, one_row_this,'k');
    set(gca, 'XTick', [],'YTick',[]);
    %     ylabel(scene_str{ii})
    ConfAxis
    set(gca, 'YLim', [-contrast_max,contrast_max]);
    
    title(scene_str(ii),'Interpreter', 'none');
    %% autocorrelation
    % also plot the one needs to be matched with? color?
    axes('Units', h_axes(ii,2).Units, 'Position', h_axes(ii,2).Position);
    [autocorrelation_this,lags] = autocorr(one_row_this, n_autocorr);
    spatial_resolution = 360/n_hor_pixels;
    plot(lags *  spatial_resolution, autocorrelation_this, 'color', color_correlation);
    
    if ~ (ii == n_scene)
        set(gca, 'XTick',[],'XAxisLocation','origin');
    end
    hold on; plot(get(gca, 'XLim'), [0,0],'k--');
    if ii == n_scene
        xlabel('\delta x [degree]');
    end
    if ii == 1
        title('spatial correlation');
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
    axes('Units', h_axes(ii,3).Units, 'Position', h_axes(ii,3).Position);
    if strcmp(scene_str(ii) ,'m_sc_i_cd') ...
            || strcmp(scene_str(ii) ,'i_sc_i_cd') ...
            || strcmp(scene_str(ii) ,'m_sc_i_cd_fullcov')...
            || strcmp(scene_str(ii) ,'i_sc_i_cd_fullcov')
            gray_value_edge = med_info{ii}.gray_value_edge;
        % turn histogram into log scale so that people can see.
        h_hist_value = histcounts(one_row_this, gray_value_edge, 'Normalization', 'probability');
        %         h_hist = bar((gray_value_edge(1:end - 1) + gray_value_edge(2:end))/2, h_hist_value);
    elseif strcmp(scene_str(ii) ,'natural scene')
        % you need to bin it to 8.
        K = 4; N = 8;
        gray_value_edge = linspace(min(one_row_this), max(one_row_this), N + 1); % That is a great idea actuall... you should do 11 levels.
        h_hist_value = histcounts(one_row_this, gray_value_edge, 'Normalization', 'probability');
        %         h_hist = bar((gray_value_edge(1:end - 1) + gray_value_edge(2:end))/2, h_hist_value);
    else
        [h_hist_value,  gray_value_edge]= histcounts(one_row_this, 20, 'Normalization', 'probability');
        %         h_hist = bar((gray_value_edge(1:end - 1) + gray_value_edge(2:end))/2, log(h_hist_value));
    end
    semilogy((gray_value_edge(1:end - 1) + gray_value_edge(2:end))/2, h_hist_value, 'color', color_distribution); hold on;

    set(gca, 'XLim', [-contrast_max,contrast_max]);
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
    end
    ConfAxis
    
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