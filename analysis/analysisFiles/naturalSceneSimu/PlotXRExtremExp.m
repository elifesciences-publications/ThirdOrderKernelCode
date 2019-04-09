function PlotXRExtremExp(Extr,NoExtr,ExtW,NoExtW,xData,p)
%% plot the r and std.
makeFigure;
subplot(2,3,1)
plot(xData,Extr.k2,'g','lineWidth',3);
hold on
plot(xData,Extr.k3,'y','lineWidth',3);
xlabel('velocity [degree/second]');
ylabel('r');
title(['All data points : correlation between predicted v and real v']);
legend('k2','k3');
figurePretty;
grid on
%% only use 95 % of the data to do analysis.

%% plot the Extr.k2,Extr.k3, and r 
subplot(2,3,2)
plot(xData,Extr.k2,'g','lineWidth',3);
hold on
plot(xData,Extr.k3,'y','lineWidth',3);
plot(xData,Extr.k2plusk3,'b','lineWidth',3);
plot(xData,Extr.best,'m','lineWidth',3);
xlabel('velocity [degree/second]');
ylabel('r');
legend('k2','k3','k2+k3','best');
figurePretty;
grid on

%% plot the extr.k2 and extr.k3 best weighting;
subplot(2,3,3)
bestRatio = ExtW(2,:)./ExtW(1,:);
plot(xData,bestRatio,'m','lineWidth',3);
xlabel('velocity [degree/second]');
ylabel('K3/K2');
legend('best weighting');
figurePretty;
grid on

%%
subplot(2,3,4)
plot(xData,NoExtr.k2,'g','lineWidth',3);
hold on
plot(xData,NoExtr.k3,'y','lineWidth',3);
xlabel('velocity [degree/second]');
ylabel('r');
title([num2str(100 - 2 * p),'%: correlation between predicted v and real v']);
legend('k2','k3');
figurePretty;
grid on
%% only use 95 % of the data to do analysis.

%% plot the NoExtr.k2,NoExtr.k3, and r 
subplot(2,3,5)
plot(xData,NoExtr.k2,'g','lineWidth',3);
hold on
plot(xData,NoExtr.k3,'y','lineWidth',3);
plot(xData,NoExtr.k2plusk3,'b','lineWidth',3);
plot(xData,NoExtr.best,'m','lineWidth',3);
xlabel('velocity [degree/second]');
ylabel('r');
legend('k2','k3','k2+k3','best');
figurePretty;
grid on

%
subplot(2,3,6)
bestRatio = NoExtW(2,:)./NoExtW(1,:);
plot(xData,bestRatio,'m','lineWidth',3);
xlabel('velocity [degree/second]');
ylabel('K3/K2');
legend('best weighting');
figurePretty;
grid on
end