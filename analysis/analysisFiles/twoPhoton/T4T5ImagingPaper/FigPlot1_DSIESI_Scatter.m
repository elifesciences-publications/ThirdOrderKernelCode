function FigPlot1_DSIESI_Scatter(DSI,ESI,edgeType,varargin)
% FigPlot1_DSIESIScatter(DSI,ESI,edgeType,'threshDSI',0.4,'threshESI',0.4)
threshDSI = 0.4;
threshESI = 0.4;
saveFigFlag = false;
MainName = ['Fig1'];
nFigSave = 3;
figFileType = {'fig','eps','png'}

for ii = 1:2:length(varargin)
    str = [ varargin{ii} ' = varargin {' num2str(ii+1) '};'];
    eval(str);
end
roiSelected = abs(DSI) > threshDSI & abs(ESI) > threshESI;
MakeFigure;
subplot(2,2,1);

xLabelStr = ['DSI (edge)'];
yLabelStr = ['ESI (edge)'];
% only selected on will be put on color...
scatter(DSI,ESI,'k','filled');
axis([-1,1,-1,1]);
xlabel(xLabelStr);
ylabel(yLabelStr);
title('T4T5');
ConfAxis;
axis equal
hold on
FigPlot_IndexScatter(DSI(roiSelected),ESI(roiSelected),edgeType(roiSelected),xLabelStr,yLabelStr,' ')
% plot the threshold 
hold on
plot([threshDSI,threshDSI],[-1,1],'r--');
plot([-threshDSI,-threshDSI],[-1,1],'r--');
plot([-1,1],[-threshESI,-threshESI],'r--');
plot([-1,1],[threshESI,threshESI],'r--');
% ConfAxis;
% axis equal

subplot(2,2,2);
hESI = histogram(ESI);
hESI.BinWidth = 0.1;
hESI.FaceColor = [1,0,0];
view(90,-90);
ConfAxis;
xlabel('ESI');
xlim([-1,1]);

subplot(2,2,3)
hDSI = histogram(DSI);
hDSI.BinWidth = 0.1;
hDSI.FaceColor = [1,0,0];
xlabel('DSI');
xlim([-1,1]);
ConfAxis;

if saveFigFlag
    MySaveFig_Juyue(gcf,MainName,'_d_scatter','nFigSave',nFigSave,'fileType',figFileType);
end
