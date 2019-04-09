function FigPlot_SK_Utils_OpponencySignificance(dt,pval,alpha,plotVerValue)
% how many points, 
pPlotStar = pval < alpha;
hold on
scatter(dt(pPlotStar),ones(1,sum(pPlotStar)) * plotVerValue,'k.');
% give out P value.
hold off
text(1,plotVerValue * 1.5,['p:',num2str(pval(1))]);
text(2,plotVerValue * 1.5, ['p:',num2str(pval(2))]);
text(2.5,plotVerValue,['p< ',num2str(alpha)]);
end