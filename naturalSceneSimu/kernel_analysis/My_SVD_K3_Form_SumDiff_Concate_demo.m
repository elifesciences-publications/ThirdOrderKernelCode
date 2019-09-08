function My_SVD_K3_Form_SumDiff_Concate_demo(K3_Impulse, n_sum, n_diff)
%% first, the integration plot.
k3_integrated = squeeze(sum(K3_Impulse, 1));
k3_2L = k3_integrated(:, 1:n_diff);
k3_2R = k3_integrated(:, n_diff+1:end);


MakeFigure;
thisMaxVal = max(abs(k3_integrated(:)));

subplot(2,2,1);
% Change the presentation direction...
imagesc(1:n_sum, 1:n_diff, k3_2L');
colormap_gen;
colormap(mymap);
set(gca,'Clim',[-thisMaxVal thisMaxVal]);
xlabel('\Delta\tau_{21} + \Delta\tau_{23}');
ylabel('\Delta\tau_{21} - \Delta\tau_{23}');
set(gca, 'clim')
axis equal; axis tight;
ConfAxis('fontSize',15);
title('LLR')
box on

subplot(2,2,2);
imagesc(1:n_sum, 1:n_diff, k3_2R');
colormap_gen;
colormap(mymap);
set(gca,'Clim',[-thisMaxVal thisMaxVal]);
xlabel('\Delta\tau_{21} + \Delta\tau_{23}');
ylabel('\Delta\tau_{21} - \Delta\tau_{23}');
set(gca, 'clim')
axis equal; axis tight;
ConfAxis('fontSize',15);
title('RRL')
box on

subplot(2,2,3);
imagesc(1:n_sum, [1:n_diff, 1:n_diff], k3_integrated');
set(gca, 'YTick', []);
colormap_gen;
colormap(mymap);
set(gca,'Clim',[-thisMaxVal thisMaxVal]);
xlabel('\Delta\tau_{21} + \Delta\tau_{23}');
ylabel('\Delta\tau_{21} - \Delta\tau_{23}');
set(gca, 'clim')
title('combined');
axis equal; axis tight;
ConfAxis('fontSize',15);
box on

subplot(2,2,4); % plot the integration of the third-dimension.
K3_integrated_23 = sum(k3_integrated, 2);
plot(1:n_sum, -K3_integrated_23, 'k-');
hold on; plot(get(gca, 'XLim'), [0,0],'k--');
xlabel('\Delta\tau_{21} + \Delta\tau_{23}');
title('Integrated Out (\Delta\tau_{21} - \Delta\tau_{23})')
ConfAxis('fontSize', 15);
%% Keep First dimension, integrate out the third dimension.
% MakeFigure;
% subplot(1,2,1); % plot the integration of the third-dimension.
% K3_integrated_3 = sum(K3_Impulse, 3);
% imagesc(1:n_sum, 1:size(K3_integrated_3, 1), K3_integrated_3);
% colormap_gen;
% colormap(mymap);
% thisMaxVal = max(abs(K3_integrated_3(:)));
% set(gca,'Clim',[-thisMaxVal thisMaxVal]);
% xlabel('\Delta\tau_{21} + \Delta\tau_{23}');
% ylabel('time since the most recent');
% set(gca, 'clim')
% title('Integrated Out (\Delta\tau_{21} - \Delta\tau_{23})');
% axis tight; axis equal
% ConfAxis('fontSize',15);
% box on

end