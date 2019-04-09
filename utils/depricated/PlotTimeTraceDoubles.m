analysis.GS_T = GrabSnips(analysis.OD,D.data.params,varargin{:},'limits',TTlimits);
analysis.CD_T = CombineDuplicates(analysis.GS_T.comb);
analysis.CI3_T = CombineInput(analysis.CD_T.comb,3);

MakeFigure;
PlotXvsY((TTlimits(1):TTlimits(2)-1)',analysis.CI3_T.turn,'error',analysis.CI3_T.semTurn);
ConfAxis('tickX',linspace(TTlimits(1),TTlimits(2),6),'tickLabelX',linspace(TTlimits(1)/60*1000,TTlimits(2)/60*1000,6));
xlabel('time (miliseconds)');
eX = [analysis.GS.limits(1) analysis.GS.limits(2); analysis.GS.limits(1) analysis.GS.limits(2)];
eY = [get(gca,'ylim')' get(gca,'ylim')' ];
hold on;
plot(eX,eY,'k--','LineWidth',2);
hold off;


MakeFigure;
PlotXvsY((TTlimits(1):TTlimits(2)-1)',analysis.CI3_T.walk,'error',analysis.CI3_T.semWalk);
ConfAxis('tickX',linspace(TTlimits(1),TTlimits(2),6),'tickLabelX',linspace(TTlimits(1)/60*1000,TTlimits(2)/60*1000,6));
xlabel('time (miliseconds)');
eX = [analysis.GS.limits(1) analysis.GS.limits(2); analysis.GS.limits(1) analysis.GS.limits(2)];
eY = [get(gca,'ylim')' get(gca,'ylim')' ];
hold on;
plot(eX,eY,'k--','LineWidth',2);
hold off;
