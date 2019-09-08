function High_Corr_PaperFig_Utils_CompareTwoScenes(one_row_different, scene_str)

MakeFigure;
%%
h = repmat(struct('Units', 'normalized','Position', []), 2, 4);
subplot_num = {[1,4], [7], [2, 5], [3,6]};
for ii = 1:1:2
    for jj = 1:1:4
        if ii == 1
            a = subplot(6, 3, subplot_num{jj});
        else
            a = subplot(6, 3, subplot_num{jj}+ 9);
            
        end
        h(ii, jj).Position = a.Position;
    end
end



% for power spectrum.
% n_hor_pixels = 927; NFFT = 927;
% frequency = (0:1:(NFFT + 1)/4) * 1/NFFT * 927/360; % what is
% f_plot_ind = length(frequency);

n_hor_pixels = 927;
spatial_resolution = 360/n_hor_pixels;
x_plot = spatial_resolution:spatial_resolution:360;

MakeFigure;
for ii = 1:1:2
    axes('Units', h(ii,1).Units, 'Position', h(ii,1).Position);
    one_row_this = one_row_different{ii};
    % by degree
    plot(x_plot, one_row_this,'k');
    set(gca, 'XTick', [],'YTick',[]);
    ylabel('contrast');
    title(scene_str{ii})
    ConfAxis
%     
%     axes('Units', h(ii,2).Units, 'Position', h(ii,2).Position);
%     imagesc(one_row_this); colormap(gray); set(gca, 'XTick', [],'YTick',[]);
%     xlabel('location');
%     ConfAxis
%     box on;
    
    axes('Units', h(ii,3).Units, 'Position', h(ii,3).Position);
    n_autocorr= 100;
    [autocorrelation_this,lags] = autocorr(one_row_this, n_autocorr);
    spatial_resolution = 360/n_hor_pixels;
    plot(lags *  spatial_resolution, autocorrelation_this,'r');
    hold on
    hold on; plot(get(gca, 'XLim'), [0,0],'k--');
    xlabel('\delta x [degree]');
    title('spatial correlation');
    ConfAxis
    
    axes('Units', h(ii,4).Units, 'Position', h(ii,4).Position);
    h_contrast = histogram(one_row_this, 20); % 20 bins
    h_contrast.FaceColor = [0,0,0]; h_contrast.Normalization = 'probability';
    title('contrast distribution');
    xlabel('contrast');
    ConfAxis
end
end