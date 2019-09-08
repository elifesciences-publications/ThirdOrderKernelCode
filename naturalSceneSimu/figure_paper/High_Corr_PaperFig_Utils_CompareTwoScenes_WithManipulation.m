function High_Corr_PaperFig_Utils_CompareTwoScenes_WithManipulation(one_row_different, scene_str,scene_str2, synthetic_type)

MakeFigure;
%%
h = repmat(struct('Units', 'normalized','Position', []), 2, 4);
for ii = 1:1:2
    for jj = 1:1:4
        a = subplot(4, 4, (ii * 2 - 1) * 4 + jj);
        h(ii, jj).Position = a.Position;
    end
end

%% for one row,
%% 

n_hor_pixels = 927;
spatial_resolution = 360/n_hor_pixels;
x_plot = spatial_resolution:spatial_resolution:360;

MakeFigure;
for ii = 1:1:2
    one_row_this =  one_row_different{ii};
    axes('Units', h(ii,1).Units, 'Position', h(ii,1).Position);
    % by degree
    plot(x_plot, one_row_this,'k');
    set(gca, 'XTick', [],'YTick',[]);
    ylabel('contrast');
    title(scene_str{ii})
    ConfAxis
    % do the manipulation...
    
    axes('Units', h(ii,2).Units, 'Position', h(ii,2).Position);
    one_row_manipulate_this  = Generate_VisualStim_And_VelEstimation_Utils_ManipulateOneScene(one_row_this, synthetic_type);
    one_row_manipulate_this = one_row_manipulate_this{1};
    % by degree
    plot(x_plot, one_row_manipulate_this,'k');
    set(gca, 'XTick', [],'YTick',[]);
    ylabel('contrast');
    title(scene_str2{ii})
    ConfAxis
    
    axes('Units', h(ii,3).Units, 'Position', h(ii,3).Position);
    n_autocorr= 100;
    [autocorrelation_this,lags] = autocorr(one_row_manipulate_this, n_autocorr);
    spatial_resolution = 360/n_hor_pixels;
    plot(lags *  spatial_resolution, autocorrelation_this,'r');
    hold on
    hold on; plot(get(gca, 'XLim'), [0,0],'k--');
    xlabel('\delta x [degree]');
    title('spatial correlation');
    ConfAxis
    
    axes('Units', h(ii,4).Units, 'Position', h(ii,4).Position);
    h_contrast = histogram(one_row_manipulate_this, 20); % 20 bins
    h_contrast.FaceColor = [0,0,0]; h_contrast.Normalization = 'probability';
    title('contrast distribution');
    xlabel('contrast');
    ConfAxis
end
end