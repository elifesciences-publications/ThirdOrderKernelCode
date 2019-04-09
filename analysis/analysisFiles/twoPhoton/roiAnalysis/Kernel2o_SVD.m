function [kernelFromSVD, U,V] = Kernel2o_SVD(kernel,titleStr)
% first, get the relevant point out.
timeUnit = 1/60;
dt = -30:1:30;
tMax = 30;
maxTauSquared = length(kernel);
maxTau = round(sqrt(maxTauSquared));

ind = 1:1:maxTau^2;
ind = reshape(ind,[maxTau,maxTau]);

nDt = length(dt);
indOffDia = zeros(tMax,nDt);
for ii = 1:1:nDt
    temp = diag(ind,dt(ii));
    indOffDia(:,ii) = temp(1:tMax);
end

flatKernel = zeros(tMax,nDt);
for ii = 1:1:nDt
    flatKernel(:,ii) = kernel(indOffDia(:,ii));
end

[U,S,V] = svd(flatKernel);
kernel1Component = U(:,1) * V(:,1)'; 
% predicted 2 second order by svd;
kernelFromSVD = zeros(size(kernel));
for ii = 1:1:nDt
    kernelFromSVD((indOffDia(:,ii))) =  kernel1Component(:,ii);
end

MakeFigure;
subplot(2,3,1);
quickViewOneKernel(kernel,2);
title(titleStr);
subplot(2,3,2);
quickViewOneKernel(flatKernel,1,'posLabelStr','time [s]','posUnit',timeUnit);
title('flattened kernel');
subplot(2,3,5);
quickViewOneKernel(kernel1Component,1,'posLabelStr','time [s]','posUnit',timeUnit);

subplot(2,3,4);
quickViewOneKernel(kernelFromSVD,2);

subplot(4,3,9);
plot(timeUnit * (1:tMax),U(:,1)/sum(U(:,1)));
xLim = get(gca,'XLim'); yLim = get(gca,'YLim'); hold on;
plot(xLim,[0,0],'k--');plot([0,0],yLim,'k--');
title('along diagonal kinetics')
subplot(4,3,12);
plot(dt * timeUnit,V(:,1)/sum(V(:,1))); 
xlabel('time[s]');
xLim = get(gca,'XLim'); yLim = get(gca,'YLim'); hold on;
plot(xLim,[0,0],'k--');plot([0,0],yLim,'k--');
xlabel('time[s]');
title('dt response');
%% look at the middle one, whether it is diagnal...
% MakeFigure;
% A = zeros(maxTauSquared,1);
% A(indOffDia(:,31)) = 1;
% quickViewKernelsSecond(A)

end

