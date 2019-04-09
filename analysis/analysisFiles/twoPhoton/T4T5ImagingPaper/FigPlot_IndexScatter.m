function FigPlot_IndexScatter(x,y,edgeType,xLabelStr,yLabelStr,titleStr)
% predDSI_plot = predDSI_r;
% DSI_plot = DSI;
typeStr = {'T4 Progressive','T4 Regressive','T5 Progressive','T5 Regressive'};
[~,edgeTypeColorRGB,~] = FigPlot1ColorCode();
for tt = 1:1:4
    roiUse = find(edgeType == tt);
    if isempty(roiUse)
        disp('bad luck, no good fly for this type');
    else
       scatter(x(roiUse),y(roiUse),'MarkerFaceColor',edgeTypeColorRGB(tt,:),'MarkerEdgeColor','none');
        hold on
        xlabel(xLabelStr);
        ylabel(yLabelStr);
        axis([-1,1,-1,1]);
        axis equal
%         ConfAxis;
    end
end
% legend(typeStr)
title(titleStr);
hold on
plot([0,0],[-1,1],'k--');
plot([-1,1],[0,0],'k--');
hold off
end