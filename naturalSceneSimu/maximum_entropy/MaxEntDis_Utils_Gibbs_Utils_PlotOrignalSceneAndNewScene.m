function MaxEntDis_Utils_Gibbs_Utils_PlotOrignalSceneAndNewScene(data_natural_scene, data_synthetic_scene, gray_value_edge_ns)
gray_value_edge = cell(2, 1);
gray_value_edge{1} = gray_value_edge_ns;
gray_value_edge{2} = gray_value_edge_ns;
gray_value_edge{2}(1) = min([data_synthetic_scene, gray_value_edge{2}(1)]); gray_value_edge{2}(end) = max([data_synthetic_scene, gray_value_edge{2}(end)]);

data_scene = cell(2, 1);
data_scene{1} = data_natural_scene;
data_scene{2} = data_synthetic_scene;
data_all = cell2mat(data_scene);
scene_lim = [min(data_all(:)), max(data_all(:))];
scene_str = {'natural scene', 'synethetic scene: contrast + spatial corr'};
MakeFigure;
for ii = 1:1:2
    [N, ~] = histcounts(data_scene{ii}, gray_value_edge{ii});
    constrast_distribution = N/length(data_scene{ii});
    
    subplot(3,3,(ii - 1) * 3 + 1); 
    plot(data_scene{ii}); ylabel('contrast');
    set(gca, 'YLim',scene_lim);
    title(scene_str{ii})
    ConfAxis
    
    subplot(3,3,(ii - 1) * 3 + 2)
    h_hist = histogram(data_scene{ii}, gray_value_edge{ii}, 'Normalization', 'probability'); hold on;
    h_hist.FaceColor = [0,0,0];
    xlim = get(gca, 'XLim'); set(gca, 'XLim', [-1, xlim(2)]);
    title('contrast distribution');
%     plot((gray_value_edge{ii}(1:end - 1) + gray_value_edge{ii}(2:end))/2, constrast_distribution,'r');
    ConfAxis
    subplot(3,3,(ii - 1) * 3 + 3)
    
     n_hor_pixels = 927;
    n_autocorr= 100;
    [autocorrelation_this,lags] = autocorr(data_scene{ii}, n_autocorr);
    spatial_resolution = 360/n_hor_pixels;
    plot(lags *  spatial_resolution, autocorrelation_this,'r');
    hold on
    hold on; plot(get(gca, 'XLim'), [0,0],'k--');
    xlabel('\delta x [degree]');
    title('spatial correlation');
     hold on
      ConfAxis
end