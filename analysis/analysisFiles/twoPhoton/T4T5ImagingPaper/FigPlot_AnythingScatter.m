function FigPlot_AnythingScatter(x,y,edgeType,xLabelStr,yLabelStr,titleStr)
% predDSI_plot = predDSI_r;
% DSI_plot = DSI;
typeStr = {'T4 Progressive','T4 Regressive','T5 Progressive','T5 Regressive'};
[~,edgeTypeColorRGB,~] = FigPlot1ColorCode();

% you have to find the Lim....
yLimMax = max(abs(y)); 
xLimMax = max(abs(x));

for tt = 1:1:4
    roiUse = find(edgeType == tt);
    if isempty(roiUse)
        disp('bad luck, no good fly for this type');
    else
       scatter(x(roiUse),y(roiUse),'MarkerFaceColor',edgeTypeColorRGB(tt,:),'MarkerEdgeColor','none');
        hold on
        xlabel(xLabelStr);
        ylabel(yLabelStr);
        set(gca,'YLim',[-yLimMax, yLimMax]);
        set(gca,'XLim',[-xLimMax,xLimMax]);
        axis equal
%         ConfAxis;
    end
end
% legend(typeStr);
hold on
plot([0,0],[-yLimMax,yLimMax],'k--');
plot([-xLimMax,xLimMax],[0,0],'k--');
hold off
title(titleStr);
end