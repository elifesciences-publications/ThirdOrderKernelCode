function plotH = ScatterXYBinned(x,y,nBins,nOneBin,varargin)
% ScatterXYBinned(x,y,nBins,nOneBin,color,'r','lineWidth',5,'markerType','o','setAxisLimFlag',1,'plotDashLineFlag',1);
color = 'r';
lineWidth = 5;
markerType = 'o';
setAxisLimFlag = 1;
plotDashLineFlag = 1;
plotXYCordi = false;
edge_distribution = 'linear';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

[x_,y_,n] = BinXY(x,y,'x','nbins', nBins, 'edge_distribution', edge_distribution);
% you might need a flag to decide whether to plot this range.
xPlot = x_(n>nOneBin);
yPlot = y_(n>nOneBin);
xValue = max(abs(xPlot));
yValue = max(abs(yPlot));

xLimValue = [-xValue - 0.1 * xValue,xValue + 0.1 * xValue];
yLimValue = [-yValue - 0.1 * yValue,yValue + 0.1 * yValue];
% can you change the color and the lineWidth?
plotH = scatter(x_(n>nOneBin),y_(n>nOneBin),'filled');

plotH.LineWidth = lineWidth;
plotH.Marker = markerType;
plotH.MarkerEdgeColor = color;
plotH.MarkerFaceColor = color;
% ConfAxis;

if setAxisLimFlag
set(gca,'XLim',xLimValue,'YLim',yLimValue);
end
if plotDashLineFlag 
hold on
plot(xLimValue,yLimValue,'b--');
hold off
end
if plotXYCordi
    hold on
    plot([0,0],yLimValue,'k--');
    plot(xLimValue,[0,0],'k--');
    hold off
end
% legend(['nbins :',num2str(nBins),', data in one bin : ',num2str(nOneBin)]);
end