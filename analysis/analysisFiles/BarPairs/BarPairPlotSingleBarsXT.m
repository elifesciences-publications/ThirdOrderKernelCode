function BarPairPlotSingleBarsXT(barsPlot, barsOff, barDelay, barColor, epochDuration)

    if nargin<5
        epochDuration = barsOff;
    end
    axis([0 epochDuration -3.5 4.5])
    patch([barDelay barDelay barsOff barsOff], [0.5 1.5 1.5 0.5], barColor)

    hold on
    plot([0,0], [0.5 1.5], 'r', 'LineWidth', 5);

    
    barsPlot.Color = get(gcf,'color');
    barsPlot.YColor = get(gcf,'color');
    barsPlot.XTick = [0 barsOff];
    barsPlot.XTickLabel = [0 barsOff];
    xlabel('Time (s)');
