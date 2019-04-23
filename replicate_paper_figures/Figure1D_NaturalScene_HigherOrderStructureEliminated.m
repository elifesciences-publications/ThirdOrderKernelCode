function Figure1D_NaturalScene_HigherOrderStructureEliminated()
%% scrambled natural scene.
LineWidth_data = 1;
LineWidth_axis = 0.5;
%% get one scene.
S = GetSystemConfiguration;
imagefolder = fullfile(S.natural_scene_simulation_path, 'image','statiche0_ensemble_2ndpreserved_allimages','image_set_0');
%%
scenes = load(imagefolder);
scene_example = scenes.I(2, :);
[n_ver_pixels,n_hor_pixels] = size(scene_example);

%% plot the example scene.
MakeFigure_Paper
axes('Units', 'points', 'Position', [250,430,300,300/6],'FontName','Arial')
plot(scene_example,'k');
hold on
plot([0, length(scene_example)], [0,0], 'k--')
set(gca, 'XTick',[]);
axis('tight');

set(gca,'YLim',[-0.55,0.55]);
set(gca, 'YTick', [-0.5, 0, 0.5], 'YTickLabel', {'-0.5', '0', '0.5'});
ylabel('contrast')

ConfAxis('LineWidth', LineWidth_axis, 'fontSize', 10);
set(gca, 'XTick',[1,n_hor_pixels], 'XTickLabel',{'-180\circ', '180\circ'});
xlabel('horizontal spatial location');

% MySaveFig_Juyue(gcf,'NaturalScene_Scramble','1D_example','nFigSave',2,'fileType',{'pdf','fig'})
end