% function High_Corr_PaperFig_Utils_SmallFontSize
fontSize = 8;
ax = gca;
ax.YLabel.FontSize = fontSize;
ax.XLabel.FontSize = fontSize;
set(gca,'FontSize',fontSize,'FontName','Helvetica');
set(gca,'XColor',[0 0 0],'YColor',[0 0 0],'ZColor',[0 0 0]);

