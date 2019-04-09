function FigPlot2_OneLN(x_,y_,varargin)

color = 'r';
lineWidth = 5;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
xLimValue = [-0.2,0.2];
yLimValue = [-0.2,0.4];

plotH = plot(x_,y_,'color',color);
plotH.LineWidth = lineWidth;
set(gca,'XLim',xLimValue,'YLim',yLimValue);
hold on
plot(xLimValue,xLimValue,'k--');
hold off
hold on
plot([0,0],yLimValue,'k--');
plot(xLimValue,[0,0],'k--');
set(gca,'data',[1,1,1]);
set(gca,'XTick',-0.2:0.2:0.2);
set(gca,'YTick',-0.2:0.2:0.4);
hold off
% axis tight
xlabel(['predited linear response (\Delta','F/F)']);
ylabel(['Actual Response \Delta','F/F']);

end