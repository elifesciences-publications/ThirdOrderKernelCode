function FigPlot_Scatter_VarAndCorr(data,varargin)
% you need a way to track the thing you are plotting.1
colorTable.resp = [1,1,0]; % red
colorTable.firstOrder = [1,0,0]; % yellow
colorTable.secondOrder = [0,0,0]; % black
colorTable.LN_Poly2 = [0,1,0]; % green;
colorTable.LN_Rec = [0,0,1]; % blue;
colorTable.firstPlusSecond = [1,0,1]; % pink;
legendStr = '';
titleStr = '';
markerArea = 1;
LineWidth = 1;
setLogScaleFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% it should be larger.
varExplained = data(:,end);
% use legend to find the index for each one. 
ind = find(strcmp(legendStr,'1o'));
r1 = data(:,ind);
ind = find(strcmp(legendStr,'2o'));
r2 =  data(:,ind );
ind = find(strcmp(legendStr,'LN-Poly'));
rLN_poly =  data(:,ind);
ind = find(strcmp(legendStr,'LN-Rec'));
rLN_Rec =  data(:,ind );
ind = find(strcmp(legendStr,'1o+2o'));
r1r2 =  data(:,ind);

scatter(varExplained.^2,r1.^2,markerArea ,'MarkerEdgeColor',colorTable.firstOrder,'MarkerFaceColor',colorTable.firstOrder,'LineWidth',LineWidth);hold on;xlabel('varExplainedByMean');
scatter(varExplained.^2,r2.^2,markerArea ,'MarkerEdgeColor',colorTable.secondOrder,'MarkerFaceColor',colorTable.secondOrder,'LineWidth',LineWidth);hold on;xlabel('varExplainedByMean');
scatter(varExplained.^2,rLN_poly.^2,markerArea ,'MarkerEdgeColor',colorTable.LN_Poly2,'MarkerFaceColor',colorTable.LN_Poly2,'LineWidth',LineWidth);hold on;xlabel('varExplainedByMean');
scatter(varExplained.^2,rLN_Rec.^2,markerArea ,'MarkerEdgeColor',colorTable.LN_Rec,'MarkerFaceColor',colorTable.LN_Rec,'LineWidth',LineWidth);hold on;xlabel('varExplainedByMean');
scatter(varExplained.^2,r1r2.^2,markerArea ,'MarkerEdgeColor',colorTable.firstPlusSecond,'MarkerFaceColor',colorTable.firstPlusSecond,'LineWidth',LineWidth);hold on;xlabel('varExplainedByMean');
ylabel('r^2 by Model' );
xlabel('Var Explained By Mean');
legend(legendStr,'Location','northwest');
% put the legend to the left side.
% you should get the x axis;
ax = gca;
xLim = ax.XLim;
hold on; plot(linspace(0,xLim(2),15),linspace(0,xLim(2),15),'b--');
title(titleStr);

if setLogScaleFlag
    set(gca,'xscale','log'); set(gca,'yscale','log');
end
end