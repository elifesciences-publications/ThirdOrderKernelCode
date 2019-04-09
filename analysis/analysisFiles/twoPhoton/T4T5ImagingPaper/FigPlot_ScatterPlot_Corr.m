function FigPlot_ScatterPlot_Corr(data,varargin)
% you would plot the scatter plot, and plot out the mean and 25 % 75 %
% percentile? only mean... use a big filler dot...
plot1oRefereceLineFlag = true;
yLabelStr = '';
logScaleFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
[nData,nBar] = size(data);
x = 1:nBar;

arithmeticMean = mean(data);
try
    geometricMean = geomean(data);
catch
end
semY = std(data,1)./sqrt(nData);

% set
maxValue = max(abs(data(:)));
% it does not matter too much, but you still have to do it.
for nn = 1:1:nBar
    scatter(nn * ones(nData,1),data(:,nn),'bo');
    hold on
    scatter(nn, arithmeticMean(nn),'filled','r');
    try
        scatter(nn, geometricMean (nn),'filled','g');
    catch
    end
end
if logScaleFlag
    set(gca,'yscale','log');
end
if limPreSetNeg
    set(gca,'yLim',[0,maxValue * 1.2]);
else
    set(gca,'yLim',[-maxValue * 1.2,maxValue * 1.2]);
end
% BarXY_Juyue(x,meanY,'errorBarFlag',true,'sem',semY ,'xTickStr',xTickStr,'limPreSetFlag',true, 'maxValue',maxValueVar,'limPreSetNeg',true);
title(titleStr);
ylabel(yLabelStr);
numTick = length(x);
set(gca,'XTick',1:1:numTick,'XTickLabel',xTickStr);
% draw a line on the first order
if plot1oRefereceLineFlag
    hold on
    plot(x,arithmeticMean(1) * ones(size(x)),'k--');
    try
        plot(x,geometricMean (1) * ones(size(x)),'k--');
    catch
    end
    hold off
end
% write the ratio on top of it.? summary ratio? mean value
end