function FigPlot_BarPlot_Corr(data,varargin)
plot1oRefereceLineFlag = true;
yLabelStr = '';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
[nData,nBar] = size(data);
x = 1:nBar;
meanY= mean(data);
semY = std(data,1)./sqrt(nData);

% set
maxValueVar = max(meanY) + 2 * max(semY);
BarXY_Juyue(x,meanY,'errorBarFlag',true,'sem',semY ,'xTickStr',xTickStr,'limPreSetFlag',true, 'maxValue',maxValueVar,'limPreSetNeg',true);
title(titleStr);
ylabel(yLabelStr);
% draw a line on the first order 
if plot1oRefereceLineFlag 
hold on 
plot(x,meanY(1) * ones(size(x)),'b--');
hold off
end
% write the ratio on top of it.? summary ratio? mean value
end