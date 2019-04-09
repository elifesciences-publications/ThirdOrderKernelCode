function roi = roiAnalysis_OneRoi_ESIDSI9950(roi,MaxOrMean)
trace = roi.typeInfo.trace;
nEdge = 4; % only
trace = trace(:,1:nEdge);
% edgeTypesStrEye = {'Progressive Light','Regressive Light','Progressive Dark','Regressive Dark','Progressive','Regressive','Up','Down'};

meanTrace = cell(1,nEdge);
for ee = 1:1:nEdge
    meanTrace{ee} = mean(cell2mat(trace(:,ee)'),2);
end
% get value for 4 edges and then compute the dsi and esi
value = zeros(nEdge,1);
for ee = 1:1:nEdge
    value(ee) =  percentileThresh(meanTrace{ee},0.99) -  percentileThresh(meanTrace{ee},0.50);
end

switch MaxOrMean
    case 'max'
        edgeProLeft = max(value([1,3]));
        edgeRegRight = max(value([2,4]));
        DSI = (edgeProLeft - edgeRegRight)/(edgeProLeft + edgeRegRight);
        
        lightValue = max(value(1:2));
        darkValue = max(value(3:4));
        ESI= (lightValue - darkValue)/(lightValue + darkValue);
    case 'mean'
        edgeProLeft = mean(value([1,3]));
        edgeRegRight = mean(value([2,4]));
        DSI = (edgeProLeft - edgeRegRight)/(edgeProLeft + edgeRegRight);
        
        lightValue = mean(value(1:2));
        darkValue = mean(value(3:4));
        ESI= (lightValue - darkValue)/(lightValue + darkValue);
end
if ESI >= 0
    if DSI >= 0
        roi.typeInfo.edgeType = 1;
    else
        roi.typeInfo.edgeType = 2;
    end
else
    if DSI >= 0
        roi.typeInfo.edgeType = 3;
    else
        roi.typeInfo.edgeType = 4;
    end
end
roi.typeInfo.DSI = DSI;
roi.typeInfo.ESI = ESI;
%%
end