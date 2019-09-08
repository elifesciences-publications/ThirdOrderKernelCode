function PlotXRExtremTheo(Extr,NoExtr,xData,p)

%% plot the r and velocity , for 
makeFigure;
subplot(2,2,1)
plot(xData,Extr.HRC,'r','lineWidth',3);
hold on
plot(xData,Extr.bestConvK3,'g','lineWidth',3);
plot(xData,Extr.bestPSK3,'y','lineWidth',3);
xlabel('velocity [degree/second]');
ylabel('r');
title(['All data points : correlation between predicted v and real v']);
legend('HRC','Converging K3','Past Skew K3');
figurePretty;
grid on

subplot(2,2,2)
plot(xData,Extr.HRC,'r','lineWidth',3);
hold on
plot(xData,Extr.HRCConvK3,'g','lineWidth',3);
plot(xData,Extr.HRCPSK3,'y','lineWidth',3);
plot(xData,Extr.HRCCP,'m','lineWidth',3);
xlabel('velocity [degree/second]');
ylabel('r');
legend('HRC','HRC + Converging K3','HRC + Past-Skew K3','HRC + CK3 + PS');
figurePretty;
grid on

subplot(2,2,3)
plot(xData,NoExtr.HRC,'r','lineWidth',3);
hold on
plot(xData,NoExtr.bestConvK3,'g','lineWidth',3);
plot(xData,NoExtr.bestPSK3,'y','lineWidth',3);
xlabel('velocity [degree/second]');
ylabel('r');
title([num2str(100 - 2 * p), ' percentile of the data points: correlation between predicted v and real v']);
legend('HRC','Converging K3','Past Skew K3');
figurePretty;
grid on

subplot(2,2,4)
plot(xData,NoExtr.HRC,'r','lineWidth',3);
hold on
plot(xData,NoExtr.HRCConvK3,'g','lineWidth',3);
plot(xData,NoExtr.HRCPSK3,'y','lineWidth',3);
plot(xData,NoExtr.HRCCP,'m','lineWidth',3);
xlabel('velocity [degree/second]');
ylabel('r');
legend('HRC','HRC + Converging K3','HRC + Past-Skew K3','HRC + CK3 + PS');
figurePretty;
grid on
end