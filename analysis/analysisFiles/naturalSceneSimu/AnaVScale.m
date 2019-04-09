% try to plot the range of data...
function AnaVScale(v)

p = [0,0.05,2.5,5];
withinP = 100 - 2 * p;
np = length(p);

% stdv.HRC = zeros(1,np);
% stdv.k2 = zeros(1,np);
% stdv.k3 = zeros(1,np);
makeFigure;
for i = 1:1:np
    
    [vHRC,indHRC] = PerV(p(i),v.HRC);
    [vk2,indk2] = PerV(p(i),v.k2);
    [vk3,indk3] = PerV(p(i),v.k3);
   
%     stdv.vHRC(i) = std(vHRC);
%     stdv.k2(i) = std(vk2);
%     stdv.k3(i) = std(vk3);
    strTitle = ['histogram of ', num2str(withinP((i))),' precentile'];
    DistrHistPlot(vHRC,vk2,vk3,strTitle);
end

%% plot the std.
% makeFigure;
% plot(withinP,stdv.HRC,'r','lineWidth',1.5);
% hold on
% plot(withinP,stdv.k2,'g','lineWidth',1.5);
% plot(withinP,stdv.k3,'b','lineWidth',1.5);
% xlabel('percentile');
% ylabel('standard deviation');
% legend('HRC','k2','k3');
% figurePretty;
end
