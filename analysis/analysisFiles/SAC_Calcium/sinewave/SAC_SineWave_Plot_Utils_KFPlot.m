function SAC_SineWave_Plot_Utils_KFPlot(resp, set_clim, c_max)
mymap = flipud(brewermap(100,'RdBu'));
colormap(mymap);

imagesc(resp);
set(gca ,'XTick', [1, 2, 3, 4], 'XTickLabel', {'1/15', '1/30', '1/60', '1/90'});
set(gca, 'YDir', 'normal');
set(gca, 'XDir', 'reverse');

set(gca ,'YTick', [1:10], 'YTickLabel', {'1/2','\surd{2}/2', '1', '\surd{2}', '2', '2\surd{2}','4','4\surd{2}','8', '8\surd{2}'});
ylabel('temporal frequency (Hz)');
xlabel('spatial frequency');

if set_clim
    set(gca, 'CLim', [-c_max, c_max]);
else
    c_max = max(abs(resp(:)));
    set(gca, 'CLim', [-c_max, c_max]);
end

ConfAxis('fontSize', 15);
box on;

%% set up the tick for colorbar.
ch = colorbar;
% min_val = min(min(resp(:)), 0);
% set(ch, 'XTick', [min_val, c_max]);
end