function [corr_ns_within_scene, v_real, v2_one_scene] = HRC_On_Natural_Scene_WithinSceneCorr(data, varargin)
plot_flag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
rng(1); % which one do you select?
%%
if ndims(data.v2) == 2
    n_scene = size(data.v2, 2);
    which_scene = randi(n_scene);
    v2_one_scene = data.v2(:, which_scene);
    v_real =  data.v_real(:,1);
else
    n_scene = size(data.v2, 3);
    which_scene = randi(n_scene);
    which_position = randi(size(data.v2, 1));
    v2_one_scene = squeeze(data.v2(which_position, :, which_scene))';
    v_real =  data.v_real(1,:,1)';
end

%% look at the within scene average result.
corr_ns_within_scene = zeros(n_scene, 1);
for nn = 1:1:n_scene
    if ndims(data.v2) == 2
        v2_this_scene  = data.v2(:, nn);
    else
        which_position = randi(size(data.v2, 1));
        v2_this_scene = squeeze(data.v2(which_position, :, nn))';
        
    end
    corr_ns_within_scene(nn) = corr(v2_this_scene, v_real);
    
end

if plot_flag
    MakeFigure;
    subplot(2, 2, 1)
    scatter(v_real, v2_one_scene, 'MarkerEdgeColor', [0,0,0], 'MarkerFaceColor', [0,0,0]);
    ylim = [min(v2_one_scene(:)), max(v2_one_scene(:))];
    Velocity_ScatterPlot_Utils('image velocity', 'HRC motion estimates','y_lim_flag', 1, 'ylim', ylim );
    xlim = get(gca, 'XLim'); ylim = get(gca, 'YLim');
    text(xlim(2),  ylim(2),   ['r = ', num2str(corr(v2_one_scene, v_real))],'FontSize', 30);
    ConfAxis
    subplot(2,2,3)
    h_corr = histogram(corr_ns_within_scene, 'Normalization','probability'); h_corr.FaceColor = [0,0,0];
    xlabel('correlation');
    ylabel('frequency');
    ConfAxis
    box on
end
% MySaveFig_Juyue(gcf, 'HRC_Gau_NaturalScene_One_Scene','ScatterPlot', 'nFigSave',2,'fileType',{'png','fig'})
end