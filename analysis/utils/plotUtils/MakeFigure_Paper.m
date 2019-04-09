function MakeFigure_Paper(varargin)
    plotH = figure('Color',[1 1 1],varargin{:});
    set(plotH,'Units','points','WindowStyle', 'normal', 'Position',[100,0,612, 720], 'DockControl', 'off');
end
