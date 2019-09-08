function [plotH,plotTitle] = PlotData(plotType,suppressPlot,varargin)
    %lets you use any of the plot utils, and makes sure the figure is
    %properly saved and annotated
    holdPlot = 0;
    
    if length(suppressPlot) > 1
        holdPlot = suppressPlot(2);
        suppressPlot = suppressPlot(1);
    end
    
    if suppressPlot
        plotH = -1;
        plotTitle = 'null';
        return;
    end
    
    plotFun = str2func(plotType);
    
    if ~holdPlot
        plotH = figure;
        set(plotH,'Position',[200,500,1000,1000],'WindowStyle','docked');
    else
        hold on;
        plotH = -1;
    end
    
    plotTitle = plotFun(varargin{:});
    plotTitle = convertToFilename(plotTitle);
    
    hold off;
end