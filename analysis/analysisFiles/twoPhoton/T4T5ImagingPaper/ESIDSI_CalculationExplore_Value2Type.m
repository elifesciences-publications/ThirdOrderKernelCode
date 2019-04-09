function roiClass = ESIDSI_CalculationExplore_Value2Type(value,meanValue,dirTypeStr,edgeTypesStr,contrastTypeStr)
nRoi = size(value,1);

edgeType = zeros(nRoi,1);
edgeName = cell(nRoi,1);
ESI = zeros(nRoi,4);

dirTypeEdge = zeros(nRoi,1);
dirTypeNameEdge = cell(nRoi,1);
DSI_Edge = zeros(nRoi,1);

leftRightFlag = false(nRoi,1);
LDSI_Combined = zeros(nRoi,1);
% direction is determined by the square wave.
% (rr) = dark - bright at both direction
LDSI_PreferedDir = zeros(nRoi,1);
% direction is determined by the square wave.
% (rr) = dark at progressive direction - bright at progressive direction.
contrastName = cell(nRoi,1);
contrastType = zeros(nRoi,1); % type 1 light, type 2 dard, 0 nothing.

dirTypeSquare = zeros(nRoi,1); % up/down/left/right.
dirNameSquare = cell(nRoi,1);
DSI = zeros(nRoi,4);
DSI_Diff = zeros(nRoi,2);
% DSI_Diff(rr,1) : left - right or Progressive - Regressive.
% DSI_Diff(rr,2) : Up VS Down. Use the mean value.

for rr = 1:1:nRoi
    %     value(rr,:) =  classMetric.cc(rr,:);
    % first, decide whether a roi is left or right selective based on its
    % peak activity.
    % Square Wave.
    [~,dirTypeThis] = max(meanValue(rr,5:8));  % Left/Right/Up/Down are determined by the square waves... If you do.
    dirTypeSquare(rr) = dirTypeThis;
    dirNameSquare{rr} = dirTypeStr{dirTypeThis};
    leftRightFlag(rr) = dirTypeThis < 3;
    DSI(rr,:) = meanValue(rr,5:8)/sum(meanValue(rr,5:8));
    % directions....You have to keep this term.
    % second, decide whether a roi's edge type based on its peak activity.
    % only first 4 edge types..
    [~,edgeTypeThis] = max(value(rr,1:4));
    edgeType(rr) = edgeTypeThis;
    edgeName{rr} = edgeTypesStr{edgeTypeThis};
    ESI(rr,:) = value(rr,1:4)/sum(value(rr,1:4));
    
    % do not use square waves to compute Direction selectivity anymore. use
    % the edge response.
    % it is okay if you have to change everything.
    DSI_Diff(rr,1) = (meanValue(rr,5) - meanValue(rr,6))/(sum(meanValue(rr,5:6)));
    DSI_Diff(rr,2) = (meanValue(rr,7) - meanValue(rr,8))/(sum(meanValue(rr,7:8)));
end

%%
%% for each roi. determine its direction selectivity first
% different ways to calculate ESI...
for rr = 1:1:nRoi
    edgeProLeft = sum(value(rr,[1,3]));
    edgeRegRight = sum(value(rr,[2,4]));
    DSI_Edge(rr) = (edgeProLeft - edgeRegRight)/(edgeProLeft + edgeRegRight);
    if DSI_Edge(rr) > 0
        dirTypeEdge(rr) = 1;
        dirTypeNameEdge{rr} = dirTypeStr{1};
    else
        dirTypeEdge(rr) = 2;
        dirTypeNameEdge{rr} = dirTypeStr{2};
    end
    % do you want to compute another metrics
    
    % first, for the combined signal. % only possible for dirType = 1 or 2.
    lightValue = value(rr,1:2);
    darkValue = value(rr,3:4);
    lightCombine = sum(lightValue);
    darkCombine = sum(darkValue);

    LDSI_Combined(rr) = (lightCombine - darkCombine)/(lightCombine + darkCombine);
    if leftRightFlag(rr)
        lightPrefered =  lightValue(dirTypeEdge(rr));
        darkPrefered = darkValue(dirTypeEdge(rr));
        LDSI_PreferedDir(rr) = (lightPrefered - darkPrefered)/(lightPrefered + darkPrefered);
    end
    % contrastType is determined by both...
    if leftRightFlag(rr)
        [~,contrastType(rr)] = max([lightCombine,darkCombine]);
        contrastName{rr} = contrastTypeStr{contrastType(rr)};
    end
    
end
DSI_V2 = zeros(nRoi,1);
ESI_V2 = zeros(nRoi,1);
for rr = 1:1:nRoi
    edgeProLeft = max(value(rr,[1,3]));
    edgeRegRight = max(value(rr,[2,4]));
    DSI_V2(rr) = (edgeProLeft - edgeRegRight)/(edgeProLeft + edgeRegRight);
    lightValue = value(rr,1:2);
    darkValue = value(rr,3:4);
    lightCombine = max(lightValue);
    darkCombine = max(darkValue);
    ESI_V2(rr) = (lightCombine - darkCombine)/(lightCombine + darkCombine);
end

roiClass.value = value;
roiClass.edgeType = edgeType;
roiClass.edgeName = edgeName;
roiClass.ESI = ESI; % ESI will have a new defination... so painful... does that matter a lot?
roiClass.dirType = dirTypeSquare;
roiClass.dirName = dirNameSquare;
roiClass.DSI = DSI;
roiClass.DSI_Diff = DSI_Diff;
roiClass.DSI_Edge = DSI_Edge;
roiClass.dirTypeEdge = dirTypeEdge;
roiClass.dirTypeEdgeName = dirTypeNameEdge;
roiClass.contrastType = contrastType;
roiClass.contrastName = contrastName;
roiClass.LDSI_PreferedDir = LDSI_PreferedDir;
roiClass.LDSI_Combined = LDSI_Combined;
roiClass.leftRightFlag = leftRightFlag;
roiClass.DSI_V2 = DSI_V2;
roiClass.ESI_V2 = ESI_V2;
end