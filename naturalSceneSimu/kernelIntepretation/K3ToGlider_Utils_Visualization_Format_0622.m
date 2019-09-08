function K3ToGlider_Utils_Visualization_Format_0622(firstKernel,secondKernel,thirdKernelCorrType,dtBankStr)
% this is only one format. 

% think of other format... for 20 bars...
MakeFigure;
subplot(2,2,1);
quickViewOneKernel(flipud(firstKernel),1);
subplotNum = [9,11,13,15;10,12,14,16];
plotSequence = [4,7,5,9]; % this only works for the 9 corrMethod... % try out differ
maxValue = max([max(max(abs(thirdKernelCorrType{1}(plotSequence,:)))),max(max(abs(thirdKernelCorrType{2}(plotSequence,:))))]);
for cc = 1:1:2
    for ii = 1:1:4
        subplot(8,2,subplotNum(cc,ii));
        if cc == 1
            bar(thirdKernelCorrType{1}(plotSequence(ii),:));
        else
            bar(thirdKernelCorrType{2}(plotSequence(ii),:));
        end
        set(gca,'XTick',1:20);
        axis tight
        xlabel('bar position [degree]');
        set(gca,'YLim',[-maxValue,maxValue ]);
        ylabel(dtBankStr(plotSequence(ii)))
    end
end
%%
MakeFigure;
subplot(2,2,1);
quickViewOneKernel(flipud(firstKernel),1);
subplot(2,2,2);
bar(thirdKernelCorrType{3}(1,:));
set(gca,'XTick',1:20);
axis tight
xlabel('bar position [degree]');
yLim = max(abs(get(gca,'YLim')));
set(gca,'YLim',[-yLim,yLim]);
subplotNum = [9,11,13,15;10,12,14,16];
plotSequence = [2,6,4,8];
maxValue = max([max(max(abs(thirdKernelCorrType{3}(plotSequence,:)))),max(max(abs(thirdKernelCorrType{4}(plotSequence,:))))]);
for cc = 1:1:2
    for ii = 1:1:4
        subplot(8,2,subplotNum(cc,ii));
        if cc == 1
            bar(thirdKernelCorrType{3}(plotSequence(ii),:));
        else
            bar(thirdKernelCorrType{4}(plotSequence(ii),:));
        end
        set(gca,'XTick',1:20);
        axis tight
        xlabel('bar position [degree]');
        set(gca,'YLim',[-maxValue,maxValue ]);
        ylabel(dtBankStr(plotSequence(ii)))
    end
end