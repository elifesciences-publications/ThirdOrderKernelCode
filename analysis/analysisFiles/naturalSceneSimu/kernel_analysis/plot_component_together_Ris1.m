
function plot_component_together_Ris1(K2_norm, K3_U_norm,R, dtxy_bank, dtxx_bank, tMax)

color_k2 = [114, 206, 245]/255;
color_k3 = [49, 168, 73]/255;

%% adjust the size of the figure.
MakeFigure;
subplot(3,2,1);
time_since_most_recent = 1:tMax;
plot(time_since_most_recent , K2_norm{1}, 'color', color_k2);
hold on
plot(time_since_most_recent , K3_U_norm{1}, 'color', color_k3);
xlabel('time since most recent bar [s]');
ylabel('first dimension [a.u]');
set(gca, 'XTick', [1, 17, 33,49], 'XTickLabel',{'0', '0.25', '0.5', '0.75'});
ymax = max([max(K2_norm{1}), max(K3_U_norm{1})]);
set(gca, 'YLim',[0, ymax]* 1.3);
set(gca, 'XLim',[1, tMax]);
legend('2^{nd} order','3^{rd} order');
% xtickangle(90)

ConfAxis

subplot(3,2,3);
plot(dtxy_bank, K2_norm{2}, 'color', color_k2);
hold on
plot(dtxy_bank, K3_U_norm{2}, 'color', color_k3);
plot([dtxy_bank(1), dtxy_bank(end)],[0,0],'k--')
xlabel('\tau2 - \tau1 [ms]');
ylabel('second dimension [a.u]');
set(gca, 'XTick',dtxy_bank, 'XTickLabel',strsplit(num2str( dtxy_bank * 1/60* 1000,2)));
legend('2^{nd} order','3^{rd} order');
% scatter(0,0,'MarkerEdgeColor',[0,0,0]);
ymax = max([max(abs(K2_norm{2})), max(abs(K3_U_norm{2}))]);
set(gca, 'YLim',[-ymax, ymax] * 1.3);
set(gca, 'XLim',[dtxy_bank(1), dtxy_bank(end)]);
xtickangle(90)
ConfAxis

end