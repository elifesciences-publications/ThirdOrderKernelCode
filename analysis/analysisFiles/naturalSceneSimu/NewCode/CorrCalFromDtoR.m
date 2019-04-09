function [r,weight,mutR] = CorrCalFromDtoR(D)

r.k2 = corr(D.v.k2,D.v.real);
r.k3 = corr(D.v.k3,D.v.real);
r.k2plusk3 = corr(D.v.k2 + D.v.k3,D.v.real);

XX = [D.v.k2,D.v.k3];
weight = (XX\D.v.real);
vbest = ( XX * weight);
r.best= corr(vbest,D.v.real);

mutR = corr(D.v.k2,D.v.k3);

MakeFigure;
subplot(2,2,1)
PlotLNModel(D.v.real,D.v.k2);

subplot(2,2,2)
PlotLNModel(D.v.real,D.v.k3);

subplot(2,2,3)
PlotLNModel(D.v.real,D.v.k2 + D.v.k3);

subplot(2,2,4)
PlotLNModel(D.v.real,vbest);

end
% for the best weighting...
% wrigth your own function here.


