function Velocity_ScatterPlot_Utils(xlabel_str, ylabel_str, varargin)
y_lim_flag = false;
ylim = [];
XTick = [-500, 500];
xLim = [-650, 650];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
set(gca, 'XAxisLocation','origin', 'YAxisLocation','origin');
set(gca,'YTick',[],'XTick',[]);
set(gca,'XTick',XTick, 'XTickLabel',strsplit(num2str(XTick)));
set(gca,'XLim', xLim);
if y_lim_flag 
    set(gca, 'YLim', ylim);
end
yLim = get(gca, 'YLim');

xLim = get(gca, 'XLim');
xl = xlabel(xlabel_str,'VerticalAlignment','middle','HorizontalAlignment','center');
yl = ylabel(ylabel_str,'Rotation', 90, 'HorizontalAlignment','center');
xl.Position = [0, yLim(1) - diff(yLim) * 0.1, 0];
yl.Position = [xLim(1) - diff(xLim) * 0.1, 0, 0];
