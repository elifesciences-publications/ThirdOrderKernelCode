fontSizeText = 15;
fontSizeAxis = 15;
lineWidth = 3;

box off
a = get(plotH,'CurrentAxes');
set(a,'FontSize',fontSizeAxis);

%%
b = get(a,'Title');
set(b, 'FontSize',fontSizeText);
b = get(a,'XLabel');
set(b, 'FontSize',fontSizeText);
b = get(a,'YLabel');
set(b, 'FontSize',fontSizeText);
%%
grid on
