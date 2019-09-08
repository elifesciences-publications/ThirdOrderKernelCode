function [r,weight,mutR] = CorrCalFromDtoR_NoExtremValue(D)

modeExtreme = 'number';
modeExtreme  = 'percentile';
number = 10;
p = 0.1;
v = D.v;
indk2 = FindExtVel(v.k2,modeExtreme,p,number);
indk3 = FindExtVel(v.k3,modeExtreme,p,number);


% you have to get rid of the numbers that you do not like. 
% both standard.
ind = false(size(D.v.real));
ind(indk2 | indk3) = true;

vNoExtreme = [D.v.real(~ind),D.v.k2(~ind),D.v.k3(~ind)];

r.k2 = corr(vNoExtreme(:,1),vNoExtreme(:,2));
r.k3 = corr(vNoExtreme(:,1),vNoExtreme(:,3));
r.k2plusk3 = corr(vNoExtreme(:,1),vNoExtreme(:,2)+vNoExtreme(:,3));
mutR = corr(vNoExtreme(:,2),vNoExtreme(:,3));

XX = [vNoExtreme(:,2),vNoExtreme(:,3)];
weight = (XX\vNoExtreme(:,1));
vbest = ( XX * weight);


MakeFigure;
subplot(2,2,1)
PlotLNModel(vNoExtreme(:,1),vNoExtreme(:,2));

subplot(2,2,2)
PlotLNModel(vNoExtreme(:,1),vNoExtreme(:,3));

subplot(2,2,3)
PlotLNModel(vNoExtreme(:,1),vNoExtreme(:,3)+vNoExtreme(:,2));

subplot(2,2,4)
PlotLNModel(vNoExtreme(:,1),vbest);
end