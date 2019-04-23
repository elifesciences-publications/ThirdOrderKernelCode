function Figure1B_NaturalScene()
load('D:\ThirdOrderKernel_intermediate_data\contrast_image.mat');
LineWidth_data = 1;
LineWidth_axis = 0.5;

%% horizontally half.
hor_l = 927;
ver_l = 231;
example_row = 50;

ns_scene = contrPictureLocal{45}((1:ver_l), 1 : end); %%
[n_ver_pixels,n_hor_pixels] = size(ns_scene);


MakeFigure_Paper;
%% 2D plot.
axes('Units', 'points', 'Position', [250,500,300,300/4],'FontName','Arial')
imagesc(ns_scene);colormap(gray);hold on
plot([0, n_hor_pixels],[example_row, example_row ],  'r-');

ylabel('vertical spatial location');
title('An example natural scene');

set(gca, 'XTick',[]);
set(gca, 'YTick',[1, n_ver_pixels - 1], 'YTickLabel', {'-45\circ', '45\circ'});
daspect([1, 1, 1]);

ConfAxis('LineWidth', LineWidth_axis,'fontSize', 10);
box on

%%
axes('Units', 'points', 'Position', [250,430,300,300/6],'FontName','Arial')
plot(ns_scene(example_row , :),'k');
hold on
plot([0, length(ns_scene(example_row, :))], [0,0], 'k--')
set(gca, 'XTick',[]);
set(gca, 'YTick', [-1, 0, 1], 'YTickLabel', {'-1', '0', '1'});
ylabel('contrast')
set(gca,'YLim',[-1.5,2.5]);

ConfAxis('LineWidth', LineWidth_axis, 'fontSize', 10);
axis('tight');
set(gca, 'XTick',[1,n_hor_pixels], 'XTickLabel',{'-180\circ', '180\circ'});
xlabel('horizontal spatial location');

%% plot another natural scene for the color bar.
axes('Units', 'points', 'Position', [250,300,300,300/4],'FontName','Arial')
imagesc(ns_scene);colormap(gray);hold on
plot([0, n_hor_pixels],[example_row, example_row ],  'r-');

ylabel('vertical spatial location');
title('An example natural scene');

set(gca, 'XTick',[]);
set(gca, 'YTick',[1, n_ver_pixels - 1], 'YTickLabel', {'-45\circ', '45\circ'});

c = colorbar;
set(c, 'LineWidth', LineWidth_axis, 'Ticks',[-1, 0, 1, 2, 3]);
% daspect([1, 1, 1]);
ConfAxis('LineWidth', LineWidth_axis,'fontSize', 10);

%% also plot another thing to make h
% MySaveFig_Juyue(gcf,'NaturalScene_2DExample','2_D1D_plot','nFigSave',2,'fileType',{'pdf','fig'})
end