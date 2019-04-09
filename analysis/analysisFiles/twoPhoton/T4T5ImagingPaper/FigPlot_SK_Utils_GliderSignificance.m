function FigPlot_SK_Utils_GliderSignificance(dt,pval,alpha,plotVerValue,showPValueFlag)
% how many points,
pPlotStar = pval < alpha;
n = length(pval);
pPlotDoubleStar = pval < alpha./n;


hold on
scatter(dt(pPlotStar),ones(1,sum(pPlotStar)) * plotVerValue,'k+', 'LineWidth', 10);
text(max(dt) * 1.1,plotVerValue,['p < ', num2str(alpha)]);
scatter(dt(pPlotDoubleStar),ones(1,sum(pPlotDoubleStar)) * plotVerValue * 1.2,'k+','LineWidth', 10);
text(max(dt)* 1.1,plotVerValue * 1.2,['p < ', num2str(alpha./n)]);
hold off

if showPValueFlag
    for ii = 1:1:length(dt)
        text(dt(ii),plotVerValue *  1.5,['p:',num2str(pval(ii))],'Rotation',90);
    end
end
end