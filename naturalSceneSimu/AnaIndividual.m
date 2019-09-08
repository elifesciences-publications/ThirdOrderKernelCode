% try to plot the correlation varied with real data.
function result = AnaIndividual(v, p, bsFlag)
%p = 5;
nboot = 10000;

r.HRC = zeros(1,nboot);
r.k2 = zeros(1,nboot);
r.k3 = zeros(1,nboot);
r.k2k3 = zeros(1,nboot);
r.best = zeros(1,nboot);
weight = zeros(2,nboot);

% preprocess the original data, get the 90 percentile of the data, exclude
% the extreme value.
[~,indHRC] = PerV(p,v.HRC);
[~,indk2] = PerV(p,v.k2);
[~,indk3] = PerV(p,v.k3);
ind = indHRC & indk2 & indk3;
sizeData = sum(ind);

vHRC = v.HRC(ind);
vk2 = v.k2(ind);
vk3 = v.k3(ind);
vreal = v.real(ind);

%%
if bsFlag 
[result,~] = bootstrp(nboot,@AnalysizeCorr,vHRC,vk2,vk3,vreal);

%%
for i = 1:1:nboot
    r.HRC(i) = result(i).r.HRC;
    r.k2(i) = result(i).r.k2;
    r.k3(i) = result(i).r.k3;
    r.k2plusk3(i) = result(i).r.k2plusk3;
    r.best(i) = result(i).r.best;
    weight(:,i) = result(i).weight;
end

%% show result. startwith the easist.

makeFigure;
subplot(2,1,1)
nbin = 50;
[counts,centers] = hist(r.HRC,nbin);
plot(centers,counts,'r','lineWidth',3);
hold on
[counts,centers] = hist(r.k2,nbin);
plot(centers,counts,'g','lineWidth',3);
[counts,centers] = hist(r.k3,nbin);
plot(centers,counts,'b','lineWidth',3);
[counts,centers] = hist(r.best,nbin);
plot(centers,counts,'y','lineWidth',3);
[counts,centers] = hist(r.k2plusk3,nbin);
plot(centers,counts,'m','lineWidth',3);

legend('HRC','k2','k3','best','k2plusk3');
title('bootstraping,histgram of R');
xlabel('R')
ylabel('counts');
figurePretty;


%%
subplot(2,2,3)
nbin = 50;
[counts,centers] = hist(weight(2,:)./weight(1,:),nbin);
plot(centers,counts,'r','lineWidth',3);
title('bootstraping,histgram of ratio of Weight K3/K2');
xlabel('K3/K2')
ylabel('counts');
figurePretty;

else
    result = AnalysizeCorr(vHRC,vk2,vk3,vreal);
end
end