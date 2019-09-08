function SemilogXRW(r,weight,xData,strInfo)
% strInfo contains all kinds of information.
strXLabel = strInfo.xlabel;
strTitle = strInfo.title;

%% semilogx the r and std.
makeFigure;
subplot(2,2,1)
semilogx(xData,r.HRC,'r','lineWidth',3);
hold on
semilogx(xData,r.k2,'g','lineWidth',3);
semilogx(xData,r.k3,'y','lineWidth',3);
xlabel(strXLabel);
ylabel('r');
title([strTitle ,': correlation between estimated v and real v']);
legend('HRC','k2','k3');
figurePretty;
grid on
%% only use 95 % of the data to do analysis.

%% semilogx the r.k2,r.k3, and r 
subplot(2,2,2)
semilogx(xData,r.k2,'g','lineWidth',3);
hold on
semilogx(xData,r.k3,'y','lineWidth',3);
semilogx(xData,r.k2plusk3,'b','lineWidth',3);
semilogx(xData,r.best,'m','lineWidth',3);
xlabel(strXLabel);
ylabel('r');
legend('k2','k3','k2+k3','best');
figurePretty;
grid on

%%
subplot(2,2,3)
semilogx(xData,weight(2,:)./weight(1,:),'lineWidth',3);
title([strTitle ,': best weighting']);
xlabel(strXLabel);
ylabel('K3 / K2');
figurePretty;
grid on

end