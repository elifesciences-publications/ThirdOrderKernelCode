function PlotXY_Juyue(x,y,varargin)
% PlotXY_Juyue(x,y,'errofBarFlag',true,'sem',sem)
errorBarFlag = false;
sem = [];
xLabelStr = [];
% wheter determine the yLim ahead
limPreSetFlag = false;
maxValue = 0;
colorMean = [1,0,0];
colorError = [1,0,0];
lineStyle = '-';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end


meanValue = y;
if errorBarFlag
    semValue = sem;
    semUp = meanValue + semValue;
    semBottom = meanValue - semValue;
    
    patchPlotX = [x;x(end:-1:1)];
    patchPlotY = [semUp;semBottom(end:-1:1)];
    hold on
    %     patch(patchPlotX,patchPlotY,'red','EdgeColor','none','FaceColor',[1,0,0],'FaceAlpha',0.2);
    %    h =  patch(patchPlotX,patchPlotY,'red','EdgeColor','none','FaceColor',colorError);
    h =  patch(patchPlotX,patchPlotY,'red','EdgeColor','none','FaceColor',colorError,'FaceAlpha',0.2);
    %     h.FaceVertexCData = colorError;
    h.Annotation.LegendInformation.IconDisplayStyle = 'off';
    hold off
end
if limPreSetFlag
    set(gca,'yLim',[-maxValue,maxValue]);
end
hold on
plot(x,meanValue,'color',colorMean, 'LineStyle',lineStyle);
hold off

hold on
h1 = plot(x,zeros(1,length(x)),'k--');    h1.Annotation.LegendInformation.IconDisplayStyle = 'off';
h2 = plot([0,0],get(gca, 'YLim'),'k--');    h2.Annotation.LegendInformation.IconDisplayStyle = 'off';
hold off

axis tight

end