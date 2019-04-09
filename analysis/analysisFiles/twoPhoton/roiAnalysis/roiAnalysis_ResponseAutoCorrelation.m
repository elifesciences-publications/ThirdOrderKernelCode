function roiAnalysis_ResponseAutoCorrelation(roiData,varargin)
nRoi = length(roiData);
nXcorr = 20;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

autoCorr = zeros(nXcorr,nRoi);
for rr = 1:1:nRoi
    autoCorr(:,rr) =  roiAnalysis_OneRoi_ResponseAutoCorrelation(roiData{rr},'nXcorr',nXcorr);
end

meanAutoCorr = mean(autoCorr,2);
stdAutoCorr = std(autoCorr,1,2);
semAutoCorr = stdAutoCorr/sqrt(nRoi);

dt = 1:nXcorr;
dt = dt';
semValue = semAutoCorr(dt);
meanValue = meanAutoCorr(dt);
semUp = meanValue + semValue;
semBottom = meanValue - semValue;
% not plot all of them....
% plot from the second....
timeLabelStr = 'time [s]';
timeUnit = 1/60;
dtPlot = dt * timeUnit;

patchPlotX = [dtPlot;dtPlot(end:-1:1)];
patchPlotY = [semUp;semBottom(end:-1:1)];
% calculate the standard deviation.
MakeFigure;
plot(dtPlot,meanValue,'color',[1,0,0]);
patch(patchPlotX,patchPlotY,'red','EdgeColor','none','FaceColor',[1,0,0],'FaceAlpha',0.2);
hold on
plot(dt * timeUnit,zeros(1,length(dt)),'k--');
ax = gca;
yLim = ax.YLim;
plot([0,0],yLim,'k--');
xlabel(timeLabelStr);

title('Auto Correlation of the response');
ylabel('r');

ConfAxis;

end