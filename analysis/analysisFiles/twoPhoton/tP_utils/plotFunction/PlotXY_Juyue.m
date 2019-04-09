function PlotXY_Juyue(x,y,varargin)
errorBarFlag = false;
sem = [];
xLabelStr = [];
% wheter determine the yLim ahead
limPreSetFlag = false;
maxValue = 0;
colorMean = [1,0,0];
colorError = [1,0,0];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end


meanValue = y;
plot(x,meanValue,'color',colorMean);
if errorBarFlag
    semValue = sem;
    semUp = meanValue + semValue;
    semBottom = meanValue - semValue;
    
    patchPlotX = [x;x(end:-1:1)];
    patchPlotY = [semUp;semBottom(end:-1:1)];
    hold on
%     patch(patchPlotX,patchPlotY,'red','EdgeColor','none','FaceColor',[1,0,0],'FaceAlpha',0.2);
%    h =  patch(patchPlotX,patchPlotY,'red','EdgeColor','none','FaceColor',colorError);
    h =  patch(patchPlotX,patchPlotY,'red','EdgeColor','none','FaceColor',colorError);
%     h.FaceVertexCData = colorError;
    hold off
    
    if limPreSetFlag
        set(gca,'yLim',[-maxValue,maxValue]);
    end
end
hold on
plot(x,meanValue,'color',colorMean);
hold off

hold on
plot(x,zeros(1,length(x)),'k--');
ax = gca;
yLim = ax.YLim;
plot([0,0],yLim,'k--');
hold off
%% put the integration line there...
hold on
plot([8,8] * 1/60,yLim,'k--');
plot([-8,-8] * 1/60,yLim,'k--');
hold off

%% change the tick so that the it is [0,50,100,150,250]; %
% first, get rid of the tick?
ax = gca;
a = [-250,-150,-100,-50,0,50,100,150,250]/1000;
ax.XTick = a
ax.XTickLabel = strread(num2str(a * 1000),'%s')
ax.XTickLabelRotation = 45;
%%
xLabelStr = 'ms'
xlabel(xLabelStr);
end