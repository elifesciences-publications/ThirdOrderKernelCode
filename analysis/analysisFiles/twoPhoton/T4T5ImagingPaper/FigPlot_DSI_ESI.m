function FigPlot_DSI_ESI(roiData)


nRoi = length(roiData);
edgeType = zeros(nRoi,1);
DSI_Diff = zeros(nRoi,1);
DSI_Edge = zeros(nRoi,1);
LDSI_PreferedDir = zeros(nRoi,1);
LDSI_Combined = zeros(nRoi,1);
leftRightFlag = false(nRoi,1);

for rr = 1:1:nRoi
    roi = roiData{rr};
    % where do you store the information?
    edgeType(rr)= roi.typeInfo.edgeType;
    DSI_Diff(rr) = roi.typeInfo.DSI_Diff;
    DSI_Edge(rr) = roi.typeInfo.DSI_Edge;
    LDSI_PreferedDir(rr) = roi.typeInfo.LDSI_PreferedDir;
    LDSI_Combined(rr) = roi.typeInfo.LDSI_Combined;
    leftRightFlag(rr) = roi.typeInfo.leftRightFlag;
end

%% DSI by Square
DSI_Diff_Plot = DSI_Diff(leftRightFlag);
LDSI_Plot = LDSI_PreferedDir(leftRightFlag);

% before plotting.
DSI_Diff_Plot(DSI_Diff_Plot > 1) = 1;
DSI_Diff_Plot(DSI_Diff_Plot < -1) = -1;
MakeFigure;
subplot(2,2,1);
scatter(DSI_Diff_Plot,LDSI_Plot,'r+','lineWidth',10);
axis([-1,1,-1,1]);
dirTypeStrEye = {'Progressive','Regressive','Up','Down'};
contrastTypeStr = {'Light','Dark'};
xlabel(['(',dirTypeStrEye{1} ,'-',dirTypeStrEye{2},')']);
ylabel(['(',contrastTypeStr{1},'-' , contrastTypeStr{2}, ')']);


subplot(2,2,2)
titleStr = {'DSI(Square)'};
xLabelStr = {'Progressive - Regressive'};
yLabelStr = {'Light - Dark'};
FigPlot_IndexScatter(DSI_Diff_Plot,LDSI_Plot,edgeType,xLabelStr,yLabelStr{1},titleStr{1});

subplot(2,2,3);
hDSI = histogram(DSI_Diff_Plot);
hDSI.BinLimits = [-1,1];
hDSI.BinWidth = 0.1;
hDSI.FaceColor = [1,0,0];
hDSI.EdgeColor = [1,0,0];
title('DSI Square Wave');
xlabel(['(',dirTypeStrEye{1} ,'-',dirTypeStrEye{2},')']);
ylabel('count');

subplot(2,2,4);
hLDSI = histogram(LDSI_Plot);
hLDSI.BinLimits = [-1,1];
hLDSI.BinWidth = 0.1;
hLDSI.FaceColor = [1,0,0];
hLDSI.EdgeColor = [1,0,0];
title('ESI');
xlabel(['(',contrastTypeStr{1},'-' , contrastTypeStr{2}, ')']);
ylabel('count');

%% DSI by Edge;
DSI_Diff_Plot = DSI_Edge(leftRightFlag);
LDSI_Plot = LDSI_PreferedDir(leftRightFlag);

% before plotting.
DSI_Diff_Plot(DSI_Diff_Plot > 1) = 1;
DSI_Diff_Plot(DSI_Diff_Plot < -1) = -1;
MakeFigure;
subplot(2,2,1);
scatter(DSI_Diff_Plot,LDSI_Plot,'r+','lineWidth',10);
axis([-1,1,-1,1]);
dirTypeStrEye = {'Progressive','Regressive','Up','Down'};
contrastTypeStr = {'Light','Dark'};
xlabel(['(',dirTypeStrEye{1} ,'-',dirTypeStrEye{2},')']);
ylabel(['(',contrastTypeStr{1},'-' , contrastTypeStr{2}, ')']);

subplot(2,2,2)
titleStr = {'DSI(Edge)'};
xLabelStr = {'Progressive - Regressive'};
yLabelStr = {'Light - Dark'};
FigPlot_IndexScatter(DSI_Diff_Plot,LDSI_Plot,edgeType,xLabelStr,yLabelStr{1},titleStr{1});

subplot(2,2,3);
hDSI = histogram(DSI_Diff_Plot);
hDSI.BinLimits = [-1,1];
hDSI.BinWidth = 0.1;
hDSI.FaceColor = [1,0,0];
hDSI.EdgeColor = [1,0,0];
title('DSI Edge');
xlabel(['(',dirTypeStrEye{1} ,'-',dirTypeStrEye{2},')']);
ylabel('count');

subplot(2,2,4);
hLDSI = histogram(LDSI_Plot);
hLDSI.BinLimits = [-1,1];
hLDSI.BinWidth = 0.1;
hLDSI.FaceColor = [1,0,0];
hLDSI.EdgeColor = [1,0,0];
title('ESI');
xlabel(['(',contrastTypeStr{1},'-' , contrastTypeStr{2}, ')']);
ylabel('count');


end
