function [p_mean] = PlotXY_Juyue(x,y,varargin)
% PlotXY_Juyue(x,y,'errofBarFlag',true,'sem',sem)
% Or PlotXY_Juyue(x, y, errorBarFlag, 'tru', 'sem', sem, 'asym_sem_flag', true)
errorBarFlag = false;
sem = [];
xLabelStr = [];
% wheter determine the yLim ahead
limPreSetFlag = false;
maxValue = 0;
colorMean = lines(1);
colorError = lines(1);
asym_sem_flag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end


meanValue = y;
p_mean = plot(x,meanValue,'color',colorMean);
if errorBarFlag
    if asym_sem_flag
        semBottom = sem(1,:)'; % lower bound.
        semUp = sem(2,:)'; % higher bound.
    else
        semUp = meanValue + sem;
        semBottom = meanValue - sem;
    end
    patchPlotX = [x;x(end:-1:1)];
    patchPlotY = [semUp;semBottom(end:-1:1)];
    hold on
    %     patch(patchPlotX,patchPlotY,'red','EdgeColor','none','FaceColor',[1,0,0],'FaceAlpha',0.2);
    %    h =  patch(patchPlotX,patchPlotY,'red','EdgeColor','none','FaceColor',colorError);
    h =  patch(patchPlotX,patchPlotY,colorError,'EdgeColor','none','FaceColor',colorError,'FaceAlpha',0.25);
%     error = bsxfun(@minus,y,sem);
%     g = errorbar(x,y,sem,'marker','o', 'color', colorError);
    %     h.FaceVertexCData = colorError;
    hold off
end
if limPreSetFlag
    set(gca,'yLim',[-maxValue,maxValue]);
end


% hold on
% plot(x,zeros(1,length(x)),'k--');
% ax = gca;
% yLim = ax.YLim;
% plot([0,0],yLim,'k--');
% hold off
% 
% axis tight
%% put the integration line there...
% hold on
% plot([8,8] * 1/60,yLim,'k--');
% plot([-8,-8] * 1/60,yLim,'k--');
% hold off

%% change the tick so that the it is [0,50,100,150,250]; %
% first, get rid of the tick?
% ax = gca;
% a = [-250,-150,-100,-50,0,50,100,150,250]/1000;
% ax.XTick = a
% ax.XTickLabel = strread(num2str(a * 1000),'%s')
% ax.XTickLabelRotation = 45;
% %%
% xLabelStr = 'ms'
% xlabel(xLabelStr);
end