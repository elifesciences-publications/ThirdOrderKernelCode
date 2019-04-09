function BarPairPlotOneApartBarsXT(barsPlot, bothBarsOff, secondBarDelay, barColorOne, barColorTwo)

axis([0 bothBarsOff -3.5 4.5])
patch([0 0 bothBarsOff bothBarsOff], [1.5 2.5 2.5 1.5], barColorOne)
patch([secondBarDelay secondBarDelay bothBarsOff bothBarsOff], [-0.5 0.5 0.5 -0.5], barColorTwo)

barsPlot.Color = get(gcf,'color');
barsPlot.YColor = get(gcf,'color');
barsPlot.XTick = [0 bothBarsOff];
barsPlot.XTickLabel = [0 bothBarsOff];
xlabel('Time (s)');