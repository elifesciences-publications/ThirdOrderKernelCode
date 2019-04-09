% temparary result
% strInfo contains all kinds of information.
function tempPlot(r,weight,xData,strInfo)
strXLabel = strInfo.xlabel;
strTitle = strInfo.title;

%% plot the r and std.
makeFigure;
plot(xData,r.HRC,'r','lineWidth',3);
hold on
plot(xData,r.k2,'g','lineWidth',3);
plot(xData,r.k3,'y','lineWidth',3);
xlabel(strXLabel);
ylabel('r');
title([strTitle ,': correlation between estimated v and real v']);
legend('HRC','k2','k3');
figurePretty;
grid on
end
