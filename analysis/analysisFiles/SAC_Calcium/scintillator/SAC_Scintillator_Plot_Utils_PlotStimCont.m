function SAC_Scintillator_Plot_Utils_PlotStimCont(stim, color_box)
imagesc(stim'); colormap(gray);
set(gca, 'clim',[-1,1], 'YDir','normal');
set(gca, 'YTick',[2,3,4], 'YTickLabel',{'-1','0','1'}, 'XTick',[5,6,7], 'XTickLabel',{'-1','0','1'});
ConfAxis('fontSize',10);
set(gca, 'XColor', color_box,'YColor', color_box);
box on
ylabel('\Delta x','Color', [0,0,0]);
xlabel('\Delta t', 'Color', [0,0,0]);
end