nboot = 10000;
[result,bootsam] = bootstrp(nboot,@AnalysizeCorr,vHRC,vk2,vk3,vreal);

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
makeFigure
nbin = 50;
[counts,centers] = hist(weight(2,:)./weight(1,:),nbin);
plot(centers,counts,'r','lineWidth',3);
title('bootstraping,histgram of ratio of Weight K3/K2');
xlabel('K3/K2')
ylabel('counts');
figurePretty;
