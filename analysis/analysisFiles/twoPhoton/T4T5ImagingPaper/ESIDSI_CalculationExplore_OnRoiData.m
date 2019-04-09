% analyze 10 degree data and re calculate the ESI and DSI...
stimulusType = '10';
roiMethodType = 'ICA';
roiData = getData_Juyue(stimulusType,roiMethodType);

% try to recalculate everything...
%%
nRoi = length(roiData);

DSI =  zeros(nRoi,1);
ESI = zeros(nRoi,1);
edgeType = zeros(nRoi,1);

for rr = 1:1:nRoi
    roi = roiData{rr};
    
    DSI(rr) = roi.typeInfo.DSI_Edge;
    ESI(rr) = roi.typeInfo.LDSI_Combined;
    edgeType(rr) = roi.typeInfo.edgeType;
end

FigPlot1_DSIESI_Scatter(DSI,ESI,edgeType,'MainName','sumOfMax','saveFigFlag',false);

%% try other ways of calculating data...

% first, max of the max....
% calculate mean traces first.
roiTraces = cell(nRoi,1); % every cell will include the 8 traces there...
% whether this trace is light progressive. light regressive, dark
% progressive, dark regressive? not sure, check it..
nEdge = 8;
meanTrace = cell(nRoi,nEdge);
thresholdP = 0.99;
value = zeros(rr,nEdge);
% the trace is calculated in the correct way...
for rr = 1:1:nRoi
    roi = roiData{rr};
    flyEye = roi.flyInfo.flyEye;
    trace = roi.typeInfo.trace;
    value(rr,:) = roi.typeInfo.value;
    
    nEdge = size(trace,2);
    for ee = 1:1:nEdge
        meanTrace{rr,ee} = (trace{1,ee} + trace{2,ee})/2;
        % make them shorter... all to be 156...
        if ee < 5
            maxLength = 156;
        else
            maxLength = 52;
        end
        meanTrace{rr,ee} = meanTrace{rr,ee}(1:maxLength);
    end
end
%%
DSI_V3 = zeros(nRoi,1);
ESI_V3 = zeros(nRoi,1);
for rr = 1:1:nRoi
    edgeProLeft = max(value(rr,[1,3]));
    edgeRegRight = max(value(rr,[2,4]));
    DSI_V3(rr) = (edgeProLeft - edgeRegRight)/(edgeProLeft + edgeRegRight);
    % do you want to compute another metrics
    
    % first, for the combined signal. % only possible for dirType = 1 or 2.
    lightValue = max(value(rr,1:2));
    darkValue = max(value(rr,3:4));
    ESI_V3(rr) = (lightValue - darkValue)/(lightValue + darkValue);
end
FigPlot1_DSIESI_Scatter(DSI_V3,ESI_V3,edgeType,'MainName','MaxOfMax','saveFigFlag',true);
%%
%%
edgeRespContrast = zeros(nRoi,2); % combine the response first, and do max/mean from them later...
edgeRespDirection = zeros(nRoi,2);
edgeTypesStrStim = {'Left Light Edge','Right Light Edge','Left Dark Edge','Right Dark Edge','Square Left','Square Right','Square Up','Square Down'};
for rr = 1:1:nRoi
    % for light / dark. add the trace together.
    lightTrace = (meanTrace{rr,1} + meanTrace{rr,2})/2;
    darkTrace = (meanTrace{rr,3} +  meanTrace{rr,4})/2;
    proTrace = (meanTrace{rr,1} + meanTrace{rr,3})/2;
    regTrace = (meanTrace{rr,2} + meanTrace{rr,4})/2;
    % do you do the maximun? or percentile...the noise can be huge...
    edgeRespContrast(rr,1) = percentileThresh(lightTrace,thresholdP);
    edgeRespContrast(rr,2) = percentileThresh(darkTrace,thresholdP);
    edgeRespDirection(rr,1) = percentileThresh(proTrace,thresholdP);
    edgeRespDirection(rr,2) = percentileThresh(regTrace,thresholdP);
end
edgeRespContrast(edgeRespContrast < 0) = 0;
edgeRespDirection(edgeRespDirection < 0) = 0;

ESI_V2 = (edgeRespContrast(:,1) - edgeRespContrast(:,2))./(edgeRespContrast(:,1) + edgeRespContrast(:,2));
DSI_V2 = (edgeRespDirection(:,1) - edgeRespDirection(:,2))./(edgeRespDirection(:,1) + edgeRespDirection(:,2));
FigPlot1_DSIESI_Scatter(DSI_V2,ESI_V2,edgeType,'MainName','maxOfMeanTrace','saveFigFlag',true);

%%

% get a number for everything....
threshDSI = 0.4;
threshESI = 0.4;
roiSelected_V1 = abs(DSI) > threshDSI & abs(ESI) > threshESI;
roiSelected_V2 = abs(DSI_V2) > threshDSI & abs(ESI_V2) > threshESI;
roiSelected_V3 = abs(DSI_V3) > threshDSI & abs(ESI_V3) > threshESI;

nRoiUse = size(4,3); % 4 types and 3 version;
for tt = 1:1:4
    nRoiUse(tt,1) = length(find(roiSelected_V1 & (edgeType == tt)));
    nRoiUse(tt,2) = length(find(roiSelected_V2 & (edgeType == tt)));
    nRoiUse(tt,3) = length(find(roiSelected_V3 & (edgeType == tt)));
end
%%
bar(nRoiUse,'DisplayName','nRoiUse');
xlabel('four type');
set(gca,'XTickLabel',{'T4 pro','T4 reg','T5 pro','T5 reg'});
title('10 degree data')
legend('sum of max','max of averaged trace','max of the max');
ylabel('number of Rois selected')