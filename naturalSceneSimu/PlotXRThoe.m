function PlotXRThoe(r,mut,xData,strInfo)
% strInfo contains all kinds of information.
strXLabel = strInfo.xlabel;
strTitle = strInfo.title;

%% plot the r and velocity , for 
makeFigure;
subplot(2,2,1)
plot(xData,r.HRC,'r','lineWidth',3);
hold on
plot(xData,r.bestConvK3,'g','lineWidth',3);
plot(xData,r.bestPSK3,'y','lineWidth',3);
xlabel(strXLabel);
ylabel('r');
title([strTitle ,': correlation between estimated v and real v']);
legend('HRC','Converging K3','Past Skew K3');
figurePretty;
grid on

subplot(2,2,2)
plot(xData,r.HRC,'r','lineWidth',3);
hold on
plot(xData,r.HRCConvK3,'g','lineWidth',3);
plot(xData,r.HRCPSK3,'y','lineWidth',3);
plot(xData,r.HRCCP,'m','lineWidth',3);
xlabel(strXLabel);
ylabel('r');
legend('HRC','HRC + Converging K3','HRC + Past-Skew K3','HRC + CK3 + PS');
figurePretty;
grid on

%% plot the correlation between, hrc, convk3, pask3 and convk3, pask3?

end