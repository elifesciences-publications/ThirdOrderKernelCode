
function plot_component_together_both_SVD(K2_norm, K3_U_norm, K2_S, K3_S, dtxy_bank_2, dtxy_bank_3, tMax)

color_k2 = [114, 206, 245]/255;
color_k3 = [49, 168, 73]/255;

%% adjust the size of the figure.
MakeFigure_Paper;
axes('Units', 'Points', 'Position', [100,500,160,50]);
time_since_most_recent = 1:tMax;
plot(time_since_most_recent , K2_norm{1}, 'color', color_k2);
hold on
plot(time_since_most_recent , K3_U_norm{1}, 'color', color_k3);
xlabel('time since most recent bar [s]');
ylabel('u_{1} [a.u.]');
set(gca, 'XTick', [1, 17, 33,49], 'XTickLabel',{'0', '0.25', '0.5', '0.75'});
ymax = max([max(K2_norm{1}), max(K3_U_norm{1})]);
set(gca, 'YLim',[0, ymax]* 1.2);
set(gca, 'XLim',[1, tMax]);
legend('2^{nd} order','3^{rd} order');
ConfAxis('fontSize', 9, 'LineWidth', 0.5);

axes('Units', 'Points', 'Position', [100,400,160,50]);
plot(dtxy_bank_2, K2_norm{2}, 'color', color_k2);
hold on
plot(dtxy_bank_3, K3_U_norm{2}, 'color', color_k3);
plot(get(gca,'XLim'),[0,0],'k--');
xlabel('\Delta\tau_{21}  [ms]');
ylabel('u_{2} [a.u.]');
set(gca, 'XTick',dtxy_bank_2, 'XTickLabel',strsplit(num2str( dtxy_bank_2 * 1/60* 1000,2)));
legend('2^{nd} order','3^{rd} order');
% scatter(0,0,'MarkerEdgeColor',[0,0,0]);
ymax = max([max(abs(K2_norm{2})), max(abs(K3_U_norm{2}))]);
set(gca, 'YLim',[-ymax, ymax] * 1.2);
set(gca, 'XLim',[dtxy_bank_2(1), dtxy_bank_2(end)]);
% xtickangle(90)
ConfAxis('fontSize', 9, 'LineWidth', 0.5);

axes('Units', 'Points', 'Position', [300,500,100,68]);
plot(diag(K2_S), 'Marker','.', 'color',color_k2);
set(gca, 'XLim',[0,11],'YLim', [-0.01, 0.2]);
% xtickangle(90)
ConfAxis('fontSize', 9, 'LineWidth', 0.5);

axes('Units', 'Points', 'Position', [300,400,100,68]);
plot(diag(K3_S), 'Marker','.', 'color',color_k3);
set(gca, 'XLim',[0,11], 'YLim', [-0.001, 0.02]);
ConfAxis('fontSize', 9, 'LineWidth', 0.5);

end