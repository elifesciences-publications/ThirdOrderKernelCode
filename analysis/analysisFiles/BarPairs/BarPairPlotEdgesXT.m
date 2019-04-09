function BarPairPlotEdgesXT(barsPlot, bothBarsOff, barColorOne, barColorTwo, barToCenter, progMot)

if barToCenter == 0
    barShift = 0;
elseif barToCenter == 1;
    barShift = 1;
else
    barShift = -1;
end

if progMot
    axis([0 bothBarsOff -3.5 4.5])
    patch([0 0 bothBarsOff bothBarsOff], [1.5 5.5 5.5 1.5], barColorOne)
    patch([0 0 bothBarsOff bothBarsOff], [-2.5 1.5 1.5 -2.5], barColorTwo)
    % Do the wraparound
    patch([0 0 bothBarsOff bothBarsOff], [-6.5 -2.5 -2.5 -6.5], barColorOne)
   
else
    axis([0 bothBarsOff -3.5 4.5])
    patch([0 0 bothBarsOff bothBarsOff], [-3.5 1.5 1.5 -3.5]+barShift, barColorOne)
    patch([0 0 bothBarsOff bothBarsOff], [1.5 5.5 5.5 1.5]+barShift, barColorTwo)
    % Do the wraparound
    patch([0 0 bothBarsOff bothBarsOff], [-7.5 -3.5 -3.5 -7.5]+barShift, barColorTwo)
    patch([0 0 bothBarsOff bothBarsOff], [5.5 9.5 9.5 5.5]+barShift, barColorOne)
end

barsPlot.Color = get(gcf,'color');
barsPlot.YColor = get(gcf,'color');

barsPlot.XTick = [0 bothBarsOff];
barsPlot.XTickLabel = [0 bothBarsOff];
xlabel('Time (s)');
