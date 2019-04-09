function SAC_AppMot_Plot_Utils_PlotStimCont(stim, color_box)
imagesc(stim'); colormap(gray);
set(gca, 'XTick',[], 'YTick', [], 'clim',[-1,1],'YDir','normal');
% ConfAxis('fontSize',10);
set(gca, 'XColor', color_box,'YColor', color_box);
box on
ylabel('space','Color', [0,0,0]);
xlabel('time', 'Color', [0,0,0]);
end