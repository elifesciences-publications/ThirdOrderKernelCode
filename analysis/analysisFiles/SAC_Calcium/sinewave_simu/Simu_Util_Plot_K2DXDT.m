function Simu_Util_Plot_K2DXDT(K2_DXDT, dx_bank, dt_bank)
c_max = max(abs(K2_DXDT(:)));
imagesc(dx_bank, dt_bank, K2_DXDT'); %% dx, dt... plot it with 
set(gca, 'YDir', 'normal');
xlabel('\Delta X');
ylabel('\Delta T');
ConfAxis('fontSize', 15); box on;
hold on; plot([0,0], get(gca, 'YLim'), 'k--');
plot(get(gca, 'XLim'), [0,0], 'k--');
% set(gca, 'XTick', 1:length(dx_bank), 'XTickLabel', num2str(dx_bank));
% set(gca, 'YTick', 1:length(dt_bank), 'YTickLabel', num2str(dt_bank));
mymap = flipud(brewermap(100, 'RdBu'));
colormap(mymap);
set(gca, 'CLim', [-c_max, c_max]);
end