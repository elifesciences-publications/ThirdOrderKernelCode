function PlotXRW(r,weight,mut,xData,strInfo)
% strInfo contains all kinds of information.
strXLabel = strInfo.xlabel;
strTitle = strInfo.title;

%% plot the r and std.
makeFigure;
subplot(2,2,1)
plot(xData,r.k2,'g','lineWidth',3);
hold on
plot(xData,r.k3,'y','lineWidth',3);
xlabel(strXLabel);
ylabel('r');
title([strTitle ,': correlation between estimated v and real v']);
legend('k2','k3');
figurePretty;
grid on
%% only use 95 % of the data to do analysis.

%% plot the r.k2,r.k3, and r
subplot(2,2,2)
plot(xData,r.k2,'g','lineWidth',3);
hold on
plot(xData,r.k3,'y','lineWidth',3);
plot(xData,r.k2plusk3,'b','lineWidth',3);
plot(xData,r.best,'m','lineWidth',3);
xlabel(strXLabel);
ylabel('r');
legend('k2','k3','k2+k3','best');
figurePretty;
grid on

%%
subplot(2,2,3)
plot(xData,weight(2,:)./weight(1,:),'lineWidth',3);
title([strTitle ,': best weighting']);
xlabel(strXLabel);
ylabel('K3 / K2');
figurePretty;
grid on

%% correlation between k2 and k3 should be included.
% subplot(2,2,4)
% colorStr = ['g','y','r'];
% for i = 1:1:3
%     plot(xData,mut.r(:,i),colorStr(i),'lineWidth',3);
%     hold on
% end
% xlabel(strXLabel);
% ylabel('r');
% title('correlation between different predicted velocities')
% legend('HRC vs k2','HRC vs k3', 'k2 vs k3');
% figurePretty;
% grid on

subplot(2,2,4)
colorStr = ['r'];
plot(xData,mut.k2k3,colorStr,'lineWidth',3);
hold on
xlabel(strXLabel);
ylabel('r');
title('correlation between different predicted velocities')
legend('k2 vs k3');
figurePretty;
grid on

end