function PlotDtSweepResponse_EmilioFormat(meanResp,dtNumBank,uncorrelatedResp,flyEye,titleStr,flipByEyeFlag)
% prefered direction is larger than zeros.
% null directio is smaller than zeros.

% dtNumBank minus is moving to left. dtNumBank minus is moving to right.
% if dirTypeEdge == 1 % if it is left selective cell, you put the left dt response to right, to make it a prefered direction.
%     meanResp = flipud(meanResp);
% end
if flipByEyeFlag
    if strcmp(flyEye,'left') || strcmp(flyEye,'Left')
        meanResp = flipud(meanResp);
    end
end
% MakeFigure;
% subplot(2,2,1);
legendStr = {'Phi','Reverse Phi'};
% put the limit of two plots the same. how do you do that?
yLimMin = min(meanResp(:));
yLimMin = yLimMin - 0.1 * abs(yLimMin);
yLimMax = max(meanResp(:));
yLimMax = yLimMax + 0.1 * abs(yLimMax);

% plot zero.
if yLimMin > 0
    yLimMin = 0;
end
if yLimMax < 0
    yLimMax = 0;
end

% you need two kernels, one for phi, another for reverse phi.
% plot the prefered direction and null direction differently....
dirInd = [dtNumBank >= 0; dtNumBank <= 0];
lineStyle = {'-','--'};
for ii = 1:1:2
    if ii == 2
        h = plot(-dtNumBank(dirInd(ii,:)) * 1/60 * 1000,meanResp(dirInd(ii,:),1),'r');
        h.LineStyle = lineStyle{ii};
    else
        h = plot(dtNumBank(dirInd(ii,:)) * 1/60 * 1000,meanResp(dirInd(ii,:),1),'r');
        h.LineStyle = lineStyle{ii};
    end
    hold on
end

for ii = 1:1:2
    if ii == 2
        h = plot(-dtNumBank(dirInd(ii,:)) * 1/60 * 1000,meanResp(dirInd(ii,:),2),'b');
        h.LineStyle = lineStyle{ii};
    else
        h = plot(dtNumBank(dirInd(ii,:)) * 1/60 * 1000,meanResp(dirInd(ii,:),2),'b');
        h.LineStyle = lineStyle{ii};
    end
end
hold on
plot(get(gca,'XLim'),uncorrelatedResp * [1,1],'k');
hold off

xlabel('dt [ms]');
ylabel('response');
hold off
% legend(legendStr);
% set(gca,'YLim',[yLimMin,yLimMax]);
title(titleStr);