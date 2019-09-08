%%

%%
makeFigure
subplot(2,1,1)
errorbar(log(stdVbank),r.HRC.mean,r.HRC.sem,'rx','lineWidth',1.5);
hold on
errorbar(log(stdVbank),r.k2.mean,r.k2.sem,'gx','lineWidth',1.5);
errorbar(log(stdVbank),r.k3.mean,r.k3.sem,'yx','lineWidth',1.5);
legend('HRC','k2','k3');
title('R between estimated v and real v');
xlabel('standard deviation of velocity');
ylabel('R');
figurePretty;

subplot(2,2,3)
errorbar(log(stdVbank),r.k2.mean,r.k2.sem,'gx','lineWidth',1.5);
hold on
errorbar(log(stdVbank),r.k2plusk3.mean,r.k2plusk3.sem,'rx','lineWidth',1.5);
errorbar(log(stdVbank),r.best.mean,r.best.sem,'bx','lineWidth',1.5);

legend('k2','k2 + k3','best');
title('R between estimated v and real v');
xlabel('standard deviation of velocity');
ylabel('R');

subplot(2,2,4)
errorbar(log(stdVbank),w.mean,w.sem,'bx','lineWidth',1.5);
title('best weighting');
xlabel('standard deviation of velocity [degree/sec]');
ylabel('R');
