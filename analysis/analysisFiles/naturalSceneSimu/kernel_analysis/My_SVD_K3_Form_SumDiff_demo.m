function My_SVD_K3_Form_SumDiff_demo(K3_Impulse, K3_Impulse_tight, tau_sum, tau_diff)
%% first, the integration plot.
k3_integrated = squeeze(sum(K3_Impulse, 1));
k3_integrated_tight = squeeze(sum(K3_Impulse_tight, 1));

MakeFigure;
subplot(2,2,1);
% Change the presentation direction...
imagesc(tau_sum, tau_diff, k3_integrated');
colormap_gen;
colormap(mymap);
thisMaxVal = max(abs(k3_integrated(:)));
set(gca,'Clim',[-thisMaxVal thisMaxVal]);
xlabel('\Delta\tau_{21} + \Delta\tau_{23}');
ylabel('\Delta\tau_{21} - \Delta\tau_{23}');
set(gca, 'clim')
axis equal; axis tight;
ConfAxis('fontSize',15);
box on

n_diff = length(tau_diff);
subplot(2,2,2);
imagesc(tau_sum, tau_diff(1: floor(n_diff/2)) + 0.5, k3_integrated_tight');
colormap_gen;
colormap(mymap);
thisMaxVal = max(abs(k3_integrated_tight(:)));
set(gca,'Clim',[-thisMaxVal thisMaxVal]);
xlabel('\Delta\tau_{21} + \Delta\tau_{23}');
ylabel('\Delta\tau_{21} - \Delta\tau_{23}');
set(gca, 'clim')
axis equal; axis tight;
ConfAxis('fontSize',15);
box on
end