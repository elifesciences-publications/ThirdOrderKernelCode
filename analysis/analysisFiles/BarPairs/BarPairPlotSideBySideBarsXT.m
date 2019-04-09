function BarPairPlotSideBySideBarsXT(barsPlot, bothBarsOff, secondBarDelay, barColorOne, barColorTwo, barToCenter, progMot)

if barToCenter == 0
    barShift = 0;
elseif barToCenter == 1;
    barShift = 1;
else
    barShift = -1;
end

if progMot
    axis([0 bothBarsOff -3.5 4.5])
    patch([0 0 bothBarsOff bothBarsOff], [1.5 2.5 2.5 1.5], barColorOne)
    patch([secondBarDelay secondBarDelay bothBarsOff bothBarsOff], [0.5 1.5 1.5 0.5], barColorTwo)
   
else
    axis([0 bothBarsOff -3.5 4.5])
    patch([0 0 bothBarsOff bothBarsOff], [0.5 1.5 1.5 0.5] + barShift, barColorOne)
    patch([secondBarDelay secondBarDelay bothBarsOff bothBarsOff], [1.5 2.5 2.5 1.5] + barShift, barColorTwo)
end

barsPlot.Color = get(gcf,'color');
barsPlot.YColor = get(gcf,'color');
if secondBarDelay == 0
    secondBarDelay = [];
end
barsPlot.XTick = [0 secondBarDelay bothBarsOff];
barsPlot.XTickLabel = [0 secondBarDelay bothBarsOff];
xlabel('Time (s)');

hold on
if barToCenter == 2
    plot([0,0], [0.5 1.5], 'r', 'LineWidth', 5);
elseif barToCenter == 1
    plot([0,0], [1.5 2.5], 'r', 'LineWidth', 5);
end
hold off